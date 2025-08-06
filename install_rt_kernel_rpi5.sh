#!/bin/bash

set -e  # Stop script if any command fails

echo "=== INSTALLING PREEMPT_RT KERNEL ON RASPBERRY PI 5 ==="

# 1. Update system and install build tools
echo "-> Installing required build tools..."
sudo apt update
sudo apt install -y git bc bison flex libssl-dev make libc6-dev libncurses5-dev crossbuild-essential-arm64 dwarves fakeroot rsync gdebi wget rt-tests

# 2. Download kernel source
echo "-> Cloning kernel source (rpi-6.12.y)..."
cd ~
git clone --depth=1 --branch rpi-6.12.y https://github.com/raspberrypi/linux.git
cd linux

# 3. Download and apply PREEMPT_RT patch
echo "-> Downloading and applying PREEMPT_RT patch..."
wget https://cdn.kernel.org/pub/linux/kernel/projects/rt/6.12/patch-6.12.28-rt10.patch.gz
gunzip patch-6.12.28-rt10.patch.gz
patch -p1 < patch-6.12.28-rt10.patch

# 4. Configure kernel
echo "-> Configuring kernel for Raspberry Pi 5 with PREEMPT_RT..."
make bcm2712_defconfig
scripts/config --disable DEBUG_INFO
scripts/config --enable PREEMPT_RT
scripts/config --set-str LOCALVERSION "-v8_full_preempt"

# 5. Build kernel
echo "-> Building the kernel (this may take 30-60 minutes.."
KERNEL=kernel_2712
make -j$(nproc) Image.gz modules dtbs
sudo make -j$(nproc) modules_install

# 6. Install the compiled kernel
echo "-> Installing the new kernel..."
sudo cp /boot/firmware/${KERNEL}.img /boot/firmware/${KERNEL}-backup.img || true
sudo cp arch/arm64/boot/Image.gz /boot/firmware/${KERNEL}.img
sudo cp arch/arm64/boot/dts/broadcom/*.dtb /boot/firmware/
sudo cp arch/arm64/boot/dts/overlays/*.dtb* /boot/firmware/overlays/
sudo cp arch/arm64/boot/dts/overlays/README /boot/firmware/overlays/

# 7. Configure isolcpus
echo "-> Adding isolcpus=2,3 to cmdline.txt (if not already present)..."
if ! grep -q "isolcpus=2,3" /boot/firmware/cmdline.txt; then
    sudo sed -i 's/$/ isolcpus=2,3/' /boot/firmware/cmdline.txt
fi

# 8. Install LinuxCNC uspace (optional)
echo "-> Downloading and installing LinuxCNC uspace..."
wget https://www.linuxcnc.org/dists/bookworm/2.9-uspace/binary-arm64/linuxcnc-uspace_2.9.3_arm64.deb
sudo gdebi -n linuxcnc-uspace_2.9.3_arm64.deb

# 9. Reboot to apply changes
echo "-> All done. The system will reboot now."
sleep 3
sudo reboot