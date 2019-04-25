#!/usr/bin/env bash

function directory {
  #creates a directory "documents" and changes directory into it
  mkdir documents
  cd documents

  #makes the current user the owner of this config directory
  sudo chown -R $(whoami) ~/.config 
}

#clones the repository where the appto be deployed is
function cloneRepo {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< CLONING REPO >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  git clone https://github.com/primuse/SendIt-React.git
  cd SendIt-React
}

function app {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALLING APP DEPENDENCIES >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  npm install

  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ENVIRONMENT IS READY; STARTING APP >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  pm2 start npm -- start
  pm2 startup
  sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
  pm2 save

  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< APPLICATION STARTED >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  cd ~
}

directory
cloneRepo
app