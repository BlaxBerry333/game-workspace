#!/usr/bin/env bash
# ============================================================
# make help
# 命令说明读的是 Makefile 分隔框里的「# 目标：说明」
# ============================================================
set -euo pipefail

WORKSPACE_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
source "$WORKSPACE_ROOT/dev/scripts/lib.color.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.log.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.game.sh"

printf '%s  make <命令>\n\n' "$(color.bold '用法')"

log.title '命令'
{ grep -E '^# [a-z][a-z0-9-]*：' "$WORKSPACE_ROOT/Makefile" || true; } | while IFS= read -r line; do
  line=${line#\# }
  printf '  %s %s\n' "$(color.yellow "$(printf '%-8s' "${line%%：*}")")" "${line#*：}"
done

echo
log.title '游戏'
games=$(game.list)
if [ -z "$games" ]; then
  printf '  %s\n' "$(color.dim '还没有游戏')"
fi
for name in $games; do
  if [ -f "$(game.dir "$name")/Makefile" ]; then
    printf '  %s\n' "$(color.green "$name")"
  else
    printf '  %s %s\n' "$name" "$(color.dim '没有 Makefile')"
  fi
done
