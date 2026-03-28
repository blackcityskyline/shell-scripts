#!/bin/bash
# Уменьшить громкость через swayosd
swayosd-client --output-volume lower

# current=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')
# echo "Volume: $current%"
