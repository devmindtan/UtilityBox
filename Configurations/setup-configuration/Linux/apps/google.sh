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

echo "--- Đang cài đặt Google Chrome ---"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-fast install -y -q ./google-chrome-stable_current_amd64.deb
log_status "google-chrome-stable"

# Dọn dẹp file tạm
rm -rf google-chrome-stable_current_amd64.deb

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
