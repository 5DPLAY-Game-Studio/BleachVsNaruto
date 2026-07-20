# 工程模块总览（AI）

何时读：不确定改哪个顶层目录、或任务跨模块时。玩法细节定点见 [`map.md`](map.md)（仅 KernelLogic）。

---

## 默认落点

| 优先级 | 模块 | 何时进 |
|--------|------|--------|
| 1 | `CORE_KernelLogic` | 战斗/场景/UI 玩法/数据逻辑（约 90% 代码任务） |
| 2 | `CORE_Shared` | 对外常量、版本、与资源侧共享的接口 |
| 3 | `CORE_Utils` / `LIB_KyoLib` | 通用工具；后者为独立子模块库 |
| — | `BleachVsNaruto_FlashSrc` | 美术/XFL；**代码任务默认避开** |
| — | `CORE_Components` | Animate 组件库代码；常规玩法少碰 |

---

## 模块表

| 目录 | 角色 | 备注 |
|------|------|------|
| `CORE_KernelLogic` | 核心玩法逻辑 | 入口速查 → [`map.md`](map.md) |
| `CORE_Shared` | 对外共享 API / 版本 | 编译资源时进 `shared` SWC |
| `CORE_Utils` | 工程内公用工具 | |
| `LIB_KyoLib` | 通用显示/输入/加载等库 | git 子模块，单独维护 |
| `LIB_Other` | 其它第三方/附属库 | |
| `CORE_Components` | Animate 可交互组件类 | 供 `component.xfl` |
| `BleachVsNaruto_FlashSrc` | Flash/美术源 | 非代码主战场 |
| `shared` | 共享 SWC 等构建产物/接口落点 | 与 Shared 编译相关 |
| `SHELL_Dev` | 开发用壳 / Application | 本地跑、调试入口侧 |
| `SHELL_Pc` | PC 发行壳 | |
| `SHELL_Mob` | 移动端壳 | |
| `tools` | 脚本与工具 | |
| `keysign` | 签名相关 | |
| `out` | 构建输出 | 勿当源码改 |
| `.idea` / `.vscode` | IDE 配置 | 含代码风格 `Project.xml` |

---

## 关系（极简）

```
SHELL_* ──启动──► CORE_KernelLogic
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
    CORE_Shared   CORE_Utils   LIB_KyoLib
          │
          ▼
    shared SWC ◄── BleachVsNaruto_FlashSrc（资源编译）
```

---

## NEVER（模块选择）

- 常规功能优先改 `CORE_Components` 或长时间泡在 `BleachVsNaruto_FlashSrc`
- 把 `out/` 当源码仓库改
- 能在 KernelLogic 解决却先大改 `LIB_KyoLib`（除非确属库能力）
