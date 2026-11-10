# tokens 文件夹

`frontend/src/tokens/` 存放前端的设计令牌（design tokens）：用 CSS 自定义属性统一命名颜色、间距、字体、圆角、阴影、动画时长和层级等设计值。组件通过 `var(--变量名)` 引用这些值，以便保持界面一致，并集中调整设计或切换主题。

目录按用途拆分为 `colors.css`、`spacing.css`、`typography.css`、`radius.css`、`elevation.css`、`motion.css` 和 `z-index.css`。`index.css` 集中导入这些文件，再由 `frontend/src/index.css` 引入应用。

## colors.css

`frontend/src/tokens/colors.css` 定义颜色体系，主要分为三层：

1. **基础色**：`--gray-*`、`--blue-*`、`--red-*` 等具体色值。灰色覆盖背景、面板、文字等多个明度；蓝色及状态色只定义当前界面需要的色阶。组件不应直接使用基础色。
2. **语义色**：`--color-bg-*`、`--color-fg-*`、`--color-action-*`、`--color-feedback-*` 等按用途命名的变量。组件使用这一层，例如 `color: var(--color-fg-default)`，无需自行决定深浅主题下的具体色值。
   - `bg`：页面底色、各层容器、输入框、遮罩和顶栏的背景。
   - `fg`：正文、弱化文字及操作按钮上的前景色。
   - `border`：默认、强调和弱化的边框颜色。
   - `wash`：悬停、按下和选中时叠加在背景上的半透明颜色。
   - `action`：主要和次要操作的填充色、悬停色及主要操作的文字色。
   - `accent`：强调元素的文字、浅色背景和边框，常用于选中或激活状态。
   - `feedback`：错误、成功、警告和信息提示的颜色，以及提示区域的浅色背景和边框。
   - `focus`：键盘焦点的外框（`--color-focus-ring`）。
   - `tier`：免费版、Pro 版和团队版的标识颜色。
   - `canvas`：模拟器画布、网格、面板、标签背景及阴影。
   - `symbol`：画布中电路符号的线条、引脚、标签和主体颜色。
   - `wire`：导线的对比轮廓及悬停、选中标记颜色。
   - `probe`：直流、交流及错误测量标注的颜色。
   - `terminal`：串口终端的背景和文字颜色。
   - `scrollbar`：滚动条滑块、悬停滑块和轨道的颜色。
   - `--wb-*`：工作台界面（workbench) 的背景、面板、边框和文字色阶，按界面层次排列，随主题切换。
3. **旧名称兼容变量**：`--accent`、`--bg` 等映射到语义色，供尚未迁移的组件使用；新代码应使用语义色。

组件不直接使用基础色，是为了让颜色由用途决定，而不是由组件自行挑选色号。例如，主要按钮使用 `var(--color-action-primary)`，由语义色映射到 `--blue-600`；悬停时使用 `var(--color-action-primary-hover)`，深色主题映射到 `--blue-500`，浅色主题映射到 `--blue-700`。如果组件直接写 `var(--blue-500)`，切换主题后仍会使用同一个蓝色，后续调整配色也需要逐个检查组件。基础色因此作为语义色的色值来源，组件通常引用语义色。

深色主题是 `:root` 的默认值，也可由 `[data-theme='dark']` 指定；浅色主题由 `[data-theme='light']` 覆盖相应的语义色。基础色保持不变，主题切换主要改变语义色到基础色的映射。用户选择“跟随系统”时，系统偏好由 JavaScript 读取并设置主题，而不是在这个 CSS 文件中直接使用 `prefers-color-scheme`。

## spacing.css

`frontend/src/tokens/spacing.css` 定义 `--space-0` 到 `--space-16` 的间距等级，供内边距、外边距和元素间距使用，例如 `gap: var(--space-6)`。数值从 0 到 160px，小尺寸间隔更密；变量编号表示相对大小，不等于固定倍数。

## typography.css

`frontend/src/tokens/typography.css` 声明 Inter 和 JetBrains Mono 字体及系统字体回退，并用 `--font-sans`、`--font-mono` 区分正文和等宽字体。`--text-*` 将字重、字号、行高和字体组合成从说明文字到大标题的排版样式，可写作 `font: var(--text-body)`；`--tracking-*` 控制字距。

## radius.css

`frontend/src/tokens/radius.css` 定义 `--radius-xs` 到 `--radius-2xl` 的圆角尺寸，分别适用于标签、输入框、卡片、弹窗等不同大小的界面元素；`--radius-pill` 用于胶囊形按钮或徽章。`--radius` 和 `--radius-pill-old` 是旧名称兼容变量。

## elevation.css

`frontend/src/tokens/elevation.css` 定义 `--shadow-flat` 与 `--shadow-1` 到 `--shadow-4` 的阴影层级，供卡片、下拉菜单、弹窗等表达不同的悬浮高度。浅色主题使用更淡的阴影；`--shadow`、`--shadow-sm` 是旧名称兼容变量。

## motion.css

`frontend/src/tokens/motion.css` 定义 `--duration-fast`、`--duration-base`、`--duration-slow` 三档动画时长，以及 `--ease-*` 缓动曲线，供悬停反馈、普通过渡和弹窗开合等使用。还提供 `--transition-color`、`--transition-transform`、`--transition-opacity` 常用过渡组合；用户偏好减少动态效果时，时长会缩短到 1ms。

## z-index.css

`frontend/src/tokens/z-index.css` 定义 `--z-base` 到 `--z-tooltip` 的叠放层级，依次用于基础内容、下拉菜单、吸顶元素、遮罩、弹窗、浮层、提示消息和工具提示。组件通过这些变量设置 `z-index`，避免自行填写层级数字。

## index.css

`frontend/src/tokens/index.css` 按顺序导入上述令牌文件，作为统一入口；还为 `:focus-visible` 元素应用 `--color-focus-ring` 全局焦点样式。
