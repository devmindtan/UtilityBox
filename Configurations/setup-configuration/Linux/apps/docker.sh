#!/bin/bash
# --- Đoạn này chỉ dành cho test nên không cần để tâm ---
if ! command -v sudo &> /dev/null; then
    sudo() { "$@"; }
fi
# --- Đoạn này chỉ dành cho test nên không cần để tâm ---

# Khai báo màu sắc
GREEN='\e[32m'
RED='\e[31m'
CYAN='\e[36m'
NC='\e[0m' # No Color

# Khởi tạo mảng lưu kết quả
declare -A RESULTS

# Hàm kiểm tra và lưu trạng thái
log_status() {
    [ $? -eq 0 ] && RESULTS[$1]="SUCCESS" || RESULTS[$1]="ERROR"
}

echo "--- Đang cài đặt Docker --- "
echo "Đang tiến hành dọn dẹp...."
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)
echo "Bắt đầu chuẩn bị các phần dependencies cần thiết và cài đặt Docker Engine..."
sudo apt update -q
# Add Docker's official GPG key:
sudo install -y -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt update -q

echo "Bắt đầu cài đặt tất cả PLUGIN cần thiết..."
sudo apt-fast install -y -q docker-ce
log_status "docker-ce"

sudo apt-fast install -y -q docker-ce-cli
log_status "docker-ce-cli"

sudo apt-fast install -y -q containerd.io
log_status "containerd.io"

sudo apt-fast install -y -q docker-buildx-plugin
log_status "docker-buildx-plugin"

sudo apt-fast install -y -q docker-compose-plugin
log_status "docker-compose-plugin"

# --- BẢNG TỔNG KẾT ---
echo "┌────────────────────────────────────────────────┐"
echo -e "│\t\t     ${CYAN}SUMMARY${NC}        \t\t │"
# Dùng echo -e cho dòng tiêu đề để đảm bảo printf không tính sai độ dài ký tự màu
echo "├──────────────────────────────┬─────────────────┤"
printf "│ %-29s │ %-18s │\n" "Tên Package" "Trạng thái"
echo "├──────────────────────────────┼─────────────────┤"
for task in "${!RESULTS[@]}"; do
    raw_res=${RESULTS[$task]}
    
    # Định dạng màu sắc dựa trên kết quả thuần túy
    if [ "$raw_res" == "SUCCESS" ]; then
        # SUCCESS (7 ký tự)
        colored_res="${GREEN}SUCCESS${NC}"
        # Cần in thêm 8 khoảng trắng để đủ 15 ký tự của cột
        printf "│ %-28s │ %b         │\n" "$task" "$colored_res"
    else
        # ERROR (5 ký tự)
        colored_res="${RED}ERROR${NC}"
        # Cần in thêm 10 khoảng trắng để đủ 15 ký tự của cột
        printf "│ %-30s │ %b           │\n" "$task" "$colored_res"
    fi
done
echo "└──────────────────────────────┴─────────────────┘"
