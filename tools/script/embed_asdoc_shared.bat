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
::   构建后钩子：将 ASDoc 嵌入 CORE_Shared.swc（不生成可浏览 HTML）。
::   由 build.bat、VSCode tasks、IDEA External Tool EmbedSharedAsDoc 调用。
::
:: 用法
::   tools\script\embed_asdoc_shared.bat
::   tools\script\embed_asdoc_shared.bat "D:\...\CORE_Shared.swc"
::
:: 前置条件
::   - 同 asdoc_shared.bat（FLEX_HOME、已编译的 CORE_Shared.swc）
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

set "BAT_HOME=%~dp0"
set "FUNC_COMMON=%BAT_HOME%func\common.bat"
call "%FUNC_COMMON%" INIT_LANG "%~n0"

set "MODE=embed"
set "NO_PAUSE=1"

set "REPO_ROOT=%BAT_HOME%..\.."
for %%I in ("%REPO_ROOT%") do set "REPO_ROOT=%%~fI"

if "%SWC_PATH%"=="" (
	set "SWC_PATH=%REPO_ROOT%\out\production\CORE_Shared\CORE_Shared.swc"
)

if not "%~1"=="" (
	set "SWC_PATH=%~f1"
)

:: IDEA Make 后可能短暂占用 SWC
powershell -NoProfile -ExecutionPolicy Bypass -File "%BAT_HOME%asdoc\wait_swc_ready.ps1" -SwcPath "!SWC_PATH!" -TimeoutSec 45
if errorlevel 1 (
	call "%FUNC_COMMON%" ECHO_LANG :SWC_NOT_READY "!SWC_PATH!"
	exit /b 1
)

call "%BAT_HOME%asdoc_shared.bat"
exit /b %ERRORLEVEL%
