data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu-18" {
  most_recent = true
  owners      = [var.ubuntu_account_number]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = ["My_VPC"]
  }
}



data "aws_subnet" "private0" {
  filter {
   name = "tag:Name"
    values = ["Private_subnet_${regex(".$", data.aws_availability_zones.available.names[0])}_${data.aws_vpc.vpc.id}"]
  }
}

data "aws_subnet" "private1" {
  filter {
   name = "tag:Name"
    values =["Private_subnet_${regex(".$", data.aws_availability_zones.available.names[1])}_${data.aws_vpc.vpc.id}"]
  }
}

data "aws_subnet" "public0" {
  filter {
   name = "tag:Name"
    values = ["Public_subnet_${regex(".$", data.aws_availability_zones.available.names[0])}_${data.aws_vpc.vpc.id}"]
  }
}

data "aws_subnet" "public1" {
  filter {
   name = "tag:Name"
    values =["Public_subnet_${regex(".$", data.aws_availability_zones.available.names[1])}_${data.aws_vpc.vpc.id}"]
  }
}
/*
variable "aws_subnet_private" {
  default = tolist([data.aws_subnet.private0,data.aws_subnet.private1])
}
*/
#data "aws_subnet" "public" {
  #filter {
  #  name = "tag:Name"
  #  values = ["Public_subnet_${regex(".$", data.aws_availability_zones.available.names[0])}_${data.aws_vpc.vpc.id}",
  #  "Public_subnet_${regex(".$", data.aws_availability_zones.available.names[1])}_${data.aws_vpc.vpc.id}"]
 # }
#}
#data "aws_subnet" "public" {
 # vpc_id = data.aws_vpc.vpc.id
  #tags = { Name = ["Public_subnet_${regex(".$", data.aws_availability_zones.available.names[0])}_${data.aws_vpc.vpc.id}",
 #   "Public_subnet_${regex(".$", data.aws_availability_zones.available.names[1])}_${data.aws_vpc.vpc.id}"] }
#}

#data "aws_subnet" "private" {
 # vpc_id = data.aws_vpc.vpc.id
 # tags = { Name = ["Private_subnet_${regex(".$", data.aws_availability_zones.available.names[0])}_${data.aws_vpc.vpc.id}",
 #  "Private_subnet_${regex(".$", data.aws_availability_zones.available.names[1])}_${data.aws_vpc.vpc.id}"] }
#}
#data "aws_subnet" "private0" {
#  count = "2"
#  filter {
#    name   = "tag:Name"
#    values = "Private_subnet_${regex(".$", data.aws_availability_zones.available.names[0])}_${data.aws_vpc.vpc.id}"
#  }
  
#}

#data "aws_subnet" "private1" {
 # count = "2"
 # filter {
 #   name   = "tag:Name"
  # values = "Private_subnet_${regex(".$", data.aws_availability_zones.available.names[1])}_${data.aws_vpc.vpc.id}"
  #}
  
#}
#data "aws_subnet" "public" {
  #filter {
 #   name   = "tag:Name"
  #  values = ["Public*"]
 # }
 # count = "2"
#}

