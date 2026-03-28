#!/usr/bin/env bash

player_status=$(playerctl --player=kew,playerctld,%any status 2>/dev/null)

if [ "$player_status" = "Playing" ] || [ "$player_status" = "Paused" ]; then
  artist=$(playerctl --player=kew,playerctld,%any metadata artist 2>/dev/null || echo "") # Unknow Arist
  title=$(playerctl --player=kew,playerctld,%any metadata title 2>/dev/null || echo "hmmm?")

  # Убираем кавычки и лишние символы
  artist=$(echo "$artist" | sed 's/["'\'']//g' | xargs)
  title=$(echo "$title" | sed 's/["'\'']//g' | xargs)

  # Формируем полный текст
  if [ -z "$artist" ]; then
    full_text="$title"
  else
    full_text="$artist - $title"
  fi

  # Определяем максимальную длину для отображения (примерно 20 символов)
  MAX_LENGTH=20

  # Если текст короче или равен максимальной длине, оставляем как есть
  if [ ${#full_text} -le $MAX_LENGTH ]; then
    display_text="$full_text"
  else
    # Создаем эффект бегущей строки
    # Используем текущее время для создания смещения
    current_time=$(date +%s)

    # Создаем длинную строку с разделителем для плавной анимации
    separator=" • "
    extended_text="$full_text$separator$full_text"

    # Вычисляем позицию в длинной строке (циклично)
    text_length=${#full_text}
    extended_length=${#extended_text}

    # Смещение меняется с течением времени (1 символ в секунду)
    offset=$((current_time % (text_length + ${#separator})))

    # Берем подстроку из расширенного текста
    display_text="${extended_text:offset:MAX_LENGTH}"

    # Если строка короче MAX_LENGTH, добавляем начало
    if [ ${#display_text} -lt $MAX_LENGTH ]; then
      remaining=$((MAX_LENGTH - ${#display_text}))
      display_text="$display_text${extended_text:0:remaining}"
    fi
  fi

  # Для обрезанного отображения (как было ранее)
  if [ ${#artist} -gt 10 ]; then
    artist_short="${artist:0:10}…"
  else
    artist_short="$artist"
  fi
  if [ ${#title} -gt 15 ]; then
    title_short="${title:0:15}…"
  else
    title_short="$title"
  fi

  if [ -z "$artist" ]; then
    short_text="$title_short"
  else
    short_text="$artist_short - $title_short"
  fi

  if [ "$player_status" = "Playing" ]; then
    icon=""
  else
    icon=""
  fi

  # Используем display_text для бегущей строки, но в JSON
  echo "{\"text\": \"$icon $display_text\", \"class\": \"$player_status\", \"tooltip\": \"$artist - $title\\nClick: Play/Pause | Scroll: Next/Prev\"}"
else
  echo "{\"text\": \"\", \"class\": \"stopped\", \"tooltip\": \"No active media player\"}"
fi
