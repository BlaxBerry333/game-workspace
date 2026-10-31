---
paths:
  - "games/*/{apps/web,apps/introduction,data,assets}/**"
  - "dev/playground/**"
---

# web 项目的目录

项目的 README 和它链接的文档跟这里冲突时先问我。新加文件时先按「怎么判断放哪」找位置。

## 项目根目录

- lint、format 的配置放 `configs/`，文件名不加点：`configs/oxlint.json`、`configs/prettier.json`、`configs/prettierignore`
  - oxlint：`package.json` 的命令里写 `-c configs/oxlint.json`
  - prettier：`package.json` 的命令里写 `--config configs/prettier.json --ignore-path .gitignore --ignore-path configs/prettierignore`，lint-staged 里的也一样
- 缓存都放 `.cache/`，不进 git：prettier 加 `--cache --cache-location .cache/prettier/cache.json`，tsc 的 `tsBuildInfoFile` 放 `.cache/tsc/`
- `npm test` 跑类型检查、lint、格式检查；游戏的 web 项目还按 schema 检查 `data/`（`scripts/validate-data.ts`，用 ajv）
- 游戏的 web 项目提交前用 husky 跑 lint-staged：暂存的文件做格式化和 lint，类型检查跑整个项目。lint-staged 的配置写在 `package.json` 的 `"lint-staged"` 里；lint-staged 会把文件名接在命令后面，tsc 收到文件名会报错，所以写成 `bash -c 'tsc -b'`。`package.json` 不在 git 仓库根目录时，`prepare` 写成从仓库根目录装 husky，钩子放在项目的 `.husky/`
- 一个 git 仓库只能装一套 husky（`core.hooksPath` 只有一个）。同一个游戏仓库里别的 web 项目也要检查时，加进已有的 `pre-commit`，不再装第二套
- 环境变量放 `envs/`，`vite.config.ts` 里设 `envDir`
  - `.env.production`：正式部署用，进 git
  - `.env.local`：本地开发用，不进 git。`make setup`、`make dev` 时没有就从 `.env.example` 复制
  - `.env.example`：模板，列出所有变量和说明，值是本地开发用的，进 git
  - 变量名全大写，单词用 `_` 连，前面加项目名和两个下划线：`<项目名>__<名字>`（比如 `TENEBRAE__BASE_PATH`），跟别的项目分开。这些只在 `vite.config.ts` 里用
  - 要打进前端包的在最前面再加 `VITE_`：`VITE_<项目名>__<名字>`。谁都看得到，不放密钥
  - 端口也是环境变量，用 `<项目名>__<用途>_PORT`（比如 `TENEBRAE__DEV_PORT`），`vite.config.ts` 里不写死端口号。游戏仓库的 `make ports` 也读这些（见 `dir.games.md`），文档里写端口号时注明是默认值
  - 代码里只在 `src/utils/helpers/env.ts` 读，写成 `ENV` 常量对象，缺了就报错；别的地方用 `ENV.<名字>`，不直接写 `import.meta.env.VITE_…`
- 版本号写在 `package.json` 的 `version`。构建日期、commit 这类打包时才知道的，在 `scripts/build-info.ts` 里生成，`vite.config.ts` 用 `define` 写进代码，只在 `src/utils/helpers/version.ts` 读。版本跟环境无关，不放 `envs/`
- `vite.config.ts` 只放设置。打包时要算的东西写在 `scripts/` 里，再导入进来；`scripts/` 放开发和打包用的脚本
- tsconfig、`vite.config.ts`、`package.json`、`index.html`、`.tool-versions`、`.gitignore` 留在根目录
- `public/` 只放必须有固定网址的：favicon、PWA 的 manifest 和图标
- E2E 测试和测试设置放 `tests/`

## src

| 目录 | 放什么 | 不放什么 |
|---|---|---|
| `main.tsx` | 入口，只负责挂载 | |
| `app/` | 根组件、全局 provider、画面状态机或路由 | 功能逻辑 |
| `views/`（有路由时 `pages/`） | 画面，把功能组件拼起来 | 逻辑、自己的 state |
| `features/<功能>/` | 一个功能的全部：组件、状态、类型、3D | 别的功能的东西 |
| `core/` | 通用的引擎部分：主循环、输入、渲染、资源加载、镜头 | React、这个项目专属的东西 |
| `ui/` | `components/` 基础组件、`styles/` 全局样式、`tokens/` 设计系统 | 游戏逻辑 |
| `utils/` | `helpers/` 函数、`hooks/` hooks，两个以上的地方共用的 | 只有一个地方用的 |
| `dev/` | `debug/` 开发工具、`mocks/` 假数据 | 正式功能 |

- 用到时才建目录
- 游戏的 web 项目：数据和素材不放 src，跟别的平台共用，放游戏仓库根目录的 `data/`、`assets/`
- `dev/playground/` 的试验：不跟别的平台共用，数据和素材放在试验自己的 `src/` 里，不用 `@data/`、`@assets/`

## 怎么判断放哪

| 问题 | 放哪 |
|---|---|
| 别的平台也要用的数据或素材吗？ | 游戏仓库根目录 `data/`、`assets/` |
| 换一个项目也能原样用吗？ | 引擎放 `core/`，界面放 `ui/` |
| 只跟一个功能有关吗？ | 那个功能的文件夹 |
| 两个以上的地方共用的函数或 hook？ | `utils/` |
| 是一整个画面吗？ | `views/` 或 `pages/` |
| 只有开发时用吗？ | `dev/` |

## 依赖方向

- `app` → `views` → `features` → `core` / `ui` / `utils`，只能往右用
- `@data/`、`@assets/` 谁都可以用
- `ui`、`core` 只能用 `utils`；`core` 不碰 React
- 功能之间只能通过对方的 `index.ts` 互相用
- 正式代码用 `dev/` 时只能用 `import.meta.env.DEV` 判断后动态导入，测试不受限

## features 里

```
features/<功能>/
├── components/                 这个功能的组件
├── 3d/                         three.js 的部分，有才建
├── <ClassName>.ts              类文件
├── <功能>.types.ts
├── <功能>.constants.ts
├── <功能>.helpers.ts
└── index.ts                    唯一出口
```

- 类文件按 `style.typescript.md` 用类名，其他逻辑文件用 `<功能>.<用途>.ts`

## 别名

| 别名 | 指向 |
|---|---|
| `@/` | 这个项目的 `src/` |
| `@data/` | 游戏仓库根目录 `data/` |
| `@assets/` | 游戏仓库根目录 `assets/` |

- 定义在 tsconfig 的 `paths`，Vite 用 `resolve.tsconfigPaths` 读，不在 `vite.config` 里另写 alias
- `vite.config` 的 `server.fs.allow` 放开到游戏仓库根目录，开发服务器才读得到 `data/`、`assets/`
- 不加别的别名

## 数据

- 统一用 JSON，结构以 `data/schema/` 的 JSON Schema 为准，每个 JSON 开头写 `$schema`。`npm test` 会检查；提交前的检查只管 web 项目里的文件，不查 `data/`
- 用 `@data/` 直接导入，不复制进 src
- 放进 `data/` 的：游戏内容和玩法规则（物品、配方、武器规格、数值、剧情文本）
- 留在代码里的：跟这个平台的画面和操作绑在一起的（动画名、镜头、界面文案、表现上的时长）

## 素材

- 放游戏仓库根目录 `assets/<类别>/`：`models/`、`environments/`、`textures/<名字>/`，2D 的图放 `images/`。文件名用小写加连字符。playground 的试验在自己的 `src/` 里也这样分
- 只用 CC0 或明确允许商用的素材，每加一个都在素材目录的 `CREDITS.md`（游戏是仓库根目录的 `assets/CREDITS.md`）记上来源和许可
- 用 `import url from '@assets/….glb?url'` 取网址再交给 loader，打包后文件名带 hash

## 测试

- 单元测试跟被测的文件放一起：`InventoryStore.test.ts`、`<功能>.helpers.test.ts`、`Menu.test.tsx`
- 假数据从 `src/dev/mocks/` 取
