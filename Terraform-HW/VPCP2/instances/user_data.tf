locals {
  my-nginx-instance-userdata = <<USERDATA
#!/bin/bash

sudo apt update -y
sudo apt install nginx -y
sudo hostnamectl set-hostname nginx.example.com
sed -i "s/nginx/Grandpa's Whiskey/g" /var/www/html/index.nginx-debian.html
sed -i "s/nginx/MyHostName/g" /var/www/html/index.nginx-debian.html
sed -i '15,23d' /var/www/html/index.nginx-debian.html
service nginx restart
sudo cat /etc/hosts
USERDATA
}