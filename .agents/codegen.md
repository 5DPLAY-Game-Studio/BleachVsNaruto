# 代码生成约定（AI）

何时读：新建/改类、命名、单例、复用与任务执行方式。格式见 [`code_style.md`](code_style.md)；注释见 [`comment.md`](comment.md)；落点见 [`modules.md`](modules.md)/[`map.md`](map.md)。

---

## MUST

| # | 规则 |
|---|------|
| 1 | 工具/管理器类优先单例，静态访问器 **`ClassName.I`**（与仓内现有管理器一致） |
| 2 | 命名：类 `PascalCase`；方法/变量 `camelCase`；常量 `UPPER_SNAKE_CASE`；私有成员 `_` 前缀 |
| 3 | 强类型；避免无必要的 `*` |
| 4 | 关键操作有适当错误处理（校验、抛错或可恢复路径，与邻码一致） |
| 5 | 优先复用 `LIB_KyoLib`、`CORE_Utils` 及模块内已有工具；不重复造轮子 |
| 6 | 保持简洁，解决当前问题；避免过度设计 |
| 7 | 模块落点服从 [`modules.md`](modules.md)（默认 `CORE_KernelLogic`） |
| 8 | 需要本地信息时主动用工具（读文件/搜索/只读 git 等）；大任务用 Todo 规划拆步 |

## NEVER

- 管理器/工具该单例却到处 `new` 多实例（除非现有 API 明确非单例）
- 私有字段不用 `_`、常量不用全大写下划线等破坏仓内一致性
- 能明确类型却滥用 `*`
- 为「优雅」引入无需求的抽象层/框架
- 大任务无步骤规划就铺开大范围改动

---

## 单例形态

```actionscript
public class FooCtrl {
    private static var _i:FooCtrl;

    public static function get I():FooCtrl {
        if (!_i) {
            _i = new FooCtrl();
        }
        return _i;
    }

    public function FooCtrl() {
    }
}
```

（以实现文件现有写法为准；要点是对外 **`FooCtrl.I`**。）

---

## 与「标准」差异（已知）

| 本仓约定 | 相对 AS3/常见惯例 |
|----------|-------------------|
| `ClassName.I` 单例 | 非语言标准；属本仓惯例 |
| 私有 `_` 前缀 | 非语言强制；Flex/AS 社区常见 |
| 尽量不用 `*` | 比语言默认更严（AS3 允许 `*`） |
| 复用指定库 / Kernel 优先 | 纯工程约定 |
