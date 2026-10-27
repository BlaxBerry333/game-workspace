# ============================================================
# 终端输出
# 要先 source lib.color.sh
# ============================================================

log.title() { printf '%s\n' "$(color.bold "$1")"; }
log.step()  { printf '%s\n' "$(color.bold "$(color.cyan "▶ $1")")"; }
log.error() { printf '%s\n' "$(color.red "✖ $1")" >&2; }
log.hint()  { printf '  %s\n' "$(color.dim "$1")" >&2; }
