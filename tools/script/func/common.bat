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
::   tools\script 下各 bat 的共用子程序库。
::
:: 用法
::   set "BAT_HOME=%~dp0"
::   set "FUNC_COMMON=%BAT_HOME%func\common.bat"
::   call "%FUNC_COMMON%" INIT_LANG "%~n0"
::   call "%FUNC_COMMON%" ECHO_LANG :TAG "arg"
::   call "%FUNC_COMMON%" EXIST "path"
::   if errorlevel 1 goto END
::
:: 前置条件
::   - 调用方已 setlocal enabledelayedexpansion
::   - 调用方已设置 BAT_HOME（末尾带反斜杠）
::   - 本文件不使用 setlocal，以便 INIT_LANG 写入调用方环境变量
::
:: 导出
::   INIT_LANG  - 按控制台代码页选择 lang 下对应脚本与 codepage，设置 LANG_BAT
::   ECHO_LANG  - 调用 LANG_BAT 输出多语言文案
::   EXIST      - 路径存在返回 0，否则提示并返回 1
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
if "%~1"=="" exit /b 1
call :%~1 %2 %3 %4 %5 %6 %7 %8 %9
exit /b

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: %1 = 主脚本名（%~n0），用于定位 lang 下目录
:INIT_LANG
set "SCRIPT_NAME=%~1"
if "%SCRIPT_NAME%"=="" set "SCRIPT_NAME=unknown"

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

set "LANG_BAT=%BAT_HOME%lang\%SCRIPT_NAME%\%CURRENT_CODEPAGE%.bat"
if not exist "%LANG_BAT%" set "LANG_BAT="
exit /b 0

:: %1 = 语言标签（如 :TITLE），%2 = 可选参数
:ECHO_LANG
if "%LANG_BAT%"=="" (
	echo ECHO_LANG [N/A]
	exit /b 0
)
call "%LANG_BAT%" %1 %2
exit /b 0

:: %1 = 路径；不存在则提示并返回 1
:EXIST
if not exist %1 (
	call :ECHO_LANG :NOT_EXIST %1
	exit /b 1
)
exit /b 0
