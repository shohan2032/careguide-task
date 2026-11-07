#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly LOG_FILE="${HEALTH_LOG_FILE:-${SCRIPT_DIR}/health_log.txt}"
readonly DISK_PATH="${DISK_PATH:-/}"
readonly DISK_THRESHOLD="${DISK_THRESHOLD:-80}"

read_cpu_times() {
  local _ user nice system idle iowait irq softirq steal
  read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
  echo "$((user + nice + system + idle + iowait + irq + softirq + steal)) $((idle + iowait))"
}

cpu_usage() {
  local total1 idle1 total2 idle2
  read -r total1 idle1 <<< "$(read_cpu_times)"
  sleep 1
  read -r total2 idle2 <<< "$(read_cpu_times)"
  awk -v t="$((total2 - total1))" -v i="$((idle2 - idle1))" \
    'BEGIN { printf "%.1f", (t > 0 ? (t - i) * 100 / t : 0) }'
}

memory_usage() {
  awk '/^MemTotal:/ { total = $2 } /^MemAvailable:/ { avail = $2 }
    END { printf "%.1f", (total - avail) * 100 / total }' /proc/meminfo
}

disk_usage() {
  df -P "$DISK_PATH" | awk 'NR == 2 { gsub("%", "", $5); print $5 }'
}

main() {
  if [[ ! -r /proc/stat || ! -r /proc/meminfo ]]; then
    echo "[ERROR] This script requires Linux (/proc is not available)." >&2
    exit 1
  fi

  local timestamp cpu mem disk entry
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  cpu="$(cpu_usage)"
  mem="$(memory_usage)"
  disk="$(disk_usage)"

  entry="${timestamp} | CPU: ${cpu}% | Memory: ${mem}% | Disk (${DISK_PATH}): ${disk}%"
  echo "$entry" | tee -a "$LOG_FILE"

  if (( disk > DISK_THRESHOLD )); then
    echo "[WARNING] Disk space high!"
    echo "${timestamp} | [WARNING] Disk space high! (${disk}% > ${DISK_THRESHOLD}%)" >> "$LOG_FILE"
  fi
}

main "$@"
