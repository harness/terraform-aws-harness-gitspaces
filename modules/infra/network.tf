locals {
  az_public_subnet_map = {
    for region_key, region in local.region_configs :
    region_key => {
      for az in region.availability_zones :
      az.zone => az.public_cidr_block
    }
    if region.region_name == var.region
  }

  az_private_subnet_map = {
    for region_key, region in local.region_configs :
    region_key => {
      for az in region.availability_zones :
      az.zone => az.private_cidr_block
    }
    if region.region_name == var.region
  }

  all_public_subnets = merge([
    for region_key, az_map in local.az_public_subnet_map :
    {
      for az, cidr in az_map :
      "${az}" => {
        region_name = region_key
        az          = az
        cidr_block  = cidr
        type        = "public"
      }
    }
  ]...)

  all_private_subnets = merge([
    for region_key, az_map in local.az_private_subnet_map :
    {
      for az, cidr in az_map :
      "${az}" => {
        region_name = region_key
        az          = az
        cidr_block  = cidr
        type        = "private"
      }
    }
  ]...)
}


resource "aws_vpc" "vpc_network" {
  cidr_block           = local.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${local.name}-network"
  }
}

resource "aws_subnet" "private_subnet" {
  for_each = local.all_private_subnets

  vpc_id                  = aws_vpc.vpc_network.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.name}-${each.key}-private-subnet"
  }
}

resource "aws_subnet" "public_subnet" {
  for_each = local.all_public_subnets

  vpc_id                  = local.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.name}-${each.key}-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_network.id
  tags = {
    Name = "${local.name}-igw"
  }
}

resource "aws_route_table" "private_rt" {
  for_each = aws_nat_gateway.nat

  vpc_id = aws_vpc.vpc_network.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }

  tags = {
    Name = "${local.name}-${each.key}-private-rt"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.name}-public-rt"
  }
}

resource "aws_route_table_association" "public_rta" {
  for_each = local.all_public_subnets

  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rta" {
  for_each = local.all_private_subnets

  subnet_id = aws_subnet.private_subnet[each.key].id

  route_table_id = aws_route_table.private_rt[each.key].id
}

resource "aws_eip" "nat_static_ip" {
  for_each = local.all_public_subnets

  domain = "vpc"
  tags = {
    Name = "${local.name}-${each.value.region_name}-${each.value.az}-nat-ip"
  }
}

resource "aws_nat_gateway" "nat" {
  for_each = local.all_public_subnets

  allocation_id = aws_eip.nat_static_ip[each.key].id
  subnet_id     = aws_subnet.public_subnet[each.key].id
  tags = {
    Name = "${local.name}-${each.value.region_name}-${each.value.az}-nat"
  }

  depends_on = [aws_internet_gateway.igw]
}
