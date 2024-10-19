# 如何构建

本文件将简述如何构建本工程。

## 环境需求

### 操作系统

- Windows 7 SP1 或更高，建议 Windows 10。必须为 **64** 位操作系统。

### 软件

- [Intellij IDEA 2022.1.4] （构建源代码）
- Adobe Animate 2018 （构建 fla/xfl 文件）

### SDK

- FlexSDK [flex4.16.1-air50.2.4.1]（此 SDK 由 [Apache FlexSDK] 与 [Harman AirSDK] 合并得到）（解压后请保持根目录名称为 ***flex4.16.1-air50.2.4.1***）

## 构建要求

### Intellij IDEA 2022.1.4

1. 安装插件
    - 安装插件 [Flash/Flex] （必须）和 [Chinese ​(Simplified)​ Language Pack / 中文语言包] （可选）
    - 可以在菜单 ***文件(F) -> 设置(T)... -> 插件*** 的内置插件市场中搜寻插件
2. 更新 SDK 设置
    - 在右键项目 ***BleachVsNaruto***，在弹出的菜单中选择 ***打开模块设置*** 项目，在弹出的 ***项目结构*** 对话框中选择  ***平台设置 -> SDK*** 选项，单击 【➕】 图标，选择 ***添加 Flex/AIR SDK...*** 选项，在弹出的 ***选择Flex/AIR SDK的主目录*** 对话框中选择已下载并解压完成的 FlexSDK [flex4.16.1-air50.2.4.1]（不要更改 SDK 的名称，请保持 ***flex4.16.1-air50.2.4.1***），单击 【确定】 按钮以完成导入
    - 右键项目 ***BleachVsNaruto***，在弹出的菜单中选择 ***打开模块设置*** 项目，在弹出的 ***项目结构*** 对话框中选择  ***项目设置 -> 模块*** 选项，在右侧列表中单击并展开 ***CORE_KernelLogic*** 目录，单击展开的 ***CORE_KernelLogic (lib)*** 条目，在右侧配置项中单击 ***依赖项***，单击 ***Flex/AIR SDK*** 右侧对应的下拉列表，将会看到一个 **红色无效** 的 ***flex4.16.1-air50.2.4.1***，选择最下方刚配置好未标红的 ***flex4.16.1-air50.2.4.1***选项，此时可看到该项红色波浪线已消除，按照如上步骤将剩余所有带有波浪线的项目更新 SDK 设置
    - 若已正确完成该步骤，在 ***项目结构*** 对话框中，***问题*** 列表已无提示
3. 导入素材同步工具
    - 执行 ***文件(F) -> 管理 IDE 设置 -> 导入设置***，在弹出的 ***导入文件的位置*** 对话框中选择工程目录下的 ***tools\idea_settings\5DPLAY_TOOLS.zip***，在弹出的 ***选择要导入的组件*** 对话框中单击【确认】按钮，按要求重启 IDEA

### 标记资源 TagAssets

1. 在仓库 [BleachVsNaruto_TagAssets] 内可下载对应 tag 标记的完整二进制素材用于构建完整工程
2. 进入 [TagAssets\tag] 页面，选择与本工程 [BleachVsNaruto\tag] **名称相同**的资源，下载后将所有资源覆盖在本工程下

## 执行构建

### 构建项目

- 单击 ***构建(B) -> 构建项目(P)*** 选项或按下 ***Ctrl + F9*** 快捷键以快速构建工程

### 调试项目

- 单击 ***运行(U) -> 调试...*** 选项或按下 ***Alt + Shift + F9*** 快捷键，在弹出的 ***调试*** 菜单中选择 ***SHELL_Dev FighterTester***，编译完成片刻后将执行编译结果

[Intellij IDEA 2022.1.4]: https://download.jetbrains.com/idea/ideaIU-2022.1.4.exe?_gl=1*ctjhlb*_gcl_au*MTMxNjgyNzEyOC4xNzI0ODYxMjEz*_ga*MTE0MDQ4OTE2Ni4xNzI0ODYxMjEx*_ga_9J976DJZ68*MTcyODI2ODM2NC44LjEuMTcyODI2ODM3MC41NC4wLjA.
[flex4.16.1-air50.2.4.1]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto_FlexSDK/releases/download/flex4.16.1-air50.2.4.1/flex4.16.1-air50.2.4.1.7z
[Apache FlexSDK]: https://flex.apache.org/
[Harman AirSDK]: https://airsdk.harman.com/
[Flash/Flex]: https://plugins.jetbrains.com/plugin/14508-flash-flex
[Chinese ​(Simplified)​ Language Pack / 中文语言包]: https://plugins.jetbrains.com/plugin/13710-chinese-simplified-language-pack----
[BleachVsNaruto_TagAssets]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto_TagAssets
[TagAssets\tag]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto_TagAssets/tags
[BleachVsNaruto\tag]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/tags