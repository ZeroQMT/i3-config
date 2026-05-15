#!/usr/bin/env bash

MUSIC_DIR="${1:-$HOME/Music}"
STATE_FILE="/tmp/tmux-music-state"
PID_FILE="/tmp/tmux-music-pid"
SOCKET="/tmp/mpv-socket"

# Toggle OFF nếu đang chạy
if [[ -f "$PID_FILE" ]]; then
  kill "$(cat "$PID_FILE")" 2>/dev/null
  rm -f "$PID_FILE" "$STATE_FILE" "$SOCKET"
  exit 0
fi

# Lấy file nhạc
shopt -s nullglob
FILES=("$MUSIC_DIR"/*.{mp3,flac,ogg,opus,m4a,wav})

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "Không tìm thấy nhạc trong $MUSIC_DIR"
  exit 1
fi

# Chạy mpv nền hoàn toàn
mpv \
  --no-video \
  --no-terminal \
  --really-quiet \
  --shuffle \
  --loop-playlist=inf \
  --input-ipc-server="$SOCKET" \
  "${FILES[@]}" >/dev/null 2>&1 &

MPV_PID=$!
echo "$MPV_PID" > "$PID_FILE"

# Updater background
(
  while kill -0 "$MPV_PID" 2>/dev/null; do
    sleep 2

    TRACK=$(echo '{"command":["get_property","media-title"]}' \
      | socat - "$SOCKET" 2>/dev/null \
      | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',''))" 2>/dev/null)

    DURATION=$(echo '{"command":["get_property","duration"]}' \
      | socat - "$SOCKET" 2>/dev/null \
      | python3 -c "import sys,json; d=json.load(sys.stdin).get('data',0); print(int(d or 0))" 2>/dev/null)

    POSITION=$(echo '{"command":["get_property","playback-time"]}' \
      | socat - "$SOCKET" 2>/dev/null \
      | python3 -c "import sys,json; d=json.load(sys.stdin).get('data',0); print(int(d or 0))" 2>/dev/null)

    REMAINING=$(( DURATION - POSITION ))

    echo "playing|$REMAINING|$TRACK" > "$STATE_FILE"
  done

  rm -f "$PID_FILE" "$STATE_FILE" "$SOCKET"
) &

echo "started"
