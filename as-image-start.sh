#!/bin/bash

echo "Restarting servicess .... "

nfsIPAddress=ec2-XX-XX-XX-XX.ap-southeast-2.compute.amazonaws.com
nfsPath=/filestorage

## Remount the NFS path
sudo mkdir -p $nfsPath
sudo mount $nfsIPAddress:$nfsPath $nfsPath

## Create and setup the /tmp/http_sessions, where sessions will be hosted.
## If it does not exists or if permissions are insufficient you won't be able to login
mkdir -p /tmp/http_sessions
sudo chmod -R 777 /tmp/http_sessions

## Restart the servers
sudo /usr/local/sbin/php-fpm
sudo /usr/local/nginx/sbin/nginx


