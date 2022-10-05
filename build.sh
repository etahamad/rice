#!/bin/bash

# Welcome Page
echo  "Welcome to the build script for etahamad/ci project!"

echo # Enviroment
export KBUILD_BUILD_USER="etahamad" # change this to your name.
export KBUILD_BUILD_HOST="etahamadCI" # this tells that you compiled your rom on my project, you can change it or leave it, your call.

# Initial Values
deviceName="lavender" # change this to your device name.

cd ~/home/xd

rm -rf device/xiaomi/lavender device/xiaomi/sdm660-common vendor/xiaomi/lavender vendor/xiaomi/sdm660-common kernel/xiaomi/sdm660

git clone https://github.com/lavenderOSS/device_xiaomi_lavender device/xiaomi/lavender -b xd
git clone https://github.com/lavenderOSS/device_xiaomi_sdm660-common device/xiaomi/sdm660-common
git clone https://github.com/lavenderOSS/vendor_xiaomi_sdm660-common vendor/xiaomi/sdm660-common --depth=1
git clone https://github.com/lavenderOSS/vendor_xiaomi_lavender vendor/xiaomi/lavender --depth=1
git clone https://github.com/lavenderOSS/kernel_xiaomi_sdm660-4.19 kernel/xiaomi/sdm660 --depth=1

# This create a folder at the source directory and bind it to be used as ccache.
echo "ccache setup for a13"
mkdir tempcc
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export CCACHE_DIR=$PWD/tempcc
ccache -M 100G -F 0

# Building ROM
echo "Building your ROM..."
. build/envsetup.sh
lunch xdroid_lavender-user # change this to your device lunch command.
make xd -j$(($(nproc --all) - 4)) # number of CPUs - 4, our servers have vCPUs = RAM GB, so we can't use all of them.

echo "Uploading your ROM..."
cd out/target/product/lavender # change this to your device name.

function sendNotify() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
         -d chat_id="$chat_id" \
         -d "disable_web_page_preview=true" \
         -d "parse_mode=html" \
         -d text="Your build is ready to be downloaded: $(curl --upload-file ./$(ls -U *.zip | head -1) https://transfer.sh/$(ls -U *.zip | head -1))."
}

sendNotify
