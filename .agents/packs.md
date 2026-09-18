# 角色 / 地图包（AI）

何时读：写/改 `shared/assets/assets/packs/**`、`config/packs.json`，或包合并/校验工具。  
JSON 排版仍服从 [`json_style.md`](json_style.md)。

---

## MUST

| # | 规则 |
|---|------|
| 1 | 角色粒度按 **SWF 包**（一目录一 `.swf` + 多 `start_frame` variant）；地图 **一 id 一包** |
| 2 | 战斗员：`packs/fighters/<pack>/`；援助：`packs/assists/<pack>/`；地图：`packs/maps/<id>/` |
| 3 | 权威源是 pack + [`config/packs.json`](../shared/assets/assets/config/packs.json)；`fighter.json` / `assist.json` / `map.json` 仅工具生成 |
| 4 | 角色：`meta.path.face` + 裸文件名；地图：`file` / `img` 为包内文件名，`bgm` 相对全局 `bgm/` |
| 5 | 发现：内置清单为主；AIR 额外扫 `assets/mods/fighters|assists|maps/`（同 id **覆盖**） |
| 6 | 缺包软降级：不因缺 id 抛错崩游戏 |

## NEVER

- 把 `select.json` / `mission.json` 拆进角色/地图包
- 把 AIR `File` API 写进 Kernel 通用加载路径（壳注入 `PackRegistry.extraPackRootsProvider`）
- 援助与战斗员共用同一 pack 目录树

---

## 目录

```text
packs/fighters/<pack>/meta.json + <file>.swf + face/
packs/assists/<pack>/...
packs/maps/<id>/meta.json + <id>.swf + <id>.png
config/packs.json          # { fighters, assists, maps }
mods/maps/<id>/            # AIR 外部
```

## 地图 meta 示例

```json
{
  "pack": "xianshi",
  "kind": "map",
  "id"  : "xianshi",
  "name": "现世",
  "file": "xianshi.swf",
  "img" : "xianshi.png",
  "bgm" : "city.mp3"
}
```

无 SWF 的选图位（如 `random`）省略 `file`。

## 工具

| 命令 | 作用 |
|------|------|
| `python tools/script/py/pack_fighters.py migrate\|merge\|shorten\|doctor` | 角色包 |
| `python tools/script/py/pack_maps.py migrate\|merge\|doctor` | 地图包 |

## 加载

| 配置 | 加载 | 解析 |
|------|------|------|
| `packs.json` + 各 `meta.json` | `PackRegistry` | `FighterModel` / `AssisterModel` / `MapModel` |
| 生成总表 | 可选回退 | 同左 |
