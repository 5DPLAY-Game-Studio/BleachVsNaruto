# CORE_KernelLogic 速查（AI）

路径根：`CORE_KernelLogic/src/net/play5d/game/bvn/`  
模糊问题先对本表定点，再读源码。

| 主题 | 先看 |
|------|------|
| 启动入口 | `MainGame.as` |
| 场景（菜单/选人/对战/加载/地图） | `stage/` → `MenuStage` `SelectFighterStage` `GameStage` `Loading*` `WorldMapStage` |
| 对战流程 | `ctrler/game_ctrls/` → `GameCtrl` + `IFightSession`（`VersusFightSession` / `MusouFightSession`） |
| 无双 / 闯关 | `ctrler/musou_ctrls/` `data/musou/` `ui/musou/` `ui/big_map/` |
| 角色 / 动作 / 受击 | `fighter/` `fighter/ctrler/` → `FighterMcCtrler`（时间轴门面，`$mc_ctrler`）+ `FighterMcRuntime` + `FighterMcHurtCtrl` / `FighterMcActionCtrl`；`FighterActionLogic`；`fighter/models/` → `HitVO` |
| 援助 | `fighter/Assister.as` `fighter/ctrler/AssisterCtrler.as` |
| AI | `fighter/ctrler/EnemyFighterAICtrl.as` `fighter/ctrler/ai/` |
| 输入 | `input/` `ctrler/KeyEvent.as` `data/vos/KeyConfigVO.as` |
| 碰撞 | `collision/` → `CollisionBridge` |
| 加载 / 资源 | `ctrler/GameLoader.as` `ctrler/AssetManager.as` `ctrler/game_stage_loader/` |
| 音效 | `ctrler/SoundCtrl.as` |
| 特效 | `ctrler/EffectCtrl.as`（门面）+ `ctrler/effect/`（Handler + `EffectManager` / `EffectCacheVO`）+ `views/effects/` |
| 联机锁帧 | `ctrler/lan/LockFrameLogic.as`（壳 `LAN*Ctrl` 调用） |
| 启动预热（首次交互卡顿） | `ctrler/WarmupCtrl.as` → 约定见 [`.agents/warmup.md`](warmup.md) |
| 渲染节拍 | `ctrler/GameRender.as` |
| 数据 / VO | `data/` `data/vos/`（存档/模式/通用）；角色判定 VO → `fighter/models`；角色瞬时 VO → `fighter/vos` |
| 战斗 HUD | `ui/fight/` |
| 选人 UI | `ui/select/` `SelectFighterListCtrl`（列表/光标）`ui/select/flow/`（模式步进）`ui/dialog/select/` |
| 菜单 / 暂停 / 设置 | `ui/` `stage/SettingStage.as` |
| 多语言 | `utils/MultiLangUtils.as` `ui/language/` `stage/LanguageStage.as`；键约定见 [i18n.md](i18n.md) |
| 作弊码 | `utils/CheatCodeManager.as` |
| 事件 | `events/` `fighter/events/` |

| 说法 | 先打开 |
|------|--------|
| 卡加载 | `stage/Loading*` `GameLoader` `AssetManager` |
| 主菜单 | `MenuStage` `ui/MenuBtn*` |
| 选人错乱 | `SelectFighterStage` `ui/select/` `ui/select/flow/` `data/vos/SelectVO` |
| 角色/技能 | `fighter/` `GameCtrl` `input/` |
| 判定 | `collision/` `HitVO` `FighterActionLogic` |
| 无双/续关 | `musou_*` `WorldMapStage` |
| 血条 UI | `ui/fight/` 或 `ui/musou/` |
| 按键 | `input/` `KeyConfigVO` |
| 镜头 | `GameCamera` `FighterCameraCtrler` |

## 依赖边界（增量优化）

| NEVER | 改为 |
|-------|------|
| `ctrler`/`fighter`/`data` 回写 `ui/` 静态字段或新增具体控件 import | 写 `GameConfig` / 事件 / 数据；既有 `GameUI` 门面除外 |
| 往 `utils/` 塞域业务（特效/联机/角色状态机等） | 放入对应域包（如 `ctrler/effect`、`ctrler/lan`、`fighter/ctrler`） |

## 控制层分工

| 层 | 包 | 职责 |
|----|-----|------|
| 全局 | `ctrler.*` | 对局、特效、加载、联机、无双会话 |
| 实体 | `fighter.ctrler.*` | 单角色 MC/键/AI/镜头/语音 |

## Flash IDE 冻结面

`FighterCtrler.initFighter` → `main_mc.initFighter({ fighter_ctrler, mc_ctrler, effect_ctrler, camera_ctrler })` 注入名与 `$mc_ctrler` 等时间轴 API **尽量不改**（角色 SWF 依赖）。
