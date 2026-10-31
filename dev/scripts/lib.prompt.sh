# ============================================================
# 终端里的问答
# 要先 source lib.color.sh、lib.log.sh。问题写到 stderr，$( ) 收回答时也能看到问题
# ============================================================

# ============================================================
# prompt.ask <问题>：读一行，去掉前后空白后输出。读到输入结束（Ctrl-D）时返回 1
# ============================================================
prompt.ask() {
  local answer COLOR_TO_STDERR=1
  printf '%s' "$(color.bold "$1")" >&2
  if ! IFS= read -r answer; then
    printf '\n' >&2
    return 1
  fi
  answer=${answer#"${answer%%[![:space:]]*}"}
  answer=${answer%"${answer##*[![:space:]]}"}
  printf '%s' "$answer"
}

# ============================================================
# prompt.confirm <问题> <y|n>：第二个参数是直接回车时的默认值。是返回 0，否返回 1
# 读到输入结束时直接退出脚本
# ============================================================
prompt.confirm() {
  local answer choices
  if [ "$2" = y ]; then choices='[Y/n]'; else choices='[y/N]'; fi
  while true; do
    answer=$(prompt.ask "$1 $choices: ") || exit 1
    case "$answer" in
      '') [ "$2" = y ] && return 0 || return 1 ;;
      y | Y | yes) return 0 ;;
      n | N | no) return 1 ;;
      *) log.warn '回答 y 或 n' ;;
    esac
  done
}
