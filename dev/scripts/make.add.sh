#!/usr/bin/env bash
# ============================================================
# make add
# 一问一答登记一个游戏：游戏名、仓库地址，确认后追加到 games/games.list，
# 再问要不要马上 clone 并跑 setup。直接编辑 games.list 后跑 make setup 也一样
# ============================================================
set -euo pipefail

WORKSPACE_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
source "$WORKSPACE_ROOT/dev/scripts/lib.color.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.log.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.game.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.prompt.sh"

if [ ! -t 0 ]; then
  log.error 'make add 要在终端里跑，一问一答'
  log.hint '不在终端里时，直接编辑 games/games.list 后跑 make setup'
  exit 2
fi

# ============================================================
# 问：输错了当场提示，重新输入
# ============================================================
while true; do
  name=$(prompt.ask '游戏名（小写英文、数字，用 - 连）: ') || exit 1
  if ! game.valid_name "$name"; then
    log.warn "游戏名格式不对：${name:-（空）}"
  elif game.is_registered "$name"; then
    log.warn "games/games.list 里已经有 $name"
  elif [ -e "$(game.dir "$name")" ]; then
    log.warn "games/$name 已经存在"
  else
    break
  fi
done

while true; do
  url=$(prompt.ask '仓库地址: ') || exit 1
  game.valid_url "$url" && break
  log.warn "不像 git 地址：${url:-（空）}"
  log.hint "比如 git@github.com:<用户名>/$name.git 或 https://github.com/<用户名>/$name.git"
done

# ============================================================
# 确认后写进清单：没有清单先从 example 复制；最后一行没换行时先补上，再追加一行
# ============================================================
echo
printf '  %s  %s\n' "$(color.bold "$name")" "$url"
if ! prompt.confirm '写进 games/games.list？' y; then
  printf '%s\n' "$(color.dim '没写，什么都没改')"
  exit 0
fi

if [ ! -f "$GAME_LIST_FILE" ]; then
  cp "$WORKSPACE_ROOT/games/games.list.example" "$GAME_LIST_FILE"
fi
if [ -s "$GAME_LIST_FILE" ] && [ -n "$(tail -c 1 "$GAME_LIST_FILE")" ]; then
  printf '\n' >> "$GAME_LIST_FILE"
fi
printf '%-12s %s\n' "$name" "$url" >> "$GAME_LIST_FILE"
log.ok "登记到 games/games.list：$name"

# ============================================================
# clone 和 setup 交给 make setup game=<游戏名>，跟手动登记后跑的是同一套
# ============================================================
echo
status=0
if prompt.confirm '现在 clone 并跑 setup？' y; then
  echo
  "$WORKSPACE_ROOT/dev/scripts/make.setup.sh" "$name" || status=$?
else
  printf '%s\n' "$(color.dim "之后跑 make setup game=$name")"
fi

exit "$status"
