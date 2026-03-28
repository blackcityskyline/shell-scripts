#!/usr/bin/env bash
# ~/.config/waybar/scripts/powermenu.sh

show_menu() {
  if command -v wlogout &>/dev/null; then
    wlogout --protocol layer-shell --buttons-per-row 5
  elif command -v rofi &>/dev/null; then
    chosen=$(echo -e " Lock\n󰌾 Logout\n󰒲 Suspend\n󰜉 Reboot\n⏻ Shutdown" |
      rofi -dmenu -i -p "Power Menu:" -theme-str '* { font: "JetBrains Mono 12"; }')

    case "$chosen" in
    *Lock) swaylock -f -c 000000 ;;
    *Logout) hyprctl dispatch exit ;;
    *Suspend) systemctl suspend ;;
    *Reboot) systemctl reboot ;;
    *Shutdown) systemctl poweroff ;;
    esac
  else
    # Fallback to simple notification
    notify-send "Power Menu" "Install wlogout or rofi for power menu"
  fi
}

# Execute menu
show_menu
