#! /bin/bash

set -e

if [ -z `alias | grep 'll'` ] && [ -f /tmp/bash_aliases ]; then
    sudo mv /tmp/bash_aliases /etc/bash_aliases
    echo '. /etc/bash_aliases' | sudo tee -a /etc/bash.bashrc > /dev/null
fi