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

echo -e "\n======================================="
echo -e "\t${CYAN}BẮT ĐẦU SETUP HỆ THỐNG${NC}"
echo -e "======================================="

# --- Bắt đầu cài đặt ---
sudo apt update -q # Chạy im lặng một chút

sudo apt install -y -q atool
log_status "atool"

sudo apt install -y -q wget
log_status "wget"

# Thử thêm một gói bị lỗi để test bảng tổng kết
sudo apt install -y package-khong-ton-tai
log_status "Test lỗi"

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

