#!/usr/bin/env bash
# tmux-music.sh — toggle / pick / control nhạc qua mpv IPC
# Usage:
#   tmux-music.sh            → toggle play/stop
#   tmux-music.sh pick       → fzf picker để chọn bài
#   tmux-music.sh next       → bài kế
#   tmux-music.sh prev       → bài trước
#   tmux-music.sh pause      → pause / resume
#   tmux-music.sh vol +/-N   → tăng/giảm âm lượng N%

MUSIC_DIR="${MUSIC_DIR:-$HOME/note/music/}"
STATE_FILE="/tmp/tmux-music-state"
PID_FILE="/tmp/tmux-music-pid"
SOCKET="/tmp/mpv-socket"

# ── helpers ────────────────────────────────────────────────────────────────────

_mpv_cmd() {
  echo "{\"command\":[$1]}" | socat - "$SOCKET" 2>/dev/null
}

_is_running() { [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; }

_start_mpv() {
  local -a playlist=("$@")
  mpv \
    --no-video \
    --no-terminal \
    --really-quiet \
    --shuffle \
    --loop-playlist=inf \
    --input-ipc-server="$SOCKET" \
    "${playlist[@]}" >/dev/null 2>&1 &
  local pid=$!
  echo "$pid" > "$PID_FILE"

  # state updater
  (
    while kill -0 "$pid" 2>/dev/null; do
      sleep 2
      TRACK=$(_mpv_cmd '"get_property","media-title"' \
        | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',''))" 2>/dev/null)
      DURATION=$(_mpv_cmd '"get_property","duration"' \
        | python3 -c "import sys,json; d=json.load(sys.stdin).get('data',0); print(int(d or 0))" 2>/dev/null)
      POSITION=$(_mpv_cmd '"get_property","playback-time"' \
        | python3 -c "import sys,json; d=json.load(sys.stdin).get('data',0); print(int(d or 0))" 2>/dev/null)
      PAUSED=$(_mpv_cmd '"get_property","pause"' \
        | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',False))" 2>/dev/null)
      REMAINING=$(( DURATION - POSITION ))
      STATUS="playing"
      [[ "$PAUSED" == "True" ]] && STATUS="paused"
      echo "$STATUS|$REMAINING|$TRACK" > "$STATE_FILE"
    done
    rm -f "$PID_FILE" "$STATE_FILE" "$SOCKET"
  ) &
}

_get_files() {
  shopt -s nullglob
  local -a files=("$MUSIC_DIR"/*.{mp3,flac,ogg,opus,m4a,wav})
  shopt -u nullglob
  printf '%s\n' "${files[@]}"
}

# ── subcommands ────────────────────────────────────────────────────────────────

cmd_toggle() {
  if _is_running; then
    kill "$(cat "$PID_FILE")" 2>/dev/null
    rm -f "$PID_FILE" "$STATE_FILE" "$SOCKET"
    exit 0
  fi
  mapfile -t FILES < <(_get_files)
  if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "Không tìm thấy nhạc trong $MUSIC_DIR" >&2; exit 1
  fi
  _start_mpv "${FILES[@]}"
  echo "▶ Started (${#FILES[@]} tracks)"
}

cmd_pick() {
  mapfile -t FILES < <(_get_files)
  if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "Không tìm thấy nhạc trong $MUSIC_DIR" >&2; exit 1
  fi

  # Build display list: basename only, with index
  mapfile -t NAMES < <(printf '%s\n' "${FILES[@]}" | xargs -I{} basename {})

  # fzf picker (multi-select với TAB)
  mapfile -t CHOSEN_NAMES < <(
    printf '%s\n' "${NAMES[@]}" \
      | fzf \
          --multi \
          --prompt="🎵 Chọn bài (TAB multi-select, ENTER phát): " \
          --height=60% \
          --border=rounded \
          --color="fg:#cdd6f4,bg:#1e1e2e,hl:#89b4fa,prompt:#cba6f7,pointer:#f38ba8" \
          --preview="echo 'Bài: {}'" \
          --preview-window=up:1
  )

  [[ ${#CHOSEN_NAMES[@]} -eq 0 ]] && exit 0   # bấm ESC

  # Map tên → đường dẫn đầy đủ
  declare -A NAME_TO_PATH
  for f in "${FILES[@]}"; do
    NAME_TO_PATH["$(basename "$f")"]="$f"
  done

  local -a CHOSEN_PATHS=()
  for name in "${CHOSEN_NAMES[@]}"; do
    [[ -n "${NAME_TO_PATH[$name]}" ]] && CHOSEN_PATHS+=("${NAME_TO_PATH[$name]}")
  done

  # Dừng player cũ nếu có
  if _is_running; then
    kill "$(cat "$PID_FILE")" 2>/dev/null
    rm -f "$PID_FILE" "$STATE_FILE" "$SOCKET"
    sleep 0.4
  fi

  _start_mpv "${CHOSEN_PATHS[@]}"
  echo "▶ Đang phát ${#CHOSEN_PATHS[@]} bài đã chọn"
}

cmd_next()  { _mpv_cmd '"playlist-next"'  >/dev/null; echo "⏭ Next"; }
cmd_prev()  { _mpv_cmd '"playlist-prev"'  >/dev/null; echo "⏮ Prev"; }

cmd_pause() {
  _mpv_cmd '"cycle","pause"' >/dev/null
  # đọc trạng thái mới
  sleep 0.2
  PAUSED=$(_mpv_cmd '"get_property","pause"' \
    | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',False))" 2>/dev/null)
  [[ "$PAUSED" == "True" ]] && echo "⏸ Paused" || echo "▶ Resumed"
}

cmd_vol() {
  local delta="${1:-+5}"
  _mpv_cmd "\"add\",\"volume\",$delta" >/dev/null
  VOL=$(_mpv_cmd '"get_property","volume"' \
    | python3 -c "import sys,json; print(int(json.load(sys.stdin).get('data',0)))" 2>/dev/null)
  echo "🔊 Volume: ${VOL}%"
}

# ── dispatch ───────────────────────────────────────────────────────────────────

case "${1:-toggle}" in
  toggle|"") cmd_toggle ;;
  pick)       cmd_pick ;;
  next)       cmd_next ;;
  prev)       cmd_prev ;;
  pause)      cmd_pause ;;
  vol)        cmd_vol "${2:-+5}" ;;
  *)          echo "Unknown command: $1" >&2; exit 1 ;;
esac
