---
paths:
  - "Makefile"
  - "dev/scripts/**"
---

# 命令和脚本

- `Makefile` 只登记入口，每个目标上面用分隔框写 `# 目标：说明`（`make help` 读它）
- 逻辑写在 `dev/scripts/`，要能在 macOS 自带的 bash 3.2 上跑，开头固定 `#!/usr/bin/env bash`
- 文件名：`lib.<组>.sh` 放共用函数，`make.<命令>.sh` 是 Makefile 调用的命令（`dev` / `build` / `test` 共用 `make.run.sh`）
- 函数名：`<组>.<动作>`，组名和所在的 `lib.<组>.sh` 一致
- 变量名：共用的用大写 `<组>_<名字>`，临时的用小写
- 终端输出只用 `log.*` / `color.*`
