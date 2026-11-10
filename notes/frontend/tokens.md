# tokens 文件夹

`frontend/src/tokens/` 存放前端的设计令牌（design tokens）：用 CSS 自定义属性统一命名颜色、间距、字体、圆角、阴影、动画时长和层级等设计值。组件通过 `var(--变量名)` 引用这些值，以便保持界面一致，并集中调整设计或切换主题。

目录按用途拆分为 `colors.css`、`spacing.css`、`typography.css`、`radius.css`、`elevation.css`、`motion.css` 和 `z-index.css`。`index.css` 集中导入这些文件，再由 `frontend/src/index.css` 引入应用。

## colors.css

`frontend/src/tokens/colors.css` 定义颜色体系，主要分为三层：

1. **基础色**：`--gray-*`、`--blue-*`、`--red-*` 等具体色值。灰色覆盖背景、面板、文字等多个明度；蓝色及状态色只定义当前界面需要的色阶。组件不应直接使用基础色。
2. **语义色**：`--color-bg-*`、`--color-fg-*`、`--color-action-*`、`--color-feedback-*` 等按用途命名的变量。组件使用这一层，例如 `color: var(--color-fg-default)`，无需自行决定深浅主题下的具体色值。
3. **旧名称兼容变量**：`--accent`、`--bg` 等映射到语义色，供尚未迁移的组件使用；新代码应使用语义色。

组件不直接使用基础色，是为了让颜色由用途决定，而不是由组件自行挑选色号。例如，主要按钮使用 `var(--color-action-primary)`，由语义色映射到 `--blue-600`；悬停时使用 `var(--color-action-primary-hover)`，深色主题映射到 `--blue-500`，浅色主题映射到 `--blue-700`。如果组件直接写 `var(--blue-500)`，切换主题后仍会使用同一个蓝色，后续调整配色也需要逐个检查组件。基础色因此作为语义色的色值来源，组件通常引用语义色。

深色主题是 `:root` 的默认值，也可由 `[data-theme='dark']` 指定；浅色主题由 `[data-theme='light']` 覆盖相应的语义色。基础色保持不变，主题切换主要改变语义色到基础色的映射。用户选择“跟随系统”时，系统偏好由 JavaScript 读取并设置主题，而不是在这个 CSS 文件中直接使用 `prefers-color-scheme`。
