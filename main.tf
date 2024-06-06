# CREATE VPC
resource "aws_vpc" "Tencity_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
      Name = "Tencity_vpc"
    }
}



# CREATE PUBLIC SUBNET-1
resource "aws_subnet" "Prod-pub-sub1" {
  vpc_id     = aws_vpc.Tencity_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Prod-pub-sub1"
  }
}


# CREATE PUBLIC SUBNET-2
resource "aws_subnet" "Prod-pub-sub2" {
  vpc_id     = aws_vpc.Tencity_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Prod-pub-sub2"
  }
}


# CREATE PRIVATE SUBNET-1
resource "aws_subnet" "Prod-priv-sub1" {
  vpc_id     = aws_vpc.Tencity_vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "Prod-priv-sub1"
  }
}


# PRIVATE SUBNET-2
resource "aws_subnet" "Prod-priv-sub2" {
  vpc_id     = aws_vpc.Tencity_vpc.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "Prod-priv-sub2"
  }
}



# CREATE PUBLIC ROUTE-TABLE
resource "aws_route_table" "Prod-pub-route-table" {
  vpc_id = aws_vpc.Tencity_vpc.id


  tags = {
    Name = "Prod-pub-route-table"
  }
}


# CREATE PRIVATE ROUTE-TABLE
resource "aws_route_table" "Prod-priv-route-table" {
  vpc_id = aws_vpc.Tencity_vpc.id


  tags = {
    Name = "Prod-priv-route-table"
  }
}


# SUBNET-ASSOCIATION WITH PUBLIC ROUTE-TABLE
resource "aws_route_table_association" "Prod-pub-route-table-1" {
  subnet_id      = aws_subnet.Prod-pub-sub1.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

resource "aws_route_table_association" "Prod-pub-route-table-2" {
  subnet_id      = aws_subnet.Prod-pub-sub2.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}



# SUBNET ASSOCIATION WITH PRIVATE ROUTE-TABLE
resource "aws_route_table_association" "Prod-priv-route-table-1" {
  subnet_id      = aws_subnet.Prod-priv-sub1.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

resource "aws_route_table_association" "Prod-priv-route-table-2" {
  subnet_id      = aws_subnet.Prod-priv-sub2.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}



# CREATE IGW
resource "aws_internet_gateway" "Prod-igw" {
  vpc_id = aws_vpc.Tencity_vpc.id

  tags = {
    Name = "Prod-igw"
  }
}


# ASSOCIATE INTERNET GATEWAY WITH PUBLIC ROUTE TABLE
resource "aws_route" "internet-route" {
  route_table_id            = aws_route_table.Prod-pub-route-table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.Prod-igw.id
}



# CREATE ELASTIC IP
resource "aws_eip" "eip" {
  domain = "vpc"
}


# CREATE NAT-GATEWAY
resource "aws_nat_gateway" "Prod-Nat-gateway" {
  subnet_id     = aws_subnet.Prod-pub-sub1.id
  allocation_id                  = aws_eip.eip.id

  tags = {
    Name = "Prod-Nat-gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.Prod-igw]
}



# UPDATE NATGATEWAY WITH THE PRIVATE ROUTE
resource "aws_route" "nat-priv-route" {
  route_table_id            = aws_route_table.Prod-priv-route-table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            =  aws_nat_gateway.Prod-Nat-gateway.id 
}



