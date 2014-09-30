
#!/bin/bash
# This Script will set up the environment required for vUPS for a fresh Ubuntu Server 14.04
clear

echo "Welcome to the vUPS Initialization Script"

# Set hostname
echo "Enter hostname (FQDN), followed by [ENTER]:"
read hostname

echo $hostname > /etc/hostname 
#hostname -F /etc/hostname

# Update the Ubuntu Repository
sudo apt-get update

# Install required packages
apt-get install -y python python-pip python-virtualenv python-dev mongodb git uwsgi uwsgi-plugin-python nginx openssh-server ntp

# Configure timezone
sudo timedatectl set-timezone Europe/Oslo

# semi-autocreate self-signed cert

echo "Generating an SSL private key to sign your certificate..."
openssl genrsa -des3 -out myssl.key 1024

echo "Generating a Certificate Signing Request..."
openssl req -new -key myssl.key -out myssl.csr

echo "Removing passphrase from key (for nginx)..."
cp myssl.key myssl.key.org
openssl rsa -in myssl.key.org -out myssl.key
rm myssl.key.org

echo "Generating certificate..."
openssl x509 -req -days 365 -in myssl.csr -signkey myssl.key -out myssl.crt

echo "Copying certificate (myssl.crt) to /etc/ssl/certs/"
mkdir -p  /etc/ssl/certs
cp myssl.crt /etc/ssl/certs/

echo "Copying key (myssl.key) to /etc/ssl/private/"
mkdir -p  /etc/ssl/private
cp myssl.key /etc/ssl/private/

rm myssl*


# Pull vUPS code from github

#cd /path/to/code
cd /tmp


#TODO: Pull real code + UPS script
git clone https://github.com/h0bbel/autotest.git #replace with real URL 



# Copy nginx config from git repository

mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.original 
cp autotest/nginx.default /etc/nginx/sites-available/default
rm /usr/share/nginx/html/index.html
cp autotest/nginx.html /usr/share/nginx/html/index.html

# Restart nginx
service nginx restart

clear

echo “Initialization completed!”
echo Open https://$hostname to configure!



exit
