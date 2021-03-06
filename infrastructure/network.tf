# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.base_cidr_block

  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

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
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}${each.key}"
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, each.value)

  tags = {
    Name = "${var.project_name}-public-subnet-${each.key}"
  }
}

resource "aws_route_table_association" "public_route_subnet_association" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
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
  for_each = var.private_subnets
  vpc_id   = aws_vpc.vpc.id

  availability_zone = "${var.aws_region}${each.key}"
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, each.value)

  tags = {
    Name = "${var.project_name}-private-subnet-${each.key}"
  }
}



resource "aws_route_table_association" "private_route_subnet_association" {
  for_each       = aws_subnet.private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}


resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasksg"
  description = "Security group used by the ECS task"
  vpc_id      = aws_vpc.vpc.id


  //  ingress {
  //    protocol        = "tcp"
  //    from_port       = 443
  //    to_port         = 443
  //    cidr_blocks = [var.base_cidr_block]
  //  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-ecs-task-sg"
  }
}

resource "aws_security_group" "vpc_endpoint" {
  name   = "vpce"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }
  tags = {
    Name = "${var.project_name}-vpc-endpoint-sg"
  }
}

# TODO add ecs endpoint

resource "aws_vpc_endpoint" "ecr" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.private_subnet : subnet.id]
  security_group_ids  = [aws_security_group.ecs_tasks.id]

  tags = {
    Name = "${var.project_name}-ecr-endpoint"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids = [for subnet in aws_subnet.private_subnet : subnet.id]
  tags = {
    Name = "${var.project_name}-logs-endpoint"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_route_table.id]

  tags = {
    Name = "${var.project_name}-s3-endpoint"
  }
}
