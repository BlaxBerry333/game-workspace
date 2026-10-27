#!/usr/bin/env bash
# ============================================================
# make pull
# ============================================================
set -euo pipefail

WORKSPACE_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
source "$WORKSPACE_ROOT/dev/scripts/lib.color.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.log.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.game.sh"

log.title '拉取游戏'

names=$(game.registered)
if [ -z "$names" ]; then
  printf '  %s\n' "$(color.dim '清单里还没有游戏：games/games.list')"
  exit 0
fi

failed=0
for name in $names; do
  label=$(printf '%-12s' "$name")
  dir=$(game.dir "$name")
  url=$(game.url "$name")
  detail=''
  bad=0

  if ! game.valid "$name"; then
    result=$(color.red '✖ 游戏名不能用：不能以 . 开头，也不能带 /')
    bad=1
  elif [ -z "$url" ]; then
    result=$(color.red '✖ 没写 git 地址')
    bad=1
  elif [ ! -e "$dir" ]; then
    if detail=$(git clone -q "$url" "$dir" 2>&1); then
      result=$(color.green '✔ clone 下来了')
    else
      result=$(color.red '✖ clone 失败')
      bad=1
    fi
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
