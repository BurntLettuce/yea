#!/usr/bin/env bash

# Directory for album art
ART_DIR="/tmp/hyprlock_art"
mkdir -p "$ART_DIR"

# Final art path (atomic write)
TEMP_ART="$ART_DIR/.temp_cover.jpg"
FINAL_ART="$ART_DIR/current_cover.jpg"

# Get current art URL
current_art_url=$(playerctl -p tauon metadata mpris:artUrl 2>/dev/null)

# Process album art
{
    # Delete temp file if it exists
    rm -f "$TEMP_ART"

    if [[ -n "$current_art_url" ]]; then
        # Convert URL to filesystem path
        ART_FILE=$(sed -e 's/file:\/\///' -e 's/%20/ /g' <<< "$current_art_url")
        
        if [[ -f "$ART_FILE" ]]; then
            # Resize and convert to TEMP file
            convert "$ART_FILE" \
                    -thumbnail 140x140^ \
                    -gravity center \
                    -extent 140x140 \
                    -quality 90 \
                    "$TEMP_ART" 2>/dev/null
        fi
    fi

    # Fallback if no art found
    if [[ ! -f "$TEMP_ART" ]]; then
        convert -size 140x140 xc:none \
                -fill gray \
                "$TEMP_ART" 2>/dev/null
    fi

    # Atomic Move
    mv -f "$TEMP_ART" "$FINAL_ART"

    # Output the final art path
    echo "$FINAL_ART"
} >/dev/null 2>&1

# Output music info
echo -e \
"󰝚 $(playerctl -p tauon metadata album 2>/dev/null || echo 'No album')\n" \
"󰎈 $(playerctl -p tauon metadata artist 2>/dev/null || echo 'No artist')\n" \
"󰎄 $(playerctl -p tauon metadata title 2>/dev/null || echo 'No title')"
