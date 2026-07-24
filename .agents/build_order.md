# 编译链顺序（AI）

何时读：改模块依赖、`build.bat` / `.vscode/tasks.json` / IDEA Run Before Launch、ASDoc embed 钩子，或分析「谁先谁后」时。细节以各模块 `asconfig.json` / `*.iml` / `flex-config.xml` 为准。

---

## MUST

| # | 规则 |
|---|------|
| 1 | **SHELL_* 最小编译链**（与 VSCode `SHELL_Dev` task 一致）：`LIB_Other → LIB_KyoLib → CORE_Shared → CORE_KernelLogic → CORE_Utils → sync → SHELL_*` |
| 2 | `CORE_Shared` 与 `LIB_KyoLib` **无互相编译依赖**；链上先 KyoLib 再 Shared 仅为统一习惯 |
| 3 | `CORE_Components` **仅依赖** `CORE_Shared`；**SHELL_* 不依赖**它。`build.bat` 仍编译它（供组件/XFL 消费） |
| 4 | ASDoc embed：`LIB_KyoLib`、`CORE_Shared` 各在 **本模块 compc 成功后**（`build.bat` / VSCode）；IDEA 在 **Make 之后** 一次跑 `embed_asdoc_libs.bat` |
| 5 | 改依赖顺序时同步三处：`tools/script/build.bat` 的 `LIB_MODULES`、`.vscode/tasks.json`、本文 |

## NEVER

- 假定 SHELL 需要 `CORE_Components`
- 把 IDEA「Sync → Make → Embed」当成与 VSCode「先 embed 再编下游」同一时刻（结果应一致，时机不同）
- 在独立打开的 `LIB_KyoLib` 子模块里依赖主仓 `tools/script`（子模块有本地 asdoc 回退）

---

## 依赖 DAG（库 → 壳）

```text
LIB_Other
   └─► LIB_KyoLib ──► CORE_KernelLogic ──► CORE_Utils ──► SHELL_*
CORE_Shared ──────────► CORE_KernelLogic ──┘                ▲
   └─► CORE_Components（旁路，SHELL 不用）                  │
sync.bat / shared assets ───────────────────────────────────┘
```

| 模块 | 编译输入（工程 SWC） |
|------|----------------------|
| `LIB_Other` | （叶） |
| `LIB_KyoLib` | include `LIB_Other.swc` |
| `CORE_Shared` | （无其它工程库） |
| `CORE_Components` | merge `CORE_Shared.swc` |
| `CORE_KernelLogic` | merge `LIB_KyoLib` + `CORE_Shared` |
| `CORE_Utils` | merge `LIB_KyoLib` + `CORE_KernelLogic` |
| `SHELL_*` | merge KernelLogic + KyoLib + Utils + Shared（+ Dev 本地 `lib/swc`） |

---

## 三管道对照

| 步骤 | `build.bat` | VSCode `SHELL_Dev` | IDEA `SHELL_*` Run |
|------|-------------|--------------------|--------------------|
| LIB_Other | ✓ | ✓（经 KyoLib task） | ✓ Make |
| LIB_KyoLib + embed | ✓ 紧随 compc | ✓ 紧随 compc | Embed **在 Make 后** |
| CORE_Shared + embed | ✓ 紧随 compc | ✓ 紧随 compc | 同上（`EmbedLibsAsDoc`） |
| CORE_Components | ✓ | ✗（SHELL 链跳过） | ✓ 若模块在工程内 |
| KernelLogic / Utils | ✓ | ✓ | ✓ Make |
| sync | 库后、壳前 | 壳 task 末依赖 | **Make 前** SyncAssets |
| SHELL | amxmlc Dev | asconfig Dev | Make |

---

## ASDoc 落点（勿再拆散）

| 用途 | 路径 |
|------|------|
| 共用 ps1（inject / wait / build_terms） | `tools/script/ps/` |
| Shared 生成/嵌入 | `asdoc_shared.bat` / `embed_asdoc_shared.bat` |
| IDEA 一次嵌两库 | `embed_asdoc_libs.bat` → External Tool `EmbedLibsAsDoc` |
| KyoLib（可独立） | `LIB_KyoLib/tools/asdoc.bat`；优先 `tools/script/ps/`，否则本地 `tools/asdoc/` |

相关 bat 约定 → [`bat_script.md`](bat_script.md)。
