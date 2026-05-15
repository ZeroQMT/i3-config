#!/usr/bin/env bash
# ~/.config/tmux/scripts/status.sh
# Được gọi mỗi 5 giây bởi tmux (status-interval 5)

SEP="#[fg=#2A2A37]│#[default]"

# ── Nhạc ────────────────────────────────────────────────────────────────────
MUSIC_STATE_FILE="/tmp/tmux-music-state"
MUSIC_SEG=""
if [[ -f "$MUSIC_STATE_FILE" ]]; then
  IFS='|' read -r STATUS DEADLINE TRACK < "$MUSIC_STATE_FILE"
  if [[ "$STATUS" == "playing" ]]; then
    NOW=$(date +%s)
    REMAINING=$(( DEADLINE - NOW ))
    if [[ $REMAINING -gt 0 ]]; then
      MM=$(( REMAINING / 60 ))
      SS=$(( REMAINING % 60 ))
      # Cắt tên bài nếu quá dài
      SHORT_TRACK="${TRACK:0:22}"
      [[ "${#TRACK}" -gt 22 ]] && SHORT_TRACK="${SHORT_TRACK}…"
      MUSIC_SEG="#[fg=#98BB6C]▶ #[fg=#76946A]${SHORT_TRACK} #[fg=#54546D]${MM}:$(printf '%02d' $SS)#[default] ${SEP} "
    fi
  fi
fi

# ── Thời tiết (đọc cache) ────────────────────────────────────────────────────
WEATHER_SEG=""
CACHE="/tmp/tmux-weather-cache"
if [[ -f "$CACHE" ]]; then
  # Refresh cache nếu cũ hơn 15 phút
  CACHE_AGE=$(( $(date +%s) - $(stat -c %Y "$CACHE" 2>/dev/null || echo 0) ))
  if [[ $CACHE_AGE -gt 900 ]]; then
    ~/.config/tmux/scripts/weather-cache.sh &
  fi
  WEATHER=$(cat "$CACHE")
  WEATHER_SEG="#[fg=#7FB4CA]🌥️${WEATHER}#[default] ${SEP} "
fi

# ── Todo ─────────────────────────────────────────────────────────────────────
TODO_SEG=""
TODO_DATA=$(~/.config/tmux/scripts/todo-parse.sh 2>/dev/null)
UNDONE="${TODO_DATA%%|*}"
DONE="${TODO_DATA##*|}"
if [[ "$UNDONE" =~ ^[0-9]+$ && "$UNDONE" -gt 0 ]]; then
  TODO_SEG="#[fg=#E6C384]✓ ${UNDONE} job#[default] ${SEP} "
elif [[ "$UNDONE" == "0" && "$DONE" =~ ^[0-9]+$ && "$DONE" -gt 0 ]]; then
  TODO_SEG="#[fg=#76946A]✓ clean#[default] ${SEP} "
fi

# ── OFF indicator ─────────────────────────────────────────────────────────────
OFF_SEG=""
[[ "$(tmux show-option -qv key-table)" == "off" ]] && \
  OFF_SEG="#[fg=#A3D4F5,bg=#2D4F67] [OFF] #[default]${SEP} "

echo " ${OFF_SEG}${MUSIC_SEG}${WEATHER_SEG}${TODO_SEG}${TIME_SEG}"
