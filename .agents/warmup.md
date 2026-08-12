# 预热资源（AI）

何时读：新增/改动**首次交互**可能卡顿的路径（悬停、点击、首次弹窗、首次缓动、首次 SWC 音、首次位图字），或改 `WarmupCtrl` / `SoundCtrl` 预热 API。

源码入口：`CORE_KernelLogic/.../ctrler/WarmupCtrl.as`；音效预热：`SoundCtrl.warmMenuSounds` / `warmCommonSwcSounds` / `warmSwcSound`；语言项：`CountryItem.warmUp`；菜单：`MenuBtn.warmCommon`；设置线：`SetBtnLine.warmCommon`。

---

## MUST

| # | 规则 |
|---|------|
| 1 | 新的「首次使用才分配 / 才光栅化 / 才注册插件」逻辑，须评估是否加入预热，并接到 `WarmupCtrl`（勿在各 Stage 散落复制） |
| 2 | **语言页之前**就能触发 → `warmEarly()` 或 `warmCountryItems()`；须等 `loadBasic` / `font1` / `effect.swf` → `warmBasic()`（由 `AssetManager.initAssets` 调用） |
| 3 | 新 SWC 菜单/UI/对战提示音走 `SoundCtrl.warmSwcSound` / 扩 `warmCommonSwcSounds`；勿只在调用点 `new sndXxx()` |
| 4 | 新悬停/展开动画（`scale≈0`→1、`width=0`→展开、Elastic/Back 等）→ 在 `WarmupCtrl` 加探针或组件自有 `warmUp`，并由 `warmEarly`/`warmBasic` 调用 |
| 5 | 新位图字体 / 首次 `BitmapFontText` 重绘 → `warmBasic` 的字体预热段覆盖常用字形 |
| 6 | 预热须**幂等**、尽量**不入显示列表**、不发出可闻音效；失败可吞错，勿阻断启动 |
| 7 | 改预热后：语言页首次悬停、菜单首次悬停/展开、设置线、首次确认音、首次弹窗、首次 BGM 路径各点验一下 |

## NEVER

- 在 `LanguageStage` / `MenuStage` 等再写一套与 `WarmupCtrl` 重复的 TweenLite/音效预热
- 把必须 `loadBasic` 之后才有的资源塞进 `warmEarly`（如 `font1`、多数 effect）
- 预热时真正 `Sound.play` 大声菜单音，或把对话框遮罩 `addChild` 到 root
- 为「优雅」预热全部对战特效 MC（过重）；对战侧按需、另阶段，或只预热已确认的 SWC 音 / 池尺寸

---

## 阶段对照

| 阶段 | API | 典型内容 |
|------|-----|----------|
| 早期 | `WarmupCtrl.I.warmEarly()` | TweenLite 引擎；`snd_menu1/2` |
| 语言项 | `WarmupCtrl.I.warmCountryItems(items)` | `CountryItem.warmUp` |
| 基础后 | `WarmupCtrl.I.warmBasic()` | 缓动插件 Back/Elastic；常用 SWC 音；`font1`；`MenuBtn`/`SetBtnLine`；scale 探针；BGM 播放器；`DialogManager.warmUp`；`BitmapDataPool`；滤镜类 |

接线：语言列表建完 → early + countryItems；`AssetManager.initAssets` 末尾 → `warmBasic()`。

---

## 触发清单（出现则评估预热）

| 现象 / 写法 | 预热落点 |
|-------------|----------|
| `playSwcSound` / `new snd_*` 首次 | `SoundCtrl.warmSwcSound` → early 或 common |
| `TweenLite.to` + 新 `ease:` 插件 | `warmTweenPlugins` / `warmBasic` |
| UI `scaleX/width` 从近 0 展开 | 探针或组件 `warmUp` → early/basic |
| 首次 `BitmapFontText` / `getFont` | `warmBitmapFont`（basic） |
| 首次全屏遮罩 / 对话框底 | `DialogManager.warmUp`（basic） |
| 首次 `BitmapDataPool.acquire` 常用尺寸 | `warmBitmapDataPool`（basic） |
| 首次 `GlowFilter` / `DropShadowFilter` 构造 | `warmFilters`（basic） |
| 菜单底板 MC 首次 `visible` / 光栅化 | `MenuBtn.warmCommon`（basic） |
| 设置下划线首次 `graphics` + scale | `SetBtnLine.warmCommon`（basic） |

---

## 排查结论（同类项）

| 路径 | 结论 |
|------|------|
| `CountryItem` / `LanguageStage` | 已做：scale 展开、光栅化、悬停只切当前项、音效缓存 |
| `SoundCtrl.playSwcSound` | 已全局 Class→Sound 缓存 + early/common 预热；选图/选人等 `sndSelect` 无需再单点预热 |
| `MenuBtn` / `MenuBtnGroup` | 已做：`warmCommon` 光栅化底板；`hoverBtn` 只切当前项；fadIn Back 由探针覆盖 |
| `SetBtn` / `SetBtnLine` / `SetBtnGroup` | 已做：`SetBtnLine.warmCommon`；`setArrowIndex` 只切当前项（本就有同 index 早退） |
| `SelectMapUI` / `SelectIndexUIGroup` | 仅 `sndSelect`，音效侧已覆盖；无 scale≈0 悬停底板 |
| `WorldMapPointUI` / 选人缩放 | 较晚界面 + Back 已在 `warmBasic` 探针；不必再为每个 MC 做 `warmUp` |
| 对战特效 MC / 残影池 | 另阶段；勿塞进启动 `warmBasic` |

---

## 速查

```actionscript
// 语言页列表就绪
WarmupCtrl.I.warmEarly();
WarmupCtrl.I.warmCountryItems(_insCountries);

// loadBasic 完成后（已有接线，新增资源扩 WarmupCtrl 即可）
WarmupCtrl.I.warmBasic();
```
