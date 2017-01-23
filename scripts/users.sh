#! /bin/bash

set -e

USER="$1"

# Update root password
sudo usermod -p $(echo "<TODO: Define root password>" | openssl passwd -1 -stdin) root

# Add "$USER" user
sudo adduser --disabled-password --gecos "" "$USER"
sudo adduser "$USER" sudo

# Update "$USER" password
sudo usermod -p $(echo "<TODO: Define user password>" | openssl passwd -1 -stdin) "$USER"


# Setup sudo to allow no-password sudo for "admin" users ("$USER" + possibly vagrant)
sudo groupadd -r admin || true
sudo usermod -a -G admin "$USER"
sudo cp /etc/sudoers /etc/sudoers.orig
sudo sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sudo sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers





