
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block

  tags = {
    "Name" = "My_VPC"
  }
}

# SUBNETS
resource "aws_subnet" "public" {
  map_public_ip_on_launch = "true"
  count                   = length(var.public_subnet)
  cidr_block              = var.public_subnet[count.index]
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = "Public_subnet_${regex(".$", data.aws_availability_zones.available.names[count.index])}_${aws_vpc.vpc.id}",
   
  }
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnet)
  cidr_block              = var.private_subnet[count.index]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "false"
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = "Private_subnet_${regex(".$", data.aws_availability_zones.available.names[count.index])}_${aws_vpc.vpc.id}"
    "Network" = "Private"
  }
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "IGW_${aws_vpc.vpc.id}"
  }
}

# EIPs (for nats)
resource "aws_eip" "eip" {
  count = length(var.public_subnet)

  tags = {
    "Name" = "NAT_elastic_ip_${regex(".$", data.aws_availability_zones.available.names[count.index])}_${aws_vpc.vpc.id}"
  }
}

# NATs
resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet)
  allocation_id = aws_eip.eip.*.id[count.index]
  subnet_id     = aws_subnet.public.*.id[count.index]

  tags = {
    "Name" = "NAT_${regex(".$", data.aws_availability_zones.available.names[count.index])}_${aws_vpc.vpc.id}"
  }
}

