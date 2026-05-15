#!/usr/bin/env bash
# Hiện chi tiết đầy đủ trong popup

echo ""

# ── Nhạc ────────────────────────────────────────────────────────────────────
STATE_FILE="/tmp/tmux-music-state"
if [[ -f "$STATE_FILE" ]]; then
  IFS='|' read -r STATUS DEADLINE TRACK < "$STATE_FILE"
  NOW=$(date +%s)
  REMAINING=$(( DEADLINE - NOW ))
  ELAPSED=$(( (DEADLINE - NOW) ))  # sẽ tính ngược từ duration
  MM=$(( REMAINING / 60 )); SS=$(( REMAINING % 60 ))
  printf "\033[32m♪ NHẠC\033[0m\n"
  printf "  Đang chạy: \033[36m%s\033[0m\n" "$TRACK"
  printf "  Còn lại:   \033[33m%d:%02d\033[0m phút\n\n" "$MM" "$SS"
else
  printf "\033[90m♪ Không có nhạc đang chạy\033[0m\n"
  printf "  Bật nhạc: \033[36mPrefix + m\033[0m\n\n"
fi

# ── Thời tiết ───────────────────────────────────────────────────────────────
printf "\033[34mTHỜI TIẾT\033[0m\n"
DETAIL="/tmp/tmux-weather-detail"
if [[ -f "$DETAIL" ]]; then
  while IFS= read -r line; do
    printf "  %s\n" "$line"
  done < "$DETAIL"
else
  printf "  \033[90mChưa có dữ liệu — đang tải...\033[0m\n"
  ~/.config/tmux/scripts/weather-cache.sh &
fi
echo ""

# ── Todo ─────────────────────────────────────────────────────────────────────
VAULT_DIR="${OBSIDIAN_VAULT:-$HOME/note/}"
TODAY=$(date '+%Y-%m-%d')
NOTE=""
for PATTERN in \
  "$VAULT_DIR/Daily Notes/$TODAY.md" \
  "$VAULT_DIR/daily/$TODAY.md" \
  "$VAULT_DIR/Journal/$TODAY.md"; do
  [[ -f "$PATTERN" ]] && NOTE="$PATTERN" && break
done

printf "\033[33m✓ VIỆC CẦN LÀM — %s\033[0m\n" "$TODAY"
if [[ -n "$NOTE" ]]; then
  grep -E '^\s*- \[[ x]\]' "$NOTE" | while IFS= read -r line; do
    if echo "$line" | grep -q '\[x\]'; then
      printf "  \033[90m✓ %s\033[0m\n" "$(echo "$line" | sed 's/.*\[.\] //')"
    else
      printf "  \033[33m○ %s\033[0m\n" "$(echo "$line" | sed 's/.*\[ \] //')"
    fi
  done
else
  printf "  \033[90mKhông tìm thấy daily note hôm nay\033[0m\n"
fi

echo ""
printf "\033[90mNhấn q hoặc Ctrl+C để đóng\033[0m\n"
