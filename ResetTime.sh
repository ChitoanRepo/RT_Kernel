# 1. Cập nhật hệ thống và cài lại ntpsec
sudo apt update
sudo apt install --reinstall ntpsec -y

# 2. Bỏ mask timer (nếu có)
sudo systemctl unmask ntpsec.timer

# 3. Kích hoạt service và timer
sudo systemctl enable ntpsec.service --now
sudo systemctl enable ntpsec.timer --now

# 4. Đồng bộ UTC ngay lập tức
sudo ntpsec -gq

# 5. Kiểm tra trạng thái NTPsec và thời gian
systemctl status ntpsec.service
systemctl status ntpsec.timer
timedatectl status
