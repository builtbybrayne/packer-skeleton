#! /bin/bash

set -e


# Install necessary libraries for guest additions and Vagrant NFS Share
sudo apt-get -y -q install linux-headers-$(uname -r) build-essential dkms nfs-common


# Set up vagrant user ssh access
mkdir ~/.ssh
chmod 700 ~/.ssh
cd ~/.ssh
#wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
curl -k 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -o authorized_keys
sudo chmod 600 ~/.ssh/authorized_keys
sudo chown -R vagrant ~/.ssh

echo "Match User vagrant" | sudo tee -a /etc/ssh/sshd_config #> /dev/null
echo "      PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config #> /dev/null

sudo service ssh restart