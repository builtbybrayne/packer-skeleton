This project creates the base ubuntu box/image with a user and some basic bash aliases baked in. 

It does not fully provision the images as that's what ansible is for.

There are 3 supported target environments:

* amazon - this will build an ami
* vagrant - this will build a local box (which can be saved to some shared filesystem)
* bare metal - this will provision the target machine in-situ. (Useful for embedded hardware like Raspberry Pis)


# Prerequisites

You must have installed the [secrets](https://bitbucket.org/droneportal/secrets) repo.

You must have installed https://www.packer.io/.


# Installation

Check this repo out anywhere on your local machine.
 

# Usage

## Configuration

Each target environment has an `<env>-example.conf` configuration file. Copy those to `<env>.conf` and make sure you're happy with the values in them.

There is also a `user-example.conf` example file. Copy that to `user.conf` and again make sure you're ok with the settings. 

You can override these config files per provisioning run via cli arguments. These are just convenience defaults. 


## Running a build

After setting up your config as desired, run the appropriate .sh file in the root of this directory.
 
Most settings have sane defaults provided where possible.
 
 
# Users

The default users for each target environment (e.g. ubuntu or vagrant) are still present at the end of these scripts, but they will not be accessible over SSH.


# Directory Structure

```
builds      --- Stores the final output builds
http        --- Needed for vagrant
packs       --- The packer definitions. Each has a main.json with the core packer configuration for that pack
- ubuntu    --- - Packer for Ubuntu Trust 14.04. Loads both Vagrant and AWS
resources   --- files required by the scripts
scripts     --- Common provisioning scripts available to all packs 
```