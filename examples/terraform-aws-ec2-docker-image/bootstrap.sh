#!/bin/bash

sudo apt update -y
# Mount the extra EBS volume
sudo mkdir /data  # Create a directory to mount the volume
sudo mount /dev/xvdf/data  # Replace with the actual device name and directory
    
# Optional: Update /etc/fstab to mount the volume on boot
echo "/dev/xvdf/data ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
echo "Bootstrapping Complete!"