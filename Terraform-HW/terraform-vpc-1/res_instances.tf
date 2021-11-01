##################################################################################
# RESOURCES
##################################################################################

resource "aws_ebs_volume" "vol1" {
  availability_zone = var.availability_zone[0]
  size              = var.encrypted_disk_size
  encrypted = true
  type = "gp2"
  tags = {
    Name = "Vol1"
  }
}

resource "aws_ebs_volume" "vol2" {
  availability_zone = var.availability_zone[1]
  size              = var.encrypted_disk_size
  encrypted = true
  type = "gp2"
  tags = {
    Name = "Vol2"
  }
}

resource "aws_volume_attachment" "ebs_att1" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.vol1.id
  instance_id = aws_instance.nginx1.id
}

resource "aws_volume_attachment" "ebs_att2" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.vol2.id
  instance_id = aws_instance.nginx2.id
}

resource "aws_instance" "db1" {
  ami                    = data.aws_ami.ubuntu-18.id
  instance_type          = var.instance_type
  availability_zone = var.availability_zone[0]
  subnet_id                   = aws_subnet.private_subnet1.id
  vpc_security_group_ids = [aws_security_group.only_egress_for_db.id]
  tags = {
    Name        = "DB-1"
    Purpose = "Whiskey DB"
  }
    root_block_device {
        volume_size              = var.root_disk_size
        encrypted = true
        volume_type = "gp2"
    }
}

resource "aws_instance" "db2" {
  ami                    = data.aws_ami.ubuntu-18.id
  instance_type          = var.instance_type
  availability_zone = var.availability_zone[1]
  subnet_id                   = aws_subnet.private_subnet2.id
  vpc_security_group_ids = [aws_security_group.only_egress_for_db.id]
  tags = {
    Name        = "DB-2"
    Purpose = "Whiskey DB"
  }
    root_block_device {
        volume_size              = var.root_disk_size
        encrypted = true
        volume_type = "gp2"
    }
}

resource "aws_instance" "nginx1" {
  ami                    = data.aws_ami.ubuntu-18.id
  instance_type          = var.instance_type
  subnet_id                   = aws_subnet.public_subnet1.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  availability_zone = var.availability_zone[0]
  user_data                   = local.my-instance-userdata

  tags = {
    Name        = "${var.name_tag}-1"
    Server_Name = "Whiskey-1"
    Purpose = var.purpose_tag
  }

  root_block_device {
        volume_size              = var.root_disk_size
        encrypted = true
        volume_type = "gp2"
    }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.private_key_path)

  }
}

resource "aws_instance" "nginx2" {
  ami                    = data.aws_ami.ubuntu-18.id
  instance_type          = var.instance_type
  subnet_id                   = aws_subnet.public_subnet2.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  availability_zone = var.availability_zone[1]
  user_data                   = local.my-instance-userdata

  tags = {
    Name        = "${var.name_tag}-2"
    Server_Name = "Whiskey-2"
    Purpose = var.purpose_tag
  }

  root_block_device {
        volume_size              = var.root_disk_size
        encrypted = true
        volume_type = "gp2"
    }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.private_key_path)

  }
}

##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns1" {
  value = aws_instance.nginx1.public_dns
}

output "aws_instance_public_dns2" {
  value = aws_instance.nginx2.public_dns
}
