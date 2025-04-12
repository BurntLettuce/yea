#!/bin/sh

# Debugging: Log script execution
echo "Running script with argument: $1" > /tmp/hypr_app_launcher.log

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

# Check if window exists and focus it
if hyprctl clients | grep -q "class: $CLASS"; then
    echo "Window exists, focusing..." >> /tmp/hypr_app_launcher.log
    hyprctl dispatch focuswindow "class:$CLASS"
else
    echo "Launching application..." >> /tmp/hypr_app_launcher.log
    $CMD &
    PID=$!
    
    # Wait for window to appear with timeout
    for i in $(seq 1 20); do
        if hyprctl clients | grep -q "class: $CLASS"; then
            echo "Window detected, focusing..." >> /tmp/hypr_app_launcher.log
            hyprctl dispatch focuswindow "class:$CLASS"
            exit 0
        fi
        sleep 0.25
    done
    
    echo "Timeout reached, window not found" >> /tmp/hypr_app_launcher.log
    # Focus anyway in case the window appeared but we missed it
    hyprctl dispatch focuswindow "class:$CLASS"
fi
