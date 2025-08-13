#!/bin/bash
set -e

# --- Hàm kiểm tra model Raspberry Pi ---
detect_rpi_model() {
    if grep -q "Raspberry Pi 5" /proc/device-tree/model; then
        echo "rpi5"
    elif grep -q "Raspberry Pi 4" /proc/device-tree/model; then
        echo "rpi4"
    elif grep -q "Raspberry Pi 3" /proc/device-tree/model; then
        echo "rpi3"
    else
        echo "unknown"
    fi
}

# --- Xác định kiến trúc ---
ARCH=$(uname -m)
RPI_MODEL=$(detect_rpi_model)
echo "[1/9] Phát hiện: $RPI_MODEL ($ARCH)"

# --- Lấy phiên bản stable mới nhất từ kernel.org ---
LATEST_VERSION=$(curl -s https://www.kernel.org/ | grep -A1 "stable:" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)
echo "[2/9] Phiên bản stable mới nhất: $LATEST_VERSION"

# --- Kiểm tra patch RT ---
RT_PATCH_URL="https://cdn.kernel.org/pub/linux/kernel/projects/rt/${LATEST_VERSION%.*}/patch-$LATEST_VERSION-rt1.patch.gz"
if curl --output /dev/null --silent --head --fail "$RT_PATCH_URL"; then
    echo "[3/9] Patch RT tìm thấy: $RT_PATCH_URL"
else
    echo "⚠ Không tìm thấy patch RT cho $LATEST_VERSION — chọn phiên bản trước đó."
    LATEST_VERSION=$(curl -s https://www.kernel.org/ | grep -A1 "longterm:" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)
    RT_PATCH_URL="https://cdn.kernel.org/pub/linux/kernel/projects/rt/${LATEST_VERSION%.*}/patch-$LATEST_VERSION-rt1.patch.gz"
fi

# --- Tạo thư mục làm việc ---
WORKDIR=$HOME/rt_kernel_build
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# --- Tải kernel source ---
echo "[4/9] Tải Linux kernel $LATEST_VERSION..."
wget -c https://cdn.kernel.org/pub/linux/kernel/v${LATEST_VERSION%%.*}.x/linux-$LATEST_VERSION.tar.xz

# --- Giải nén ---
echo "[5/9] Giải nén..."
tar -xf linux-$LATEST_VERSION.tar.xz
cd linux-$LATEST_VERSION

# --- Áp patch RT ---
if curl --output /dev/null --silent --head --fail "$RT_PATCH_URL"; then
    echo "[6/9] Áp patch RT..."
    wget -c "$RT_PATCH_URL"
    gzip -cd patch-$LATEST_VERSION-rt1.patch.gz | patch -p1
else
    echo "⚠ Không có patch RT — có thể RT đã tích hợp sẵn trong kernel."
fi

# --- Cấu hình cho Raspberry Pi ---
echo "[7/9] Thiết lập cấu hình mặc định..."
if [[ "$RPI_MODEL" == "rpi5" || "$RPI_MODEL" == "rpi4" ]]; then
    make bcm2711_defconfig
elif [[ "$RPI_MODEL" == "rpi3" ]]; then
    make bcm2709_defconfig
else
    echo "Không nhận diện được model Pi, dùng defconfig mặc định."
    make defconfig
fi

# Bật PREEMPT_RT tự động
scripts/config --set-val CONFIG_PREEMPT_RT y || true
scripts/config --disable CONFIG_PREEMPT_VOLUNTARY || true
scripts/config --enable CONFIG_PREEMPT

# --- Build kernel ---
echo "[8/9] Bắt đầu build kernel RT..."
make -j$(nproc) Image.gz modules dtbs
sudo make modules_install

# --- Cài đặt kernel ---
echo "[9/9] Cài kernel mới..."
sudo cp arch/arm64/boot/Image.gz /boot/firmware/kernel_rt.img
sudo cp arch/arm64/boot/dts/broadcom/*.dtb /boot/firmware/
sudo cp arch/arm64/boot/dts/overlays/*.dtb* /boot/firmware/overlays/
sudo cp arch/arm64/boot/dts/overlays/README /boot/firmware/overlays/

echo "✅ Hoàn tất. Sửa /boot/firmware/config.txt để boot kernel_rt.img"
echo "Ví dụ: dtoverlay=vc4-kms-v3d"
echo "       kernel=kernel_rt.img"
