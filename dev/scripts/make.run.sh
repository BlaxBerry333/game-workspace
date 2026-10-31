#!/usr/bin/env bash
# ============================================================
# make dev / build / test
# 工作区的 make setup game=<游戏名> 也转到这里
# ============================================================
set -euo pipefail

WORKSPACE_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
source "$WORKSPACE_ROOT/dev/scripts/lib.color.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.log.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.game.sh"

target=$1
name=${2:-}

if [ -z "$name" ]; then
  log.error "要指定游戏：make $target game=<游戏名>"
  game.hint
  exit 2
fi

if ! game.exists "$name"; then
  log.error "没有这个游戏：$name"
  game.hint
  exit 2
fi

dir=$(game.dir "$name")
if [ ! -f "$dir/Makefile" ]; then
  log.error "games/$name 里没有 Makefile"
  game.hint
  exit 2
fi

log.step "$name · $target"
exec make --no-print-directory -C "$dir" "$target"
