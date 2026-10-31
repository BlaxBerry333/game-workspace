#!/usr/bin/env bash
# ============================================================
# make ports
# 列出各游戏声明的端口和现在的状态。端口由游戏的 make ports 给出，工作区不分配
# 两个游戏声明了同一个端口、或游戏的 make ports 出错时算失败
# ============================================================
set -euo pipefail

WORKSPACE_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
source "$WORKSPACE_ROOT/dev/scripts/lib.color.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.log.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.game.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.port.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.proc.sh"

games=$(game.list)
if [ -z "$games" ]; then
  log.title '端口'
  printf '  %s\n' "$(color.dim '还没有游戏')"
  exit 0
fi

# ============================================================
# 先收齐所有游戏的端口（一行「游戏 用途 端口」），才查得出重复
# ============================================================
declared=''
broken=''
for name in $games; do
  game.has_ports "$name" || continue
  if ! lines=$(game.ports "$name" 2>/dev/null); then
    broken="$broken $name "
    continue
  fi
  declared="$declared$(awk -v game="$name" 'NF == 2 { print game, $1, $2 }' <<< "$lines")"$'\n'
done

listeners=$(port.listeners)
failed=0
no_ports=''

# ============================================================
# 一个游戏一段：游戏名单独一行，下面一行一个端口，要处理的再跟一行说明
# 说明行缩进到状态那一列：4 + 用途 14 + 1 + 端口 5 + 2
# ============================================================
log.title '端口'
for name in $games; do
  case "$broken" in
    *" $name "*)
      echo
      printf '  %s\n' "$(color.bold "$(color.cyan "$name")")"
      printf '    %s\n' "$(color.red '✖ 读不出端口：make ports 出错了')"
      printf '    %s\n' "$(color.dim "在 games/$name 里跑 make ports 看报错")"
      failed=1
      continue
      ;;
  esac

  rows=$(awk -v game="$name" '$1 == game { print $2, $3 }' <<< "$declared")
  if [ -z "$rows" ]; then
    no_ports="$no_ports $name"
    continue
  fi

  echo
  printf '  %s\n' "$(color.bold "$(color.cyan "$name")")"
  game_dir=$(cd "$(game.dir "$name")" && pwd -P)
  while read -r usage port; do
    note=''
    if ! port.valid "$port"; then
      state=$(color.red '✖ 不是端口号')
      failed=1
    else
      others=$(awk -v game="$name" -v port="$port" '$3 == port && $1 != game { print $1 }' <<< "$declared" | sort -u | tr '\n' ' ')
      pid=$(awk -v port="$port" '$2 == port { print $1; exit }' <<< "$listeners")
      if [ -n "$others" ]; then
        state=$(color.red "✖ 跟 ${others% } 重复")
        note='改掉其中一个游戏的端口'
        failed=1
      elif [ -z "$pid" ]; then
        state=$(color.dim '○ 空闲')
      else
        case "$(proc.cwd "$pid")/" in
          "$game_dir"/*)
            state=$(color.green '● 正在运行')
            note="关掉：make stop port=$port，或 make stop game=$name 关掉这个游戏的全部"
            ;;
          *)
            state=$(color.yellow "⚠ 被别的程序占着（$(proc.command "$pid")）")
            note="这个游戏用到它时会启动失败。关掉：make stop port=$port"
            ;;
        esac
      fi
    fi

    printf '    %s %s  %s\n' "$(color.dim "$(printf '%-14s' "$usage")")" "$(color.yellow "$(printf '%5s' "$port")")" "$state"
    if [ -n "$note" ]; then
      printf '%26s%s\n' '' "$(color.dim "$note")"
    fi
  done <<< "$rows"
done

if [ -n "$no_ports" ]; then
  echo
  no_ports=${no_ports# }
  printf '  %s\n' "$(color.dim "不用端口：${no_ports// /、}")"
fi

exit "$failed"
