# 代码生成约定（AI）

何时读：新建/改类、命名、单例、复用与任务执行方式。格式见 [`code_style.md`](code_style.md)；注释见 [`comment.md`](comment.md)；落点见 [`modules.md`](modules.md)/[`map.md`](map.md)。

---

## MUST

| # | 规则 |
|---|------|
| 1 | 工具/管理器类优先单例，静态访问器 **`ClassName.I`**；懒初始化写 **`_i ||= new ClassName()`**（与仓内现有管理器一致） |
| 2 | 命名：类 `PascalCase`；方法/变量 `camelCase`；常量 `UPPER_SNAKE_CASE`；私有成员 `_` 前缀 |
| 3 | 强类型；避免无必要的 `*` |
| 4 | 关键操作有适当错误处理（校验、抛错或可恢复路径，与邻码一致） |
| 5 | 优先复用 `LIB_KyoLib`、`CORE_Utils` 及模块内已有工具；不重复造轮子 |
| 6 | 保持简洁，解决当前问题；避免过度设计 |
| 7 | 模块落点服从 [`modules.md`](modules.md)（默认 `CORE_KernelLogic`） |
| 8 | 需要本地信息时主动用工具（读文件/搜索/只读 git 等）；大任务用 Todo 规划拆步 |
| 9 | **无用空构造一律不写**：纯静态类、单例、普通类均省略无参空构造（含仅 `super();`）；也不写「无需实例化 / 构造方法」空构造 ASDoc。可写在字段上的初始化勿放进构造 |
| 10 | VO 落点：存档/模式/通用 → `data` / `data/vos`；角色判定 → `fighter/models`；角色瞬时 → `fighter/vos`；特效帧缓存 → `ctrler/effect`；输入配置可留 `input` |
| 11 | 新逻辑跟域包走；**勿**往 `utils/` 堆业务。通用字符串/显示/加载小工具才进 `utils` |

## NEVER

- 管理器/工具该单例却到处 `new` 多实例（除非现有 API 明确非单例）
- 单例懒初始化写成 `if (!_i) { _i = new …; }`（应用 `_i ||= new …`）
- 私有字段不用 `_`、常量不用全大写下划线等破坏仓内一致性
- 能明确类型却滥用 `*`
- 为「优雅」引入无需求的抽象层/框架
- 大任务无步骤规划就铺开大范围改动
- 生成无参空构造 `public function Xxx() { }`（含仅 `super();`、仅「构造方法/无需实例化」ASDoc）
- `ctrler` / `fighter` / `data` **新增**对具体 UI 控件的 import，或回写 `ui/` 静态字段（应写 `GameConfig` / 事件 / 数据；既有 `GameUI` 门面调用除外）
- 改 `main_mc.initFighter` 注入字段名，或破坏 `$mc_ctrler` / `$fighter_ctrler` / `$effect_ctrler` / `$camera_ctrler` 时间轴契约（除非明确同步改全角色 SWF）
- 把特效管理、联机锁帧、角色状态机等域逻辑新建进 `utils/`

---

## 纯静态工具类

仅静态 API 时省略构造；AS3 默认无参构造即可。

```actionscript
public class FooUtils {
    public static function bar():void {
    }
}
```

---

## 单例形态

懒初始化统一用 **`_i ||= new Xxx()`**（勿写 `if (!_i) { _i = new …; }`）。

```actionscript
public class FooCtrl {
    private static var _i:FooCtrl;

    public static function get I():FooCtrl {
        _i ||= new FooCtrl();
        return _i;
    }
}
```

（无初始化逻辑时不要写空构造；要点是对外 **`FooCtrl.I`**。字段可直接 `= ...` 初始化时写在声明上。）

---

## 与「标准」差异（已知）

| 本仓约定 | 相对 AS3/常见惯例 |
|----------|-------------------|
| `ClassName.I` 单例 | 非语言标准；属本仓惯例 |
| 私有 `_` 前缀 | 非语言强制；Flex/AS 社区常见 |
| 尽量不用 `*` | 比语言默认更严（AS3 允许 `*`） |
| 复用指定库 / Kernel 优先 | 纯工程约定 |
