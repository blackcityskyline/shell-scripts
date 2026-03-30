#!/bin/sh
LED=$(find /sys/class/leds -name '*capslock*' | head -1)/brightness
prev=$(cat "$LED")

while true; do
  sleep 0.2
  cur=$(cat "$LED")
  [ "$cur" != "$prev" ] && swayosd-client --caps-lock && prev="$cur"
done
