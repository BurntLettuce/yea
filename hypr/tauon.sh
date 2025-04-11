#!/bin/sh
case "$1" in
    "tauon")
        CLASS="tauonmb"
        CMD="tauon"
        ;;
    "discord")
        CLASS="discord"
        CMD="discord"
        ;;
    *)
        echo "Usage: $0 [tauon|discord]"
        exit 1
        ;;
esac

hyprctl dispatch focuswindow "class:$CLASS" 2>/dev/null || {
    $CMD &
    sleep 0.5
    hyprctl dispatch focuswindow "class:$CLASS"
}
