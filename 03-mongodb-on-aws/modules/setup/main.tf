data "http" "ip" {
  url = "https://ifconfig.me/ip"
}


locals {
  client_public_ip = data.http.ip.response_body
}


# Create VPC with DNS hostnames enabled
resource "aws_vpc" "infra-aws-mongodb" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true

  tags = {
    Name = "infra-aws-mongodb"
  }
}


# Create subnet with public IPs declared
resource "aws_subnet" "infra-aws-mongodb" {
  vpc_id            = aws_vpc.infra-aws-mongodb.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = var.aws_availability_zone

  map_public_ip_on_launch = true
  
  tags = {
    Name = "infra-aws-mongodb"
  }
}


# Create internet gateway
resource "aws_internet_gateway" "infra-aws-mongodb" {
  vpc_id = aws_vpc.infra-aws-mongodb.id

  tags = {
    Name = "infra-aws-mongodb"
  }
}


# Create internet access route in route table
resource "aws_route" "infra-aws-mongodb" {
  route_table_id         = aws_vpc.infra-aws-mongodb.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.infra-aws-mongodb.id
}


# Create security group
resource "aws_default_security_group" "infra-aws-mongodb" {
  
  tags = {
    Name = "aws_mongodb_security_group"
  }

  vpc_id      = aws_vpc.infra-aws-mongodb.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  ingress {
    description      = "SSH to VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [ "${local.client_public_ip}/32" ]
  }

  ingress {
    description      = "TCP to VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = [ "${local.client_public_ip}/32" ]
  }

  ingress {
    description      = "MongoDB Client to VPC"
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    cidr_blocks      = [ "${local.client_public_ip}/32" ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}