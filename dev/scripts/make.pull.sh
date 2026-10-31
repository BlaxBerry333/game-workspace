#!/usr/bin/env bash
# ============================================================
# make pull
# 更新清单里已经 clone 下来的游戏。还没 clone 的交给 make setup
# ============================================================
set -euo pipefail

WORKSPACE_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
source "$WORKSPACE_ROOT/dev/scripts/lib.color.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.log.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.game.sh"

if [ ! -f "$GAME_LIST_FILE" ]; then
  log.warn '还没有 games/games.list'
  log.hint '先跑 make setup'
  exit 0
fi

names=$(game.registered)
if [ -z "$names" ]; then
  log.warn '清单里还没有游戏'
  log.hint '填好 games/games.list 后跑 make setup'
  exit 0
fi

log.title '更新游戏'
failed=0
for name in $names; do
  label=$(printf '%-12s' "$name")
  dir=$(game.dir "$name")
  detail=''
  bad=0

  if ! game.valid "$name"; then
    result=$(color.red '✖ 游戏名不能用：不能以 . 开头，也不能带 /')
    bad=1
  elif [ ! -e "$dir" ]; then
    result=$(color.dim '还没 clone，跑 make setup')
  elif [ ! -e "$dir/.git" ]; then
    result=$(color.red '✖ 文件夹已经存在，但不是 git 仓库')
    bad=1
  else
    before=$(git -C "$dir" rev-parse -q --verify HEAD 2>/dev/null || true)
    if detail=$(git -C "$dir" pull -q --ff-only 2>&1); then
      after=$(git -C "$dir" rev-parse -q --verify HEAD 2>/dev/null || true)
      if [ "$before" = "$after" ]; then
        result=$(color.dim '✔ 已经是最新')
      else
        result=$(color.green '✔ 更新了')
      fi
    else
      result=$(color.red '✖ pull 失败')
      bad=1
    fi
  fi

  printf '  %s %s\n' "$label" "$result"
  if [ "$bad" = 1 ]; then
    failed=1
    if [ -n "$detail" ]; then
      printf '    %s\n' "$(color.dim "${detail%%$'\n'*}")"
    fi
  fi
done

exit "$failed"
