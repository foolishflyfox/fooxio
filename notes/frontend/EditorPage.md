# EditorPage.tsx 代码分析

源码：[frontend/src/pages/EditorPage.tsx](../../frontend/src/pages/EditorPage.tsx)

## 页面职责

`EditorPage` 是编辑器页面的总装配处：它把顶部菜单和工具栏、左侧文件栏、代码编辑器、电路画布、编译输出、串口监视器、示波器及弹窗组合起来。具体的文件编辑、电路仿真和项目存储分别由对应组件、状态模块及服务完成；这个页面主要协调它们的布局、入口和交互。

## 页面启动与新建项目引导

页面挂载后，`startSimulation()` 启动电路仿真，并在卸载时清理；`restoreStashedWorkspace()` 尝试恢复登录跳转前暂存的工作区。

直接进入没有查询参数的 `/editor`，且工作区仍是程序自带的初始 Arduino Uno 示例时，页面会运行一次新建项目引导。它先检查原项目状态 `currentProject` 和服务器项目状态 `active`：任意一边已有打开的项目，就跳过引导，避免误清空项目。确认是初始状态后，`clearWorkspaceForStarter()` 清空开发板、文件、元件和导线；等“新功能”公告处理完，再显示 `NewProjectDialog`，供用户选空白工作区或开发板入门模板。关闭弹窗会留下空白工作区。

手动点击“新建工作区”则只先打开 `NewProjectDialog`；用户选择模板后才替换当前内容，直接取消不会清空工作区。

## 保存与打开项目

`handleSaveClick` 调用 `triggerSaveAction()`。顶部菜单、文件栏保存按钮和 Ctrl+S／Cmd+S 都进入同一保存入口；实际保存行为由保存动作模块决定。页面还将 `project.save`、`project.new` 和 `view.toggleExplorer` 注册为编辑器菜单命令。

`EditorPage` 将 `handleSaveClick`、`handleNewClick` 和 `autoSave` 传给 `FileExplorer`。开源版服务器项目的命名、列表和提示由页面挂载的 `ServerProjectHost` 显示；文件栏负责“打开项目”按钮，详细流程见 [FileExplorer.md](FileExplorer.md)。文件栏折叠时组件仍保持挂载，只隐藏其界面，以便菜单中的“打开项目”命令和本地文件选择器继续可用。

## 布局与面板

桌面端用 `viewMode` 切换“仅代码”“代码与电路”“仅电路”，并允许拖动分隔线调整两侧宽度；文件栏和底部面板也可以拖动调整大小。移动端通过标签切换代码与电路视图。`AppHeader` 装载菜单和统一工具栏，主区域分别装载 `CodeEditor` 与 `SimulatorCanvas`。

编译输出面板、串口监视器和示波器按各自的打开状态显示。`CompileProgressCard` 通常显示在电路画布上；画布隐藏时移到代码区域，避免编译进度一起被隐藏。页面还挂载 `NewsAnnouncer`、新建项目弹窗和 GitHub 提示横幅。
