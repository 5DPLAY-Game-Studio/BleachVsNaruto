# 代码风格（AI）

源：[`.idea/codeStyles/Project.xml`](../.idea/codeStyles/Project.xml)。生成 AS3 代码时**必须**遵守。非给人阅读的冗长说明。

ASDoc 见 [`comment.md`](comment.md)。

---

## MUST

| # | 规则 |
|---|------|
| 1 | 行分隔符 `CRLF` |
| 2 | 字符串单引号 `'...'`；语句以 `;` 结尾 |
| 3 | 行尾 `{`：`package`/`class`/`interface`/方法/`if`/`else`/`while`/`for`/`do`/`try`/`catch`/`finally`/`switch` 的 `{` 均在同行末尾 |
| 4 | `if`/`while`/`for`/`do-while` **始终**加大括号（即使单行） |
| 5 | `else`/`catch`/`finally` **单独起一行**（不跟在 `}` 后同行） |
| 6 | `switch` 内 `case`/`default` **不**相对 `switch` 再缩进 |
| 7 | 邻近 `var` 按 **`=`** 对齐（不对齐 `:` / 行尾 `;`） |
| 8 | 对象字面量属性按 **`:`** 对齐 |
| 9 | 多行方法**形参**按 **`:`** 对齐（书写约定；IDEA 无此项） |
| 10 | 折行类规则均为 **过长才折**（`*_WRAP=1`）；短内容保持单行 |
| 11 | `for`：**仅括号内条件过长**才折行；短循环必须单行 |
| 12 | 折行时：调用/形参/`for` 的 `(` **紧跟**名/`for` 行尾；`)` **单独一行** |
| 13 | 数组折行：`[` 紧跟赋值行尾；`]` 单独一行 |
| 14 | 赋值过长折行：`=` 在**下一行开头** |
| 15 | 链式/二元/三元/extends 多行时对齐续行 |

## NEVER

- `"` 字符串（除非强制要求）
- 左 `{` 单独起一行（Allman）
- `if (x) stmt;` 无大括号
- `} else {` / `} catch` / `} finally` 同行
- 短 `for` 无故拆成多行
- 调用写成 `foo\n(`（`(` 必须行尾：`foo(`）

---

## 模式速查

```actionscript
// 引号/分号/行尾{
package p {
public class C extends Sprite
    implements IDisposable, IUpdatable {
    public function f():void {
        if (ok) {
            a();
        }
        else {
            b();
        }
    }
}
}

// var 按=；对象按:
var id:int             = 1;
var displayName:String = 'naruto';
var cfg:Object = {
    x    : 10,
    y    : 20,
    width: 100
};

// else/catch/finally 换行；case 不缩进
try {
    load();
}
catch (e:Error) {
    handle(e);
}
finally {
    cleanup();
}
switch (state) {
case STATE_IDLE:
    idle();
    break;
default:
    reset();
    break;
}

// 短 for：单行；长 for：才折
for (var i:int = 0; i < list.length; i++) {
    process(list[i]);
}
for (
    var i:int = 0;
    i < team.fighters[slot].comboHistory.length;
    i++
) {
    process(team.fighters[slot].comboHistory[i]);
}

// 过长调用/形参：`(行尾` + 参对齐 + `)独占行`；形参按:
fighter.attack(
    target,
    damage,
    hitType
);
public function bind(
    key    :String,
    handler:Function,
    once   :Boolean = false
):void {
}

// 赋值/运算/三元过长
var message:String
    = 'load complete: ' + fileName;
value = left
      + middle
      + right;
label = ready
    ? 'ok'
    : 'wait';

// 链对齐；数组折行
result = service
    .load(id)
    .then(parse)
    .done();
var ids:Array = [
    1,
    2,
    3
];
```

---

## IDEA 配置键（与约定对应）

| 键 | 值 | 含义 |
|----|-----|------|
| `LINE_SEPARATOR` | CRLF | |
| `USE_DOUBLE_QUOTES` | false | 单引号 |
| `FORCE_QUOTE_STYlE` / `FORCE_SEMICOLON_STYLE` | true | |
| `BRACE_STYLE` / `CLASS_BRACE_STYLE` / `METHOD_BRACE_STYLE` | 1 | 行尾 `{` |
| `IF/WHILE/FOR/DOWHILE_BRACE_FORCE` | 3 | 始终加大括号 |
| `ELSE/CATCH/FINALLY_ON_NEW_LINE` | true | |
| `INDENT_CASE_FROM_SWITCH` | false | |
| `ALIGN_OBJECT_PROPERTIES` | 1 | 对象按 `:` |
| `ALIGN_VAR_STATEMENTS` | 2 | var 按 `=` |
| `ALIGN_MULTILINE_*`（链/调用参/二元/三元/extends/数组表达式） | true | |
| 各 `*_WRAP` | 1 | 过长才折 |
| `CALL/METHOD/FOR_*_LPAREN_ON_NEXT_LINE` | false | `(` 行尾 |
| `CALL/METHOD/FOR_*_RPAREN_ON_NEXT_LINE` | true | `)` 换行 |
| `ARRAY_INITIALIZER_LBRACE_ON_NEXT_LINE` | false | `[` 行尾 |
| `ARRAY_INITIALIZER_RBRACE_ON_NEXT_LINE` | true | `]` 换行 |
| `PLACE_ASSIGNMENT_SIGN_ON_NEXT_LINE` | true | `=` 下行首 |
| `REFORMAT_C_STYLE_COMMENTS` / `WRAP_COMMENTS` | true | |
| （无 IDEA 键）多行形参按 `:` 对齐 | 书写约定 | 生成时必须手写对齐 |
