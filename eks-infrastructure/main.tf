terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = aws_eks_cluster.banking_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.banking_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.banking_cluster.token
}

data "aws_eks_cluster_auth" "banking_cluster" {
  name = aws_eks_cluster.banking_cluster.name
}

# VPC
resource "aws_vpc" "banking_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "banking-eks-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "banking_igw" {
  vpc_id = aws_vpc.banking_vpc.id

  tags = {
    Name = "banking-eks-igw"
  }
}

# Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.banking_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name                        = "banking-public-subnet-1"
    "kubernetes.io/role/elb"    = "1"
    "kubernetes.io/cluster/banking-cluster" = "owned"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.banking_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name                        = "banking-public-subnet-2"
    "kubernetes.io/role/elb"    = "1"
    "kubernetes.io/cluster/banking-cluster" = "owned"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.banking_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name                              = "banking-private-subnet-1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/banking-cluster" = "owned"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.banking_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name                              = "banking-private-subnet-2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/banking-cluster" = "owned"
  }
}

# NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "banking-nat-eip"
  }
}

resource "aws_nat_gateway" "banking_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "banking-nat-gateway"
  }
}

# Route Tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.banking_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.banking_igw.id
  }

  tags = {
    Name = "banking-public-rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.banking_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.banking_nat.id
  }

  tags = {
    Name = "banking-private-rt"
  }
}

resource "aws_route_table_association" "public_rta_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rta_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rta_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rta_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

data "aws_availability_zones" "available" {
  state = "available"
}