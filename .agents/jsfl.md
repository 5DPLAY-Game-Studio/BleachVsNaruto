# JSFL 脚本约定（AI）

何时读：新建/改 `tools/jsfl/*.jsfl`，或 bat 通过 `-run-jsfl` 驱动 Animate。落点见 [`modules.md`](modules.md)（`tools`）。批处理 bat 侧见 [`bat_script.md`](bat_script.md)。

参照实现：`tools/jsfl/publish_flashsrc.jsfl`（非交互）、`tools/jsfl/Batch Release.jsfl`（交互）。

---

## MUST

| # | 规则 |
|---|------|
| 1 | 路径：`tools/jsfl/<name>.jsfl`；行分隔符 **CRLF**；引擎按 **ES3 + JSFL 扩展**（无 `let`/`const`/`=>`/`Promise`；用 `var` + 索引 `for`） |
| 2 | 文件头：GPL 版权块 + 文件级 JSDoc（职责、调用方、交互/非交互、结果约定） |
| 3 | 注释用 **JSDoc（中文）**，不用 ASDoc；函数写 `@param` / `@return`；关键分支用短 `//`；勿堆调试注释 |
| 4 | 字符串用双引号 `"..."`（与现有 JSFL 一致；**不**套用 AS3 单引号） |
| 5 | `else` / `catch` **单独起一行**；`if`/`for`/`while`/`try` 始终加大括号 |
| 6 | `FLfile.listFolder` 结果先判空再遍历；禁止假定返回数组 |
| 7 | 打开/发布/关闭文档用 `try`/`catch`；**无论成败都尝试** `doc.close(false)`，避免残留影响后续 |
| 8 | 批量发布收集规则与现有脚本一致：当前目录 `*.fla`；`子目录名/子目录名.xfl` 存在则整包加入且不深入；否则递归子目录 |
| 9 | URI 工具可复用同文件内小函数：`normalizeDirURI`（去尾部 `/`\\）、`toRelPath`、`dirnameURI`、`winPathToURI`；相对路径用 `split(root).join("")`，勿单次 `replace` 当「去全部前缀」 |
| 10 | 非交互脚本：**禁止** `browseForFolderURL`；根路径由 bat 写 `tools/script/log/_*.txt` 或 `fl.scriptURI` 相对回退；退出前尽量 `fl.quit()`（包 try） |
| 11 | 供 bat 读的结果文件：启动先写失败码（如 `"1"`），全部成功再改成功码（如 `"0"`）；首行即码，供 `for /f` 读取 |
| 12 | 交互脚本可保留 `browseForFolderURL` + `langObj`（`zh_CN`/`en_US`/`ja_JP`/`ko_KR`，缺省 `en_US`）；`getLangText` 须安全回退 |

## NEVER

- 非交互批处理里弹文件夹对话框
- 无 try 的 `openDocument` / `publish` / `close`（单文件失败应可继续下一批）
- `for each` 遍历可能为 `null` 的 `listFolder` 结果
- 把 AS3 [`code_style.md`](code_style.md) 的单引号/包结构硬套到 JSFL
- 在 JSFL 内再实现 bat 的 `INIT_LANG` / 多语言 bat 资源（交互多语言用脚本内 `langObj`）
- 结果文件写成功后仍不 `quit`，导致 `-run-jsfl` 挂起（非交互场景）

---

## 脚本分工

| 脚本 | 场景 | 根目录 | 结果 |
|------|------|--------|------|
| `publish_flashsrc.jsfl` | `publish.bat` / `-run-jsfl` | `_publish_root.txt` 或相对回退 | `_publish_result.txt` 首行 `0`/`1` |
| `Batch Release.jsfl` | IDE 内手动运行 | `browseForFolderURL` | 仅 `fl.trace` |

日志/临时文件目录：`tools/script/log/`（约定见 [`bat_script.md`](bat_script.md)）。

---

## 模式速查

```javascript
/**
 * 文件职责一句话。
 * 调用方 / 交互性 / 结果约定。
 */

var LOG_TAG = "[my_jsfl]";
var trace = fl.trace;

main();

/**
 * 入口说明。
 */
function main() {
	// ...
}

/**
 * @param {string} dirUrl 搜索目录 URI
 * @return {string[]} 可发布文件 URI 列表
 */
function getFilesByDir(dirUrl) {
	var files = [];
	var flaFileList = FLfile.listFolder(dirUrl + "/*.fla", "files");
	if (flaFileList) {
		for (var i = 0; i < flaFileList.length; i++) {
			files.push(dirUrl + "/" + flaFileList[i]);
		}
	}
	// ... xfl 同名包 / 递归
	return files;
}

/**
 * @param {string} file 文件 URI
 * @return {boolean} 是否发布成功
 */
function publishFile(file) {
	var doc = null;
	try {
		doc = fl.openDocument(file);
	}
	catch (e) {
		return false;
	}
	if (!doc) {
		return false;
	}
	var ok = false;
	try {
		doc.publish();
		ok = true;
	}
	catch (e) {
		// 记日志
	}
	try {
		doc.close(false);
	}
	catch (e) {
		// 关闭失败不影响成败
	}
	return ok;
}
```

---

## 与 bat 协作（非交互）

1. bat 写入 `tools/script/log/_publish_root.txt`（Windows 路径或 `file://` URI）
2. 清除旧 `_publish_result.txt`，再 `Animate.exe -run-jsfl "...\publish_flashsrc.jsfl"`
3. JSFL 启动写 `"1"` → 全成功改 `"0"` → `fl.quit()`
4. bat 读结果首行；**勿依赖** Animate 进程退出码

新增同类批处理时：成对约定 `_xxx_root.txt` / `_xxx_result.txt` 命名，并在对应 `.bat` 与本 JSFL 文件头 JSDoc 写清。
