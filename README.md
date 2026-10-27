# game-workspace

游戏开发工作区。

游戏各自是独立的 git 仓库，本仓库只作为开发的工作区。

## 游戏一览

| 游戏名   | 状态 | 技术栈                             | 端口段    |
| -------- | ---- | ---------------------------------- | --------- |
| tenebrae | 原型 | Web：three.js + React + TypeScript | 5100–5109 |

> 端口段从 5100 起，每个游戏最多占 10 个。

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
│   └── scripts/                Makefile 调用的脚本
├── games/
│   ├── .ignore                 让搜索工具看得到游戏文件
│   ├── games.list              游戏清单，不进 git
│   ├── games.list.example      清单的样例
│   └── <game>/                 拉下来的游戏，各自是独立的 git 仓库
├── .gitattributes
├── .gitignore
├── Makefile
└── README.md
```

## 命令

| 命令                     | 做什么                                          |
| ------------------------ | ----------------------------------------------- |
| `make`                   | 列出命令和游戏                                  |
| `make status`            | 看每个游戏有没有没提交、没 push 的              |
| `make pull`              | 按清单 clone 或 pull 游戏                       |
| `make dev game=<游戏名>` | 转发到游戏自己的 Makefile，`build`、`test` 同理 |

## 新开一个游戏

1. 建好游戏的仓库
2. 在 `games/games.list` 登记，游戏名用小写英文，定了不改
3. `make pull`
4. 在「游戏一览」加一行（不想公开的游戏不做第 4 步）。
