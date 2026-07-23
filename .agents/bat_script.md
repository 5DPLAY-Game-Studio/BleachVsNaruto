# BAT 脚本约定（AI）

何时读：新建/改 `tools/script` 下 `.bat`、`lang/` 多语言资源、或 `func/` 共用子程序。源码落点见 [`modules.md`](modules.md)（`tools`）。

---

## MUST

| # | 规则 |
|---|------|
| 1 | 主脚本：`tools/script/<name>.bat`；多语言：`tools/script/lang/<name>/<codepage>.bat`；共用子程序：`tools/script/func/`；PowerShell：`tools/script/ps/`；配置：`tools/script/conf/`；运行时日志/临时报告：`tools/script/log/` |
| 2 | 主脚本与 `func/*.bat`：**GBK + CRLF**；中文注释详略得当（头：用途/用法/前置；段：短标题；子程序：一行职责） |
| 3 | `lang/<cp>.bat` 按文件名编码读写：**437** ASCII；**932** cp932（Shift-JIS）；**936** GBK；**949** cp949。仅保留版权声明 + 文案标签，不加多余注释 |
| 4 | 重复路径/开关/工具名抽成 `set "MY_VAR=..."`，之后用 `%MY_VAR%` / `!MY_VAR!`；列表用空格分隔一次定义（如 `SHELL_LIST`） |
| 5 | 启动样板：`setlocal enabledelayedexpansion` → `BAT_HOME` → `FUNC_COMMON` → `call "%FUNC_COMMON%" INIT_LANG "%~n0"` |
| 6 | 多语言输出、路径存在检查**必须**走 `func\common.bat`（`ECHO_LANG` / `EXIST`），禁止在主脚本再复制一份 |
| 7 | `:EXIST` / 同类校验子程序：内部 `exit /b 1\|0`；调用方 `if errorlevel 1 goto END`（或子程序内 `exit /b 1`）。**禁止**在 `call` 出的子程序里 `goto END` 再 `exit /b`（无法结束主脚本） |
| 8 | 结束码用 `exit /b`，不用 `exit`（避免 `call` 时杀掉父 cmd） |
| 9 | 路径类赋值一律 `set "VAR=..."`；含空格路径全程加引号；`::` 注释避免 `<...>`（易被当成重定向） |
| 10 | 新增/改 `ECHO_LANG` 标签时，同步改齐 `lang/<name>/` 下 **437/932/936/949**，并按各自编码保存 |
| 11 | 优先可维护与检逻辑错误；发现共用模式可回写已改脚本并抽到 `func/` |

## NEVER

- 在主脚本内再实现 `INIT_LANG` / `ECHO_LANG` / `EXIST`
- `lang` 资源用错误代码页保存，或往 `lang` 里堆说明性注释
- `call :FOO` 内 `goto END` + `exit /b` 当作失败退出
- 未加引号的 `set PATH=...` / `set FLASH_EXE=...`（空格路径会截断）
- 用 Write 工具直接写含中文的 GBK bat（易变成 `?`）；应用脚本按目标编码 `encode` 写入

---

## 目录与职责

| 路径 | 职责 |
|------|------|
| `tools/script/*.bat` | 业务脚本（build / publish / debug / sync 等） |
| `tools/script/func/common.bat` | 共用：`INIT_LANG`、`ECHO_LANG`、`EXIST`（**无** `setlocal`，以便写回调用方变量） |
| `tools/script/ps/*.ps1` | 由 bat 调用的 PowerShell 辅助脚本 |
| `tools/script/conf/*` | 构建/工具共享配置（如 `sdk-external.xml`） |
| `tools/script/log/*` | bat/JSFL 运行时临时报告（如 `_publish_*.txt`、`adb_devices.txt`）；不入库 |
| `tools/script/lang/<name>/<cp>.bat` | 按标签 `goto` 的文案；`%1`=标签，`%~2`=参数 |

---

## 启动 / 调用速查

```bat
@echo off
setlocal enabledelayedexpansion

set "BAT_HOME=%~dp0"
set "FUNC_COMMON=%BAT_HOME%func\common.bat"
call "%FUNC_COMMON%" INIT_LANG "%~n0"

call "%FUNC_COMMON%" ECHO_LANG :TITLE ""
call "%FUNC_COMMON%" EXIST "%SOME_PATH%"
if errorlevel 1 goto END

:: ...

:END
exit /b 1
```

```bat
:: func\common.bat 入口（已有，勿再复制到主脚本）
@echo off
if "%~1"=="" exit /b 1
call :%~1 %2 %3 %4 %5 %6 %7 %8 %9
exit /b
```

---

## 头注释骨架（主脚本）

```bat
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Copyright (C) 2021-2026, 5DPLAY Game Studio
:: ... GPL 块 ...
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: 用途
::   <一句话>
::
:: 用法
::   tools\script\<name>.bat [args]
::
:: 前置条件
::   - <环境变量 / 输入产物>
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
```

---

## 编码写入（AI）

| 目标 | 做法 |
|------|------|
| 主脚本 / `func` | 内容用 Unicode，落盘 `encode("gbk")`，换行 CRLF |
| `lang/437.bat` | ASCII/`encode("ascii")` |
| `lang/932.bat` | `encode("cp932")` |
| `lang/936.bat` | `encode("gbk")` |
| `lang/949.bat` | `encode("cp949")` |
