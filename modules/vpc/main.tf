resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.tag_name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.tag_name_prefix}-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.tag_name_prefix}-public-route-table"
  }
}

#--------------------------------------
# PUBLIC SUBNETS (SUBNET 1 and SUBNET 2)
#--------------------------------------
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet1_cidr
  availability_zone       = var.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag_name_prefix}-public-subnet1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet2_cidr
  availability_zone       = var.az2
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.tag_name_prefix}-public-subnet2"
  }
}

#-----------------------------------------
# PRIVATE SUBNETS (SUBNET 1 and SUBNET 2)
#-----------------------------------------
resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet1_cidr
  availability_zone       = var.az1
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tag_name_prefix}-private-subnet1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet2_cidr
  availability_zone       = var.az2
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tag_name_prefix}-private-subnet2"
  }
}

#-------------------------------------------
# ROUTE TABLE ASSOCIATION FOR PUBLIC SUBNETS
#-------------------------------------------
resource "aws_route_table_association" "public_rta1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_rta2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

#-----------------------------------
# ELASTIC IP ADDRESSES
#-----------------------------------
resource "aws_eip" "eip1" {
  depends_on = [
    aws_route_table_association.public_rta1
  ]
  vpc = true
}

resource "aws_eip" "eip2" {
  depends_on = [
    aws_route_table_association.public_rta2
  ]
  vpc = true
}

#-----------------------------------
# NAT GATEWAYS
#-----------------------------------
resource "aws_nat_gateway" "nat_gateway1" {
  depends_on = [
    aws_eip.eip1
  ]
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public_subnet1.id
  tags = {
    Name = "${var.tag_name_prefix}-nat-gateway1"
  }
}

resource "aws_nat_gateway" "nat_gateway2" {
  depends_on = [
    aws_eip.eip2
  ]
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public_subnet2.id
  tags = {
    Name = "${var.tag_name_prefix}-nat-gateway2"
  }
}

#-------------------------------------------
# ROUTE TABLE ASSOCIATION FOR PRIVATE SUBNETS
#-------------------------------------------
resource "aws_route_table_association" "private_rta1" {
  route_table_id = aws_route_table.private_rt1.id
  subnet_id      = aws_subnet.private_subnet1.id
}

resource "aws_route_table_association" "private_rta2" {
  route_table_id = aws_route_table.private_rt2.id
  subnet_id      = aws_subnet.private_subnet2.id
}

#-------------------------------------------
# ROUTE TABLE FOR PRIVATE SUBNETS
#-------------------------------------------
resource "aws_route_table" "private_rt1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway1.id
  }

  tags = {
    Name = "${var.tag_name_prefix}-private_route_table1"
  }
}

resource "aws_route_table" "private_rt2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway2.id
  }

  tags = {
    Name = "${var.tag_name_prefix}-private_route_table2"
  }
}