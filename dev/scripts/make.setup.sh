#!/usr/bin/env bash
# ============================================================
# make setup
# 不指定 game= 时：没有清单就从 example 复制 → clone 清单里还没有的游戏 → 跑每个游戏的 setup
# 指定 game= 时只管那个游戏：登记了还没 clone 的先 clone，再跑它的 setup。跑几次都一样，只有 clone 时要联网
# ============================================================
set -euo pipefail

WORKSPACE_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
source "$WORKSPACE_ROOT/dev/scripts/lib.color.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.log.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.game.sh"

name=${1:-}
if [ -n "$name" ]; then
  if game.valid "$name" && [ ! -e "$(game.dir "$name")" ] && game.is_registered "$name"; then
    if [ -z "$(game.url "$name")" ]; then
      log.error "games/games.list 里没写 $name 的 git 地址"
      exit 2
    fi
    log.step "$name · clone"
    if ! detail=$(game.clone "$name" 2>&1); then
      log.error "clone 失败：games/$name"
      log.hint "${detail%%$'\n'*}"
      exit 1
    fi
  fi
  if game.exists "$name" && [ -f "$(game.dir "$name")/Makefile" ] &&
    ! grep -qE '^setup:' "$(game.dir "$name")/Makefile"; then
    printf '%s\n' "$(color.dim "games/$name 的 Makefile 里没有 setup，不用跑")"
    exit 0
  fi
  exec "$WORKSPACE_ROOT/dev/scripts/make.run.sh" setup "$name"
fi

if [ -f "$GAME_LIST_FILE" ]; then
  log.ok '已经有了：games/games.list'
else
  cp "$WORKSPACE_ROOT/games/games.list.example" "$GAME_LIST_FILE"
  log.ok '从 games.list.example 复制了 games/games.list'
fi
echo

# ============================================================
# 清单里登记的在前，没登记、只在本地的在后
# ============================================================
names=$(
  game.registered
  game.list | while read -r local_name; do
    game.is_registered "$local_name" || printf '%s\n' "$local_name"
  done
)
if [ -z "$names" ]; then
  log.warn '清单里还没有游戏'
  log.hint '填好 games/games.list 后再跑一次 make setup'
  exit 0
fi

summary=''
failed=0
for name in $names; do
  dir=$(game.dir "$name")
  label=$(printf '%-12s' "$name")
  note=''

  if game.is_registered "$name"; then
    url=$(game.url "$name")
    if ! game.valid "$name"; then
      summary="$summary  $label $(color.red '✖ 游戏名不能用：不能以 . 开头，也不能带 /')"$'\n'
      failed=1
      continue
    fi
    if [ ! -e "$dir" ]; then
      if [ -z "$url" ]; then
        summary="$summary  $label $(color.red '✖ 清单里没写 git 地址')"$'\n'
        failed=1
        continue
      fi
      log.step "$name · clone"
      if ! detail=$(game.clone "$name" 2>&1); then
        log.error "clone 失败：games/$name"
        log.hint "${detail%%$'\n'*}"
        echo
        summary="$summary  $label $(color.red '✖ clone 失败')"$'\n'
        failed=1
        continue
      fi
      note='clone 了，'
    elif [ ! -e "$dir/.git" ]; then
      summary="$summary  $label $(color.red '✖ 文件夹已经存在，但不是 git 仓库')"$'\n'
      failed=1
      continue
    fi
  else
    note='没登记在清单里，'
  fi

  if ! grep -qE '^setup:' "$dir/Makefile" 2>/dev/null; then
    summary="$summary  $label $(color.dim "✔ ${note}没有 setup")"$'\n'
    continue
  fi

  log.step "$name · setup"
  if make --no-print-directory -C "$dir" setup; then
    summary="$summary  $label $(color.green "✔ ${note}setup 完成")"$'\n'
  else
    summary="$summary  $label $(color.red "✖ ${note}setup 失败")"$'\n'
    failed=1
  fi
  echo
done

log.title '游戏'
printf '%s' "$summary"
exit "$failed"
