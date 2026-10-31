# game-workspace

[![Bash](https://img.shields.io/badge/Bash-20232A?logo=gnubash&logoColor=4EAA25)](https://www.gnu.org/software/bash/)
[![GNU Make](https://img.shields.io/badge/GNU_Make-20232A?logo=gnu&logoColor=A42E2B)](https://www.gnu.org/software/make/)
[![Claude Code](https://img.shields.io/badge/Claude_Code-20232A?logo=claude&logoColor=D97757)](https://www.anthropic.com/claude-code)

游戏开发工作区。

游戏各自是独立的 git 仓库，本仓库只作为开发的工作区。

## 目录

```
game-workspace/
├── .claude/
│   ├── CLAUDE.md
│   ├── launch.json             Claude 启动开发服务器用的配置，不进 git
│   ├── rules/                  按需加载的规范
│   └── skills/
├── .vscode/                    各游戏通用的设置和推荐插件
├── dev/                        不属于任何一个游戏的东西
│   ├── ideas/                  随手记，不定规矩
│   ├── playground/             技术试验，一个试验一个文件夹，各自能单独跑，不进 git
│   └── scripts/                Makefile 调用的脚本
├── games/
│   ├── .ignore                 让搜索工具看得到游戏文件
│   ├── games.list              游戏清单，不进 git
│   ├── games.list.example      清单的样例
│   └── <game>/                 拉下来的游戏，各自是独立的 git 仓库
├── .gitattributes
├── .gitignore
├── Makefile
├── README.md
└── TODO.md                     待办和各游戏的进度，不进 git
```

## 命令

| 命令                     | 做什么                                                         |
| ------------------------ | -------------------------------------------------------------- |
| `make`                   | 列出命令和游戏                                                 |
| `make add`               | 一问一答登记一个游戏，可以接着 clone 并跑 `setup`              |
| `make setup`             | 准备清单，clone 还没有的游戏，跑各游戏的 `setup`；可加 `game=` |
| `make status`            | 看每个游戏有没有没提交、没 push 的                             |
| `make pull`              | 更新已经 clone 下来的游戏                                      |
| `make dev game=<游戏名>` | 转发到游戏自己的 Makefile，`build`、`test` 同理                |
| `make stop`              | 关掉进程：`port=<端口>` 或 `game=<游戏名>`                     |

## 新开一个游戏

1. 建好游戏的仓库
2. `make add`：按提示填游戏名（小写英文、数字，用 `-` 连）和仓库地址，确认后写进 `games/games.list`，可以接着 clone 并跑 `setup`
   - 也可以直接编辑 `games/games.list`，再跑 `make setup game=<游戏名>`
