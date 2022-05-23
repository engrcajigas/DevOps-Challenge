#!/bin/bash

sudo yum -update -y 
sudo amazon-linux-extras install epel -y
sudo yum -y install httpd 
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
echo "<h1> Hello from Philippines! </h1>" >> /var/www/html/index.html 
echo "<p>Instance ID: $(curl http://169.254.169.254/latest/meta-data/instance-id)</p>" >> /var/www/html/index.html
sudo systemctl enable httpd 
sudo systemctl start httpd 
