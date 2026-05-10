#!/bin/bash
# Screenshot script cho i3wm
# Dependencies: maim, xclip, libnotify (dunst)

SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILE="$SAVE_DIR/screenshot_$TIMESTAMP.png"

MODE="${1:-full}"  # full | region | window

notify() {
    notify-send "📸 Screenshot" "$1" -t 2000 -i "$FILE" 2>/dev/null
}

case "$MODE" in
    full)
        maim "$FILE"
        xclip -selection clipboard -t image/png < "$FILE"
        notify "Toàn màn hình → $FILE"
        ;;

    region)
        # Click và kéo để chọn vùng
        maim --select "$FILE"
        if [ $? -eq 0 ]; then
            xclip -selection clipboard -t image/png < "$FILE"
            notify "Vùng chọn → $FILE"
        fi
        ;;

    window)
        # Chụp cửa sổ đang focus
        WINDOW_ID=$(xdotool getactivewindow)
        maim --window "$WINDOW_ID" "$FILE"
        xclip -selection clipboard -t image/png < "$FILE"
        notify "Cửa sổ active → $FILE"
        ;;
esac
