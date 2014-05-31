#!/bin/bash

# Import commonly reused functions
. $startDir/functions.sh

cd /cloudstone

## Install NFS server
logHeader "Install Network File System (NFS) client ..."
sudo apt-get install -y nfs-common 1> /dev/null

## Untar and setup FABAN archive taken from the client
logHeader "Setup FABAN archive taken from the client"
sudo cp ~/faban.tar.gz .
tar xzvf faban.tar.gz 1> /dev/null
exportVar FABAN_HOME "/cloudstone/faban"

## Make FABAN accessible by everyone
sudo chown -R $USER $FABAN_HOME
sudo chmod -R 777 $FABAN_HOME

