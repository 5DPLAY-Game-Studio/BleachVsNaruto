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

:: 启动 id。在 application.xml 中定义的 id
set LAUNCH_ID=net.play5d.game.bvn.mob
:: 调试包名，格式为 air.应用程序 application 定义的 id。air 是自动添加的前缀
set DBG_PACKAGE=air.%LAUNCH_ID%
:: 调试端口，默认 7936，应与 IDEA 中的 SHELL_Mob 模块启动配置中相同
set DBG_PORT=7936
:: 临时文件，转储 adb device 命令的输出
set TMP_ADB_DEVICES=%TEMP%\adb_devices.txt

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
:: echo FLEX_BIN: %FLEX_BIN%

:: 检查 adb 命令是否存在
call :CHK_CMD adb

adb start-server >nul 2>nul
:: 延时 2 秒让 adb 预启动
timeout /t 2 >nul

adb devices >nul 2>nul
timeout /t 1 >nul
adb devices >"%TMP_ADB_DEVICES%"

:: 解析 Android 设备 id
set DEVICE_COUNT=0
set "DEVICE_ID="
for /f "usebackq skip=1 delims=" %%L in ("%TMP_ADB_DEVICES%") do (
	set "LINE=%%L"
	echo !LINE! | findstr "device" >nul
	if !errorlevel!==0 (
		set /a DEVICE_COUNT+=1
		
		:: 获取设备 id
		call :GET_DEVICE_ID "!LINE!"
		:: 跳出循环，只处理遇到的第一个设备
		goto :NEXT
	)
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 下一步操作
:NEXT

set PATH=%FLEX_BIN%;%PATH%
echo.

:: 删除临时文件
del "%TMP_ADB_DEVICES%" >nul 2>nul

:: 没有检测到连接的设备，提示并退出
if !DEVICE_COUNT!==0 (
	call :ECHO_LANG :NO_DEVICE ""
	goto :END
)

:: 如果有设备连接的操作
:: 更新标题
call :ECHO_LANG :TITLE_ADB "!DEVICE_ID!"
call :ECHO_LANG :CONNECT "!DEVICE_ID!"

:: 检测应用是否安装
adb shell pm path %DBG_PACKAGE% | findstr "package:" >nul 2>nul
if not %errorlevel%==0 (
	call :ECHO_LANG :NOT_INSTALLED "%DBG_PACKAGE%"
	goto :END
)

:: 重置 adb 转发端口
adb -s "!DEVICE_ID!" forward --remove-all >nul 2>nul
adb -s "!DEVICE_ID!" forward tcp:%DBG_PORT% tcp:%DBG_PORT% >nul

:: 启动 fdb 等待 Adobe AIR 程序链接
:: 重启应用程序
adb -s "!DEVICE_ID!" shell am force-stop %DBG_PACKAGE% >nul
adb -s "!DEVICE_ID!" shell am start -n %DBG_PACKAGE%/.AppEntry >nul

:: 循环监听，直到关闭窗口
:LOOP
call :ECHO_LANG :START_MSG ""
echo.

(
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
:: pause >nul
:: exit 0
goto :LOOP

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

:: 检测命令是否存在
:CHK_CMD
where %1 >nul 2>nul
if %errorlevel%==1 (
	call :ECHO_LANG :NO_CMD %1
	goto END
)
goto :EOF

::::::::::::::::::::::::::::::::::

:: 移除末尾的 "device"，保留完整ID
:GET_DEVICE_ID
set "STRING=%~1"
::					   ↓ 这里是 TAB
set "DEVICE_ID=!STRING:	device=!"
goto :EOF

::::::::::::::::::::::::::::::::::

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