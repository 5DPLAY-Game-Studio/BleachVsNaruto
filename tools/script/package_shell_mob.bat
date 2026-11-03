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
::   使用 SDK adt 将 SHELL_Mob 打包为 Android APK 发行版。
::   签名：keysign\5dplay.p12（storepass 123456）。
::   输出：out\production\SHELL_Mob\launch.apk
::   打入包内的文件与 SHELL_Mob.iml packaging-android 一致：
::   drawable 与 shared\_tmp\mob 的内容位于包根目录。
::   未传 -arch；架构由 launch-app.xml 的 buildArchitectures
::   或 adt 默认决定（当前描述文件未指定，与 IDEA 一致，默认为 armv7）。
::
:: 用法
::   tools\script\package_shell_mob.bat
::   （build.bat 会先编译 SHELL_Mob）
::
:: 前置条件
::   - FLEX_HOME 指向 AIR/Flex SDK（含 bin\adt.bat）
::   - 已生成 out\production\SHELL_Mob\launch.swf
::   - SHELL_Mob\src\launch-app.xml 的 content 为 launch.swf
::   - 已执行 sync.bat，存在 shared\_tmp\mob\assets
::   - SHELL_Mob\drawable\icon 含描述文件引用的图标
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

set "BAT_HOME=%~dp0"
set "FUNC_COMMON=%BAT_HOME%func\common.bat"
call "!FUNC_COMMON!" INIT_LANG "%~n0"
call "!FUNC_COMMON!" ECHO_LANG :TITLE ""

set "REPO_ROOT=%BAT_HOME%..\.."
for %%I in ("%REPO_ROOT%") do set "REPO_ROOT=%%~fI"

set "ADT=%FLEX_HOME%\bin\adt.bat"
set "OUT_DIR=%REPO_ROOT%\out\production\SHELL_Mob"
set "OUT_APK=%OUT_DIR%\launch.apk"
set "OUT_SWF=%OUT_DIR%\launch.swf"
set "SRC_APP_XML=%REPO_ROOT%\SHELL_Mob\src\launch-app.xml"
set "DRAWABLE_DIR=%REPO_ROOT%\SHELL_Mob\drawable"
set "ICON_DIR=%DRAWABLE_DIR%\icon"
set "MOB_TMP=%REPO_ROOT%\shared\_tmp\mob"
set "MOB_ASSETS=%MOB_TMP%\assets"
set "KEYSTORE=%REPO_ROOT%\keysign\5dplay.p12"
set "STOREPASS=123456"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 1) 环境与输入校验
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if "%FLEX_HOME%"=="" (
	call "!FUNC_COMMON!" ECHO_LANG :UNDEFINE "FLEX_HOME"
	goto END
)

call "!FUNC_COMMON!" EXIST "!ADT!"
if errorlevel 1 goto END
call "!FUNC_COMMON!" EXIST "!OUT_SWF!"
if errorlevel 1 goto END
call "!FUNC_COMMON!" EXIST "!SRC_APP_XML!"
if errorlevel 1 goto END
call "!FUNC_COMMON!" EXIST "!DRAWABLE_DIR!"
if errorlevel 1 goto END
call "!FUNC_COMMON!" EXIST "!ICON_DIR!"
if errorlevel 1 goto END
call "!FUNC_COMMON!" EXIST "!MOB_ASSETS!"
if errorlevel 1 goto END
call "!FUNC_COMMON!" EXIST "!KEYSTORE!"
if errorlevel 1 goto END

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 2) SDK adt 打包（Android APK）
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if exist "!OUT_APK!" del /f /q "!OUT_APK!"

call "!FUNC_COMMON!" ECHO_LANG :PACKAGE_START ""
call "!FUNC_COMMON!" ECHO_LANG :SDK_INFO "!FLEX_HOME!"
call "!FUNC_COMMON!" ECHO_LANG :OUT_INFO "!OUT_APK!"

pushd "!OUT_DIR!"
call "!ADT!" -package ^
	-target apk ^
	-storetype pkcs12 ^
	-keystore "!KEYSTORE!" ^
	-storepass "!STOREPASS!" ^
	launch.apk ^
	"!SRC_APP_XML!" ^
	launch.swf ^
	-C "!DRAWABLE_DIR!" . ^
	-C "!MOB_TMP!" .
set ADT_ERR=!errorlevel!
popd
if not "!ADT_ERR!"=="0" (
	call "!FUNC_COMMON!" ECHO_LANG :PACKAGE_FAIL ""
	goto END
)

call "!FUNC_COMMON!" ECHO_LANG :PACKAGE_SUCCESS "!OUT_APK!"
exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
exit /b 1
