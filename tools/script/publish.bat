::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Copyright (C) 2021-2026, 5DPLAY Game Studio
:: All rights reserved.
::
:: This program is free software: you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation, either version 3 of the License, or
:: (at your option) any later version.
::
:: This program is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
:: GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: 用途
::   通过 Flash/Animate JSFL 批量发布 BleachVsNaruto_FlashSrc（fla/xfl）。
::   不修改 tools/jsfl/Batch Release.jsfl（手动浏览工作流）。
::
:: 用法
::   tools\script\publish.bat
::
:: 前置条件
::   FLASH_HOME 指向 Flash/Animate 安装目录（内含 Animate.exe
::   或 Flash.exe），例如 E:\Program Files\Adobe\Adobe Animate 2022
::
:: 说明
::   启动使用 -run-jsfl（Animate 2022+ 隐藏选项）。旧的 -AlwaysRunJSFL
::   在现代 Animate.exe 中不存在，无效。
::   同时设置 AppData Application.xml：DontPromptForJSFLOpen + RunJSFLAsCommand
::   （等同勾选“不再显示”并选择运行）。
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

:: 当前 BAT 文件所在目录（末尾带反斜杠）
set "BAT_HOME=%~dp0"
set "FUNC_COMMON=%BAT_HOME%func\common.bat"
call "%FUNC_COMMON%" INIT_LANG "%~n0"

call "%FUNC_COMMON%" ECHO_LANG :TITLE ""
call "%FUNC_COMMON%" ECHO_LANG :PUBLISH_START ""

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 1) FLASH_HOME + 可执行文件
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: FLASH_HOME 须指向已安装的 Flash/Animate 根目录
if "%FLASH_HOME%"=="" (
	call "%FUNC_COMMON%" ECHO_LANG :UNDEFINE "FLASH_HOME"
	goto END
)
call "%FUNC_COMMON%" EXIST "%FLASH_HOME%"
if errorlevel 1 goto END

call :RESOLVE_FLASH_EXE
if "!FLASH_EXE!"=="" (
	call "%FUNC_COMMON%" ECHO_LANG :NO_EXE "%FLASH_HOME%"
	goto END
)
call "%FUNC_COMMON%" ECHO_LANG :USE_EXE "!FLASH_EXE!"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 2) 仓库 / FlashSrc / JSFL 路径
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set "REPO_ROOT=%BAT_HOME%..\.."
for %%I in ("%REPO_ROOT%") do set "REPO_ROOT=%%~fI"

set "JSFL_DIR=%REPO_ROOT%\tools\jsfl"
set "FLASH_SRC=%REPO_ROOT%\BleachVsNaruto_FlashSrc"
set "JSFL=%JSFL_DIR%\publish_flashsrc.jsfl"
set "ROOT_FILE=%JSFL_DIR%\_publish_root.txt"
set "RESULT_FILE=%BAT_HOME%_publish_result.txt"
set "ENSURE_PS1=%BAT_HOME%ensure_jsfl_no_prompt.ps1"
set "ANIMATE_APPDATA=%APPDATA%\Adobe\Animate"

call "%FUNC_COMMON%" EXIST "%FLASH_SRC%"
if errorlevel 1 goto END
call "%FUNC_COMMON%" EXIST "%JSFL%"
if errorlevel 1 goto END
call "%FUNC_COMMON%" EXIST "%ENSURE_PS1%"
if errorlevel 1 goto END

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 3) 写入 JSFL 用的根路径；清除上次结果
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

(
	echo %FLASH_SRC%
) > "%ROOT_FILE%"
if errorlevel 1 (
	call "%FUNC_COMMON%" ECHO_LANG :WRITE_FAIL "%ROOT_FILE%"
	goto END
)

if exist "%RESULT_FILE%" del /f /q "%RESULT_FILE%" >nul 2>&1

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 4) 抑制打开 JSFL 时的运行/编辑提示（偏好设置 + 命令行）
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call :ENSURE_JSFL_NO_PROMPT

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 5) 启动 Flash/Animate 并执行 JSFL（阻塞至退出）
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call "%FUNC_COMMON%" ECHO_LANG :LAUNCH ""
:: -run-jsfl：始终将 jsfl 作为命令运行（Animate.exe 隐藏选项）
start "" /wait "!FLASH_EXE!" -run-jsfl "%JSFL%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 6) 读取 JSFL 结果（Adobe 退出码不可靠）
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if not exist "%RESULT_FILE%" (
	call "%FUNC_COMMON%" ECHO_LANG :NO_RESULT "%RESULT_FILE%"
	goto END
)

set PUBLISH_CODE=1
for /f "usebackq tokens=1 delims= " %%a in ("%RESULT_FILE%") do (
	set PUBLISH_CODE=%%a
	goto HAVE_CODE
)
:HAVE_CODE

if "!PUBLISH_CODE!"=="0" (
	call "%FUNC_COMMON%" ECHO_LANG :PUBLISH_SUCCESS ""
	echo.
	exit /b 0
)

call "%FUNC_COMMON%" ECHO_LANG :PUBLISH_FAIL "!PUBLISH_CODE!"
goto END

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
echo.
exit /b 1

:: 在 FLASH_HOME 下按优先级查找 Animate/Flash 可执行文件
:RESOLVE_FLASH_EXE
set "FLASH_EXE="
for %%E in (
	"Animate.exe"
	"Flash.exe"
	"Support Files\Animate.exe"
	"Support Files\Flash.exe"
) do (
	if "!FLASH_EXE!"=="" (
		if exist "%FLASH_HOME%\%%~E" set "FLASH_EXE=%FLASH_HOME%\%%~E"
	)
)
goto :EOF

:: 修补 AppData\Adobe\Animate 各版本 Application.xml，跳过打开 JSFL 对话框
:ENSURE_JSFL_NO_PROMPT
if not exist "%ANIMATE_APPDATA%" goto :EOF
powershell -NoProfile -ExecutionPolicy Bypass -File "%ENSURE_PS1%"
goto :EOF

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
