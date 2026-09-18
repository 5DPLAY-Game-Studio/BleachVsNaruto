# 角色 / 地图包（AI）

何时读：写/改 `shared/assets/assets/packs/**`、`config/packs.json`，或包合并/校验工具。  
JSON 排版仍服从 [`json_style.md`](json_style.md)。

---

## MUST

| # | 规则 |
|---|------|
| 1 | 角色粒度按 **SWF 包**（一目录一 `.swf` + 多 `start_frame` variant）；地图 **一 id 一包** |
| 2 | 战斗员：`packs/fighters/<pack>/`；援助：`packs/assists/<pack>/`；地图：`packs/maps/<id>/` |
| 3 | 权威源是 pack + [`config/packs.json`](../shared/assets/assets/config/packs.json)；不再维护 `fighter.json` / `assist.json` / `map.json` |
| 4 | 角色：`meta.path.face` + 裸文件名；地图：`file` / `img` 为包内文件名，`bgm` 相对全局 `bgm/` |
| 5 | 发现：内置清单为主；AIR 额外扫 `assets/mods/fighters|assists|maps/`（同 id **覆盖**） |
| 6 | 缺包软降级：不因缺 id 抛错崩游戏 |
| 7 | 展示文案在 **`language.{locale}`**：战斗员/援助为 `language.zh-CN.name` / `says`（按 variant `id`）；地图为 `language.zh-CN.name`；**不进**全局 `language/*.json` |

## NEVER

- 把 `select.json` / `mission.json` 拆进角色/地图包
- 把 AIR `File` API 写进 Kernel 通用加载路径（壳注入 `PackRegistry.extraPackRootsProvider`）
- 援助与战斗员共用同一 pack 目录树
- 把角色名/台词迁入 `config/language/*.json`（包内容文案留在 meta）
- 把 `name` / `says` 写在 `variants[]` 或 meta 根（应在 `language.{locale}` 下）

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
  "language": {
    "zh-CN": {
      "name": "现世"
    }
  },
  "file": "xianshi.swf",
  "img" : "xianshi.png",
  "bgm" : "city.mp3"
}
```

无 SWF 的选图位（如 `random`）省略 `file`。`language.zh-CN.name` 可为字符串；其它 locale 同级并列。

## meta 多语言（战斗员 / 援助）

`language` 按 **locale**（如 `zh-CN`、`en`）分块，块内 `name` / `says` 再按 variant `id` 索引。`PackRegistry` + [`PackLangUtil`](../CORE_KernelLogic/src/net/play5d/game/bvn/utils/PackLangUtil.as)：当前 `LANGUAGE` → `zh-CN` → 首个可用块。单字段内仍可用 locale map 做细粒度覆盖。

```json
{
  "pack": "aizen",
  "kind": "fighter",
  "file": "aizen.swf",
  "path": { "face": "face/" },
  "language": {
    "zh-CN": {
      "name": {
        "aizen"   : "蓝染·惣右介",
        "aizen_gz": "蓝染·惣右介 叛变"
      },
      "says": {
        "aizen": [
          "台词1"
        ],
        "aizen_gz": [
          "台词1"
        ]
      }
    },
    "en": {
      "name": {
        "aizen"   : "Sosuke Aizen",
        "aizen_gz": "Aizen (Betrayal)"
      }
    }
  },
  "variants": [{
      "id"         : "aizen",
      "comic_type" : 0,
      "start_frame": 1,
      "faces"      : { "face": "aizen_captain.png" }
    }, {
      "id"         : "aizen_gz",
      "comic_type" : 0,
      "start_frame": 2,
      "faces"      : { "face": "aizen.png" }
    }]
}
```

工具 `lift-i18n`：把旧版根/`variants`/`language.name|says` 收进 `language.zh-CN`。

## 工具

| 命令 | 作用 |
|------|------|
| `python tools/script/py/pack_fighters.py migrate\|merge\|shorten\|lift-i18n\|doctor` | 角色包 |
| `python tools/script/py/pack_maps.py migrate\|merge\|lift-i18n\|doctor` | 地图包 |

## 加载

| 配置 | 加载 | 解析 |
|------|------|------|
| `packs.json` + 各 `meta.json` | `PackRegistry` | `FighterModel` / `AssisterModel` / `MapModel` |
