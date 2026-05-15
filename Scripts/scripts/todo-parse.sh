#!/usr/bin/env bash
# Đọc Daily Note hôm nay trong Obsidian vault
# Điều chỉnh VAULT_DIR và DATE_FORMAT cho khớp cấu hình Obsidian của bạn

VAULT_DIR="${OBSIDIAN_VAULT:-$HOME/note/}"
TODAY=$(date '+%Y-%m-%d')

# Tìm daily note — thử nhiều pattern phổ biến
NOTE=""
for PATTERN in \
  "$VAULT_DIR/Daily Notes/$TODAY.md" \
  "$VAULT_DIR/daily/$TODAY.md" \
  "$VAULT_DIR/Journal/$TODAY.md" \
  "$VAULT_DIR/$TODAY.md"; do
  [[ -f "$PATTERN" ]] && NOTE="$PATTERN" && break
done

if [[ -z "$NOTE" ]]; then
  echo "0"
  exit 0
fi

# Đếm số task chưa xong trong ngày hôm nay
UNDONE=$(grep -c '^\s*- \[ \]' "$NOTE" 2>/dev/null || echo 0)
DONE=$(grep -c '^\s*- \[x\]' "$NOTE" 2>/dev/null || echo 0)

echo "${UNDONE}|${DONE}"
