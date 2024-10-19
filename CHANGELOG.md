# 更新日志

本项目的所有重要变更都将会记录在此文件中。

## [3.7.0.0.10192024_alpha] - 2024-10-19

### 新增

- 新增旧版（3.3）以前的版本使用键盘事件相应对话框

### 更改

- 重构相关逻辑，梳理一般对话框和特殊（无双）对话框

## [3.7.0.0.10132024_alpha] - 2024-10-13

### 新增

- 游戏语言设置场景
- 初始化 LIB_PclLib 模块

### 更改

- 更改游戏加载方式，使其适应新增的语言设置场景

### 修复

- 修复当在非 MOB 模式下时，会有返回按钮的问题
- 修复设定字体时，字体效果不生效的问题

## [3.7.0.0.10062024_alpha] - 2024-10-06

### 更改

- 修改默认操作方式为经典模式
- 修改默认窗口样式为不全屏

### 移除

- 移除健康游戏忠告

## [3.7.0.0.10042024_alpha] - 2024-10-04

### 新增

- 初始化空工程
- 初始化 LIB_KyoLib 模块
- 初始化 CORE_Shared 模块
- 初始化 CORE_Utils 模块
- 初始化 CORE_KernelLogic 模块
- 初始化 SHELL_Pc 模块
- 初始化 SHELL_Dev 模块

### 更改

- 修改默认画质为低画质

### 修复

- [#1] 修复在执行构建前的资源清理时，5DPLAY_TOOLS 提供的 SyncAssets 工具只清理了 pc 通道的资源
- [#2] 修复BUG: 不存在无双模式时，声音被意外唤醒

[3.7.0.0.10192024_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/compare/3.7.0.0.10132024_alpha...3.7.0.0.10192024_alpha
[3.7.0.0.10132024_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/compare/3.7.0.0.10062024_alpha...3.7.0.0.10132024_alpha
[3.7.0.0.10062024_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/compare/3.7.0.0.10042024_alpha...3.7.0.0.10062024_alpha
[3.7.0.0.10042024_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/releases/tag/3.7.0.0.10042024_alpha

[#1]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/issues/1
[#2]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/issues/2
