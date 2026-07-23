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
::   使用 Apache fdb（Flash Player Debugger）调试指定 SWF。
::
:: 用法
::   tools\script\fdbg.bat [swf-file]
::
:: 前置条件
::   - FLEX_HOME 指向 Flex/AIR SDK（含 bin\fdb）
::   - 第一个参数为待调试的 .swf 路径
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

:: 当前 BAT 文件所在目录（末尾带反斜杠）
set "BAT_HOME=%~dp0"
set "FUNC_COMMON=%BAT_HOME%func\common.bat"
call "%FUNC_COMMON%" INIT_LANG "%~n0"

call "%FUNC_COMMON%" ECHO_LANG :TITLE ""

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 1) 参数：SWF 路径
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if "%~1"=="" (
	call "%FUNC_COMMON%" ECHO_LANG :USAGE ""
	goto END
)

set "SWF_FILE=%~1"
for %%I in ("%SWF_FILE%") do set "SWF_FILE=%%~fI"
call "%FUNC_COMMON%" EXIST "%SWF_FILE%"
if errorlevel 1 goto END
echo SWF_FILE: %SWF_FILE%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 2) Flex SDK + fdb
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if "%FLEX_HOME%"=="" (
	call "%FUNC_COMMON%" ECHO_LANG :UNDEFINE "FLEX_HOME"
	goto END
)
call "%FUNC_COMMON%" EXIST "%FLEX_HOME%"
if errorlevel 1 goto END
echo FLEX_HOME: %FLEX_HOME%

set "FLEX_BIN=%FLEX_HOME%\bin"
call "%FUNC_COMMON%" EXIST "%FLEX_BIN%"
if errorlevel 1 goto END
echo FLEX_BIN: %FLEX_BIN%

set "FDB=%FLEX_BIN%\fdb.bat"
call "%FUNC_COMMON%" EXIST "%FDB%"
if errorlevel 1 goto END

set "PATH=%FLEX_BIN%;%PATH%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 3) 启动 fdb（-unit：非交互批处理命令）
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call "%FUNC_COMMON%" ECHO_LANG :START_MSG ""
echo.

(
	echo run "%SWF_FILE%"
	echo connect
	echo continue
	echo continue
	echo quit
	echo y
) | "%FDB%" -unit
if errorlevel 1 goto END

timeout /t 1 >nul

echo.
call "%FUNC_COMMON%" ECHO_LANG :END_MSG ""
exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
exit /b 1
