# ============================================================
# 游戏
# 要先设好 WORKSPACE_ROOT；用 game.hint 要先 source lib.log.sh
# ============================================================

GAME_LIST_FILE="$WORKSPACE_ROOT/games/games.list"

game.list() {
  local dir
  for dir in "$WORKSPACE_ROOT"/games/*/; do
    [ -d "$dir" ] && basename "$dir"
  done
  return 0
}

game.entries() {
  local name url
  [ -f "$GAME_LIST_FILE" ] || return 0
  while read -r name url || [ -n "$name" ]; do
    case "$name" in
      '' | '#'*) continue ;;
    esac
    printf '%s %s\n' "$name" "$url"
  done < "$GAME_LIST_FILE"
}

game.registered() { game.entries | awk '!seen[$1]++ { print $1 }'; }

game.is_registered() {
  local name
  for name in $(game.registered); do
    [ "$name" = "$1" ] && return 0
  done
  return 1
}

game.url() {
  local name url
  while read -r name url; do
    if [ "$name" = "$1" ]; then
      printf '%s' "$url"
      return 0
    fi
  done <<< "$(game.entries)"
  return 0
}

game.dir() { printf '%s/games/%s' "$WORKSPACE_ROOT" "$1"; }

game.valid() {
  case "$1" in
    '' | .* | */*) return 1 ;;
  esac
  return 0
}

game.exists() { game.valid "$1" && [ -d "$(game.dir "$1")" ]; }

# ============================================================
# 登记新游戏时的格式检查。game.valid 只防路径出错，新游戏名要更严：小写英文、数字，用 - 连
# 地址只看格式（git@…、https://…、ssh://…），不联网检查
# ============================================================
game.valid_name() { printf '%s' "$1" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; }
game.valid_url() { printf '%s' "$1" | grep -qE '^(git@[^[:space:]:]+:[^[:space:]]+|(https|ssh)://[^[:space:]]+)$'; }

# ============================================================
# 按清单里的地址 clone 到 games/<游戏名>。git 的报错走 stderr，调用的地方自己收起来再显示
# ============================================================
game.clone() { git clone -q "$(game.url "$1")" "$(game.dir "$1")"; }

# ============================================================
# 端口由游戏自己声明：Makefile 的 ports 目标输出「用途 端口」，一行一个
# 没有 ports 目标的游戏不用端口
# ============================================================
game.has_ports() { grep -qE '^ports:' "$(game.dir "$1")/Makefile" 2>/dev/null; }
game.ports() { make -s --no-print-directory -C "$(game.dir "$1")" ports; }

# ============================================================
# 出错时提示现有的游戏；一个都没有时告诉下一步怎么做
# ============================================================
game.hint() {
  local games
  games=$(game.list | tr '\n' ' ')
  games=${games% }
  if [ -n "$games" ]; then
    log.hint "现有游戏：$games"
  else
    log.hint '还没有游戏：跑 make add 登记一个，或者填好 games/games.list 后跑 make setup'
  fi
}
