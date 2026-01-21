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

3. Configure your location by editing `~/.config/sketchybar/plugins/salat.sh` (lines 4-10)

4. Add to your `sketchybarrc`:
```bash
sketchybar --add item salat right \
           --set salat update_freq=60 script="$PLUGIN_DIR/salat.sh"
```

5. Reload SketchyBar:
```bash
sketchybar --reload
```

The plugin will automatically set up its popup on first run!

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
