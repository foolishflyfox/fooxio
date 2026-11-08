# FileExplorer.tsx 代码分析

源码：[frontend/src/components/editor/FileExplorer.tsx](../../frontend/src/components/editor/FileExplorer.tsx)

## 组件职责

`FileExplorer` 是编辑器左侧的 **WORKSPACE** 文件栏。它按开发板展示文件和文件夹，也展示自定义芯片的文件组；用户可在这里切换当前开发板或文件、新建和重命名文件与文件夹，以及删除文件。开发板、元件和连线等信息来自 `useSimulatorStore`，文件组、当前文件及文件操作来自 `useEditorStore`。组件还通过 `registerEditorCommand` 响应菜单中的“打开项目”和“新建文件”命令。

## 顶部三个按钮

从左到右分别是**新建工作区**、**打开项目**和**保存项目**。新建和保存按钮调用父组件传入的 `onNewClick`、`onSaveClick`；文件栏本身不决定如何创建或保存项目。`autoSave` 存在时，保存按钮还会显示保存状态。

“打开项目”按钮由 `handleOpenProjectClick` 处理。开源版网页调用 `openServerProjects()`，显示当前服务器已保存的项目列表；Pro 或桌面版则调用 `fileInputRef.current?.click()`，直接打开系统文件选择窗口。`useCallback(..., [])` 保持这个处理函数的引用稳定，避免注册菜单命令的 effect 在每次渲染后重新执行。

## 服务器项目列表与本地文件选择器

服务器项目列表在 `ServerProjectHost` 中，不在 `FileExplorer` 中。列表弹窗的“打开本地文件”按钮会向 `window` 发出 `velxio-open-local-project` 事件；`FileExplorer` 中的 `useEffect` 监听此事件，再点击它持有的隐藏 `<input type="file">`。这样两个组件可以共用原有的本地导入流程。effect 返回的函数会在组件卸载时移除监听。

`fileInputRef` 是指向该隐藏输入框的 React ref。`current?.click()` 中的 `?.` 表示输入框尚未挂载时跳过调用。选中文件后，`handleProjectFilePicked` 先确认是否覆盖当前工作区，再交给 `importProjectFile`：`.vlx` 由导入函数直接加载到编辑器和仿真状态；Wokwi `.zip` 返回解析结果，由文件栏应用开发板、文件、元件和连线。导入失败会显示错误对话框。

## 已存在的类型报错

`BOARD_ICON` 和 `BOARD_COLOR` 声明为 `Record<BoardKind, string>`，但未列出 `BoardKind` 定义的全部开发板类型，因此 TypeScript 会在这两个声明处报告缺少属性。这两个对象及其报错在服务器项目列表功能加入前就已存在，与上述打开项目逻辑无关。
