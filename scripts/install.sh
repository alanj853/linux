#!/bin/bash

set -e

if [ -z $KERNEL ]; then
    echo "Please set the KERNEL env var"
    exit -1
fi

if [ -z $1 ]; then
    echo "Please pass in the device root, e.g sda or sdb"
    exit -1
fi

mkdir -p mnt
mkdir -p mnt/fat32
mkdir -p mnt/ext4

sudo mount ${1}1 mnt/fat32
sudo mount ${1}2 mnt/ext4

sudo env PATH=$PATH make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=mnt/ext4 modules_install

sudo cp mnt/fat32/$KERNEL.img mnt/fat32/$KERNEL-backup.img
sudo cp arch/arm64/boot/Image mnt/fat32/$KERNEL.img
sudo cp arch/arm64/boot/dts/broadcom/*.dtb mnt/fat32/
sudo cp arch/arm64/boot/dts/overlays/*.dtb* mnt/fat32/overlays/
sudo cp arch/arm64/boot/dts/overlays/README mnt/fat32/overlays/
sudo umount mnt/fat32
sudo umount mnt/ext4
