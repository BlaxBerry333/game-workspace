---
paths:
  - "games/*/**/*.tsx"
  - "dev/playground/**/*.tsx"
  - "games/*/**/components/**"
  - "dev/playground/**/components/**"
---

# React

项目的 README 跟这里冲突时先问我。

## 组件

- `function` 声明、具名导出：`export function Menu(props: MenuProps) {}`
- 不用 `export default`、`forwardRef`
- 子组件挂在父组件上：`Menu.Item = MenuItem`，外面写 `<Menu.Item>`
- 一个 `.tsx` 只放一个组件，要写小组件时建子组件文件夹
- 组件超过 100 行（包括 JSX）就拆子组件

## props

- 用 `type`，名字叫 `组件名Props`
- 在参数里解构，默认值写在解构里
- 对象、数组的默认值提到组件外面写成常量，不写 `items = []`
- 回调 prop：`on` + 对象 + 动作，比如 `onItemSelect`，不写 `onSelect`
- 处理函数：`handle` + 对象 + 动作，比如 `handleItemSelect`
- `base` 里包装原生元素的组件，保留原生的 `onClick`、`onChange`

## 目录

```
src/components/
├── base/                       基础组件，不含游戏逻辑
│   └── Menu/
│       ├── index.ts            唯一出口
│       ├── Menu.tsx
│       ├── Menu.types.ts
│       ├── Menu.constants.ts
│       ├── Menu.hooks.ts
│       ├── Menu.helpers.ts     纯函数，不碰 React
│       ├── Menu.module.scss
│       └── MenuItem/           子组件，结构同上
└── features/                   功能组件，可以用 base
```

- 每个组件一个文件夹，配套文件需要时才建
- `组件名.tsx` 只导出组件，hooks 放 `.hooks.ts`
- 子组件的文件夹放在父组件文件夹里，外面只能通过父组件用
- 外面只能导入到 `base/<组件>`、`features/<组件>` 这一层，不能往里导入
- 组件文件夹里面（包括子组件）互相导入用 `@/` 完整路径，不算往里导入
- `base` 不能导入 `features`
- 不建汇总整个 `components/` 的 `index.ts`

## state

- 只有这个组件用：组件里的 state
- 互不相关的 state 分开 `useState`，一起变的用一个对象或 `useReducer`
- 很少变、很多地方用的（设置、语言、主题）：context
- 每帧都变的游戏数据：不进 React，放外部 store，用 `useSyncExternalStore` 只订阅需要的部分

## useEffect

- 只用来跟 React 外面的东西同步，比如挂 three.js 渲染器、加 DOM 事件监听
- 必须写清理函数，three.js 的对象在清理里 `dispose`
- 不用来算派生值，能算出来的在渲染时直接算
- 不放事件逻辑，用户操作引起的事写在 `handleXxx` 里

## 懒加载

- 在 `features` 这一层做：

  ```ts
  const Settings = lazy(() =>
    import('@/components/features/Settings').then((m) => ({ default: m.Settings })),
  )
  ```
