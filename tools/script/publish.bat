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

:: 当前 BAT 文件绝对运行目录
set BAT_HOME=%~dp0

call :ECHO_LANG :TITLE ""
call :ECHO_LANG :PUBLISH_START ""

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 1) FLASH_HOME + 可执行文件
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 检查环境变量 FLASH_HOME 是否存在，该变量指向已安装的 Flash/Animate
if "%FLASH_HOME%"=="" (
	call :ECHO_LANG :UNDEFINE "FLASH_HOME"
	goto END
)
call :EXIST "%FLASH_HOME%"

set FLASH_EXE=
if exist "%FLASH_HOME%\Animate.exe" set FLASH_EXE=%FLASH_HOME%\Animate.exe
if "%FLASH_EXE%"=="" if exist "%FLASH_HOME%\Flash.exe" set FLASH_EXE=%FLASH_HOME%\Flash.exe
if "%FLASH_EXE%"=="" if exist "%FLASH_HOME%\Support Files\Animate.exe" set FLASH_EXE=%FLASH_HOME%\Support Files\Animate.exe
if "%FLASH_EXE%"=="" if exist "%FLASH_HOME%\Support Files\Flash.exe" set FLASH_EXE=%FLASH_HOME%\Support Files\Flash.exe

if "%FLASH_EXE%"=="" (
	call :ECHO_LANG :NO_EXE "%FLASH_HOME%"
	goto END
)
call :ECHO_LANG :USE_EXE "%FLASH_EXE%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 2) 仓库 / FlashSrc / JSFL 路径
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set REPO_ROOT=%BAT_HOME%..\..
for %%I in ("%REPO_ROOT%") do set REPO_ROOT=%%~fI

set FLASH_SRC=%REPO_ROOT%\BleachVsNaruto_FlashSrc
call :EXIST "%FLASH_SRC%"

set JSFL=%REPO_ROOT%\tools\jsfl\publish_flashsrc.jsfl
call :EXIST "%JSFL%"

set ROOT_FILE=%REPO_ROOT%\tools\jsfl\_publish_root.txt
set RESULT_FILE=%BAT_HOME%_publish_result.txt

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 3) 写入 JSFL 用的根路径；清除上次结果
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

> "%ROOT_FILE%" echo %FLASH_SRC%
if errorlevel 1 (
	call :ECHO_LANG :WRITE_FAIL "%ROOT_FILE%"
	goto END
)

if exist "%RESULT_FILE%" del /f /q "%RESULT_FILE%" >nul 2>&1

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 3b) 抑制打开 JSFL 时的运行/编辑提示（偏好设置 + 命令行）
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call :ENSURE_JSFL_NO_PROMPT

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 4) 启动 Flash/Animate 并执行 JSFL（阻塞至退出）
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call :ECHO_LANG :LAUNCH ""
:: -run-jsfl：始终将 jsfl 作为命令运行（Animate.exe 隐藏选项）
start "" /wait "%FLASH_EXE%" -run-jsfl "%JSFL%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 5) 读取 JSFL 结果（Adobe 退出码不可靠）
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if not exist "%RESULT_FILE%" (
	call :ECHO_LANG :NO_RESULT "%RESULT_FILE%"
	goto END
)

set PUBLISH_CODE=1
for /f "usebackq tokens=1 delims= " %%a in ("%RESULT_FILE%") do (
	set PUBLISH_CODE=%%a
	goto :HAVE_CODE
)
:HAVE_CODE

if "!PUBLISH_CODE!"=="0" (
	call :ECHO_LANG :PUBLISH_SUCCESS ""
	echo.
	exit /b 0
)

call :ECHO_LANG :PUBLISH_FAIL "!PUBLISH_CODE!"
goto END

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
echo.
exit /b 1

:: 判断文件是否存在，不存在给出提示信息
:EXIST
if not exist %1 (
	call :ECHO_LANG :NOT_EXIST %1
	goto END
)
goto :EOF

:: 修补 %APPDATA%\Adobe\Animate\<ver>\Application.xml，跳过打开 JSFL 对话框
:ENSURE_JSFL_NO_PROMPT
set ANIMATE_APPDATA=%APPDATA%\Adobe\Animate
if not exist "%ANIMATE_APPDATA%" goto :EOF
powershell -NoProfile -ExecutionPolicy Bypass -File "%BAT_HOME%ensure_jsfl_no_prompt.ps1"
goto :EOF

:ECHO_LANG
for /f "tokens=2 delims=:" %%a in ('chcp') do (
	for /f "tokens=1" %%b in ("%%a") do set CURRENT_CODEPAGE=%%b
)

set SUPPORT_LANG=437 932 936 949
set IS_SUPPORT=0
for %%a in (%SUPPORT_LANG%) do (
	if "%%a"=="!CURRENT_CODEPAGE!" (
		set IS_SUPPORT=1
		goto LANG_CHK
	)
)
:LANG_CHK
if !IS_SUPPORT!==0 (
	set CURRENT_CODEPAGE=437
)

set LANG_BAT=%BAT_HOME%lang\%~n0\!CURRENT_CODEPAGE!.bat
if not exist "!LANG_BAT!" (
	echo ECHO_LANG [N/A]
	goto :EOF
)

call "!LANG_BAT!" %1 %2
goto :EOF
