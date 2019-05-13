#!/usr/bin/env bash

function nginxConfig {
  #verifies the nginx version that was installed
  nginx -v

  # remove default nginx config
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< REMOVING DEFAULT NGINX CONFIG FILES >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo rm /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default

  #change ownership of the sites-available directory to the current user
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< CHANGING FILE PERMISSIONS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo chown -R $(whoami) /etc/nginx/sites-available

  # creates custom nginx config with a proxy pass
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< CREATING CUSTOM NGINX CONFIG FILE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo cat > /etc/nginx/sites-available/sendit <<EOF
server {
  listen 80;
  server_name localhost sendit-ah.gq www.sendit-ah.gq;
  location / {
    proxy_pass http://127.0.0.1:3000;
  }
}
EOF
  cat /etc/nginx/sites-available/sendit

  # enable sendit config instead
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ENABLING CUSTOM FILE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo ln -s /etc/nginx/sites-available/sendit /etc/nginx/sites-enabled/sendit

  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< RESTARTING NGINX SERVICE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo service nginx restart
  systemctl status nginx.service

  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< SERVICE RESTARTED >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
}

# installs packages for the setup and configuration of SSL certificates
function certbot {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALLING CERTBOT >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo apt-get install software-properties-common
  sudo add-apt-repository ppa:certbot/certbot
  sudo apt-get update
  sudo apt-get install -y python-certbot-nginx
}

function main {
  nginxConfig
  certbot
}

main


