#!/bin/bash
hyprctl switchxkblayout keyd-virtual-keyboard next
sleep 0.1

# Читаем текущую группу через hyprctl
layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.name == "keyd-virtual-keyboard") | .active_keymap')

# Если всегда возвращает одно — используем счётчик в файле
LAYOUT_FILE="/tmp/hypr-layout"
if [ ! -f "$LAYOUT_FILE" ] || [ "$(cat $LAYOUT_FILE)" = "en" ]; then
  echo "ru" >"$LAYOUT_FILE"
  notify-send -t 800 -h string:x-canonical-private-synchronous:kbd "🇷🇺 RU"
else
  echo "en" >"$LAYOUT_FILE"
  notify-send -t 800 -h string:x-canonical-private-synchronous:kbd "🇺🇸 US"
fi
