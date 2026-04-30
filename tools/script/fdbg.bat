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

:: ↓ 等同于 title Apache fdb（Flash Player 调试器）
call :ECHO_LANG :TITLE ""

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 检查环境变量 FLEX_HOME 是否存在，该变量指向已安装的 FlexSDK
if "%FLEX_HOME%"=="" (
	call :ECHO_LANG :UNDEFINE "FLEX_HOME"
	goto END
)
call :EXIST "%FLEX_HOME%"
echo FLEX_HOME: %FLEX_HOME%

set FLEX_BIN=%FLEX_HOME%\bin
call :EXIST "%FLEX_BIN%"
echo FLEX_BIN: %FLEX_BIN%

set SWF_FILE=%~1
call :EXIST "%SWF_FILE%"
echo SWF_FILE: %SWF_FILE%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 调用 fdb 命令行进行调试
set PATH=%FLEX_BIN%;%PATH%
call :ECHO_LANG :START_MSG ""
echo.

(
	echo run %SWF_FILE%
	echo connect
	echo continue
	echo continue
	echo quit
	echo y
) | fdb -unit

timeout /t 1 >nul

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 结束操作
echo.
call :ECHO_LANG :END_MSG ""
exit 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
:: pause >nul
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

set SUPPORT_LANG=437 932 936 949
set IS_SUPPORT=0
for %%a in (%SUPPORT_LANG%) do (
	if "%%a"=="%CURRENT_CODEPAGE%" (
		set IS_SUPPORT=1
		goto LANG_CHK
	)
)
:LANG_CHK
if %IS_SUPPORT%==0 (
	set CURRENT_CODEPAGE=437
)

set LANG_BAT=%BAT_HOME%lang\%~n0\%CURRENT_CODEPAGE%.bat
if not exist "%LANG_BAT%" (
	echo ECHO_LANG [N/A]
	goto :EOF
)

:: echo Code Page: %CURRENT_CODEPAGE%
call "%LANG_BAT%" %1 %2
goto :EOF