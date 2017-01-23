This folder contains instructions on setting up a Raspberry Pi master with our core OS image. Ideally, you should probably
just be cloning the existing master though, as that's significantly less effort! These instructions are really being 
maintained just in case I need to go back the beginning for some reason.

Existing base images, which can be written directly to SSD, are in DropBox at `Smart miniGrid Controller/App/DevOps/RPi Base Images/`.

# Installing the Base OS

We're basing our OS on Raspberry Linux running Debian 8 Jessie, as this has support for Docker - unlike earlier versions.

## The Image

At the time of writing, no official OS images exist for the RPi. So the one we're using (from http://gnutoolchains.com/raspberry/jessie/)
which is also available in the `RPi Base Images` folder in dropbox, as per our own generated base images.

## Writing to the SSD

### On Linux (Strongly Recommended)

If you have an SSD with the image on it already, insert it via a USB card reader (assume it shows as `/dev/sda`). Stick in your
other SSD card also via a card reader (assume it show `/dev/sdb`). Now you can simply do:
 
```
pv < /dev/sda > /dev/sdb
```

If you want to copy the original SSD to an image:

```
pv < /dev/sda | gzip --fast > xyz.img.gz
```

If you want to load an image to an SSD

```
pv < xyz.img.gz | gunzip > /dev/sdX
```


### On OSX (Not Recommended)

*This is not recommended. It is better to do this on Linux. If you don't have linux but do have an RPi, then don't forget 
that you can simply use a standard Raspian linux SSD as a dev machine!* 

I use [Pi Filler](http://ivanx.com/raspberrypi/) on OSX.

The image we write is only 4GB though, and our SSDs are at least 8GB. So we need to resize them. 

If you're on OSX, you'll need to do this using Vagrant as OSX can't manage the partitions the way we want. See the section below on 
**Mounting the SSD in Vagrant**. Once that's done you can continue to the next step. However, if you have a RPi kicking 
around with a working OS on it, then it's a lot easier to just use that and a USB card reader! 

To resize the main partition so that it makes use of all the available disk space follow https://geekpeek.net/resize-filesystem-fdisk-resize2fs/.
Be aware that the sector information is different and I had to manually select the correct sectors. (It tried to write the second partition 
before the first and only had about 8000 sectors to work with ... tiny disk! Not Good).


# Setting up the Base OS

This covers 

* supporting our accessories and peripherals, such as the 8" tft screen we have which needs some specific config to work properly
* stripping x11 and gui packages from the os as we'll only be using our Pis headless 

For this, use the packer script at [/packs/rpi/base.sh](/packs/rpi/base.sh). 

And then, as per normal, the [/packs/rpi](/packs/rpi) directory contains the packs for provisioning the SSD with our 
core server requirements.



# The Final Image

Once we've created our master SSD, we save a gzipped copy of it in DropBox at `Smart miniGrid Controller/App/DevOps/RPi Base Images/`. 



# NOT RECOMMENDED Mounting the SSD in Vagrant on OSX

See http://superuser.com/questions/373463/how-to-access-an-sd-card-from-a-virtual-machine 

BUT, with the following modifications for the creation of the raw disk image

1. find which /dev/diskX the SSD is.
2. Unmount it if necessary
3. `sudo chown al:staff /dev/diskX*`
4. Unmount it again if necessary
5. `VBoxManage internalcommands createrawvmdk -filename ssd.vmdk -rawdisk /dev/diskX`   # NOTE NOT SUDO!
6. Unmount it again if necessary
7. Follow the instructions in the above link again, and don't forget to keep unmounting the disk as OSX will keep trying to mount it again and again

Basically. you have to make the SSD is unmounted in OSX when you want to mount it in the Vagrant Box
