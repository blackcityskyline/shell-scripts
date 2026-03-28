# ~/.config/waybar/toggle.sh
# ~/bin/waybar_toggle.sh
#!/bin/bash
if pgrep -x waybar >/dev/null; then
  pkill waybar
else
  waybar &
fi
