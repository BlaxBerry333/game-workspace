---
name: commit
description: 要写 commit message 时用。规定 commit message 的写法，以及写好后交给用户自己提交
---

# commit

- 按暂存区的实际改动写（`git diff --cached`），工作区还有没暂存的改动时提醒我
- 用中文，类型前缀用英文（`chore` / `feat` / `fix` 等）
- 标题一行，简单概括这次改的范围，细节不放标题
  - ○ `docs: 更新 claude code 开发规范`、`feat: 增加 make stop 命令`
  - × `fix: 修 bug`（连改的是哪块都看不出）
- 正文分条写，一条一句短话，只写改了哪样东西，不展开细节
  - ○ `- 新增 React 规范`
  - × `- style.react.md：组件和 props、一个文件一个组件、components 分 base 和 features……`
- 我定了的标题照用，不再要求改
- 只写现在是什么样，不写改的经过
- 不带 Claude 的署名（`Co-Authored-By` 等）
- 写好后贴给我过目，由我自己提交。不运行 `git commit`、`git push`
