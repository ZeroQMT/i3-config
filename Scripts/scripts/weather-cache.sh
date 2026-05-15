#!/usr/bin/env bash
# Chạy bằng cron hoặc systemd timer: */15 * * * * ~/.config/tmux/scripts/weather-cache.sh
CACHE_FILE="/tmp/tmux-weather-cache"
CITY="${TMUX_WEATHER_CITY:-Hanoi}"

# Lấy dữ liệu thời tiết gọn cho status bar
WEATHER=$(curl -sf --max-time 5 \
  "https://wttr.in/${CITY}?format=%t" 2>/dev/null)

if [[ -n "$WEATHER" ]]; then
  echo "$WEATHER" > "$CACHE_FILE"

  # Forecast chi tiết cho popup
  curl -sf --max-time 5 \
    "https://wttr.in/${CITY}?format=%l:+%t" \
    > "/tmp/tmux-weather-detail" 2>/dev/null
fi
