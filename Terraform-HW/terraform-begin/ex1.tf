##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {}
variable "availability_zone" {
  default = "us-east-1a"
}
variable "instance_count" {
  default = "2"
}
variable "html_page_path" {}


##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "us-east-1"
}

##################################################################################
# DATA
##################################################################################




##################################################################################
# RESOURCES
##################################################################################

resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "allow_ssh" {
  name        = "nginx_demo"
  description = "Allow ports for nginx"
  vpc_id      = aws_default_vpc.default.id

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

resource "aws_ebs_volume" "vol1" {
  count                  = var.instance_count
  availability_zone = var.availability_zone
  size              = 10
  encrypted = true
  type = "gp2"
  tags = {
    Name = "Vol1"
  }
}

resource "aws_volume_attachment" "ebs_att1" {
  device_name = "/dev/sdh"
  count                  = var.instance_count
  volume_id   = aws_ebs_volume.vol1[count.index].id
  instance_id = aws_instance.nginx1[count.index].id
}


resource "aws_instance" "nginx1" {
  count                  = var.instance_count
  ami                    = "ami-0747bdcabd34c712a"
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  availability_zone = var.availability_zone

  tags = {
    Owner = "Grandpa"
    Server_Name = "Whiskey-${count.index + 1}"
    Purpose = "Whiskey"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.private_key_path)

  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
      "sudo chmod 666 /var/www/html/index.nginx-debian.html",
      "sudo echo \"<!DOCTYPE html><html><body><h1>Welcome to Granpa's Whiskey</h1></body></html>\" >  /var/www/html/index.nginx-debian.html" ,
    ]
  }
}

##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
  value = [for nginx in aws_instance.nginx1 : nginx.public_dns] 
}
