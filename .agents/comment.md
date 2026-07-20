# 代码注释规范（AI）

源标准：[ASDoc](https://airsdk.dev/docs/development/asdoc-comments)。生成/补全 AS3 注释时**必须**遵守。正文中文；保留已有 `@author`/`@version` 等。代码格式见 [`code_style.md`](code_style.md)。

**仅补文档时不改业务逻辑**（不删实现、不清 dead code，除非用户要求）。

---

## MUST

| # | 规则 |
|---|------|
| 1 | public/protected：类、接口、构造、方法、属性、事件 → **完整 ASDoc** |
| 2 | private 字段 → `/** @private */`（可附一句）；不要求完整 API 文档 |
| 3 | 结构 = 主描述 + `@` 标签区；主描述在首个行首 `@` 之前结束（`@private` 除外可任意位置） |
| 4 | 注释紧贴声明正上方；类注释与 `class` 间禁止插 `import` |
| 5 | 第一句完整概括（摘要用）；第一段无 `<p>`；其后段落用 `<p>...</p>` |
| 6 | HTML 须 XHTML 成对；行内代码 `<code>`；`<`/`>`/`@` 用实体 `&lt;`/`&gt;`/`&#64;` |
| 7 | `@param` 名与签名一致、顺序一致；有返回值写 `@return`；会抛错写 `@throws` |
| 8 | 交叉引用用 `@see`，**不用** `{@link}`；`@see` 参数禁 HTML；勿链私有成员 |
| 9 | `@example` 代码用 `<listing version="3.0">`，**不用** `<pre>` |
| 10 | 逻辑简单的方法附简短 `@example` |
| 11 | getter 写完整文档；setter 仅 `/** @private */` |
| 12 | 事件：`[Event]` 上方注释 `@eventType Class.CONST`；常量上 `@eventType eventName` |
| 13 | `[Event]` 们在类注释之前；类注释在全部 `[Event]` 之后、类声明之前 |
| 14 | 逻辑注释：复杂/关键/非常规处用 `//` 说「做什么」；属性/局部说明用 `/** */` 不用 `//` |
| 15 | JS 桥接用 JSDoc，不用 ASDoc |

## NEVER

- 强制堆「设计理念 N 条 / 原理 N 步 / 性能 N 点」空模板
- 参照业务类名当规范（规范自洽）
- 为凑章节给简单工具类灌水
- 复述显而易见代码的 `//`
- 公开文档 `@see`/主描述指向 private

## 详略

- 复杂管理器：可多写主描述 + 示例
- 算法类：写清 public API；private 实现可仅 `@private`
- 简单工具：职责 + `@param`/`@return` 即可

---

## 形态与标签序

```actionscript
/**
 * 第一句概括。
 *
 * <p>第二段。</p>
 *
 * @param name 说明。
 * @return 说明。
 * @throws ErrorType 说明。
 * @default value
 * @eventType ...
 * @example
 * <listing version="3.0">
 * // ...
 * </listing>
 * @see #otherMethod()
 * @author x
 * @version 1.0
 */
```

建议标签序：`@param` → `@return` → `@throws` → `@default` → `@eventType` → `@example` → `@see` → `@author`/`@version`/`@since`

| 标签 | 要点 |
|------|------|
| `@param name desc` | 名=签名；顺序=形参 |
| `@return desc` | 不写类型名（签名已有） |
| `@throws Type desc` | |
| `@see ref [text]` | 见下表 |
| `@default v` | 明确默认值时 |
| `@example` + `<listing version="3.0">` | 简单方法要有 |
| `@eventType` | Event 注释↔常量 |
| `@private` | 排除文档 / private 字段 / setter |
| `@inheritDoc` | 覆写/实现优先用 |
| `@copy Class#member` | 非继承链复制 |

### `@see`

| 写法 | 含义 |
|------|------|
| `@see #method()` | 同类方法（带 `()`） |
| `@see #prop` | 同类属性 |
| `@see OtherClass` | 同包类 |
| `@see flash.events.Event` | 跨包全名 |
| `@see flash.events.Event#type` | 他类属性 |
| `@see flash.events.Event#clone()` | 他类方法 |
| `@see http://... Label` | URL |

---

## 按成员（模式）

```actionscript
// ----- 事件 + 类 -----
/**
 * 加载完成时分派。
 * @eventType DemoLoader.LOAD_COMPLETE
 */
[Event(name='loadComplete', type='flash.events.Event')]
/**
 * 示例加载器。
 * <p>约束说明。</p>
 * @example
 * <listing version="3.0">
 * var L:DemoLoader = new DemoLoader(3);
 * L.load('a.xml');
 * </listing>
 * @see flash.events.EventDispatcher
 * @see #load()
 */
public class DemoLoader extends EventDispatcher {

// ----- 事件常量 -----
/**
 * <code>loadComplete</code> 事件的 <code>type</code> 属性值。
 * @eventType loadComplete
 */
public static const LOAD_COMPLETE:String = 'loadComplete';

// ----- 属性 -----
/**
 * 最近 URL。
 * @default null
 */
public var lastUrl:String = null;

// ----- private 字段 -----
/** @private 超时毫秒数 */
private var _timeout:int;
/** @private */
private var _busy:Boolean;

// ----- getter / setter -----
/**
 * 是否加载中。
 * @return <code>true</code> 表示忙。
 * @default false
 */
public function get busy():Boolean { return _busy; }
/** @private */
public function set busy(value:Boolean):void { _busy = value; }

// ----- 简单方法 + 小 example -----
/**
 * 格式化资源键。
 * @param id 编号 0–999。
 * @return 如 <code>res_007</code>。
 * @example
 * <listing version="3.0">
 * DemoLoader.formatKey(7); // 'res_007'
 * </listing>
 */
public static function formatKey(id:int):String { /*...*/ }

// ----- 复杂方法 -----
/**
 * 开始加载。
 * <p>缓存命中则直接完成；同时仅允许一个进行中加载。</p>
 * @param url 非空。
 * @throws ArgumentError url 无效。
 * @throws Error 已在加载中。
 * @see #busy
 * @example
 * <listing version="3.0">
 * loader.load('assets/demo.txt');
 * </listing>
 */
public function load(url:String):void {
    // 缓存命中：同步完成
    if (_cache[url] != null) { /*...*/ }
}

// ----- 接口 -----
/** 可释放资源。 @see SomeImpl */
public interface IDisposable {}

// ----- 文件内辅助类 -----
/** 请求槽。 @private */
class RequestSlot { /*...*/ }

// ----- 覆写 -----
/** @inheritDoc */
override public function toString():String { return '[DemoLoader]'; }
```

### 成员要点（压缩）

| 成员 | 要点 |
|------|------|
| 类/接口 | 首句职责；接口 `@see` 实现类 |
| 方法/构造 | `@param`/`@return`/`@throws`；简单→`@example`；复杂主描述按需 |
| 属性 | 约束；明确默认→`@default` |
| private 方法 | 一句或仅 `@private`；体用 `//` |
| 隐藏的 public/protected | 标 `@private`（如 setter） |

---

## 逻辑注释

```actionscript
/** 重试上限 */
var maxRetry:int = 3;
// 仅缓存未命中走网络
if (!_cache[url]) {
    fetchMerged(url);
}
```

---

## 批量补全

1. 处理 public/protected + private 字段 `/** @private */`
2. 简单方法补 `@example`；复杂补 `@param`/`@return`/`@throws`/`@see`
3. 报告一句即可（如「`X` 的 ASDoc 已补全」）
