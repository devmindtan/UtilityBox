#!/bin/bash

# --- Đoạn này chỉ dành cho test ---
if ! command -v sudo &> /dev/null; then
    sudo() { "$@"; }
fi
# --- Đoạn này chỉ dành cho test ---


# Khai báo màu sắc để code sạch sẽ hơn
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

echo "--- Đang cài đặt JetBrains Toolbox ---"

# 1. Tải bản mới nhất (không cần ghi số phiên bản)
wget -O jetbrains-toolbox.tar.gz "https://data.services.jetbrains.com/products/download?code=TBA&platform=linux"

# 2. Giải nén
mkdir -p jetbrains-toolbox-temp
tar -xzf jetbrains-toolbox.tar.gz -C jetbrains-toolbox-temp --strip-components=1

# 3. Cài đặt vào /opt
sudo mkdir -p /opt/jetbrains-toolbox
sudo mv jetbrains-toolbox-temp/bin /opt/jetbrains-toolbox/
sudo chmod +x /opt/jetbrains-toolbox/bin/jetbrains-toolbox

# 4. Dọn dẹp file tạm
rm -rf jetbrains-toolbox.tar.gz jetbrains-toolbox-temp

log_status "jetbrains-toolbox"

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
