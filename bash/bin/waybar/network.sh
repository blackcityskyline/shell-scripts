#!/bin/bash

# Получаем информацию о WiFi подключениях
wifi_info=""
active_ssid=""
has_connection=false

for iface in wlan0 wlan1; do
  if link_info=$(iw dev "$iface" link 2>/dev/null); then
    if echo "$link_info" | grep -q "Connected"; then
      has_connection=true
      ssid=$(echo "$link_info" | grep "SSID:" | cut -d: -f2 | xargs)
      signal=$(echo "$link_info" | grep "signal:" | awk '{print $2}')
      ip=$(ip -4 addr show "$iface" 2>/dev/null | grep -oE 'inet ([0-9\.]+)' | head -1 | cut -d' ' -f2)

      # Получаем частоту и конвертируем в ГГц
      freq=$(echo "$link_info" | grep "freq:" | awk '{print $2}')
      if [ ! -z "$freq" ]; then
        # Конвертируем МГц в ГГц с одним знаком после запятой
        freq_ghz=$(echo "scale=1; $freq / 1000" | bc 2>/dev/null || echo "$freq")
        freq_info=", ${freq_ghz} GHz"
      else
        freq_info=""
      fi

      [ -z "$ip" ] && ip="No IP"
      [ -z "$active_ssid" ] && active_ssid="$ssid"

      wifi_info="${wifi_info}${iface}: ${ssid} (${signal} dBm${freq_info}) ${ip}\n"
    fi
  fi
done

if [ "$has_connection" = true ]; then
  text="󰖩 "
  # Ограничим 2 строки и экранируем спецсимволы для JSON
  tooltip=$(echo -e "$wifi_info" | head -n 2 | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
else
  text="󰖪 "
  tooltip="No active connections"
fi

# Экранируем спецсимволы в text тоже
text=$(echo "$text" | sed 's/"/\\"/g')

# Выводим только JSON
printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"
