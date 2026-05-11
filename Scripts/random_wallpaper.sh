#!/bin/bash
# ============================================
# random_wallpaper.sh
# Đổi ảnh nền ngẫu nhiên từ một thư mục
# ============================================

# --- CẤU HÌNH ---
WALLPAPER_DIR="$HOME/Wall/core/"
FEH_MODE="--bg-fill"   # Chế độ hiển thị: --bg-fill | --bg-scale | --bg-center | --bg-tile | --bg-max

# --- KIỂM TRA THƯ MỤC ---
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Lỗi: Thư mục '$WALLPAPER_DIR' không tồn tại."
    exit 1
fi

# --- LẤY DANH SÁCH ẢNH ---
# Hỗ trợ các định dạng phổ biến: jpg, jpeg, png, gif, bmp, webp
mapfile -t IMAGES < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
       -o -iname "*.gif" -o -iname "*.bmp"  -o -iname "*.webp" \))

# --- KIỂM TRA CÓ ẢNH KHÔNG ---
if [ ${#IMAGES[@]} -eq 0 ]; then
    echo "Lỗi: Không tìm thấy ảnh nào trong '$WALLPAPER_DIR'."
    exit 1
fi

# --- CHỌN NGẪU NHIÊN ---
RANDOM_INDEX=$(( RANDOM % ${#IMAGES[@]} ))
SELECTED="${IMAGES[$RANDOM_INDEX]}"

# --- ĐẶT LÀM ẢNH NỀN ---
feh $FEH_MODE "$SELECTED"

echo "Wallpaper: $(basename "$SELECTED")"
