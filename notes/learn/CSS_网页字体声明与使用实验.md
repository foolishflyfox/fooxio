# 网页字体：从空文件夹实验 `@font-face`

这篇教程用一个只有 HTML、CSS 和字体文件的小网页，观察字体声明、字体使用和加载策略的区别。每个实验都从同一份基础代码出发；完成一项后，请恢复原代码再做下一项。

## 1. 准备实验目录

需要浏览器、Node.js 和 npm。以下命令在**本仓库根目录**执行，`webfont-lab` 是新建的空文件夹：

```sh
mkdir webfont-lab
cd webfont-lab
mkdir fonts
cp ../frontend/public/fonts/Inter.var.woff2 fonts/
```

接下来在 `webfont-lab` 中创建两个空文件：`index.html` 和 `style.css`。完成后目录应为：

```text
webfont-lab/
├── index.html
├── style.css
└── fonts/
    └── Inter.var.woff2
```

这里复用本仓库已有的 Inter 字体文件。字体来源和许可说明见 `frontend/public/fonts/README.md`。实验网页放在仓库根目录，方便使用上面的相对路径；实验结束后可自行删除 `webfont-lab`。

## 2. 写一个对照页面

将以下内容粘贴到 `index.html`：

```html
<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>网页字体实验</title>
    <link rel="stylesheet" href="./style.css" />
  </head>
  <body>
    <main>
      <h1>网页字体实验</h1>
      <p>两组文字内容相同。观察字体形状和字重的变化。</p>

      <section class="sample system">
        <h2>系统后备字体</h2>
        <p class="weight-100">
          100 · The quick brown fox jumps over 1234567890
        </p>
        <p class="weight-400">
          400 · The quick brown fox jumps over 1234567890
        </p>
        <p class="weight-700">
          700 · The quick brown fox jumps over 1234567890
        </p>
        <p class="weight-900">
          900 · The quick brown fox jumps over 1234567890
        </p>
        <p class="italic">Italic · The quick brown fox jumps over 1234567890</p>
      </section>

      <section class="sample inter">
        <h2>本地 Inter 字体</h2>
        <p class="weight-100">
          100 · The quick brown fox jumps over 1234567890
        </p>
        <p class="weight-400">
          400 · The quick brown fox jumps over 1234567890
        </p>
        <p class="weight-700">
          700 · The quick brown fox jumps over 1234567890
        </p>
        <p class="weight-900">
          900 · The quick brown fox jumps over 1234567890
        </p>
        <p class="italic">Italic · The quick brown fox jumps over 1234567890</p>
      </section>
    </main>
  </body>
</html>
```

将以下内容粘贴到 `style.css`：

```css
@font-face {
  font-family: "Inter";
  src:
    url("/fonts/Inter.var.woff2") format("woff2-variations"),
    url("/fonts/Inter.var.woff2") format("woff2");
  font-weight: 100 900;
  font-style: normal;
  font-display: swap;
}

:root {
  --font-sans: "Inter", Arial, sans-serif;
}

body {
  margin: 0;
  background: #f3f5f8;
  color: #17212f;
  font-family: Arial, sans-serif;
}

main {
  max-width: 900px;
  margin: 40px auto;
  padding: 0 20px;
}

.sample {
  margin: 24px 0;
  padding: 16px 24px;
  border: 1px solid #ccd3dd;
  border-radius: 12px;
  background: white;
}

.sample h2 {
  font-size: 18px;
}

.sample p {
  font-size: 20px;
  white-space: nowrap;
}

.system {
  font-family: Arial, sans-serif;
}

.inter {
  font-family: var(--font-sans);
}

.weight-100 {
  font-weight: 100;
}
.weight-400 {
  font-weight: 400;
}
.weight-700 {
  font-weight: 700;
}
.weight-900 {
  font-weight: 900;
}
.italic {
  font-style: italic;
}
```

`@font-face` 是 CSS 标准的 **@规则**（at-rule），用于**登记**字体：告诉浏览器 `'Inter'` 对应哪个文件、哪些字重和样式。它不会自动把字体应用到页面；`.inter { font-family: var(--font-sans); }` 才是**使用**字体。CSS 变量 `--font-sans` 保存的是字体候选列表：先尝试 Inter，不能用时再尝试 Arial，最后尝试系统的无衬线字体。

## 3. 用 `http-server` 打开网页

保持终端位于 `webfont-lab` 目录，运行：

```sh
npx http-server -p 8080 -c-1
```

首次执行 `npx` 可能提示下载 `http-server`，按提示确认。浏览器打开 `http://localhost:8080/`。`-p 8080` 指定端口，`-c-1` 禁用 HTTP 缓存，方便观察修改后的效果。完成实验可在终端按 `Ctrl+C` 停止服务器。

> 必须通过这个本地服务器打开页面。不要直接双击 `index.html` 用 `file://` 打开：这里的 `/fonts/...` 是相对于网站根路径的 URL，而网站根路径由服务器提供。

## 4. 先确认字体真的加载了

打开浏览器开发者工具，切到 **Network（网络）**，刷新页面，筛选 `Font` 或搜索 `Inter.var.woff2`。应看到字体请求成功，通常状态为 `200`。两个 `src` 候选指向同一个文件，正常情况下**不会因此下载两次**。

再选中下方“本地 Inter 字体”的文字，在 **Elements/Inspector（元素）** 的字体信息中查看 **Rendered Fonts（实际渲染字体）**。应看到 Inter；上方对照组应是 Arial 或系统后备字体。不同浏览器的面板名称略有差异。如果看不到字体请求，请先确认 Network 面板已打开，然后勾选 **Disable cache（禁用缓存）** 并刷新；也可以检查 Elements 中的实际渲染字体。

页面上的中文字符可能由系统字体显示，因为 Inter 不一定包含这些字形；实验重点观察英文和数字。

## 5. 逐项修改，观察各配置的作用

每次修改 `style.css` 后刷新页面。建议同时看页面、Network 请求和实际渲染字体。

### 实验 A：声明不等于使用

暂时删除或注释 `.inter` 中的 `font-family: var(--font-sans);`。下方文字会继承 `body` 的 Arial，看起来更接近上方对照组；`@font-face` 虽然仍在文件里，但如果没有其他地方使用 Inter，浏览器通常也不会下载它。恢复该行后，字体再次被使用。

### 实验 B：`font-family` 是登记名称

只把 `@font-face` 中的 `font-family: 'Inter'` 改为 `font-family: 'My Inter'`，不要改 `--font-sans`。候选列表仍在找 `'Inter'`，两者名称不匹配，下方会落到 Arial。再把 `--font-sans` 的第一项改成 `'My Inter'`，字体恢复。实验后将两处都改回 `'Inter'`。

### 实验 C：`src` 与 `/` 开头的路径

将两个 `url()` 中的文件名都临时改为 `Missing.woff2`。刷新后，Network 中会出现失败的字体请求，下方文字使用后备字体。恢复文件名后再次刷新，应看到请求成功。`/fonts/Inter.var.woff2` 指向网站根目录下的 `fonts` 文件夹；`style.css` 所在目录不会改变这个 `/` 开头 URL 的基准。

### 实验 D：为什么 `src` 写两个 `format()`

`url()` 写的是字体文件地址；紧随其后的 `format()` 是给浏览器看的**格式提示**，不是转换字体文件的函数。浏览器可以依据提示跳过不支持的候选来源。**WOFF2 是字体文件格式，`woff2-variations` 不是另一种文件格式**：它是旧式的 `format()` 提示，表示“WOFF2 格式，并使用可变字体技术”，相当于较新的 `format(woff2) tech(variations)`。因此这两项 URL 指向的是同一份 `.woff2` 文件；第二项只标明 WOFF2 格式，让不认识第一种提示、但支持 WOFF2 的浏览器仍有机会使用它。浏览器按顺序选用一个可用来源，通常不会为这两项下载两遍相同的文件。[参见 W3C CSS Fonts 规范](https://www.w3.org/TR/css-fonts-4/)和 [MDN 的 `src` 说明](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@font-face/src)。

先只保留 `format('woff2')` 的那一项，刷新并确认仍能显示 Inter；支持可变字体的现代浏览器仍可使用它的不同字重。再只保留 `format('woff2-variations')` 的那一项：如果浏览器认识这个提示，页面通常也没有可见变化；如果不认识，可能跳过该来源，改用 `font-family` 中的 Arial 等后备字体。最后恢复原来的两项。**只保留一项并不会改变字体文件本身**，改变的是浏览器识别该来源的兼容机会。

### 实验 E：`font-weight: 100 900` 是字体支持范围

保留 `font-weight: 100 900`，比较 Inter 组的 100、400、700、900 四行：一个可变字体文件可以提供这些字重。CSS 规定字重数字的有效范围为 1～1000，其中 400 对应 `normal`，700 对应 `bold`；**这里选择 100～900 是因为 Inter 的字重轴支持这个范围，并非所有字体都必须支持 100～900**。然后把 `@font-face` 中的范围暂时改为 `font-weight: 400`，刷新并比较。浏览器会把这份字体登记为 400 字重；请求其他字重时，浏览器可能选择最接近的字体、合成效果或使用后备字体，具体外观由浏览器决定。因此不能仅凭“看起来仍然很粗”判断范围是否生效。

还可以删除 `@font-face` 中的 `font-weight` 整行，再刷新比较。字体仍能加载，因为 `font-family` 和 `src` 已足够声明这个字体；Inter 文件中的可变字重轴也不会因为删掉 CSS 描述符而消失。按 CSS Fonts Level 4，省略时描述符取 `auto`：字体匹配时按普通字重看待，但不会用描述符限制可变轴，因此各行仍可能显示不同粗细。明确写 `100 900`，则向浏览器声明这条字体规则支持整个范围；同一家族有多份字体文件时，这对选择正确文件尤其重要。完成后恢复 `font-weight: 100 900`。[CSS Fonts Level 4](https://www.w3.org/TR/css-fonts-4/)

在 Chrome 或 Edge 中，按 `F12`，用“选择元素”图标选中 Inter 组的 `100` 或 `900` 那一行；在 **Elements → Computed** 查看 `font-weight`，滚动到底部的 **Rendered Fonts** 查看实际使用的字体。`Computed` 显示 CSS 请求值，`Rendered Fonts` 显示字体名称，二者都不能单独证明字体内部实际使用的 `wght` 轴值。Firefox 的 **检查器 → Fonts** 可直接查看可变字体轴。

### 实验 F：`font-style: normal` 只声明正常样式

观察 Inter 组最后的 Italic 行。当前 `@font-face` 只声明了 `normal`，没有单独登记 Inter 的斜体文件。浏览器可能模拟倾斜，也可能选择后备字体。将 `.italic` 改为 `font-style: normal`，观察倾斜消失，再恢复 `italic`。这个实验说明 `font-style: normal` 描述的是**字体文件的样式**，不是要求整页文字都保持正体；想要真正的 Inter 斜体，需要另行提供对应字体文件并写一条斜体 `@font-face`。

### 实验 G：`font-display: swap` 控制加载期间的显示

打开 Network，勾选 **Disable cache**，选择较慢的网络速度（如 Slow 3G），刷新页面。`swap` 会尽快显示后备字体，Inter 加载完成后再切换；如果网络或缓存太快，切换可能一闪而过。可临时将 `swap` 改为 `block` 对比：字体加载初期可能有短暂的文字不可见阶段。具体持续时间由浏览器决定。完成后恢复 `swap`，并关闭网络限速。

## 6. 回到原项目

本实验里的主要声明对应 `frontend/src/tokens/typography.css` 中的 Inter `@font-face`。原项目的 `--font-sans` 还加入了更多系统字体作为后备，并在 `frontend/src/index.css` 中通过 `font-family: var(--font-sans)` 应用到页面。现在可以把实验中看到的三个环节对应起来：**字体文件 → `@font-face` 登记 → `font-family` 使用**。
