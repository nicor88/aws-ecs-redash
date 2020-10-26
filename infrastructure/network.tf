# VPC
resource "aws_vpc" "vpc" {
  cidr_block       = var.base_cidr_block

  enable_dns_support = "true"
  enable_dns_hostnames  = "true"

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-route"
  }
}

resource "aws_subnet" "public_subnet" {
    for_each  = var.public_subnets
    vpc_id = aws_vpc.vpc.id
    map_public_ip_on_launch = true
    availability_zone = "${var.aws_region}${each.key}"
    cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, each.value)

    tags = {
        Name = "${var.project_name}-public-subnet-${each.key}"
    }
}

resource "aws_route_table_association" "public_route_subnet_association" {
    for_each  = aws_subnet.public_subnet
    subnet_id = each.value.id
    route_table_id = aws_route_table.public_route_table.id
}

# Private subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-private-route"
  }
}

resource "aws_subnet" "private_subnet" {
    for_each  = var.private_subnets
    vpc_id = aws_vpc.vpc.id

    availability_zone = "${var.aws_region}${each.key}"
    cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, each.value)

    tags = {
        Name = "${var.project_name}-private-subnet-${each.key}"
    }
}

resource "aws_route_table_association" "private_route_subnet_association" {
    for_each  = aws_subnet.private_subnet
    subnet_id = each.value.id
    route_table_id = aws_route_table.private_route_table.id
}

# TODO add ecs endpoint
