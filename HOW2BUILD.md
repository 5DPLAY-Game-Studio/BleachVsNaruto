# 如何构建工程

本文件将简述构建本工程的全部方法。
您可以据此参考，进行完整编译代码流程。

## 环境需求

### 操作系统

- `Windows 10 1809` 或更高，建议 **Windows 10 22H2**。必须为 ***64*** 位操作系统。这是因为下述所需求的开发工具均已不支持早期 Windows 版本。

### 集成开发环境 (IDE)

Flash IDE - **必须**，用于构建 `BleachVsNaruto_FlashSrc` 目录下的 .fla/.xfl 文件。

- Adobe Animate 2020

Code IDE - 可选，依照您的开发喜好，选择合适的开发环境即可，本项目支持 **命令行** 编译。

- [Intellij IDEA 2023.1.7] - 如果使用此环境开发，您需要具有对应 Ultimate Edition 版本的许可证。
- [Microsoft Visual Studio Code] - 如果使用此环境开发，您需要 Java 17 的运行环境以运行 Flash 开发插件。（文档编辑中）

对应具体 IDE 插件参考 [构建要求](#构建要求) 章节。

### 开发工具包 (SDK)

FlexSDK - **必须**，编译工程必须使用它进行编译及打包。

- [flex4.16.1-air51.0.1.1] - 解压后推荐根目录名称为 ***flex4.16.1-air51.0.1.1***。

此 FlexSDK 非 Adobe 官方 SDK ，但使用官方 SDK 与第三方组件合并。详细的构建方法请参考 [BleachVsNaruto_FlexSDK]。

### 环境变量

**必须**，这些环境变量将被 `tools` 目录下的脚本文件等使用，缺失环境变量则脚本会无法正常工作。

- `FLEX_HOME` - 指向 FlexSDK 的全路径。例如：`FLEX_HOME=D:\sdk\flex4.16.1-air51.0.1.1`
- `FLASH_HOME` - 指向已安装 Animate/Flash 的全路径。例如：`FLASH_HOME=C:\Program Files\Adobe\Adobe Animate 2020`

## 构建要求

### 先决条件

若要编译本项目，最小化要求需要您必须安装 `Flash IDE`、下载 `FlexSDK` 和 设置 `环境变量`。
Code IDE 是可选项，其仅为您提供更好的开发体验，并非编译工程所必须的程序软件。

若您想使用 Code IDE 来丰富开发体验，则您可以按照如下操作来安装相关插件，并调整设置。

### Intellij IDEA

1. 安装插件
    - 安装插件 [Flash/Flex] （必须）和 [Chinese ​(Simplified)​ Language Pack / 中文语言包] （可选）
    - 可以在菜单 ***文件(F) -> 设置(T)... -> 插件*** 的内置插件市场中搜寻插件
2. 更新 SDK 设置
    - 在右键项目 ***BleachVsNaruto***，在弹出的菜单中选择 ***打开模块设置*** 项目，在弹出的 ***项目结构*** 对话框中选择  ***平台设置 -> SDK*** 选项，单击 【➕】 图标，选择 ***添加 Flex/AIR SDK...*** 选项，在弹出的 ***选择Flex/AIR SDK的主目录*** 对话框中选择已下载并解压完成的 FlexSDK [flex4.16.1-air51.0.1.1]（不要更改 SDK 的名称，请保持 ***flex4.16.1-air51.0.1.1***），单击 【确定】 按钮以完成导入
    - 右键项目 ***BleachVsNaruto***，在弹出的菜单中选择 ***打开模块设置*** 项目，在弹出的 ***项目结构*** 对话框中选择  ***项目设置 -> 模块*** 选项，在右侧列表中单击并展开 ***CORE_KernelLogic*** 目录，单击展开的 ***CORE_KernelLogic (lib)*** 条目，在右侧配置项中单击 ***依赖项***，单击 ***Flex/AIR SDK*** 右侧对应的下拉列表，将会看到一个 **红色无效** 的 ***flex4.16.1-air51.0.1.1***，选择最下方刚配置好未标红的 ***flex4.16.1-air51.0.1.1***选项，此时可看到该项红色波浪线已消除，按照如上步骤将剩余所有带有波浪线的项目更新 SDK 设置
    - 若已正确完成该步骤，在 ***项目结构*** 对话框中，***问题*** 列表已无提示
3. 导入素材同步工具
    - 执行 ***文件(F) -> 管理 IDE 设置 -> 导入设置***，在弹出的 ***导入文件的位置*** 对话框中选择工程目录下的 ***tools\idea_settings\5DPLAY_TOOLS.zip***，在弹出的 ***选择要导入的组件*** 对话框中单击【确认】按钮，按要求重启 IDEA

## 执行构建

在执行构建之前，您需要确认 TagAssets 是否已经手动覆盖到工程目录下。

### TagAssets 获取

- [BleachVsNaruto_TagAssets]  - 前往此仓库以下载对应 tag 标记的预编译二进制素材。
- 进入 [tags](https://github.com/5DPLAY-Game-Studio/BleachVsNaruto_TagAssets/tags) 页面，选择与本工程 [tags](https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/tags) **名称相同** 的资源，解压并覆盖于工程目录下。

在 TagAssets 中，仅包含了一些未开放源代码的编译二进制（SWF 文件），并不包含已经开放源代码的也就是 `BleachVsNaruto_FlashSrc` 目录下源文件的编译产物，
因此，您需要在本机编译源文件补齐缺失的 SWF/SWC 文件（重要，如果不执行此步骤，则会直接导致无法进行主程序的编译，其依赖此步的编译产物）。

### 构建项目

- 单击 ***构建(B) -> 构建项目(P)*** 选项或按下 ***Ctrl + F9*** 快捷键以快速构建工程

### 调试项目

- 单击 ***运行(U) -> 调试...*** 选项或按下 ***Alt + Shift + F9*** 快捷键，在弹出的 ***调试*** 菜单中选择 ***SHELL_Dev FighterTester***，编译完成片刻后将执行编译结果

[Intellij IDEA 2023.1.7]: https://download.jetbrains.com/idea/ideaIU-2023.1.7.exe?_gl=1*gtwm52*_gcl_aw*R0NMLjE3ODMzMDExMTcuQ2p3S0NBandnYWpTQmhCRUVpd0FTaWNKVTBmMmlqVGREVkVMeTJhdV9OZ3BHMGdKTXdaSVpVMkpwRDhGYVc3QXg4OUFTNlQ3NENGWE5Sb0N4U1VRQXZEX0J3RQ..*_gcl_au*MzkwNjQ2OTQ4LjE3ODAyODQxMDY.*FPAU*MzkwNjQ2OTQ4LjE3ODAyODQxMDY.*_ga*MTY1MTMxMDI1OS4xNzgwMjg0MTA2*_ga_9J976DJZ68*czE3ODQ3OTAzNzkkbzkkZzAkdDE3ODQ3OTA0MDEkajM4JGwwJGgw
[flex4.16.1-air51.0.1.1]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto_FlexSDK/releases/download/flex4.16.1-air51.0.1.1/flex4.16.1-air51.0.1.1.rar
[BleachVsNaruto_FlexSDK]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto_FlexSDK
[Flash/Flex]: https://plugins.jetbrains.com/plugin/14508-flash-flex
[Chinese ​(Simplified)​ Language Pack / 中文语言包]: https://plugins.jetbrains.com/plugin/13710-chinese-simplified-language-pack----
[BleachVsNaruto_TagAssets]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto_TagAssets
[Microsoft Visual Studio Code]: https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user
[README]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto_FlexSDK/blob/master/README.md
