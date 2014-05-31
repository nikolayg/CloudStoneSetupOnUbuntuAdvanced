#!/bin/bash

# Record the start directory 
export startDir=`pwd`

# Import commonly reused functions
echo "Load Commonly used functions from $startDir/functions.sh"
. $startDir/functions.sh

## Run common installation
. $startDir/base-setup.sh
cd /cloudstone

## Setup Tomcat and FABAN
. $startDir/base-server-setup.sh
cd /cloudstone

asIPAddress=ec2-XX-XX-XX-XX.ap-southeast-2.compute.amazonaws.com

## Mount NFS server
logHeader "Install latest NGINX from repository and configure it"

sudo apt-get install -y nginx 1> /dev/null

cd /etc/nginx/sites-available/
sudo cp ~/sites-available-default ./default-backup
resetLoadBalancer $asIPAddress 1

sudo service nginx restart
#sudo service nginx reload

## Print installation details...
logInstallDetails
