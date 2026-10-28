---
paths:
  - "Makefile"
  - "dev/scripts/**"
  - ".gitignore"
  - ".gitattributes"
  - "games/.ignore"
  - "games/*.example"
  - "games/*/**/Makefile"
  - "games/*/**/*.sh"
  - "games/*/**/.gitignore"
  - "games/*/**/.gitattributes"
  - "dev/playground/**/Makefile"
  - "dev/playground/**/*.sh"
  - "dev/playground/**/.gitignore"
  - "dev/playground/**/.gitattributes"
  - "games/*/**/*.ts"
  - "games/*/**/*.tsx"
  - "dev/playground/**/*.ts"
  - "dev/playground/**/*.tsx"
---

# 注释

- 只写代码看不出来的东西：为什么这么做、单位、坐标方向、踩过的坑。不写废话、不复述代码
- 不写行尾注释

## `#` 注释

- 只用分隔框写，不写散的注释。标题一行，需要时再加一两行说明

  ```
  # ============================================================
  # 标题
  # 说明
  # ============================================================
  ```

## TS 注释

- 需要说明时，导出的函数、类、类型、类的公开方法、带单位的字段用 `/** */`，编辑器悬停时能看到。不是每个都要写
- 函数体里用 `//`，写在要说明的那行上面
- 不用分隔框分段，一个文件一组，文件本身就是分段
