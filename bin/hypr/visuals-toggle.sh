#!/bin/bash

# ===========================================
# Hyprland Animations Mode Toggle
# Affected: blur, shadows, animations, dim, opacity
# Not affected: rounded corners, borders
# ===========================================

STATE_FILE="$HOME/.cache/hypr-visuals"
APPEARANCE="$HOME/.config/hypr/config/appearance.conf"
MISC="$HOME/.config/hypr/config/misc.conf"

# ===========================================
# Парсинг значений из конфигов
# ===========================================
load_config_values() {
  CFG_BLUR=$(
    sed -n '/blur[[:space:]]*{/,/}/p' "$APPEARANCE" |
      grep -E "^[[:space:]]*enabled[[:space:]]*=" |
      sed 's/.*=[[:space:]]*//' | sed 's/[[:space:]]*#.*//' | tr -d ' \t'
  )

  CFG_SHADOW=$(
    sed -n '/shadow[[:space:]]*{/,/}/p' "$APPEARANCE" |
      grep -E "^[[:space:]]*enabled[[:space:]]*=" |
      sed 's/.*=[[:space:]]*//' | sed 's/[[:space:]]*#.*//' | tr -d ' \t'
  )

  CFG_ANIMATIONS=$(
    sed -n '/^[[:space:]]*animations[[:space:]]*{/,/^[[:space:]]*}/p' "$APPEARANCE" |
      grep -E "^[[:space:]]*enabled[[:space:]]*=" |
      sed 's/.*=[[:space:]]*//' | sed 's/[[:space:]]*#.*//' | tr -d ' \t'
  )

  CFG_DIM_INACTIVE=$(
    grep -E "^[[:space:]]*dim_inactive[[:space:]]*=" "$APPEARANCE" |
      sed 's/.*=[[:space:]]*//' | sed 's/[[:space:]]*#.*//' | tr -d ' \t'
  )

  CFG_DIM_STRENGTH=$(
    grep -E "^[[:space:]]*dim_strength[[:space:]]*=" "$APPEARANCE" |
      sed 's/.*=[[:space:]]*//' | sed 's/[[:space:]]*#.*//' | tr -d ' \t'
  )

  CFG_DIM_SPECIAL=$(
    grep -E "^[[:space:]]*dim_special[[:space:]]*=" "$APPEARANCE" |
      sed 's/.*=[[:space:]]*//' | sed 's/[[:space:]]*#.*//' | tr -d ' \t'
  )

  CFG_DIM_AROUND=$(
    grep -E "^[[:space:]]*dim_around[[:space:]]*=" "$APPEARANCE" |
      sed 's/.*=[[:space:]]*//' | sed 's/[[:space:]]*#.*//' | tr -d ' \t'
  )

  CFG_ACTIVE_OPACITY=$(
    grep -E "^[[:space:]]*active_opacity[[:space:]]*=" "$APPEARANCE" |
      sed 's/.*=[[:space:]]*//' | sed 's/[[:space:]]*#.*//' | tr -d ' \t'
  )

  CFG_INACTIVE_OPACITY=$(
    grep -E "^[[:space:]]*inactive_opacity[[:space:]]*=" "$APPEARANCE" |
      sed 's/.*=[[:space:]]*//' | sed 's/[[:space:]]*#.*//' | tr -d ' \t'
  )

  local missing=()
  [ -z "$CFG_BLUR" ] && missing+=("blur:enabled")
  [ -z "$CFG_SHADOW" ] && missing+=("shadow:enabled")
  [ -z "$CFG_ANIMATIONS" ] && missing+=("animations:enabled")
  [ -z "$CFG_DIM_INACTIVE" ] && missing+=("dim_inactive")
  [ -z "$CFG_ACTIVE_OPACITY" ] && missing+=("active_opacity")

  if [ ${#missing[@]} -gt 0 ]; then
    notify-send -u critical "Visuals Mode" \
      "Не найдены в конфиге: ${missing[*]}"
    return 1
  fi
}

# ===========================================
# Читаем реальное состояние анимаций из Hyprland
# Возвращает 0 если perfmode активен (анимации выключены)
# Возвращает 1 если нормальный режим (анимации включены)
# ===========================================
_is_visuals_disabled() {
  local raw val
  raw=$(hyprctl getoption animations:enabled -j 2>/dev/null)

  # Формат 1: {"option":"animations:enabled","int":0,...}
  val=$(printf '%s' "$raw" | grep -o '"int":[0-9]*' | grep -o '[0-9]*$')

  # Формат 2: просто иcкать любое число в ответе
  if [ -z "$val" ]; then
    val=$(printf '%s' "$raw" | grep -oE '[0-9]+' | head -1)
  fi

  [ "$val" = "0" ]
}

# ===========================================
# Синхронизация STATE_FILE
# ===========================================
_sync_state() {
  if _is_visuals_disabled; then
    touch "$STATE_FILE"
  else
    rm -f "$STATE_FILE"
  fi
}

# ===========================================
# Disable Visuals
# ===========================================
disable_visuals() {
  hyprctl keyword decoration:blur:enabled false
  hyprctl keyword decoration:shadow:enabled false
  hyprctl keyword animations:enabled false
  hyprctl keyword decoration:dim_inactive false
  hyprctl keyword decoration:dim_strength 0
  hyprctl keyword decoration:dim_special 0
  hyprctl keyword decoration:dim_around 0
  hyprctl keyword decoration:active_opacity 1.0
  hyprctl keyword decoration:inactive_opacity 1.0
  touch "$STATE_FILE"
  notify-send -i system-run "Visuals disabled"
}

# ===========================================
# Enable visuals — восстанавление из конфига
# ===========================================
enable_visuals() {
  load_config_values || return 1

  hyprctl keyword decoration:blur:enabled "${CFG_BLUR:-true}"
  hyprctl keyword decoration:shadow:enabled "${CFG_SHADOW:-true}"
  hyprctl keyword animations:enabled "${CFG_ANIMATIONS:-yes}"
  hyprctl keyword decoration:dim_inactive "${CFG_DIM_INACTIVE:-true}"
  hyprctl keyword decoration:dim_strength "${CFG_DIM_STRENGTH:-0.08}"
  hyprctl keyword decoration:dim_special "${CFG_DIM_SPECIAL:-0.3}"
  hyprctl keyword decoration:dim_around "${CFG_DIM_AROUND:-0.5}"
  hyprctl keyword decoration:active_opacity "${CFG_ACTIVE_OPACITY:-0.98}"
  hyprctl keyword decoration:inactive_opacity "${CFG_INACTIVE_OPACITY:-0.90}"
  rm -f "$STATE_FILE"
  notify-send -i preferences-desktop-display "Visuals enabled"
}

# ===========================================
# Режим --status: возвращает true если visuals включены
# Используется swaync для подсветки кнопки
# ===========================================
if [ "$1" = "--status" ]; then
  if [ -f "$STATE_FILE" ]; then
    echo false   # STATE_FILE существует = visuals отключены
  else
    echo true    # STATE_FILE нет = visuals включены
  fi
  exit 0
fi

# ===========================================
# Режим --restore: запускается при старте Hyprland (exec-once)
# ===========================================
if [ "$1" = "--restore" ]; then
  if [ -f "$STATE_FILE" ]; then
    disable_visuals
  fi
  exit 0
fi

# ===========================================
# Обычный запуск:
# Синхронизация STATE_FILE с реальным состоянием Hyprland
# затем переключение
# ===========================================
_sync_state

if [ -f "$STATE_FILE" ]; then
  enable_visuals
else
  disable_visuals
fi
