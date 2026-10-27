#!/usr/bin/env bash
# ============================================================
# make status
# 不 fetch，没 push 的数量是跟本地记录的远程比
# ============================================================
set -euo pipefail

WORKSPACE_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
source "$WORKSPACE_ROOT/dev/scripts/lib.color.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.log.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.game.sh"

log.title '游戏仓库'

games=$(game.list)
if [ -z "$games" ] && [ -z "$(game.registered)" ]; then
  printf '  %s\n' "$(color.dim '还没有游戏')"
  exit 0
fi

for name in $games; do
  dir=$(game.dir "$name")
  label=$(printf '%-12s' "$name")

  if [ ! -e "$dir/.git" ]; then
    printf '  %s %s  %s\n' "$label" "$(color.dim "$(printf '%-10s' '-')")" "$(color.red '✖ 不是 git 仓库')"
    continue
  fi

  branch=$(git -C "$dir" symbolic-ref --short -q HEAD || echo '(detached)')
  issues=''

  changed=$(git -C "$dir" status --porcelain | wc -l | tr -d ' ')
  [ "$changed" -gt 0 ] && issues="$issues  $(color.yellow "● $changed 个文件没提交")"

  if [ -z "$(git -C "$dir" remote)" ]; then
    issues="$issues  $(color.red '✖ 没配远程')"
  elif ! git -C "$dir" rev-parse -q --verify HEAD >/dev/null 2>&1; then
    issues="$issues  $(color.dim '还没有 commit')"
  elif ! git -C "$dir" rev-parse -q --verify '@{u}' >/dev/null 2>&1; then
    issues="$issues  $(color.yellow '↑ 没设上游分支')"
  else
    ahead=$(git -C "$dir" rev-list --count '@{u}..HEAD')
    [ "$ahead" -gt 0 ] && issues="$issues  $(color.yellow "↑ $ahead 个 commit 没 push")"
  fi

  if ! game.is_registered "$name"; then
    issues="$issues  $(color.yellow '○ 没登记在清单里')"
  elif [ -z "$(game.url "$name")" ]; then
    issues="$issues  $(color.red '✖ 清单里没写 git 地址')"
  fi

  [ -z "$issues" ] && issues="  $(color.green '✔ 都已提交并 push')"
  printf '  %s %s%s\n' "$label" "$(color.dim "$(printf '%-10s' "$branch")")" "$issues"
done

for name in $(game.registered); do
  game.exists "$name" && continue
  label=$(printf '%-12s' "$name")
  if ! game.valid "$name"; then
    note=$(color.red '✖ 清单里的游戏名不能用')
  elif [ -z "$(game.url "$name")" ]; then
    note=$(color.red '✖ 清单里没写 git 地址')
  else
    note=$(color.yellow '↓ 还没拉下来，用 make pull')
  fi
  printf '  %s %s  %s\n' "$label" "$(color.dim "$(printf '%-10s' '-')")" "$note"
done
