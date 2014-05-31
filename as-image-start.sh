#!/bin/bash

echo "Restarting servicess .... "

nfsIPAddress=ec2-XX-XX-XX-XX.ap-southeast-2.compute.amazonaws.com
nfsPath=/filestorage

## Remount the NFS path
sudo mkdir -p $nfsPath
sudo mount $nfsIPAddress:$nfsPath $nfsPath

## Restart the servers
sudo /usr/local/sbin/php-fpm
sudo /usr/local/nginx/sbin/nginx
