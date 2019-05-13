#!/usr/bin/env bash

#gets latest ubuntu updates 
function updateUbuntu {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< RUN UBUNTU UPDATE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo apt-get update
}

function installNodeJs {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALLING NODEJS WITH NPM >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
  sudo apt-get install -y nodejs
}

function installNginx {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALLING NGINX >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo apt-get -y install nginx
}

#installs pm2 to run app in the background
function installPm2 {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALLING PM2>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo npm i pm2@latest -g
}

function main {
  updateUbuntu
  installNodeJs
  installNginx
  installPm2
}

main

