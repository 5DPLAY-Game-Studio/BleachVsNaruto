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
::   使用 SDK adt 将 SHELL_Pc 打包为 Windows 捆绑运行时发行版。
::   签名：keysign\5dplay.p12（storepass 123456，tsa none）。
::   输出：out\production\SHELL_Pc\launch
::
:: 用法
::   tools\script\package_shell_pc.bat
::   （VSCode 任务会先编译 SHELL_Pc）
::
:: 前置条件
::   - FLEX_HOME 指向 AIR/Flex SDK（含 bin\adt.bat）
::   - 已生成 out\production\SHELL_Pc\launch.swf
::   - SHELL_Pc\src\launch-app.xml 的 content 为 launch.swf
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

set "BAT_HOME=%~dp0"
set "FUNC_COMMON=%BAT_HOME%func\common.bat"
call "%FUNC_COMMON%" INIT_LANG "%~n0"
call "%FUNC_COMMON%" ECHO_LANG :TITLE ""

set "REPO_ROOT=%BAT_HOME%..\.."
for %%I in ("%REPO_ROOT%") do set "REPO_ROOT=%%~fI"

set "ADT=%FLEX_HOME%\bin\adt.bat"
set "OUT_DIR=%REPO_ROOT%\out\production\SHELL_Pc"
set "OUT_BUNDLE=%OUT_DIR%\launch"
set "OUT_SWF=%OUT_DIR%\launch.swf"
set "SRC_APP_XML=%REPO_ROOT%\SHELL_Pc\src\launch-app.xml"
set "ASSETS_PARENT=%REPO_ROOT%\shared\assets"
set "ASSETS_DIR=%ASSETS_PARENT%\assets"
set "ICON_PARENT=%REPO_ROOT%\SHELL_Pc\lib"
set "ICON_DIR=%ICON_PARENT%\icon"
set "KEYSTORE=%REPO_ROOT%\keysign\5dplay.p12"
set "STOREPASS=123456"
set "BUNDLE_NAME=launch"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 1) 环境与输入校验
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if "%FLEX_HOME%"=="" (
	call "%FUNC_COMMON%" ECHO_LANG :UNDEFINE "FLEX_HOME"
	goto END
)

call "%FUNC_COMMON%" EXIST "%ADT%"
if errorlevel 1 goto END
call "%FUNC_COMMON%" EXIST "%OUT_SWF%"
if errorlevel 1 goto END
call "%FUNC_COMMON%" EXIST "%SRC_APP_XML%"
if errorlevel 1 goto END
call "%FUNC_COMMON%" EXIST "%ASSETS_DIR%"
if errorlevel 1 goto END
call "%FUNC_COMMON%" EXIST "%ICON_DIR%"
if errorlevel 1 goto END
call "%FUNC_COMMON%" EXIST "%KEYSTORE%"
if errorlevel 1 goto END

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 2) SDK adt 打包（captive runtime / bundle）
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if exist "%OUT_BUNDLE%" rd /s /q "%OUT_BUNDLE%"

call "%FUNC_COMMON%" ECHO_LANG :PACKAGE_START ""
call "%FUNC_COMMON%" ECHO_LANG :SDK_INFO "%FLEX_HOME%"
call "%FUNC_COMMON%" ECHO_LANG :OUT_INFO "%OUT_BUNDLE%"

pushd "%OUT_DIR%"
call "%ADT%" -package ^
	-storetype pkcs12 ^
	-keystore "%KEYSTORE%" ^
	-storepass %STOREPASS% ^
	-tsa none ^
	-target bundle ^
	%BUNDLE_NAME% ^
	"%SRC_APP_XML%" ^
	launch.swf ^
	-C "%ASSETS_PARENT%" assets ^
	-C "%ICON_PARENT%" icon
set ADT_ERR=!errorlevel!
popd
if not "!ADT_ERR!"=="0" (
	call "%FUNC_COMMON%" ECHO_LANG :PACKAGE_FAIL ""
	goto END
)

call "%FUNC_COMMON%" ECHO_LANG :PACKAGE_SUCCESS "%OUT_BUNDLE%"
exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
exit /b 1
