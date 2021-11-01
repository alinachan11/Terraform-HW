##################################################################################
# RESOURCES
##################################################################################

resource "aws_vpc" "pvpc1" {
    cidr_block           = "10.1.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    tags = {
     Name        = "my_vpc"
    }
}


resource "aws_eip" "lb" {
  vpc      = true
}

resource "aws_nat_gateway" "my_nat" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = {
    Name = "gw NAT for DB"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.ig1]
}

output "nat_gateway_ip" {
  value = aws_eip.lb.public_ip
}

##################################################################################
# for PUBLIC
##################################################################################
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.pvpc1.id
  cidr_block              =  "10.1.254.0/24"
  availability_zone       = var.availability_zone[0]
  map_public_ip_on_launch = true
  tags = {
    Name        = "public_subnet1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.pvpc1.id
  cidr_block              =  "10.1.253.0/24"
  availability_zone       = var.availability_zone[1]
  map_public_ip_on_launch = true
  tags = {
    Name        = "public_subnet2"
  }
}

resource "aws_route_table" "public1" {
  vpc_id = aws_vpc.pvpc1.id
  tags = {
    Name        = "public-route-table1"
  }
}

resource "aws_route_table" "public2" {
  vpc_id = aws_vpc.pvpc1.id
  tags = {
    Name        = "public-route-table2"
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public1.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public2.id
}

resource "aws_route" "public_internet_gateway1" {
  route_table_id         = aws_route_table.public1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig1.id
}

resource "aws_route" "public_internet_gateway2" {
  route_table_id         = aws_route_table.public2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig1.id
}

resource "aws_internet_gateway" "ig1" {
  vpc_id =  aws_vpc.pvpc1.id
  tags = {
    Name        = "igw1"
  }
}
resource "aws_security_group" "allow_ssh" {
  name        = "nginx1 web"
  description = "Allow ports for nginx"
  vpc_id      = aws_vpc.pvpc1.id

  tags = {
    Name        = "security_group_allow_ssh"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_elb" "my_balancer" {
  name               = "mybalancer"
  subnets = [aws_subnet.public_subnet1.id,aws_subnet.public_subnet2.id]



  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = [aws_instance.nginx1.id,aws_instance.nginx2.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "my_balancer"
  }
}

##################################################################################
# for PRIVATE
##################################################################################
resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.pvpc1.id
  cidr_block              =  "10.1.1.0/24"
  availability_zone       = var.availability_zone[0]
  tags = {
    Name        = "private_subnet1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id                  = aws_vpc.pvpc1.id
  cidr_block              =  "10.1.2.0/24"
  availability_zone       = var.availability_zone[1]
  tags = {
    Name        = "private_subnet2"
  }
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.pvpc1.id
  tags = {
    Name        = "private-route-table1"
  }
}

resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.pvpc1.id
  tags = {
    Name        = "private-route-table2"
  }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private2.id
}


resource "aws_route" "nat1" {
  route_table_id         = aws_route_table.private1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.my_nat.id
}

resource "aws_route" "nat2" {
  route_table_id         = aws_route_table.private2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.my_nat.id
}

resource "aws_security_group" "only_egress_for_db" {
  name        = "db egress"
  description = "egress for db"
  vpc_id      = aws_vpc.pvpc1.id

  tags = {
    Name        = "only_egress_for_db"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
