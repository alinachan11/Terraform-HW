variable "aws_region" {
  default = "us-east-1"
  type    = string
}

variable "instance_type" {
  description = "The type of the ec2, for example - t2.medium"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  default     = "FirstKey"
  description = "The key name of the Key Pair to use for the instance"
  type        = string
}

variable "private_key_path" {
  description = "The key path of the Key Pair to use for the instance"
  type        = string
}

variable "ubuntu_account_number" {
  default = "099720109477"
}

variable "DB_instances_count" {
  default = 2
}

variable "nginx_instances_count" {
  default = 2
}

variable "nginx_root_disk_size" {
  description = "The size of the root disk"
  default = "10"
}

variable "nginx_encrypted_disk_size" {
  description = "The size of the secondary encrypted disk"
  default = "10"
}

variable "nginx_encrypted_disk_device_name" {
  description = "The name of the device of secondary encrypted disk"
  default = "xvdh"
}

variable "volumes_type" {
  description = "The type of all the disk instances in my project"
  default = "gp2"
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

