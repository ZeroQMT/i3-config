#!/usr/bin/env bash
# ~/.config/tmux/scripts/music-status.sh
# In ra fragment cho status-right, ví dụ: " ▶ Tên bài "

STATE_FILE="/tmp/tmux-music-state"

if [[ ! -f "$STATE_FILE" ]]; then
  exit 0   # không in gì khi không chạy
fi

IFS='|' read -r status remaining track < "$STATE_FILE"

[[ -z "$track" ]] && exit 0

# Icon theo trạng thái
case "$status" in
  playing) icon="▶" ;;
  paused)  icon="⏸" ;;
  *)       exit 0 ;;
esac

# Cắt tên bài nếu quá dài
short="${track:0:28}"
[[ ${#track} -gt 28 ]] && short="${short}…"

# Format thời gian còn lại
mins=$(( remaining / 60 ))
secs=$(( remaining % 60 ))
time_left=$(printf "%d:%02d" "$mins" "$secs")

printf "#[fg=#cba6f7] %s #[fg=#cdd6f4]%s #[fg=#6c7086]-%s " \
  "$icon" "$short" "$time_left"
