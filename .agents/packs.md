# 角色包（AI）

何时读：写/改 `shared/assets/assets/packs/**`、`config/packs.json`，或角色包合并/校验工具。  
JSON 排版仍服从 [`json_style.md`](json_style.md)。

---

## MUST

| # | 规则 |
|---|------|
| 1 | 粒度按 **SWF 包**（一目录一 `.swf` + 多 `start_frame` variant），勿按每个 fighter id 拆目录 |
| 2 | 战斗员：`packs/fighters/<pack>/`；援助：`packs/assists/<pack>/`；各含 `meta.json`、SWF、可选 `face/` |
| 3 | 权威源是 pack + [`config/packs.json`](../shared/assets/assets/config/packs.json)；`fighter.json` / `assist.json` 仅由工具生成（调试/回退） |
| 4 | 路径：`meta.path.face`（默认 `face/`）+ 裸文件名；SWF 为包内文件名；BGM 相对全局 `bgm/`；生成总表用 `path.fighter/face = packs/fighters|assists/` |
| 5 | 发现：内置清单为主；AIR 额外扫 `assets/mods/fighters|assists/`（同 id **覆盖**内置） |
| 6 | 缺包软降级：不因缺 id 抛错崩游戏；选人空槽 / 过滤 more；关卡跳过缺角 |

## NEVER

- 把 `select.json` / `mission.json` 拆进角色包
- 把 AIR `File` API 写进 Kernel 通用加载路径（壳注入 `PackRegistry.extraPackRootsProvider`）
- 援助与战斗员共用同一 pack 目录树

---

## 目录

```text
packs/fighters/<pack>/meta.json + <file>.swf + face/
packs/assists/<pack>/...
config/packs.json          # { "fighters": [...], "assists": [...] }
mods/fighters/<pack>/      # AIR 外部；可不入库
```

## 工具

| 命令 | 作用 |
|------|------|
| `python tools/script/py/pack_fighters.py migrate` | 自旧总表迁入 packs（含 face）并合并 |
| `python tools/script/py/pack_fighters.py merge` | 仅扫描 packs 生成总表 + packs.json |
| `python tools/script/py/pack_fighters.py shorten` | 缩短 meta faces + 再 merge |
| `python tools/script/py/pack_fighters.py doctor` | 校验缺文件 / id 冲突 / select 孤儿 |

## 加载

| 配置 | 加载 | 解析 |
|------|------|------|
| `packs.json` + 各 `meta.json` | `PackRegistry` | `FighterModel` / `AssisterModel` |
| `fighter.json` / `assist.json` | 可选回退 | 同左 |
