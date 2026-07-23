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
::   将 shared\assets\assets 同步到 shared\_tmp\{pc,dev,mob}\assets，
::   供 SHELL_PC / SHELL_Dev / SHELL_Mob 使用。
::
:: 用法
::   cd shared
::   ..\tools\script\sync.bat
::   （build.bat 会在 shared 下自动 call 本脚本）
::
:: 前置条件
::   当前工作目录为 shared（含 assets\assets 与 _tmp\pc|dev|mob）
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

:: 当前 BAT 文件所在目录（末尾带反斜杠）
set "BAT_HOME=%~dp0"
call :INIT_LANG

:: 工作目录：调用方当前目录（应为 shared）
set "WORK_SPACE=%CD%"
echo BAT_HOME: %BAT_HOME%
echo WORK_SPACE: %WORK_SPACE%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 1) 源素材与 _tmp 根目录
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set ASSETS_NAME=assets
set TMP_NAME=_tmp
set "ASSETS_DIR=%WORK_SPACE%\%ASSETS_NAME%\%ASSETS_NAME%"
set "TMP_DIR=%WORK_SPACE%\%TMP_NAME%"

call :EXIST "%ASSETS_DIR%"
if errorlevel 1 goto END
call :EXIST "%TMP_DIR%"
if errorlevel 1 goto END

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 2) 外壳通道目录（pc / dev / mob）
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 与 VSCode task / 各 SHELL 模块一致
set "SHELL_LIST=pc dev mob"

for %%S in (%SHELL_LIST%) do (
	call :EXIST "%TMP_DIR%\%%S"
	if errorlevel 1 goto END
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 3) 清空并复制素材到各通道
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

for %%S in (%SHELL_LIST%) do (
	set "DEST_ASSETS=%TMP_DIR%\%%S\%ASSETS_NAME%"
	call :DEL "!DEST_ASSETS!"
	if errorlevel 1 goto END
	call :COPY "%ASSETS_DIR%" "!DEST_ASSETS!"
	if errorlevel 1 goto END
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo.
call :ECHO_LANG :SYNC_SUCCESS ""
exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
exit /b 1

:: 路径不存在则提示并返回错误（调用方须检查 errorlevel）
:EXIST
if not exist %1 (
	call :ECHO_LANG :NOT_EXIST %1
	exit /b 1
)
exit /b 0

:: 删除目录（不存在则跳过）
:DEL
if not exist "%~1" exit /b 0
rd /s /q "%~1" >nul 2>nul
if errorlevel 1 (
	call :ECHO_LANG :DEL_DIR_FAIL "%~1"
	exit /b 1
)
call :ECHO_LANG :DEL_DIR_SUCCESS "%~1"
exit /b 0

:: 复制目录树到目标（%1=源，%2=目标）
:COPY
xcopy "%~1" "%~2\" /E /I /Y >nul
if errorlevel 1 (
	call :ECHO_LANG :COPY_DIR_FAIL "%~2"
	exit /b 1
)
call :ECHO_LANG :COPY_DIR_SUCCESS "%~2"
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
