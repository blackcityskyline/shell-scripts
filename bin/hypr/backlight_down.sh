#!/bin/bash

# Настройки
BACKLIGHT_DIR="/sys/class/backlight/intel_backlight"
MAX_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/max_brightness")
CURRENT_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/brightness")

# Шаг изменения (5% от максимальной яркости)
STEP=$((MAX_BRIGHTNESS / 20))
NEW_BRIGHTNESS=$((CURRENT_BRIGHTNESS - STEP))

# Проверка на минимальную яркость (минимально 1, иначе экран погаснет)
if [ "$NEW_BRIGHTNESS" -lt 1 ]; then
  NEW_BRIGHTNESS=1
fi

# Запись новой яркости
echo "$NEW_BRIGHTNESS" >"$BACKLIGHT_DIR/brightness"

# Вычисление процентов для уведомления
PERCENT=$((NEW_BRIGHTNESS * 100 / MAX_BRIGHTNESS))

# Уведомление через swayosd
swayosd-client --brightness "$PERCENT"

# avizo-send "Brightness: $PERCENT%"
