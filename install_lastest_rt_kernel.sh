#!/bin/bash
set -e

# Lấy phiên bản kernel mới nhất từ kernel.org
echo "[1/8] Đang kiểm tra phiên bản kernel mới nhất..."
LATEST_VERSION=$(curl -s https://www.kernel.org/ | grep -A1 "stable:" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)
echo "Phiên bản stable mới nhất: $LATEST_VERSION"

# Tạo thư mục làm việc
WORKDIR=$HOME/rt_kernel_build
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Tải kernel source
echo "[2/8] Đang tải Linux kernel $LATEST_VERSION..."
wget -c https://cdn.kernel.org/pub/linux/kernel/v${LATEST_VERSION%%.*}.x/linux-$LATEST_VERSION.tar.xz

# Giải nén
echo "[3/8] Giải nén source..."
tar -xf linux-$LATEST_VERSION.tar.xz
cd linux-$LATEST_VERSION

# Tải patch RT tương ứng (nếu tồn tại)
echo "[4/8] Đang tải patch RT..."
RT_PATCH_URL="https://cdn.kernel.org/pub/linux/kernel/projects/rt/${LATEST_VERSION%.*}/patch-$LATEST_VERSION-rt1.patch.gz"
if curl --output /dev/null --silent --head --fail "$RT_PATCH_URL"; then
    wget -c "$RT_PATCH_URL"
    echo "[5/8] Áp dụng patch RT..."
    gzip -cd patch-$LATEST_VERSION-rt1.patch.gz | patch -p1
else
    echo "⚠ Không tìm thấy patch RT cho $LATEST_VERSION. Có thể RT đã tích hợp sẵn hoặc chưa phát hành."
fi

# Mở menuconfig để chọn PREEMPT_RT
echo "[6/8] Mở menuconfig, hãy bật Fully Preemptible Kernel (Real-Time)..."
make menuconfig

# Build kernel
echo "[7/8] Bắt đầu build kernel..."
make -j$(nproc)
sudo make modules_install install

# Hoàn tất
echo "[8/8] Cài đặt xong kernel RT. Hãy reboot để sử dụng."
