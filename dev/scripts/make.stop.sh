#!/usr/bin/env bash
# ============================================================
# make stop
# game= 按进程的工作目录找，不用登记端口
# ============================================================
set -euo pipefail

WORKSPACE_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
source "$WORKSPACE_ROOT/dev/scripts/lib.color.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.log.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.game.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.port.sh"
source "$WORKSPACE_ROOT/dev/scripts/lib.proc.sh"

port=${1:-}
name=${2:-}

if [ -n "$port" ] && [ -n "$name" ]; then
  log.error "port= 和 game= 只能给一个"
  exit 2
fi

if [ -z "$port" ] && [ -z "$name" ]; then
  log.error "要指定端口或游戏：make stop port=<端口> 或 make stop game=<游戏名>"
  exit 2
fi

listeners=$(port.listeners)
pids=

if [ -n "$port" ]; then
  if ! port.valid "$port"; then
    log.error "端口要是 1 到 65535 的数字：$port"
    exit 2
  fi
  pids=$(awk -v port="$port" '$2 == port && !seen[$1]++ { print $1 }' <<< "$listeners")
  target=$port
else
  if ! game.exists "$name"; then
    log.error "没有这个游戏：$name"
    log.hint "现有游戏：$(game.list | tr '\n' ' ')"
    exit 2
  fi
  dir=$(cd "$(game.dir "$name")" && pwd -P)
  for pid in $(awk '!seen[$1]++ { print $1 }' <<< "$listeners"); do
    case "$(proc.cwd "$pid")/" in
      "$dir"/*) pids="$pids $pid" ;;
    esac
  done
  target=games/$name
fi

if [ -z "${pids// /}" ]; then
  printf '%s\n' "$(color.dim "没有进程在监听 $target")"
  exit 0
fi

failed=0
for pid in $pids; do
  ports=$(awk -v pid="$pid" '$1 == pid { print $2 }' <<< "$listeners" | sort -un | tr '\n' ' ')
  log.step "$(proc.command "$pid") · pid $pid · 端口 ${ports% }"
  if ! proc.stop "$pid"; then
    log.error "停不掉 pid $pid"
    failed=1
  fi
done
exit "$failed"
