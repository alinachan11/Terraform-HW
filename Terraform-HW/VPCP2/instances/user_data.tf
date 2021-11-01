locals {
  my-nginx-instance-userdata = <<USERDATA
#!/bin/bash

sudo apt update -y
sudo apt install nginx -y
HOSTNAME="$(curl --silent http://169.254.169.254/latest/meta-data/hostname)
sed -i "s/nginx/Grandpa's Whiskey - \$HOSTNAME/g" /var/www/html/index.nginx-debian.html
sed -i '15,23d' /var/www/html/index.nginx-debian.html
service nginx restart
sudo cat /etc/hosts
USERDATA
}