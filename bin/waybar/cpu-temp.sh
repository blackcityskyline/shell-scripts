#!/usr/bin/env bash

# CPU, Temperature, RAM and Disk monitor for Waybar

# Configuration
CPU_UPDATE_INTERVAL=1 # seconds for CPU usage calculation
PREV_STAT_FILE="/tmp/cpu_stat_prev"

# Get CPU usage (accurate calculation over interval)
get_cpu_usage() {
  # Read current CPU stats
  read -r cpu user nice system idle iowait irq softirq steal guest guest_nice <<<"$(grep '^cpu ' /proc/stat)"

  # Calculate total and idle time
  total_current=$((user + nice + system + idle + iowait + irq + softirq + steal))
  idle_current=$((idle + iowait))

  # Try to read previous values
  if [[ -f "$PREV_STAT_FILE" ]]; then
    read -r total_prev idle_prev <"$PREV_STAT_FILE"

    # Calculate difference
    total_diff=$((total_current - total_prev))
    idle_diff=$((idle_current - idle_prev))

    # Calculate usage percentage (целое число)
    if [[ $total_diff -gt 0 ]]; then
      cpu_usage=$((100 * (total_diff - idle_diff) / total_diff))
      printf "%d" "$cpu_usage"
    else
      echo "0"
    fi
  else
    # First run, no previous data
    echo "0"
  fi

  # Save current values for next run
  echo "$total_current $idle_current" >"$PREV_STAT_FILE"
}

# Get CPU temperature
get_temp() {
  # Try multiple temperature sources
  local temp sources

  # Common temperature sources
  sources=(
    "/sys/class/thermal/thermal_zone0/temp"
    "/sys/class/thermal/thermal_zone1/temp"
    "/sys/class/hwmon/hwmon0/temp1_input"
    "/sys/class/hwmon/hwmon1/temp1_input"
    "/sys/class/hwmon/hwmon2/temp1_input"
    "/sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input"
  )

  for source in "${sources[@]}"; do
    # Expand glob patterns
    for file in $source; do
      if [[ -f "$file" ]]; then
        temp=$(cat "$file" 2>/dev/null)
        if [[ -n "$temp" && "$temp" -gt 0 ]]; then
          echo $((temp / 1000))
          return 0
        fi
      fi
    done
  done

  echo "0"
}

# Get RAM usage
get_ram() {
  # Use free in bytes for more accuracy
  read -r total used _ <<<"$(free -b | awk '/^Mem:/ {print $2, $3}')"

  # Convert to GB with 1 decimal place
  total_gb=$(echo "scale=1; $total / 1073741824" | bc)
  used_gb=$(echo "scale=1; $used / 1073741824" | bc)

  # Calculate percentage (целое число)
  if [[ $total -gt 0 ]]; then
    percent=$((100 * used / total))
  else
    percent=0
  fi

  echo "$used_gb $total_gb $percent"
}

# Get Disk usage
get_disk() {
  # Use df with bytes for consistency
  read -r used_bytes total_bytes percent <<<"$(df -B1 / --output=used,size,pcent 2>/dev/null | tail -1 | tr -d '%')"

  # Convert to GB
  used_gb=$(echo "scale=1; $used_bytes / 1073741824" | bc)
  total_gb=$(echo "scale=1; $total_bytes / 1073741824" | bc)

  echo "$used_gb $total_gb $percent"
}

# Main execution
cpu_percent=$(get_cpu_usage)
temp=$(get_temp)
read -r ram_used ram_total ram_percent <<<"$(get_ram)"
read -r disk_used disk_total disk_percent <<<"$(get_disk)"

# Format display
if [[ "$temp" == "0" ]]; then
  display="${cpu_percent}%"
else
  display="${temp}°C ${cpu_percent}%"
fi

# Determine class with proper thresholds
class="normal"

# Critical: CPU temp > 80°C or CPU usage > 95% or RAM > 95% or Disk > 95%
if [[ $temp -gt 80 ]] || [[ $cpu_percent -gt 95 ]] || [[ $ram_percent -gt 95 ]] || [[ $disk_percent -gt 95 ]]; then
  class="critical"
# Warning: CPU temp > 70°C or CPU usage > 80% or RAM > 85% or Disk > 85%
elif [[ $temp -gt 70 ]] || [[ $cpu_percent -gt 80 ]] || [[ $ram_percent -gt 85 ]] || [[ $disk_percent -gt 85 ]]; then
  class="warning"
fi

# Clean up values for display (remove trailing .0)
ram_used_clean=${ram_used%.0}
ram_total_clean=${ram_total%.0}
disk_used_clean=${disk_used%.0}
disk_total_clean=${disk_total%.0}

# Format tooltip
tooltip="CPU: ${cpu_percent}% \nTemp: ${temp}°C \nRAM: ${ram_used_clean}/${ram_total_clean} GB (${ram_percent}%) \nDisk: ${disk_used_clean}/${disk_total_clean} GB (${disk_percent}%)"

# Output JSON
echo "{\"text\": \"$display\", \"class\": \"$class\", \"tooltip\": \"$tooltip\"}"
