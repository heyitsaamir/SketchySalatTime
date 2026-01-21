#!/bin/sh

# Configuration - customize these values
LOCATION="Renton, WA"  # Your city/address
CALCULATION_METHOD="2" # 0=Shia Ithna-Ansari, 1=University of Islamic Sciences, Karachi
# 2=Islamic Society of North America, 3=Muslim World League
# 4=Umm Al-Qura University, Makkah, 5=Egyptian General Authority of Survey
# 7=Institute of Geophysics, University of Tehran
SCHOOL="1"          # 0=Shafi (default), 1=Hanafi
SHOW_NEXT="true"    # "true" = show next upcoming time, "false" = show last passed time

# Initialize popup (one-time setup)
if ! sketchybar --query salat.fajr &>/dev/null; then
    # Configure main item with popup styling
    sketchybar --set "$NAME" \
               click_script="sketchybar --set $NAME popup.drawing=toggle" \
               popup.background.color=0xcc000000 \
               popup.background.corner_radius=8 \
               popup.background.border_width=2 \
               popup.background.border_color=0xff444444 \
               popup.blur_radius=30 \
               popup.background.shadow.drawing=on

    # Create popup items
    sketchybar --add item salat.fajr popup."$NAME" \
               --set salat.fajr icon.font="Hack Nerd Font:Bold:14.0" \
                     label.font="Hack Nerd Font:Regular:14.0" \
                     icon.padding_right=10 \
                     background.corner_radius=5 \
                     background.height=22 \
               --add item salat.sunrise popup."$NAME" \
               --set salat.sunrise icon.font="Hack Nerd Font:Bold:14.0" \
                     label.font="Hack Nerd Font:Regular:14.0" \
                     icon.padding_right=10 \
                     background.corner_radius=5 \
                     background.height=22 \
               --add item salat.dhuhr popup."$NAME" \
               --set salat.dhuhr icon.font="Hack Nerd Font:Bold:14.0" \
                     label.font="Hack Nerd Font:Regular:14.0" \
                     icon.padding_right=10 \
                     background.corner_radius=5 \
                     background.height=22 \
               --add item salat.asr popup."$NAME" \
               --set salat.asr icon.font="Hack Nerd Font:Bold:14.0" \
                     label.font="Hack Nerd Font:Regular:14.0" \
                     icon.padding_right=10 \
                     background.corner_radius=5 \
                     background.height=22 \
               --add item salat.maghrib popup."$NAME" \
               --set salat.maghrib icon.font="Hack Nerd Font:Bold:14.0" \
                     label.font="Hack Nerd Font:Regular:14.0" \
                     icon.padding_right=10 \
                     background.corner_radius=5 \
                     background.height=22 \
               --add item salat.isha popup."$NAME" \
               --set salat.isha icon.font="Hack Nerd Font:Bold:14.0" \
                     label.font="Hack Nerd Font:Regular:14.0" \
                     icon.padding_right=10 \
                     background.corner_radius=5 \
                     background.height=22
fi

# Cache directory
CACHE_DIR="$HOME/.cache/sketchybar"
mkdir -p "$CACHE_DIR"

# Get current and next month info
CURRENT_MONTH=$(date +%-m)
CURRENT_YEAR=$(date +%Y)
CURRENT_DAY=$(date +%-d)

# Calculate next month
if [ "$CURRENT_MONTH" -eq 12 ]; then
    NEXT_MONTH=1
    NEXT_YEAR=$((CURRENT_YEAR + 1))
else
    NEXT_MONTH=$((CURRENT_MONTH + 1))
    NEXT_YEAR=$CURRENT_YEAR
fi

# Cache file paths
CURRENT_MONTH_CACHE="$CACHE_DIR/salat_times_${CURRENT_YEAR}-$(printf "%02d" $CURRENT_MONTH).json"
NEXT_MONTH_CACHE="$CACHE_DIR/salat_times_${NEXT_YEAR}-$(printf "%02d" $NEXT_MONTH).json"

# Cleanup old cache files (keep only current and next month)
find "$CACHE_DIR" -name "salat_times_*.json" -type f | while read -r file; do
    if [ "$file" != "$CURRENT_MONTH_CACHE" ] && [ "$file" != "$NEXT_MONTH_CACHE" ]; then
        rm -f "$file"
    fi
done

# Function to fetch prayer times from Aladhan API for a given month
fetch_prayer_times() {
    local month=$1
    local year=$2
    local cache_file=$3

    # URL encode the location
    local encoded_location=$(echo "$LOCATION" | sed 's/ /%20/g')

    # Fetch prayer times for the entire month
    curl -s "https://api.aladhan.com/v1/calendarByAddress/${year}/${month}?address=${encoded_location}&method=${CALCULATION_METHOD}&school=${SCHOOL}" >"$cache_file"
}

# Fetch current month if cache doesn't exist
if [ ! -f "$CURRENT_MONTH_CACHE" ]; then
    fetch_prayer_times "$CURRENT_MONTH" "$CURRENT_YEAR" "$CURRENT_MONTH_CACHE"
fi

# Fetch next month if cache doesn't exist
if [ ! -f "$NEXT_MONTH_CACHE" ]; then
    fetch_prayer_times "$NEXT_MONTH" "$NEXT_YEAR" "$NEXT_MONTH_CACHE"
fi

# Check if cache files exist
if [ ! -f "$CURRENT_MONTH_CACHE" ]; then
    sketchybar --set "$NAME" icon="🕌" label="Error"
    exit 1
fi

# Extract today's prayer times using jq
# Array is 0-indexed, so day 1 is at index 0
DAY_INDEX=$((CURRENT_DAY - 1))

# Extract times and remove timezone suffix (e.g., " (PST)")
FAJR=$(jq -r ".data[$DAY_INDEX].timings.Fajr" "$CURRENT_MONTH_CACHE" | cut -d' ' -f1)
SUNRISE=$(jq -r ".data[$DAY_INDEX].timings.Sunrise" "$CURRENT_MONTH_CACHE" | cut -d' ' -f1)
DHUHR=$(jq -r ".data[$DAY_INDEX].timings.Dhuhr" "$CURRENT_MONTH_CACHE" | cut -d' ' -f1)
ASR=$(jq -r ".data[$DAY_INDEX].timings.Asr" "$CURRENT_MONTH_CACHE" | cut -d' ' -f1)
MAGHRIB=$(jq -r ".data[$DAY_INDEX].timings.Maghrib" "$CURRENT_MONTH_CACHE" | cut -d' ' -f1)
ISHA=$(jq -r ".data[$DAY_INDEX].timings.Isha" "$CURRENT_MONTH_CACHE" | cut -d' ' -f1)

# Get current timestamp
CURRENT_TIMESTAMP=$(date +%s)

# Convert HH:MM to timestamp for today
time_to_timestamp() {
    local time_str=$1
    date -j -f "%Y-%m-%d %H:%M" "$(date +%Y-%m-%d) $time_str" +%s 2>/dev/null
}

# Convert times to timestamps
FAJR_TS=$(time_to_timestamp "$FAJR")
SUNRISE_TS=$(time_to_timestamp "$SUNRISE")
DHUHR_TS=$(time_to_timestamp "$DHUHR")
ASR_TS=$(time_to_timestamp "$ASR")
MAGHRIB_TS=$(time_to_timestamp "$MAGHRIB")
ISHA_TS=$(time_to_timestamp "$ISHA")

# Find the current or next time marker
ICON="🕌"
TIME_NAME=""
TIME_VALUE=""
IS_NEXT=false

# Determine which time to show based on current time
if [ $CURRENT_TIMESTAMP -ge $ISHA_TS ]; then
    if [ "$SHOW_NEXT" = "true" ]; then
        # After Isha, next is tomorrow's Fajr (for now show Fajr)
        TIME_NAME="Fajr"
        TIME_VALUE="$FAJR"
        ICON="󰖜"
        IS_NEXT=true
    else
        TIME_NAME="Isha"
        TIME_VALUE="$ISHA"
        ICON="󰽥"
        IS_NEXT=false
    fi
elif [ $CURRENT_TIMESTAMP -ge $MAGHRIB_TS ]; then
    if [ "$SHOW_NEXT" = "true" ]; then
        TIME_NAME="Isha"
        TIME_VALUE="$ISHA"
        ICON="󰽥"
        IS_NEXT=true
    else
        TIME_NAME="Maghrib"
        TIME_VALUE="$MAGHRIB"
        ICON="󰖚"
        IS_NEXT=false
    fi
elif [ $CURRENT_TIMESTAMP -ge $ASR_TS ]; then
    if [ "$SHOW_NEXT" = "true" ]; then
        TIME_NAME="Maghrib"
        TIME_VALUE="$MAGHRIB"
        ICON="󰖚"
        IS_NEXT=true
    else
        TIME_NAME="Asr"
        TIME_VALUE="$ASR"
        ICON="󰖙"
        IS_NEXT=false
    fi
elif [ $CURRENT_TIMESTAMP -ge $DHUHR_TS ]; then
    if [ "$SHOW_NEXT" = "true" ]; then
        TIME_NAME="Asr"
        TIME_VALUE="$ASR"
        ICON="󰖙"
        IS_NEXT=true
    else
        TIME_NAME="Dhuhr"
        TIME_VALUE="$DHUHR"
        ICON="󰖙"
        IS_NEXT=false
    fi
elif [ $CURRENT_TIMESTAMP -ge $SUNRISE_TS ]; then
    if [ "$SHOW_NEXT" = "true" ]; then
        TIME_NAME="Dhuhr"
        TIME_VALUE="$DHUHR"
        ICON="󰖙"
        IS_NEXT=true
    else
        TIME_NAME="Sunrise"
        TIME_VALUE="$SUNRISE"
        ICON="󰖜"
        IS_NEXT=false
    fi
elif [ $CURRENT_TIMESTAMP -ge $FAJR_TS ]; then
    if [ "$SHOW_NEXT" = "true" ]; then
        TIME_NAME="Sunrise"
        TIME_VALUE="$SUNRISE"
        ICON="󰖜"
        IS_NEXT=true
    else
        TIME_NAME="Fajr"
        TIME_VALUE="$FAJR"
        ICON="󰖜"
        IS_NEXT=false
    fi
else
    # Before Fajr, show Fajr as next
    TIME_NAME="Fajr"
    TIME_VALUE="$FAJR"
    ICON="󰖜"
    IS_NEXT=true
fi

# Format the label
LABEL="$TIME_NAME $TIME_VALUE"

# Update sketchybar main item
sketchybar --set "$NAME" icon="$ICON" label="$LABEL"

# Determine which prayer time is current (not next)
CURRENT_PRAYER=""
if [ $CURRENT_TIMESTAMP -ge $ISHA_TS ]; then
    CURRENT_PRAYER="isha"
elif [ $CURRENT_TIMESTAMP -ge $MAGHRIB_TS ]; then
    CURRENT_PRAYER="maghrib"
elif [ $CURRENT_TIMESTAMP -ge $ASR_TS ]; then
    CURRENT_PRAYER="asr"
elif [ $CURRENT_TIMESTAMP -ge $DHUHR_TS ]; then
    CURRENT_PRAYER="dhuhr"
elif [ $CURRENT_TIMESTAMP -ge $SUNRISE_TS ]; then
    CURRENT_PRAYER="sunrise"
elif [ $CURRENT_TIMESTAMP -ge $FAJR_TS ]; then
    CURRENT_PRAYER="fajr"
fi

# Reset all popup items to default styling
sketchybar --set salat.fajr background.drawing=off \
           --set salat.sunrise background.drawing=off \
           --set salat.dhuhr background.drawing=off \
           --set salat.asr background.drawing=off \
           --set salat.maghrib background.drawing=off \
           --set salat.isha background.drawing=off

# Update popup items with all prayer times
sketchybar --set salat.fajr icon="󰖜" label="Fajr     $FAJR" \
           --set salat.sunrise icon="󰖜" label="Sunrise  $SUNRISE" \
           --set salat.dhuhr icon="󰖙" label="Dhuhr    $DHUHR" \
           --set salat.asr icon="󰖙" label="Asr      $ASR" \
           --set salat.maghrib icon="󰖚" label="Maghrib  $MAGHRIB" \
           --set salat.isha icon="󰽥" label="Isha     $ISHA"

# Highlight the current prayer time with system accent color
if [ -n "$CURRENT_PRAYER" ]; then
    # Get system accent color (fallback to blue if not available)
    ACCENT_COLOR=$(defaults read -g AppleAccentColor 2>/dev/null || echo "4")

    # Map accent color to hex (with transparency)
    case "$ACCENT_COLOR" in
        "-1") COLOR="0x50999999" ;;  # Graphite
        "0")  COLOR="0x50ff3b30" ;;  # Red
        "1")  COLOR="0x50ff9500" ;;  # Orange
        "2")  COLOR="0x50ffcc00" ;;  # Yellow
        "3")  COLOR="0x5034c759" ;;  # Green
        "4")  COLOR="0x50007aff" ;;  # Blue (default)
        "5")  COLOR="0x50af52de" ;;  # Purple
        "6")  COLOR="0x50ff2d55" ;;  # Pink
        *)    COLOR="0x50007aff" ;;  # Default Blue
    esac

    sketchybar --set "salat.$CURRENT_PRAYER" \
        background.drawing=on \
        background.color="$COLOR" \
        background.corner_radius=5 \
        background.height=22 \
        background.padding_left=5 \
        background.padding_right=5
fi
