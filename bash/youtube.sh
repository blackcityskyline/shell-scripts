#!/bin/bash

CONFIG_FILE="$HOME/.config/youtube/youtube.conf"

# Функция для установки стандартного пути
function folder() {
  if [ -z "$1" ]; then
    echo "Использование: folder <путь>"
    return 1
  fi
  mkdir -p "$(dirname "$CONFIG_FILE")"
  echo "$1" > "$CONFIG_FILE"
  echo "Стандартный путь сохранён: $1"
}

# Функция для отображения текущего пути
function showpath() {
  if [ -f "$CONFIG_FILE" ]; then
    echo "Текущий стандартный путь: $(cat "$CONFIG_FILE")"
  else
    echo "Стандартный путь не установлен."
  fi
}

# Обработка команд
if [ "$1" == "show" ]; then
  showpath
  exit 0
fi

if [ "$1" == "folder" ]; then
  shift
  folder "$@"
  exit 0
fi

# Для автоматики — скачивание аудио и удаление файла после воспроизведения
if [ "$1" == "audio" ]; then
  LINK=$2

  if [ -z "$LINK" ]; then
    echo "Использование: $0 audio <ссылка>"
    exit 1
  fi

  # Определение пути для сохранения
  if [ -n "$3" ]; then
    SAVE_PATH="$3"
  elif [ -f "$CONFIG_FILE" ]; then
    SAVE_PATH=$(cat "$CONFIG_FILE")
  else
    SAVE_PATH="."
  fi

  mkdir -p "$SAVE_PATH"

  # Получение название файла аудио
  FILENAME=$(yt-dlp --get-filename -f "bestaudio[ext=m4a]/bestaudio" --output "%(title)s.%(ext)s" "$LINK")
  FULL_PATH="$SAVE_PATH/$FILENAME"

  # Скачивание только аудио
  yt-dlp -f "bestaudio[ext=m4a]/bestaudio" --output "$SAVE_PATH/%(title)s.%(ext)s" "$LINK" &&

  # Воспроизведение через vlc
  vlc "$FULL_PATH"

  # После воспроизведения удаление файла
  rm "$FULL_PATH"

  exit 0
fi

# Основной блок — скачивание видео, воспроизведение
LINK=$1

# Проверка наличия ссылки
if [ -z "$LINK" ]; then
  echo "Использование: $0 <ссылка> [путь]"
  exit 1
fi

# Определение пути для сохранения
if [ -n "$2" ]; then
  SAVE_PATH="$2"
elif [ -f "$CONFIG_FILE" ]; then
  SAVE_PATH=$(cat "$CONFIG_FILE")
else
  SAVE_PATH="."
fi

mkdir -p "$SAVE_PATH"

# Получение имени файла (с учетом приоритетов: если есть 1080p, выбрать его, иначе лучший формат)
FILENAME=$(yt-dlp --get-filename -f "bestvideo[height<=1080]+bestaudio/best" --output "%(title)s.%(ext)s" "$LINK")
FULL_PATH="$SAVE_PATH/$FILENAME"

# Скачивание видео
yt-dlp -f "bestvideo[height<=1080]+bestaudio/best" --output "$SAVE_PATH/%(title)s.%(ext)s" "$LINK" &&

# Воспроизведение
vlc "$FULL_PATH"

# Удаление файла после просмотра
rm "$FULL_PATH"
