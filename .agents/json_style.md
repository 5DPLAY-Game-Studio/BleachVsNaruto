# 配置 JSON 格式（AI）

何时读：写/改 `shared/assets/assets/config/*.json`（含新建或由 XML 迁移）。  
范例：`mission.json`、`select.json`、`map.json`、`assist.json`、`fighter.json`、角色包 `meta.json` / `packs.json`。  
角色包目录与加载约定见 [`packs.md`](packs.md)。语言包格式见 [`i18n.md`](i18n.md)，不套用本文排版细则。

---

## MUST

| # | 规则 |
|---|------|
| 1 | 缩进 **2 空格**；UTF-8；键名数据字段用 **`snake_case`** |
| 2 | 对象数组用紧凑写法：`"key": [{` … `}, {` … `}]`（`[` 与首 `{` 同行，元素间 `}, {`） |
| 3 | `[{` 后对象属性相对该键行再缩进 **+4**（见下例；与 `mission` / `map` / `select` 一致） |
| 4 | 同一对象内键长短不一时，**按 `:` 对齐**（在 `"` 与 `:` 之间补空格） |
| 5 | 字符串数组（如 `fighter` / `more_fighter` / `says`）**逐项换行** |
| 6 | 短数值数组可单行：`[-10, 0]` |
| 7 | 逻辑分组之间空一行（如 `path` 与 `data`、根级大块之间） |
| 8 | 解析侧用 `initByObject` + `AssetManager.I.loadJSON`；勿再为同配置写 XML 路径 |

## NEVER

- 标准 `json.dump` 式逐对象全展开：`"key": [\n  {\n    ...\n  },\n  {`（除非整文件本就无对象数组）
- 键名 `camelCase`（配置数据字段；既有例外如 `hasWarning` 保持不改）
- 把语言包 `language/*.json` 的键树规则套到玩法配置（或反之）

---

## 排版速查

```json
{
  "stage_setting": {
    "layout": {
      "x"     : 0,
      "width" : 800,
      "height": 600
    }
  },
  
  "char_list": [{
      "offset": [40, -40],
      "item"  : [{
          "id"          : "ichigo",
          "more_fighter": [
            "ichigo_bankai",
            "ichigo_vizored"
          ],
          "offset"      : [-10, 0]
        }, {
          "id"    : "renji",
          "offset": [-20, 0]
        }, {}, {}]
    }]
}
```

| 点 | 做法 |
|----|------|
| 空槽位 | 允许 `{}`；与邻项同处 `item` 数组，勿删占位 |
| 可选字段 | 无则省略键（不要写 `null` / 空字符串凑数，除非语义需要） |
| 路径块 | 资源类配置可有 `"path": { ... }`，再接 `"data": [{ ... }]`（见 `fighter` / `assist` / `map`） |

---

## 加载对照

| 配置 | 加载 | 解析 |
|------|------|------|
| `packs.json` + `packs/**/meta.json` | `PackRegistry` | `FighterModel` / `AssisterModel` / `MapModel` |
| `fighter.json` / `assist.json` / `map.json` | 工具生成 / 调试回退 | 对应 Model |
| `select.json` | `loadJSON` | `SelectStageConfigVO.initByObject` |
| `mission.json` | `loadJSON` | `MessionModel.initByObject` |

---

## 角色包 `meta.json` / `packs.json`

```json
{
  "pack": "ichigo",
  "kind": "fighter",
  "file": "ichigo.swf",
  "path": {
    "face": "face/"
  },
  "variants": [{
      "id"         : "ichigo",
      "name"       : "黑崎·一护",
      "comic_type" : 0,
      "start_frame": 1,
      "faces": {
        "face"    : "ichigo.png",
        "face_big": "ichigo_b.png",
        "face_bar": "ichigo_m.png",
        "face_win": "ichigo_w.png"
      },
      "says": [
        "..."
      ],
      "bgm": {
        "url" : "character/ichigo.mp3",
        "rate": 70
      },
      "hasWarning": true
    }]
}
```

```json
{
  "fighters": [
    "ichigo"
  ],
  "assists": [
    "kon"
  ],
  "maps": [
    "xianshi"
  ]
}
```

| 点 | 做法 |
|----|------|
| `path.face` | 默认 `face/`；`faces.*` 写裸文件名（亦可遗留 `face/xxx.png`） |
| `file` | 包内 SWF 文件名 |
| `kind` | `fighter` / `assist` / `map` |
| 生成总表 | 角色：`path = packs/fighters\|assists/`；地图：`path.map = packs/maps/` |

---

## 地图包 `meta.json`

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

| 点 | 做法 |
|----|------|
| `file` | 可省略（如 `random` 无 SWF） |
| `img` | 选图缩略图；省略则默认 `<id>.png` |
| `bgm` | 相对全局 `bgm/`；可省略 |
