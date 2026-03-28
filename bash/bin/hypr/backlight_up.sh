#!/bin/bash

# Настройки
BACKLIGHT_DIR="/sys/class/backlight/intel_backlight"
MAX_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/max_brightness")
CURRENT_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/brightness")

# Шаг изменения (5% от максимальной яркости)
STEP=$((MAX_BRIGHTNESS / 20))
NEW_BRIGHTNESS=$((CURRENT_BRIGHTNESS + STEP))

# Проверка на превышение максимальной яркости
if [ "$NEW_BRIGHTNESS" -gt "$MAX_BRIGHTNESS" ]; then
  NEW_BRIGHTNESS=$MAX_BRIGHTNESS
fi

# Запись новой яркости
echo "$NEW_BRIGHTNESS" >"$BACKLIGHT_DIR/brightness"

# Вычисление процентов для уведомления
PERCENT=$((NEW_BRIGHTNESS * 100 / MAX_BRIGHTNESS))

# Уведомление через swayosd (показываем OSD с помощью swayosd-client)
swayosd-client --brightness "$PERCENT"

# Также можно использовать avizo для уведомления (опционально)
# avizo-send "Brightness: $PERCENT%"
