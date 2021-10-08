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

echo "Mounting..."

sudo mount -v ${1}1 mnt/fat32
sudo mount -v ${1}2 mnt/ext4

echo "Installing modules..."
sudo env PATH=$PATH make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=mnt/ext4 modules_install

echo "Copying images..."
sudo mv -v mnt/fat32/$KERNEL.img mnt/fat32/$KERNEL-backup.img
sudo cp -v arch/arm64/boot/Image mnt/fat32/$KERNEL.img

echo "Copying DTBs..."
sudo cp -v arch/arm64/boot/dts/broadcom/*.dtb mnt/fat32/
sudo cp -v arch/arm64/boot/dts/overlays/*.dtb* mnt/fat32/overlays/

echo "Copying README..."
sudo cp -v arch/arm64/boot/dts/overlays/README mnt/fat32/overlays/

echo "Unmounting..."
sudo umount -v mnt/fat32
sudo umount -v mnt/ext4

echo "DONE."
