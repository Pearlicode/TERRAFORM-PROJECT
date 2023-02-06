provider "aws" {
  region = "us-east-1"
}

# Make VPC
resource "aws_vpc" "Miniproject_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Miniproject_vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "Miniproject_internet_gateway" {
  vpc_id = aws_vpc.Miniproject_vpc.id
  tags = {
    Name = "Miniproject_internet_gateway"
  }
}

# Public Route Table
resource "aws_route_table" "Miniproject-route-table-public" {
  vpc_id = aws_vpc.Miniproject_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Miniproject_internet_gateway.id
  }
  tags = {
    Name = "Miniproject-route-table-public"
  }
}

# Public subnet 1 with public route table
resource "aws_route_table_association" "Miniproject-public-subnet1-association" {
  subnet_id      = aws_subnet.Miniproject-public-subnet1.id
  route_table_id = aws_route_table.Miniproject-route-table-public.id
  }

# Public subnet 2 with public route table
resource "aws_route_table_association" "Miniproject-public-subnet2-association" {
  subnet_id      = aws_subnet.Miniproject-public-subnet2.id
  route_table_id = aws_route_table.Miniproject-route-table-public.id
  }
  
  # Public Subnet-1
resource "aws_subnet" "Miniproject-public-subnet1" {
  vpc_id                  = aws_vpc.Miniproject_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "Miniroject-public-subnet1"
  }
}

# Public Subnet-2
resource "aws_subnet" "Miniproject-public-subnet2" {
  vpc_id                  = aws_vpc.Miniproject_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "Miniproject-public-subnet2"
  }
}

#Network Acl
resource "aws_network_acl" "Miniproject-network_acl" {
  vpc_id     = aws_vpc.Miniproject_vpc.id
  subnet_ids = [aws_subnet.Miniproject-public-subnet1.id, aws_subnet.Miniproject-public-subnet2.id]
  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}


# Security group for the load balancer
resource "aws_security_group" "Miniproject-load_balancer_sg" {
  name        = "Miniproject-load-balancer-sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.Miniproject_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Security Group to allow port 22, 80 and 443
resource "aws_security_group" "Miniproject-security-grp-rule" {
  name        = "allow_ssh_http_https"
  description = "Allow SSH, HTTP and HTTPS inbound traffic for private instances"
  vpc_id      = aws_vpc.Miniproject_vpc.id
 ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.Miniproject-load_balancer_sg.id]
  }
 ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.Miniproject-load_balancer_sg.id]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "Miniproject-security-grp-rule"
  }
}

