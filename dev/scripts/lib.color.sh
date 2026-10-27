# ============================================================
# 颜色
# 不在终端里或设了 NO_COLOR 时不上色
# ============================================================

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  COLOR_RESET=$'\033[0m'
  COLOR_BOLD=$'\033[1m'
  COLOR_DIM=$'\033[2m'
  COLOR_RED=$'\033[31m'
  COLOR_GREEN=$'\033[32m'
  COLOR_YELLOW=$'\033[33m'
  COLOR_CYAN=$'\033[36m'
else
  COLOR_RESET=''
  COLOR_BOLD=''
  COLOR_DIM=''
  COLOR_RED=''
  COLOR_GREEN=''
  COLOR_YELLOW=''
  COLOR_CYAN=''
fi

color.bold()   { printf '%s%s%s' "$COLOR_BOLD" "$1" "$COLOR_RESET"; }
color.dim()    { printf '%s%s%s' "$COLOR_DIM" "$1" "$COLOR_RESET"; }
color.red()    { printf '%s%s%s' "$COLOR_RED" "$1" "$COLOR_RESET"; }
color.green()  { printf '%s%s%s' "$COLOR_GREEN" "$1" "$COLOR_RESET"; }
color.yellow() { printf '%s%s%s' "$COLOR_YELLOW" "$1" "$COLOR_RESET"; }
color.cyan()   { printf '%s%s%s' "$COLOR_CYAN" "$1" "$COLOR_RESET"; }
