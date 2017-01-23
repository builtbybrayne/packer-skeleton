#! /bin/bash

set -e

USER="$1"
SSH_DIR="/home/$USER/.ssh"

echo ""
# Add ssh allowances for $USER (and any other admin users, e.g. Vagrant)
echo "DenyUsers root" | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo "DenyGroups root" | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo "PermitRootLogin no" | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo "AllowGroups admin" | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo "- Updated ssh config file"

# Add ssh keys for $USER user
[[ ! -d "$SSH_DIR" ]] && sudo mkdir "$SSH_DIR"
sudo chown -R `whoami` "$SSH_DIR"
cd "$SSH_DIR"
cp /tmp/id_rsa* ./
cat /tmp/id_rsa.pub >> "$SSH_DIR"/authorized_keys
chmod 700 "$SSH_DIR"
chmod 600 "$SSH_DIR"/*
cd - > /dev/null
sudo chown -R $USER:$USER "$SSH_DIR"
echo "- Set up $USER ssh keys"
