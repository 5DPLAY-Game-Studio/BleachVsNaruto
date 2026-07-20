# CORE_KernelLogic 速查（AI）

路径根：`CORE_KernelLogic/src/net/play5d/game/bvn/`  
模糊问题先对本表定点，再读源码。

| 主题 | 先看 |
|------|------|
| 启动入口 | `MainGame.as` |
| 场景（菜单/选人/对战/加载/地图） | `stage/` → `MenuStage` `SelectFighterStage` `GameStage` `Loading*` `WorldMapStage` |
| 对战流程 | `ctrler/game_ctrls/` → `GameCtrl` |
| 无双 / 闯关 | `ctrler/musou_ctrls/` `data/musou/` `ui/musou/` `ui/big_map/` |
| 角色 / 动作 / 受击 | `fighter/` `fighter/ctrler/` `fighter/models/` → `FighterMain` `FighterAction*` `HitVO` |
| 援助 | `fighter/Assister.as` `fighter/ctrler/AssisterCtrler.as` |
| AI | `fighter/ctrler/EnemyFighterAICtrl.as` `fighter/ctrler/ai/` |
| 输入 | `input/` `ctrler/KeyEvent.as` `data/vos/KeyConfigVO.as` |
| 碰撞 | `collision/` → `CollisionBridge` |
| 加载 / 资源 | `ctrler/GameLoader.as` `ctrler/AssetManager.as` `ctrler/game_stage_loader/` |
| 音效 | `ctrler/SoundCtrl.as` |
| 特效 | `ctrler/EffectCtrl.as` `views/effects/` |
| 渲染节拍 | `ctrler/GameRender.as` |
| 数据 / VO | `data/` `data/vos/` |
| 战斗 HUD | `ui/fight/` |
| 选人 UI | `ui/select/` `ui/dialog/select/` |
| 菜单 / 暂停 / 设置 | `ui/` `stage/SettingStage.as` |
| 多语言 | `utils/MultiLangUtils.as` `ui/language/` `stage/LanguageStage.as` |
| 作弊码 | `utils/CheatCodeManager.as` |
| 事件 | `events/` `fighter/events/` |

| 说法 | 先打开 |
|------|--------|
| 卡加载 | `stage/Loading*` `GameLoader` `AssetManager` |
| 主菜单 | `MenuStage` `ui/MenuBtn*` |
| 选人错乱 | `SelectFighterStage` `ui/select/` `data/vos/SelectVO` |
| 角色/技能 | `fighter/` `GameCtrl` `input/` |
| 判定 | `collision/` `HitVO` `FighterActionLogic` |
| 无双/续关 | `musou_*` `WorldMapStage` |
| 血条 UI | `ui/fight/` 或 `ui/musou/` |
| 按键 | `input/` `KeyConfigVO` |
| 镜头 | `GameCamera` `FighterCameraCtrler` |
