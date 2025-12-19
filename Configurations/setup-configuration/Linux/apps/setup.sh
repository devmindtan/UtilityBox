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

echo "--- Đang cập nhật hệ thống ---"
sudo apt update -q

echo "--- Đang chuẩn bị môi trường nền ---"
echo "tzdata tzdata/Areas select Asia" | sudo debconf-set-selections
echo "tzdata tzdata/Zones/Asia select Ho_Chi_Minh" | sudo debconf-set-selections
export DEBIAN_FRONTEND=noninteractive


echo "--- Đang cài đặt các công cụ cơ bản ---"
sudo apt install -y -q curl
log_status="curl"

sudo apt install -y -q gpg
log_status="gpg"

echo "--- Đang cài đặt apt-fast ---"
echo deb [signed-by=/etc/apt/keyrings/apt-fast.gpg] http://ppa.launchpad.net/apt-fast/stable/ubuntu focal main | sudo tee -a /etc/apt/sources.list.d/apt-fast.list
mkdir -p /etc/apt/keyrings
curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xBC5934FD3DEBD4DAEA544F791E2824A7F22B44BD" | sudo gpg --dearmor -o /etc/apt/keyrings/apt-fast.gpg
sudo apt update -q

echo "apt-fast apt-fast/aptmanager select apt" | sudo debconf-set-selections
echo "apt-fast apt-fast/maxdownloads string 5" | sudo debconf-set-selections
echo "apt-fast apt-fast/dlconfirm boolean false" | sudo debconf-set-selections
sudo apt install -y -q apt-fast

echo "--- Đang cài đặt các công cụ cần thiết để thêm PPA và cấu hình hệ thống ---"
sudo apt install -y -q software-properties-common 
log_status "software-properties-common"

sudo apt install -y -q dconf-cli
log_status "dconf-cli"

echo "--- Đang cài đặt các công cụ cơ bản ---"
sudo apt-fast install -y -q wget 
log_status "wget"

sudo apt-fast install -y -q git
log_status "git"

sudo apt-fast install -y -q build-essential 
log_status "build-essential"

sudo apt-fast install -y -q p7zip-full 
log_status "p7zip-full "

sudo apt-fast install -y -q unrar 
log_status "unrar"

sudo apt-fast install -y -q atool 
log_status "atool"

sudo apt-fast install -y -q ca-certificates
log_status "ca-certificates"

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
        printf "│ %-30.30s │ %b           │\n" "$task" "$colored_res"
    fi
done
echo "└──────────────────────────────┴─────────────────┘"
