# ============================================================
# 终端输出
# 要先 source lib.color.sh。log.ok 走 stdout，log.warn、log.error、log.hint 走 stderr
# ============================================================

log.title() { printf '%s\n' "$(color.bold "$1")"; }
log.step()  { printf '%s\n' "$(color.bold "$(color.cyan "▶ $1")")"; }
log.ok()    { printf '%s  %s\n' "$(color.green '✔ 完成')" "$1"; }
log.warn()  { local COLOR_TO_STDERR=1; printf '%s  %s\n' "$(color.yellow '⚠ 警告')" "$1" >&2; }
log.error() { local COLOR_TO_STDERR=1; printf '%s  %s\n' "$(color.red '✖ 错误')" "$1" >&2; }

# ============================================================
# 跟在 log.warn、log.error 后面，说下一步怎么做。缩进到跟上一行的正文对齐
# ============================================================
log.hint()  { local COLOR_TO_STDERR=1; printf '        %s\n' "$(color.dim "$1")" >&2; }

# ============================================================
# 命令意外失败时（set -e 会让脚本直接退出），先说清楚是哪个脚本、哪条命令
# 不报行号：bash 3.2 在函数和 if 里报的行号不准
# errtrace 让函数里的失败也能触发。$( ) 里的失败交给外面判断：
# 外面当条件用（if、||）时本来就是预料中的，不当条件用时外面会再触发一次
# ============================================================
log.on-error() {
  [ "$BASH_SUBSHELL" -gt 0 ] && return 0
  log.error "$(basename "$3") 里这条命令出错：$2（退出码 $1）"
}

set -o errtrace
trap 'log.on-error $? "$BASH_COMMAND" "${BASH_SOURCE[0]}"' ERR
