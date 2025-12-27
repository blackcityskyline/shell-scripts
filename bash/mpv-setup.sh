#!/bin/bash
# Продвинутый скрипт настройки mpv с параметрами

set -e

# Параметры по умолчанию
CONFIG_DIR="${1:-$HOME/.config/mpv}"
QUALITY="${2:-1080}"
BROWSER="${3:-brave}"
GPU_API="${4:-opengl}"

CONFIG_FILE="$CONFIG_DIR/mpv.conf"

echo "⚙️  Продвинутая настройка MPV"
echo "────────────────────────────"
echo "Директория:   $CONFIG_DIR"
echo "Качество:     ${QUALITY}p"
echo "Браузер:      $BROWSER"
echo "GPU API:      $GPU_API"
echo ""

# Функция для создания конфига
create_config() {
    local quality=$1
    local browser=$2
    local gpu_api=$3
    
    cat > "$CONFIG_FILE" << EOF
# === Основные настройки ===
# Создано: $(date)
# Качество: ${quality}p
# Браузер: $browser

# Вывод
vo=gpu
gpu-api=$gpu_api

# Декодирование
hwdec=no
hwdec-codecs=all

# YouTube
ytdl-format=best[height<=$quality]
ytdl-raw-options=cookies-from-browser=$browser

# Окно
force-window=yes
geometry=50%x50%
border=no
title=\${media-title}
keep-open=yes

# Кэш
cache=yes
cache-secs=300
demuxer-max-bytes=500M

# Производительность
profile=fast
interpolation=no
video-sync=display-resample
interpolation-threshold=0

# Аудио
audio-channels=stereo
volume=70
volume-max=200
audio-file-auto=fuzzy

# Субтитры
sub-auto=fuzzy
sub-file-paths=subs
sub-font-size=42
sub-color='#FFFFFFFF'
sub-border-color='#FF000000'
sub-border-size=2.5

# Скриншоты
screenshot-directory=~/Pictures/mpv_screenshots
screenshot-template=%F-%wH-%wM-%wS-%#04n
screenshot-format=png
screenshot-png-compression=7

# Прочее
save-position-on-quit=yes
watch-later-directory=$CONFIG_DIR/watch_later
input-conf=$CONFIG_DIR/input.conf
EOF
}

# Создаём директории
mkdir -p "$CONFIG_DIR" "$CONFIG_DIR/subs" "$CONFIG_DIR/watch_later"

# Создаём конфиг
echo "📝 Создаю конфигурацию..."
create_config "$QUALITY" "$BROWSER" "$GPU_API"

# Создаём базовый input.conf если его нет
INPUT_CONF="$CONFIG_DIR/input.conf"
if [ ! -f "$INPUT_CONF" ]; then
    cat > "$INPUT_CONF" << 'EOF'
# Управление воспроизведением
SPACE cycle pause
ENTER cycle fullscreen
f cycle fullscreen

# Перемотка
LEFT seek -5
RIGHT seek 5
UP seek 60
DOWN seek -60
Ctrl+LEFT seek -30
Ctrl+RIGHT seek 30

# Громкость
9 add volume -5
0 add volume 5
m cycle mute

# Субтитры
j add sub-delay -0.1
k add sub-delay +0.1
v cycle sub

# Скриншоты
s screenshot
S screenshot video

# Плейлист
PGUP playlist-prev
PGDWN playlist-next
` show-text ${playlist}

# Скорость
[ multiply speed 0.9091
] multiply speed 1.1
{ set speed 1.0
r cycle_values speed 1.0 1.5 2.0 0.5

# Прочее
l show-progress
ESC quit
q quit
EOF
    echo "⌨️  Создан файл горячих клавиш: $INPUT_CONF"
fi

echo "✅ Настройка завершена!"
echo ""
echo "📊 Сводка:"
echo "   • Основной конфиг: $CONFIG_FILE"
echo "   • Горячие клавиши: $INPUT_CONF"
echo "   • Директория субтитров: $CONFIG_DIR/subs"
echo "   • История просмотра: $CONFIG_DIR/watch_later"
echo ""
echo "🚀 Запуск: mpv <youtube_url>"
