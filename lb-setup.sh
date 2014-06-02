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

logHeader "Install and setup the HAProxy load balancer"

# Install HAProxy
sudo apt-get install haproxy

# Enable HAProxy
setProperty ENABLED 1 /etc/default/haproxy

# Backup HAProxy config
sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg-default

# Create HAProxy user
sudo useradd -g haproxy haproxy

# Backup HAProxy config
sudo cp ~/haproxy.cfg /etc/haproxy/

# Config the load balancer with the only web/app server we've got for now
resetLoadBalancer $asIPAddress 1

# Start HAProxy
sudo service haproxy start


## Print installation details...
logInstallDetails
