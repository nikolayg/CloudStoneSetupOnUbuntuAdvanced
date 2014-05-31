#!/bin/bash

# Import commonly reused functions
. ./functions.sh

## Input Variables...
clientIPAddress=ec2-XX-XX-XX-XX.ap-southeast-2.compute.amazonaws.com
lbIPAddress=ec2-XX-XX-XX-XX.ap-southeast-2.compute.amazonaws.com
asIPAddress=ec2-XX-XX-XX-XX.ap-southeast-2.compute.amazonaws.com
dbIPAddress=ec2-XX-XX-XX-XX.ap-southeast-2.compute.amazonaws.com
nfsIPAddress=ec2-XX-XX-XX-XX.ap-southeast-2.compute.amazonaws.com

pemFile=CloudStone.pem
userName=ubuntu

load_scale=100

## Change permissions of the pem file
sudo chmod 400 $pemFile

## Lists of files and addresses
allFiles=($pemFile functions.sh base-setup.sh base-server-setup.sh nfs-setup.sh as-setup.sh as-image-start.sh client-setup.sh lb-setup.sh db-setup.sh nginx.conf sites-available-default php-5.4.5-libxm2-2.9.0.patch php.ini setupDB.sql config)
allIPAddresses=($clientIPAddress $lbIPAddress $dbIPAddress $asIPAddress $nfsIPAddress)
allScripts=(base-setup.sh base-server-setup.sh client-setup.sh as-setup.sh as-image-start.sh lb-setup.sh db-setup.sh nfs-setup.sh)

## Print meta info
logHeader "Starting installation with the following parameters:"
echo Client Address \(Faban Driver\) : $clientIPAddress
echo Web/AS Server Address: $asIPAddress 
echo DB Server Address: $dbIPAddress

echo PEM FILE: $pemFile 
echo Node Login Username: $userName
echo Current User on the installer: `whoami` 


## Change the IP addresses in the scripts and the config file ... 
logHeader " Prepare installation scripts and configuration files"
for f in ${allScripts[*]}
do
    setProperty "clientIPAddress" $clientIPAddress ./$f
    setProperty "asIPAddress" $asIPAddress ./$f
    setProperty "lbIPAddress" $lbIPAddress ./$f
    setProperty "dbIPAddress" $dbIPAddress ./$f
    setProperty "nfsIPAddress" $nfsIPAddress ./$f
    setProperty "pemFile" $pemFile ./$f
    setProperty "load_scale" $load_scale ./$f
done

setProperty User $userName ./config " "
setProperty IdentityFile "~/$pemFile" ./config " "

## Copy the scripts and properties to the servers ... 
logHeader "Transfer scripts and config to servers..."
for address in ${allIPAddresses[*]}
do
    scp -i $pemFile ${allFiles[*]} $userName@$address:~/
done


## Set up the client
logHeader "Set up the client..."
ssh -i $pemFile $userName@$clientIPAddress "bash client-setup.sh" &> ~/client-setup.log


## Copy FABAN  and GEOCODER from the client to the local machine
logHeader "Copy FABAN and Geocoder from client locally"

scp -i $pemFile $userName@$clientIPAddress:/cloudstone/faban.tar.gz ~ 
scp -i $pemFile $userName@$clientIPAddress:/cloudstone/geocoder.tar.gz ~ 


## Copy FABAN and GEOCODER to the NFS, AS and DB servers
logHeader "Copy FABAN and geocoder to the servers"
for address in ${allIPAddresses[*]}
do
    scp -i $pemFile ~/faban.tar.gz $userName@$address:~/
    scp -i $pemFile ~/geocoder.tar.gz $userName@$address:~/
done


## Set up the NFS server...
logHeader "Set up the NFS server, modify as-setup.sh and as-image-start.sh accordingly and send it to the servers"
ssh -i $pemFile $userName@$nfsIPAddress "bash nfs-setup.sh" &> ~/nfs-setup.log

nfsPath=$(ssh -i $pemFile $userName@$nfsIPAddress "echo \$FILESTORE")
setProperty "nfsPath" $nfsPath ./as-setup.sh
setProperty "nfsPath" $nfsPath ./as-image-start.sh
echo $nfsPath 

for address in ${allIPAddresses[*]}
do
    scp -i $pemFile as-setup.sh $userName@$address:~/
done

## Set up the Load balancer server
logHeader "Setup Load Balancer... "
ssh -i $pemFile $userName@$lbIPAddress "bash lb-setup.sh" &> ~/lb-setup.log

## Set up the AS server
logHeader "Setup AS/Web server... "
ssh -i $pemFile $userName@$asIPAddress "bash as-setup.sh" &> ~/as-setup.log

## Set up the DB server
logHeader "Setup database server... "
ssh -i $pemFile $userName@$dbIPAddress "bash db-setup.sh" &> ~/db-setup.log


printf "$\n\n\n == == == == DONE! == == == == \n "
