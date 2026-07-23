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
::   使用 AIR Debug Launcher（adl）启动 SHELL_Dev 调试包。
::   通常在 tools\script\build.bat 成功后使用。
::
:: 用法
::   tools\script\debug.bat
::
:: 前置条件
::   - FLEX_HOME 指向 Flex/AIR SDK（含 bin\adl、runtimes\air\win）
::   - 已构建 out\production\SHELL_Dev（含 FighterTester-app.xml 与 SWF）
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

:: 当前 BAT 文件所在目录（末尾带反斜杠）
set "BAT_HOME=%~dp0"
call :INIT_LANG

call :ECHO_LANG :TITLE ""

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 1) Flex / AIR SDK
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if "%FLEX_HOME%"=="" (
	call :ECHO_LANG :UNDEFINE "FLEX_HOME"
	goto END
)
call :EXIST "%FLEX_HOME%"
if errorlevel 1 goto END

set "FLEX_BIN=%FLEX_HOME%\bin"
call :EXIST "%FLEX_BIN%"
if errorlevel 1 goto END

set "ADL=%FLEX_BIN%\adl.exe"
call :EXIST "%ADL%"
if errorlevel 1 goto END

set "RUNTIME=%FLEX_HOME%\runtimes\air\win"
call :EXIST "%RUNTIME%"
if errorlevel 1 goto END

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 2) SHELL_Dev 运行目录与应用描述符
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set "REPO_ROOT=%BAT_HOME%..\.."
for %%I in ("%REPO_ROOT%") do set "REPO_ROOT=%%~fI"

set "RUN_DIR=%REPO_ROOT%\out\production\SHELL_Dev"
call :EXIST "%RUN_DIR%"
if errorlevel 1 goto END

set "APP_XML=%RUN_DIR%\FighterTester-app.xml"
call :EXIST "%APP_XML%"
if errorlevel 1 goto END

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 3) 启动 adl
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set "PATH=%FLEX_BIN%;%PATH%"
:: adl/控制台输出使用 UTF-8（与 AIR 调试日志更兼容）
chcp 65001 >nul

"%ADL%" -runtime "%RUNTIME%" "%APP_XML%" "%RUN_DIR%"
if errorlevel 1 goto END

echo.
exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
pause >nul
exit /b 1

:: 路径不存在则提示并返回错误（调用方须检查 errorlevel）
:EXIST
if not exist %1 (
	call :ECHO_LANG :NOT_EXIST %1
	exit /b 1
)
exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 依据当前控制台代码页选择 lang 目录下对应 codepage 的 bat（仅初始化一次）
:INIT_LANG
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

set "LANG_BAT=%BAT_HOME%lang\%~n0\%CURRENT_CODEPAGE%.bat"
if not exist "%LANG_BAT%" set "LANG_BAT="
goto :EOF

:ECHO_LANG
if "%LANG_BAT%"=="" (
	echo ECHO_LANG [N/A]
	goto :EOF
)
call "%LANG_BAT%" %1 %2
goto :EOF
