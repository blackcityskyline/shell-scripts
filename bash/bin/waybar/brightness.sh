#!/usr/bin/env bash

# Brightness module for Waybar

# Get brightness info
brightness_percentage=0

# Try brightnessctl first
if command -v brightnessctl &>/dev/null; then
  brightness_info=$(brightnessctl info 2>/dev/null)
  brightness_percentage=$(echo "$brightness_info" | grep -oP "\(\K\d+(?=%)\)" | head -1 2>/dev/null || echo "0")
fi

# Fallback to sysfs
if [ -z "$brightness_percentage" ] || ! [[ "$brightness_percentage" =~ ^[0-9]+$ ]]; then
  if [ -d /sys/class/backlight ]; then
    device=$(ls /sys/class/backlight | head -1 2>/dev/null)
    if [ -n "$device" ] && [ -f "/sys/class/backlight/$device/brightness" ]; then
      brightness=$(cat "/sys/class/backlight/$device/brightness" 2>/dev/null || echo "0")
      max_brightness=$(cat "/sys/class/backlight/$device/max_brightness" 2>/dev/null || echo "100")

      if [[ "$brightness" =~ ^[0-9]+$ ]] && [[ "$max_brightness" =~ ^[0-9]+$ ]] && [ "$max_brightness" -gt 0 ]; then
        brightness_percentage=$((brightness * 100 / max_brightness))
      fi
    fi
  fi
fi

# Ensure it's a number
if ! [[ "$brightness_percentage" =~ ^[0-9]+$ ]]; then
  brightness_percentage=0
fi

# Brightness icon with safe comparisons
if [ "$brightness_percentage" -lt 20 ] 2>/dev/null; then
  icon="󰃞"
elif [ "$brightness_percentage" -lt 50 ] 2>/dev/null; then
  icon="󰃟"
elif [ "$brightness_percentage" -lt 80 ] 2>/dev/null; then
  icon="󰃝"
else
  icon="󰃠"
fi

# Output JSON
echo "{\"text\": \"$icon $brightness_percentage%\", \"tooltip\": \"Brightness: $brightness_percentage%\"}"
