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

@echo off
setlocal enabledelayedexpansion

:: 当前 BAT 文件绝对运行目录
set BAT_HOME=%~dp0
:: echo BAT_HOME: %BAT_HOME%

:: ↓ 等同于 title 死神vs火影 - 监视器
call :ECHO_LANG :TITLE ""

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 检查环境变量 FLEX_HOME 是否存在，该变量指向已安装的 FlexSDK
if "%FLEX_HOME%"=="" (
	call :ECHO_LANG :UNDEFINE "FLEX_HOME"
	goto END
)
call :EXIST "%FLEX_HOME%"

set FLEX_BIN=%FLEX_HOME%\bin
call :EXIST "%FLEX_BIN%"
:: echo FLEX_BIN: %FLEX_BIN%

set RUNTIME=%FLEX_HOME%\runtimes\air\win
call :EXIST "%RUNTIME%"
:: echo RUNTIME: %RUNTIME%

set RUN_DIR=%BAT_HOME%..\..\out\production\SHELL_Dev
call :EXIST "%RUN_DIR%"
:: echo RUN_DIR: %RUN_DIR%

set APP_XML=%RUN_DIR%\FighterTester-app.xml
call :EXIST "%APP_XML%"
:: echo APP_XML: %APP_XML%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set PATH=%FLEX_BIN%;%PATH%
:: 代码页切换为 utf-8 编码
chcp 65001 >nul

:: 执行 adl 命令以调试测试版
adl -runtime "%RUNTIME%" "%APP_XML%" "%RUN_DIR%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 结束操作
echo.
exit 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
pause >nul
exit 1

:: 判断文件是否存在，不存在给出提示信息
:EXIST
if not exist %1 (
	call :ECHO_LANG :NOT_EXIST %1
	goto END
)
goto :EOF

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:ECHO_LANG
for /f "tokens=2 delims=:" %%a in ('chcp') do (
	for /f "tokens=1" %%b in ("%%a") do set CURRENT_CODEPAGE=%%b
)

set LANG_BAT=%BAT_HOME%lang\debug\%CURRENT_CODEPAGE%.bat
if not exist "%LANG_BAT%" (
	echo ECHO_LANG [N/A]
	goto :EOF
)

:: echo Code Page: %CURRENT_CODEPAGE%
call "%LANG_BAT%" %1 %2
goto :EOF