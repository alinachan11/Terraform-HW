variable "aws_region" {
  default = "us-east-1"
  type    = string
}

variable "ubuntu_account_number" {
  default = "099720109477"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "private_subnet" {
  type    = list(string)
  default = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24"]
}

variable "route_tables_names" {
  type    = list(string)
  default = ["public", "private-a", "private-b"]
}

variable "owner_tag" {
  description = "The owner tag will be applied to every resource in the project through the 'default variables' feature"
  default = "Alina"
  type    = string
}

variable "purpose_tag" {
  default = "Whiskey"
  type    = string
}

variable "subnet_type_tag" {
  default = "Public"
  type    = string
}

