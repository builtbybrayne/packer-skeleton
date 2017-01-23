#! /bin/bash

set -e

# Updating and Upgrading dependencies
sudo apt-get update -y -qq > /dev/null
sudo apt-get upgrade -y -qq > /dev/null

# Install necessary dependencies
sudo apt-get -y -qq install curl wget unzip python > /dev/null
