---
paths:
  - "Makefile"
  - "dev/scripts/**"
  - "games/*/{Makefile,scripts/**}"
---

# 命令和脚本

工作区和游戏仓库的 Makefile、脚本都按这里写。

- `Makefile` 只登记入口，每个目标上面用分隔框写 `# 目标：说明`（`make help` 读它）
- 逻辑写在工作区的 `dev/scripts/`、游戏仓库根目录的 `scripts/`，要能在 macOS 自带的 bash 3.2 上跑，开头固定 `#!/usr/bin/env bash`
- 文件名：`lib.<组>.sh` 放共用函数，`make.<命令>.sh` 是 Makefile 调用的命令（`dev` / `build` / `test` 共用 `make.run.sh`；工作区的 `setup` 指定游戏时也转给它）
- 函数名：`<组>.<动作>`，组名和所在的 `lib.<组>.sh` 一致
- 变量名：共用的用大写 `<组>_<名字>`，临时的用小写
- 变量后面紧跟中文或全角符号时写成 `${变量}`：终端是 UTF-8 时，bash 3.2 会把全角字符当成变量名的一部分，`$want，` 会报变量未定义
- 终端输出只用 `log.*` / `color.*`
  - 单独一行的结果用 `log.ok`、`log.warn`、`log.error`，带颜色和「✔ 完成」「⚠ 警告」「✖ 错误」前缀；警告和错误走 stderr
  - 下一步怎么做用 `log.hint`，跟在警告、错误后面
  - 表格里每行的状态用 `color.*`
  - `setup` 这类准备步骤，已经就绪、不用做的也用 `log.ok` 说一声
  - 自己往 stderr 写带颜色的内容时，函数里先 `local COLOR_TO_STDERR=1`，颜色才按 stderr 是不是终端来判断
- 脚本都 source `lib.log.sh`：命令意外失败时它会报出哪个脚本、哪条命令。预料中会失败的命令放在 `if`、`||` 里自己处理
- 游戏仓库的 `lib.color.sh`、`lib.log.sh` 是从工作区复制的，改了要同步
