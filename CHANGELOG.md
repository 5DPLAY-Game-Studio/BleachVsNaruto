# 更新日志

本项目的所有重要变更都将会记录在此文件中。

## [3.7.0.0.03082025_alpha] - 2025-03-08

### 修复

- 修复手机版制作组页面文字排版问题
- 修复携带有 ...args 参数的全局函数在互相引用时产生的引用错误

## [3.7.0.0.03032025_alpha] - 2025-03-03

### 新增

- 手机版观战模式

## [3.7.0.0.02122025_alpha] - 2025-02-12

### 新增

- 初始化 CORE_Components 模块

## [3.7.0.0.12212024_alpha] - 2024-12-21

### 更改

- 重构功能：当防御时受到破防伤害后，削减耐力从固定 90 点改为 90%

### 修复

- 修复当处于刚身状态防御时，仍会被攻击破防的问题

## [3.7.0.0.12052024_alpha] - 2024-12-05

### 新增

- 初始化 SHELL_Mob 模块

## [3.7.0.0.11252024_alpha] - 2024-11-25

### 新增

- 新增 SHELL_Pc 的 FlashBuilder 工程支持

### 修复

- 修复没有调用所选语言的默认字体的问题

## [3.7.0.0.11192024_alpha] - 2024-11-19

### 新增

- 新增 取消保存当前设置 功能

### 更改

- 更改 SHELL_Pc 默认画质为低画质

### 修复

- 修复遍历字典算法错误导致的类型转换失败问题
- 修复 ui/fight 文件的变量声明问题

## [3.7.0.0.11132024_alpha] - 2024-11-13

### 更改

- 更新制作组名单
- 重构主菜单选项按钮的排列方式

### 修复

- 修复 AI 不防御辅助的问题（临时解决）
- 修复 SHELL_Pc 的 无双模式 未在主界面的问题

## [3.7.0.0.11112024_alpha] - 2024-11-11

### 修复

- [#3] 修复BUG: 创建AI时，AI等级引用不正确的问题
- [#4] 修复BUG: 小队模式下，1p选择顺序选择完之前去选2p顺序报空指针异常的问题

## [3.7.0.0.10222024_alpha] - 2024-10-22

### 新增

- 新增 FlashBuilder 工程支持
- 新增 观战电脑 模式

### 更改

- 重构部分资源格式，从 xml 文件转为 json 文件
- 更改额外选人框颜色为红色
- 重构 SHELL_Dev 的测试组件

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

[3.7.0.0.03082025_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/compare/3.7.0.0.03032025_alpha...3.7.0.0.03082025_alpha
[3.7.0.0.03032025_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/compare/3.7.0.0.02122025_alpha...3.7.0.0.03032025_alpha
[3.7.0.0.02122025_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/compare/3.7.0.0.12212024_alpha...3.7.0.0.02122025_alpha
[3.7.0.0.12212024_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/compare/3.7.0.0.12052024_alpha...3.7.0.0.12212024_alpha
[3.7.0.0.12052024_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/compare/3.7.0.0.11252024_alpha...3.7.0.0.12052024_alpha
[3.7.0.0.11252024_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/compare/3.7.0.0.11192024_alpha...3.7.0.0.11252024_alpha
[3.7.0.0.11192024_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/compare/3.7.0.0.11132024_alpha...3.7.0.0.11192024_alpha
[3.7.0.0.11132024_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/compare/3.7.0.0.11112024_alpha...3.7.0.0.11132024_alpha
[3.7.0.0.11112024_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/compare/3.7.0.0.10222024_alpha...3.7.0.0.11112024_alpha
[3.7.0.0.10222024_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/compare/3.7.0.0.10192024_alpha...3.7.0.0.10222024_alpha
[3.7.0.0.10192024_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/compare/3.7.0.0.10132024_alpha...3.7.0.0.10192024_alpha
[3.7.0.0.10132024_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/compare/3.7.0.0.10062024_alpha...3.7.0.0.10132024_alpha
[3.7.0.0.10062024_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/compare/3.7.0.0.10042024_alpha...3.7.0.0.10062024_alpha
[3.7.0.0.10042024_alpha]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/releases/tag/3.7.0.0.10042024_alpha

[#1]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/issues/1
[#2]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/issues/2
[#3]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/issues/3
[#4]: https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/issues/4
