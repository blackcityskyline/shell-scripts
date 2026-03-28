#!/bin/bash
# Увеличить громкость через swayosd
swayosd-client --output-volume raise

# Если нужно получить текущее значение для других целей
# current=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')
# echo "Volume: $current%"
