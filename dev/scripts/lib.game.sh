# ============================================================
# 游戏
# 要先设好 WORKSPACE_ROOT
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
