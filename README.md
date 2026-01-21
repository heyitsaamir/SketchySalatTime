# SketchySalatTime

A SketchyBar plugin that displays Islamic prayer times in your macOS menu bar with a beautiful popup showing all daily prayers.

## Features

- 🕌 Displays current or next prayer time in menu bar
- 📅 Shows all 6 daily times (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha)
- 🎨 Popup with translucent background and system accent color highlighting
- 🌍 Configurable location and calculation method
- ⚡ Efficient caching (fetches data once per month)
- 🎯 Automatic cleanup of old cached data

## Requirements

- [SketchyBar](https://github.com/FelixKratz/SketchyBar)
- `jq` (for JSON parsing)
- `curl` (for API requests)

Install dependencies via Homebrew:
```bash
brew install jq
```

## Installation

1. Clone this repository:
```bash
git clone https://github.com/heyitsaamir/SketchySalatTime.git
cd SketchySalatTime
```

2. Copy the plugin to your SketchyBar plugins directory:
```bash
cp salat.sh ~/.config/sketchybar/plugins/
chmod +x ~/.config/sketchybar/plugins/salat.sh
```

3. Add the plugin to your `sketchybarrc`:
```bash
sketchybar --add item salat right \
           --set salat update_freq=60 script="$PLUGIN_DIR/salat.sh" \
                 click_script="sketchybar --set salat popup.drawing=toggle" \
                 popup.background.color=0xcc000000 \
                 popup.background.corner_radius=8 \
                 popup.background.border_width=2 \
                 popup.background.border_color=0xff444444 \
                 popup.blur_radius=30 \
                 popup.background.shadow.drawing=on \
           --add item salat.fajr popup.salat \
           --set salat.fajr icon.font="Hack Nerd Font:Bold:14.0" \
                 label.font="Hack Nerd Font:Regular:14.0" \
                 icon.padding_right=10 \
                 background.drawing=off \
                 background.corner_radius=5 \
                 background.height=22 \
           --add item salat.sunrise popup.salat \
           --set salat.sunrise icon.font="Hack Nerd Font:Bold:14.0" \
                 label.font="Hack Nerd Font:Regular:14.0" \
                 icon.padding_right=10 \
                 background.drawing=off \
                 background.corner_radius=5 \
                 background.height=22 \
           --add item salat.dhuhr popup.salat \
           --set salat.dhuhr icon.font="Hack Nerd Font:Bold:14.0" \
                 label.font="Hack Nerd Font:Regular:14.0" \
                 icon.padding_right=10 \
                 background.drawing=off \
                 background.corner_radius=5 \
                 background.height=22 \
           --add item salat.asr popup.salat \
           --set salat.asr icon.font="Hack Nerd Font:Bold:14.0" \
                 label.font="Hack Nerd Font:Regular:14.0" \
                 icon.padding_right=10 \
                 background.drawing=off \
                 background.corner_radius=5 \
                 background.height=22 \
           --add item salat.maghrib popup.salat \
           --set salat.maghrib icon.font="Hack Nerd Font:Bold:14.0" \
                 label.font="Hack Nerd Font:Regular:14.0" \
                 icon.padding_right=10 \
                 background.drawing=off \
                 background.corner_radius=5 \
                 background.height=22 \
           --add item salat.isha popup.salat \
           --set salat.isha icon.font="Hack Nerd Font:Bold:14.0" \
                 label.font="Hack Nerd Font:Regular:14.0" \
                 icon.padding_right=10 \
                 background.drawing=off \
                 background.corner_radius=5 \
                 background.height=22
```

4. Reload SketchyBar:
```bash
sketchybar --reload
```

## Configuration

Open `salat.sh` and customize these variables at the top of the file:

```bash
# Your city or address
LOCATION="Renton, WA"

# Calculation method
# 0 = Shia Ithna-Ansari
# 1 = University of Islamic Sciences, Karachi
# 2 = Islamic Society of North America (ISNA)
# 3 = Muslim World League
# 4 = Umm Al-Qura University, Makkah
# 5 = Egyptian General Authority of Survey
# 7 = Institute of Geophysics, University of Tehran
CALCULATION_METHOD="2"

# School of jurisprudence
# 0 = Shafi (default)
# 1 = Hanafi
SCHOOL="1"

# Display mode
# "true" = show next upcoming prayer time
# "false" = show last passed prayer time
SHOW_NEXT="true"
```

## Usage

- **View times**: Click on the prayer time in your menu bar to show/hide the popup
- **Current prayer**: The current prayer time is highlighted with your system accent color
- **Auto-update**: Times refresh every 60 seconds automatically

## Data Source

Prayer times are fetched from the [Aladhan API](https://aladhan.com/prayer-times-api). Data is cached locally for the current and next month to minimize API calls.

## Cache

Prayer times are cached in `~/.cache/sketchybar/salat_times_YYYY-MM.json`. Old cache files are automatically cleaned up.

## License

MIT

## Credits

Inspired by [SalatTimesBar](https://github.com/heyitsaamir/SalatTimesBar) - a native macOS menu bar app for prayer times.
