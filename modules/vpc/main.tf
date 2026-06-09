# modules/vpc/main.tf
# This module creates the entire network layer:
# VPC → Subnets → IGW → NAT Gateway → Route Tables

# The VPC — our private network boundary
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# Public subnets — one per AZ
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  # Instances launched here get a public IP automatically  
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index+1}"
    Environment = var.environment
    Type = "public"
  }
}

# Private subnets — one per AZ
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  # No public IP — these are private
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index+1}"
    Environment = var.environment
    Type = "private"
  }
}

# Internet Gateway — the door between your VPC and the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
    Environment  = var.environment
  }
}

# Elastic IP for the NAT Gateway — a fixed public IP address
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
    Environment = var.environment
  }
}

# NAT Gateway — sits in the FIRST public subnet
# Private EC2s use this to reach the internet (e.g. to install packages)
# Traffic goes: Private EC2 → NAT Gateway → Internet Gateway → Internet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-nat-gw"
    Environment = var.environment
  }

  depends_on = [ aws_internet_gateway.main ]
}

# Route table for public subnets
# Rule: send all traffic (0.0.0.0/0) to the Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
    Environment = var.environment
  } 
}

# Route table for private subnets
# Rule: send all outbound traffic through the NAT Gateway (not directly to IGW)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
    Environment = var.environment
  }
}

 #Associate each public subnet with the public route table
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate each private subnet with the private route table
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

