#!/bin/sh

# Always try to extract cover art (if player is running)
~/.config/hypr/hyprlock_cover.sh 2>/dev/null

# Get player status
status=$(playerctl -p tauon status 2>/dev/null)

if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
    # When music is active
    artist=$(playerctl -p tauon metadata artist 2>/dev/null | sed 's/[<>]//g')
    title=$(playerctl -p tauon metadata title 2>/dev/null | sed 's/[<>]//g')    
    echo "Tauon ♫"
    echo "$title"
    echo "$artist"
else
    # When no music is playing
    echo "Tauon"
    echo "No track playing"
    echo " "
fi
