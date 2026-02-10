#!/usr/bin/env bash

# Get sanitized art path from playerctl
art_path=$(playerctl -p tauon metadata mpris:artUrl 2>/dev/null | 
           sed -e 's/file:\/\///' -e 's/%20/ /g')

# Use fallback if no art found
if [[ -z "$art_path" ]] || [[ ! -f "$art_path" ]]; then
    if [[ -f ~/.config/hypr/fallback_cover.png ]]; then
        cp ~/.config/hypr/fallback_cover.png /tmp/current_cover.jpg
    else
        # Create minimal fallback if missing
        magick -size 140x140 xc:none -fill gray -draw 'circle 70,70 70,20' \
               /tmp/current_cover.jpg
    fi
    exit 0
fi

# Process cover art with error handling
if ! magick "$art_path" -thumbnail 140x140^ -gravity center -extent 140x140 \
     -quality 90 /tmp/current_cover.jpg 2>/dev/null; then
    # Fallback if image processing fails
    magick -size 140x140 xc:gray -fill white -pointsize 40 \
           -gravity center -annotate +0+0 "♫" /tmp/current_cover.jpg
fi
