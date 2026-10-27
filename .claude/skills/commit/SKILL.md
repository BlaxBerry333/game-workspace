---
name: commit
description: 要写 commit message 时用。规定 commit message 的写法，以及写好后交给用户自己提交
---

# commit

- 按暂存区的实际改动写（`git diff --cached`），工作区还有没暂存的改动时提醒我
- 用中文，类型前缀用英文（`chore` / `feat` / `fix` 等）
- 标题写改了什么、怎么改的，不能只写做了哪类事
  - × `fix: 修 bug`
  - ○ `fix: 清单最后一行没有换行时会漏读，改成也能读到`
- 改了好几处时，正文用列表把每一处都简短写出来
- 只写现在是什么样，不写改的经过
- 不带 Claude 的署名（`Co-Authored-By` 等）
- 写好后贴给我过目，由我自己提交。不运行 `git commit`、`git push`
