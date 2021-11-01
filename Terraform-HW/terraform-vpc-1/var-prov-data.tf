##################################################################################
# VARIABLES
##################################################################################

variable "private_key_path" {}
variable "key_name" {}

variable "aws_region" {
  default = "us-east-1"
  type    = string
}
variable "availability_zone" {
  default = ["us-east-1a","us-east-1b"]
}

variable "instance_type" {
  description = "The type of the nginx EC2, for example - t2.medium"
  type        = string
  default     = "t2.micro"
}

variable "instance_count" {
  default = "2"
}
variable "db_instance_count" {
  default = "2"
}

variable "root_disk_size" {
  description = "The size of the root disk"
  default = "10"
}

variable "encrypted_disk_size" {
  description = "The size of the secondary encrypted disk"
  default = "10"
}

variable "public_subnet" {
  default = ["public_subnet1","public_subnet2"]
}

variable "private_subnet" {
  default = ["private_subnet1","private_subnet2"]
}

variable "owner_tag" {
  description = "The owner tag will be applied to every resource in the project through the 'default variables' feature"
  default = "Grandpa"
  type    = string
}

variable "purpose_tag" {
  default = "Whiskey"
  type    = string
}

variable "name_tag" {
  default = "Nginx"
  type    = string
}

variable "ubuntu_account_number" {
  default = "099720109477"
  type    = string
}


##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {

  profile = "Ops-School-profile"
  region  = var.aws_region
  default_tags {
    tags = {
      Owner = var.owner_tag
    }
  }
}

##################################################################################
# DATA
##################################################################################

data "aws_ami" "ubuntu-18" {
  most_recent = true
  owners      = [var.ubuntu_account_number]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}


