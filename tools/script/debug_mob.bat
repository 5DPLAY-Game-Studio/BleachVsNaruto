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
::   通过 adb + Apache fdb，在已连接的 Android 设备上调试 SHELL_Mob（AIR APK）。
::
:: 用法
::   tools\script\debug_mob.bat
::
:: 前置条件
::   - FLEX_HOME 指向 Flex/AIR SDK（含 bin\fdb）
::   - PATH 中可用 adb（Android SDK platform-tools）
::   - 设备已 USB 调试连接；调试端口与 IDEA SHELL_Mob 配置一致（7936）
::   - 若未安装应用，需已构建 out\production\SHELL_Mob\launch.apk
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
:: 1) 调试参数 / 路径
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set "REPO_ROOT=%BAT_HOME%..\.."
for %%I in ("%REPO_ROOT%") do set "REPO_ROOT=%%~fI"

:: APK；包名 = air. + application.xml 中的 id；端口与 IDEA SHELL_Mob 一致
set "DBG_FILE=%REPO_ROOT%\out\production\SHELL_Mob\launch.apk"
set "DBG_ID=net.play5d.game.bvn.mob"
set "DBG_PACKAGE=air.%DBG_ID%"
set "DBG_ACTIVITY=%DBG_PACKAGE%/.AppEntry"
set DBG_PORT=7936
set "LOG_DIR=%BAT_HOME%log"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
set "TMP_ADB_DEVICES=%LOG_DIR%\adb_devices.txt"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 2) Flex SDK + adb
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

set "FDB=%FLEX_BIN%\fdb.bat"
call "%FUNC_COMMON%" EXIST "%FDB%"
if errorlevel 1 goto END

set "PATH=%FLEX_BIN%;%PATH%"

call :CHK_CMD adb
if errorlevel 1 goto END

adb start-server >nul 2>nul
:: 等待 adb 服务就绪
timeout /t 2 >nul

adb devices >nul 2>nul
timeout /t 1 >nul
adb devices >"%TMP_ADB_DEVICES%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 3) 解析已连接且状态为 device 的设备（仅取第一台）
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set DEVICE_COUNT=0
set "DEVICE_ID="
for /f "usebackq skip=1 tokens=1,2" %%A in ("%TMP_ADB_DEVICES%") do (
	if /i "%%B"=="device" (
		set /a DEVICE_COUNT+=1
		set "DEVICE_ID=%%A"
		goto NEXT
	)
)

:NEXT
if exist "%TMP_ADB_DEVICES%" del /f /q "%TMP_ADB_DEVICES%" >nul 2>nul
echo.

if !DEVICE_COUNT!==0 (
	call "%FUNC_COMMON%" ECHO_LANG :NO_DEVICE ""
	goto END
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 4) 安装（若需） / 端口转发 / 启动应用
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call "%FUNC_COMMON%" ECHO_LANG :TITLE_ADB "!DEVICE_ID!"
call "%FUNC_COMMON%" ECHO_LANG :CONNECT "!DEVICE_ID!"

adb -s "!DEVICE_ID!" shell pm path %DBG_PACKAGE% | findstr "package:" >nul 2>nul
if not errorlevel 1 goto INSTALLED

call "%FUNC_COMMON%" ECHO_LANG :NOT_INSTALLED "%DBG_PACKAGE%"
call "%FUNC_COMMON%" EXIST "%DBG_FILE%"
if errorlevel 1 goto END

call "%FUNC_COMMON%" ECHO_LANG :INSTALLING "%DBG_PACKAGE%"
adb -s "!DEVICE_ID!" install "%DBG_FILE%"
if errorlevel 1 (
	call "%FUNC_COMMON%" ECHO_LANG :INSTALL_FAIL "%DBG_PACKAGE%"
	goto END
)

:INSTALLED
adb -s "!DEVICE_ID!" forward --remove-all >nul 2>nul
adb -s "!DEVICE_ID!" forward tcp:%DBG_PORT% tcp:%DBG_PORT% >nul

adb -s "!DEVICE_ID!" shell am force-stop %DBG_PACKAGE% >nul
adb -s "!DEVICE_ID!" shell am start -n %DBG_ACTIVITY% >nul

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 5) fdb 循环（关闭窗口结束）
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:LOOP
call "%FUNC_COMMON%" ECHO_LANG :START_MSG ""
echo.

(
	echo connect
	echo continue
	echo continue
	echo quit
	echo y
) | "%FDB%" -unit

timeout /t 1 >nul

echo.
call "%FUNC_COMMON%" ECHO_LANG :END_MSG ""
goto LOOP

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
pause >nul
exit /b 1

:: 检测外部命令是否在 PATH 中（调用方须检查 errorlevel）
:CHK_CMD
where %1 >nul 2>nul
if errorlevel 1 (
	call "%FUNC_COMMON%" ECHO_LANG :NO_CMD %1
	exit /b 1
)
exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
