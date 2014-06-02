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

load_scale=50

## Apply a patch to Olio
logHeader "Patch Olio and populate the filestorage..."
exportVar APP_DIR "/var/www"
sudo mkdir -p $APP_DIR

sudo cp -r $OLIO_HOME/webapp/php/trunk/* $APP_DIR
sudo cp /cloudstone/web-release/cloudstone.patch $APP_DIR
cd $APP_DIR
sudo patch -p1 < cloudstone.patch

## Find the best place to put the storage
maxSpaceDir=`getMaxDiskSpaceDir`
if [[ $maxSpaceDir == */ ]]
then 
    exportVar FILESTORE `getMaxDiskSpaceDir`filestorage
else 
    exportVar FILESTORE `getMaxDiskSpaceDir`/filestorage
fi

sudo mkdir -p $FILESTORE
sudo chmod a+rwx $FILESTORE

sudo chmod +x $FABAN_HOME/benchmarks/OlioDriver/bin/fileloader.sh
$FABAN_HOME/benchmarks/OlioDriver/bin/fileloader.sh $load_scale $FILESTORE

## Install and setup NFS server
logHeader " Install and setup Network File System (NFS) server ..."
sudo apt-get install -y nfs-kernel-server  1> /dev/null

sudo chown nobody:nogroup $FILESTORE

# Allow connection from anywhere, as we don't know in advance all web/app servers ...
sudo bash -c "echo \"$FILESTORE           *(rw,sync,no_root_squash,no_subtree_check)\" >> /etc/exports"

sudo /etc/init.d/nfs-kernel-server restart

## Print installation details...
logInstallDetails

