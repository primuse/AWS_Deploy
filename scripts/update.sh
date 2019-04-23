#!/usr/bin/env bash

#prints out each command to the terminal
set -x

#gets latest ubuntu updates 
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< RUN UBUNTU UPDATE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
sudo apt-get update

echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALLING NODEJS WITH NPM >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
sudo apt-get install -y nodejs

echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALLING NGINX >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
sudo apt-get -y install nginx

#installs pm2 to run app in the background
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALLING PM2>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
sudo npm i pm2@latest -g
