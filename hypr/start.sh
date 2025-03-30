#!/usr/bin/env bash

swww-daemon &
current_hour=$(date +%H)
if [[ "$current_hour" -ge 0 && "$current_hour" -lt 12 ]]; then
    # From 00:00 to 11:59
    swww img ~/wallpapers/wallpaper2.jpg &
else
    # From 12:00 to 23:59
    swww img ~/wallpapers/wallpaper1.jpg &
fi

nm-applet --indicator &

waybar &
hypridle &

dunst
