This project creates the base ubuntu box with all the shared options required by EVERY VM in the SMC project.

This includes:

* A base OS capable of running docker
* Common user/SSH setups

It doesn't install any software beyond what is necessary to get basic access to a core OS that meets our project requirements. 
For that, check out the [SMC Ansible Project](https://bitbucket.org/perchten/smc-ansible).

# Environments

## Vagrant

This is our dev environment. The output from this is a Vagrant Box. (Not all packs create a vagrant box, e.g. The RPi pack doesn't).

A helper script `/vagrant.sh` can (optionally) build the image and load it into Vagrant for you. Then you just need to specify
the box (`smc/<PACK>`) in the VagrantFile and vagrant will find it.

Vagrant boxes are also saved in the `/packs/<PACK>/builds` directory, so can be loaded manually from the github repo as well.


## AWS

This is our deploy environment for non-colo application servers and ops servers.
 
Images are built on AWS and stored within our Amazon account. So nothing is created locally.  

Images a named conventionally as: `smc-<PACK> - <SERVER_TYPE> <TIMESTAMP>`.



## Raspberry Pi

The RPi is a bit harder to build. The basic approach is to create a master SSD and then clone it onto each new SSD we need.

The packer script doesn't build an image that we reuse, but SSHs directly in to the RPi and runs the scripts remotely. 

This process only really needs to be done once per master. After that, you can find the prebuilt images in our Dropbox
at `App/DevOps/RPi Base Images/smc_rpi_master_*.img.gz`. These can be unzipped and written directly to SSDs. 

See the [docs on creating a base OS image](/docs/base_os_img.md) for details on how to set up an SSD with an original OS.



# Core Requirements


## Base OS

The RPi is built on Debian Jessie 8.

Vagrant and AWS boxes are available in Ubuntu Trusty 14.04 LTS, and shortly Debian Jessie 8 for compatibility with the RPi.


## Users

See [User Docs](/docs/users.md).



# Usage

We user [Packer](https://www.packer.io/) to build our base OS images. Check out the usage instructions there.

There are also a couple of utility scripts for the common packer invocations.
 
* `/run.sh <PACK` - simply builds the entire `main.json` defined for that pack
* `/vagrant.sh [-b] <PACK>` - loads the pack box into vagrant, with the optional to force it to be rebuilt first


## Packs

Each directory in [/packs](/packs) contains a README with information on that particular install.
 
 
# Directory Structure

```
builds      --- Stores the final output builds
docs        --- Additional documentation
http        --- Needed for vagrant
keys        --- Stores the master record of the ssh keys for the smc user
packs       --- The packer definitions. Each has a main.json with the core packer configuration for that pack
- jessie    --- - Packer for Debian Jessie 8. Loads both Vagrant and AWS 
- ubuntu    --- - Packer for Ubuntu Trust 14.04. Loads both Vagrant and AWS
- rpi       --- - Packer for Raspberry Pi
resources   --- files required by the scripts
scripts     --- Common provisioning scripts available to all packs 
```