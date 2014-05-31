#!/bin/bash

# Record the start directory 
export startDir=`pwd`

# Import commonly reused functions
echo "Load Commonly used functions from $startDir/functions.sh"
. $startDir/functions.sh

## Run common installation
. $startDir/base-setup.sh
cd /cloudstone

# Setup Tomcat and FABAN
. $startDir/base-server-setup.sh
cd /cloudstone

asIPAddress=ec2-XX-XX-XX-XX.ap-southeast-2.compute.amazonaws.com
load_scale=100

##Setting up Tomcat
logHeader "Setting up Tomcat"
cp web-release/apache-tomcat-6.0.35.tar.gz .
tar xzvf apache-tomcat-6.0.35.tar.gz 1> /dev/null
exportVar CATALINA_HOME "/cloudstone/apache-tomcat-6.0.35"

cd $CATALINA_HOME/bin
tar zxvf commons-daemon-native.tar.gz 1> /dev/null
cd commons-daemon-1.0.7-native-src/unix/
./configure
make
cp jsvc ../..

## Removed preconfigured MySql, set up mysql and its user
logHeader " Setup MySql"
cd /cloudstone
sudo apt-get remove --purge -y mysql-server mysql-client mysql-common
sudo apt-get autoremove
sudo apt-get autoclean

sudo groupadd mysql 
sudo useradd -r -g mysql mysql

cp ./web-release/mysql-5.5.20-linux2.6-x86_64.tar.gz .
tar xzvf mysql-5.5.20-linux2.6-x86_64.tar.gz 1> /dev/null

sudo chown -R mysql mysql-5.5.20-linux2.6-x86_64
sudo chgrp -R mysql mysql-5.5.20-linux2.6-x86_64

sudo chmod -R 777 mysql-5.5.20-linux2.6-x86_64
cd mysql-5.5.20-linux2.6-x86_64
sudo cp support-files/my-medium.cnf /etc/my.cnf

# Sets up some MySql vars like hostname
# bin/my_print_defaults
sudo scripts/mysql_install_db --user=mysql 

## Start mysql
logHeader " Start MySql"
sudo -b bin/mysqld_safe --defaults-file=/etc/my.cnf --user=mysql # 1> /dev/1> /dev/null

## Wait for MySql to start ...
sleep 1m

## Popluate DB
logHeader "Create database schema"

## MySql doesn't know of FABAN, so replace the var in the script
esapedFabanHome=`escapeString $FABAN_HOME`
sed -i "s/\$FABAN_HOME/$esapedFabanHome/g" ~/setupDB.sql 

## Grant permission from anywhere, as it does not work with EC2 DNS! 
#sed -i "s/ip.address.of.frontend/$asIPAddress/g" ~/setupDB.sql
sed -i "s/ip.address.of.frontend/%/g" ~/setupDB.sql
sudo bin/mysql -uroot < ~/setupDB.sql

logHeader "Populate database"
cd $FABAN_HOME/benchmarks/OlioDriver/bin
sudo chmod +x dbloader.sh
./dbloader.sh localhost $load_scale


## Setting up the Geocoder Emulator
logHeader " Setting up the Geocoder Emulator"
mkdir /cloudstone/geocoderhome
sudo chmod -R 777 /cloudstone/geocoderhome 
cd /cloudstone/geocoderhome

exportVar GEOCODER_HOME "/cloudstone/geocoderhome"

sudo cp ~/geocoder.tar.gz .
sudo tar xzvf geocoder.tar.gz 1> /dev/null

cd $GEOCODER_HOME/geocoder
sudo cp build.properties.template build.properties
setProperty "servlet.lib.path" "$CATALINA_HOME/lib" ./build.properties

ant all
cp dist/geocoder.war $CATALINA_HOME/webapps

## Start Tomcat:
logHeader " Start Tomcat"
$CATALINA_HOME/bin/startup.sh

## Print installation details...
logInstallDetails
