# VPC
resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "pub_subnet" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.region
}

resource "aws_subnet" "pri_subnet" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.region
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "dev_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.pub_subnet.id
}

resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.dev_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }
}

resource "aws_route_table" "pri_rt" {
  vpc_id = aws_vpc.dev_vpc.id
}

resource "aws_route_table_association" "pub_subnet_association" {
  subnet_id      = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.pub_rt.id 
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.pri_subnet.id
  route_table_id = aws_route_table.pri_rt.id
}

resource "aws_route" "pri_nat_route" {
  route_table_id         = aws_route_table.pri_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.dev_nat.id
}

resource "aws_security_group" "allow_tls" {
  name        = "Allow TLS Inbound"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.dev_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}