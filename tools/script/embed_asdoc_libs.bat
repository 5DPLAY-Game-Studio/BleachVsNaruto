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
::   IDEA After Make：依次将 ASDoc 嵌入 LIB_KyoLib.swc 与 CORE_Shared.swc。
::
:: 用法
::   tools\script\embed_asdoc_libs.bat
::
:: 前置条件
::   - 同各模块 embed 钩子；须先 Make / 编译产出 SWC
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

set "BAT_HOME=%~dp0"
set "FUNC_COMMON=%BAT_HOME%func\common.bat"
call "%FUNC_COMMON%" INIT_LANG "asdoc_shared"

set "REPO_ROOT=%BAT_HOME%..\.."
for %%I in ("%REPO_ROOT%") do set "REPO_ROOT=%%~fI"

call "%FUNC_COMMON%" ECHO_LANG :EMBED_LIBS_START ""

call "%REPO_ROOT%\LIB_KyoLib\tools\embed_asdoc.bat"
if errorlevel 1 (
	call "%FUNC_COMMON%" ECHO_LANG :EMBED_FAIL "LIB_KyoLib"
	exit /b 1
)

call "%BAT_HOME%embed_asdoc_shared.bat"
if errorlevel 1 (
	call "%FUNC_COMMON%" ECHO_LANG :EMBED_FAIL "CORE_Shared"
	exit /b 1
)

call "%FUNC_COMMON%" ECHO_LANG :EMBED_LIBS_OK ""
exit /b 0
