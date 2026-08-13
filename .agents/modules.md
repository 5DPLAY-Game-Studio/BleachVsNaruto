# 工程模块总览（AI）

何时读：不确定改哪个顶层目录、或任务跨模块时。玩法细节定点见 [`map.md`](map.md)（仅 KernelLogic）。

---

## 默认落点

| 优先级 | 模块 | 何时进 |
|--------|------|--------|
| 1 | `CORE_KernelLogic` | 战斗/场景/UI 玩法/数据逻辑（约 90% 代码任务） |
| 2 | `CORE_Shared` | 对外公开的静态方法 / 属性 / 接口（含版本与注入契约） |
| 3 | `CORE_Utils` / `LIB_KyoLib` | 通用工具；后者为独立子模块库 |
| — | `BleachVsNaruto_FlashSrc` | 美术/XFL；**代码任务默认避开** |
| — | `CORE_Components` | Animate 组件库；约定见 [`components.md`](components.md)；常规玩法少碰 |

---

## 模块表

| 目录 | 角色 | 备注 |
|------|------|------|
| `CORE_KernelLogic` | 核心玩法逻辑 | 入口速查 → [`map.md`](map.md) |
| `CORE_Shared` | 对外公开 API：接口、静态常量/属性、薄静态工具与跨壳数据形状 | 宜放：注入契约（`ISwfLib`/`IGameInput`/`IGameInterface`/`ILan*`）、版本、`Lan*` 消息码/工厂、跨壳 VO。**不含** Embed；UI SWF 的 `SwfLib` 在 Utils。勿放：DisplayList UI、壳会话控制器、非公开实现细节 |
| `CORE_Utils` | 工程内公用工具 / `SwfLib` Embed | |
| `LIB_KyoLib` | 通用显示/输入/加载等库 | git 子模块；首选 API → [`kyolib.md`](kyolib.md) |
| `LIB_Other` | 其它第三方/附属库 | |
| `CORE_Components` | Animate 可交互组件类 | 供 `component.xfl`；约定 → [`components.md`](components.md) |
| `BleachVsNaruto_FlashSrc` | Flash/美术源 | 非代码主战场 |
| `shared` | 共享 SWC 等构建产物/接口落点 | 与 Shared 编译相关 |
| `SHELL_Dev` | 开发用壳 / Application | 本地跑、调试入口侧 |
| `SHELL_Pc` | PC 发行壳 | |
| `SHELL_Mob` | 移动端壳 | |
| `tools` | 脚本与工具 | bat → [`bat_script.md`](bat_script.md)；jsfl → [`jsfl.md`](jsfl.md) |
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
- 往 `CORE_Shared` 塞 Embed、壳专属 UI/会话逻辑，或仅单模块使用的非公开实现
