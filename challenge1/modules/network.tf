# VPC Creation
resource "aws_vpc" "project_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name = var.vpc_name
  }
}

# Create public subnets
resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = var.pub_cidr_block[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = var.pub_availability_zones[count.index]
  tags = {
    Name = "${var.pub_tag_subnet}_${count.index + 1}"
  }
}

# Public Route Table Creation
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.project_vpc.id
  tags = {
    Name = var.pub_rt
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = var.destination_cidr_block
  gateway_id             = aws_internet_gateway.gw.id
}

# Public Subnet Association 
resource "aws_route_table_association" "public_subnet_association" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "private_subnet" {
  count             = 4
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = var.priv_cidr_block[count.index]
  availability_zone = var.priv_availability_zones[count.index]
  tags = {
    Name = "${var.priv_tag_subnet}_${count.index + 1}" 
  }
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.project_vpc.id
  tags = {
    Name = var.priv1_rt
  }
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = var.destination_cidr_block
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_subnet_association" {
  count          = 4
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# Internet Gateway Creation
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.project_vpc.id
  tags = {
    Name = var.igw_name
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = var.destination_cidr_block
  gateway_id             = aws_internet_gateway.gw.id
}

# Elastic IP Creation
resource "aws_eip" "eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
}

# Nat Gateway Creation
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.gw]
}

resource "aws_vpc_endpoint" "ssm_endpoint" {
  vpc_id            = aws_vpc.project_vpc.id
  service_name      = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_subnet[0].id,
    aws_subnet.private_subnet[1].id  
  ]
  security_group_ids = [aws_security_group.private_sg.id] 
}

resource "aws_vpc_endpoint" "ssm_messages_endpoint" {
  vpc_id            = aws_vpc.project_vpc.id
  service_name      = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_subnet[0].id, 
    aws_subnet.private_subnet[1].id 
  ]
  security_group_ids = [aws_security_group.private_sg.id] 
}

resource "aws_vpc_endpoint" "ec2_messages_endpoint" {
  vpc_id            = aws_vpc.project_vpc.id
  service_name      = "com.amazonaws.us-east-1.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_subnet[0].id,
    aws_subnet.private_subnet[1].id  
  ]

  security_group_ids = [aws_security_group.private_sg.id] 
}

resource "aws_security_group" "private_sg" {
  name        = var.private_sg_name
  description = "Security group for private instances"
  vpc_id      = aws_vpc.project_vpc.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] 
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

}
