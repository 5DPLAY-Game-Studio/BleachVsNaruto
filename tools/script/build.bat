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
::   使用纯 FlexSDK（compc / amxmlc）构建 SHELL_Dev 调试链，
::   不依赖 IDEA 或 VSCode。
::
:: 用法
::   tools\script\build.bat
::   之后可选用：tools\script\debug.bat
::
:: 前置条件
::   FLEX_HOME 指向 Flex/AIR SDK 根目录（flex4.16.1-air51.0.1.1）。
::
:: Flex load-config（与各模块 asconfig.json / *.iml 保持同步）：
::   [Module]/flex-config.xml
::   tools\script\conf\sdk-external.xml - 库 SWC 将 Flex/AIR/MX 标为 external
::
:: 编译顺序（SHELL_Dev 最小链）：
::   LIB_Other -> LIB_KyoLib -> CORE_Shared -> CORE_KernelLogic
::   -> CORE_Utils -> sync.bat -> SHELL_Dev
:: CORE_Components 一并编译（供独立组件消费；SHELL_* 不依赖）
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

:: 当前 BAT 文件所在目录（末尾带反斜杠）
set "BAT_HOME=%~dp0"
set "FUNC_COMMON=%BAT_HOME%func\common.bat"
call "%FUNC_COMMON%" INIT_LANG "%~n0"

call "%FUNC_COMMON%" ECHO_LANG :TITLE ""
call "%FUNC_COMMON%" ECHO_LANG :BUILD_START ""

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 1) Flex / AIR SDK
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: FLEX_HOME 须指向已安装的 Flex/AIR SDK 根目录
if "%FLEX_HOME%"=="" (
	call "%FUNC_COMMON%" ECHO_LANG :UNDEFINE "FLEX_HOME"
	goto END
)
call "%FUNC_COMMON%" EXIST "%FLEX_HOME%"
if errorlevel 1 goto END

set "FLEX_BIN=%FLEX_HOME%\bin"
call "%FUNC_COMMON%" EXIST "%FLEX_BIN%"
if errorlevel 1 goto END

set "COMPC=%FLEX_BIN%\compc.bat"
set "AMXMLC=%FLEX_BIN%\amxmlc.bat"
call "%FUNC_COMMON%" EXIST "%COMPC%"
if errorlevel 1 goto END
call "%FUNC_COMMON%" EXIST "%AMXMLC%"
if errorlevel 1 goto END

:: 库模块共用：将 Flex/AIR/MX 标为 external
set "SDK_EXT=%BAT_HOME%conf\sdk-external.xml"
call "%FUNC_COMMON%" EXIST "%SDK_EXT%"
if errorlevel 1 goto END

:: 保证本进程能直接找到 SDK 工具
set "PATH=%FLEX_BIN%;%PATH%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 2) 仓库 / 输出 / 模块路径
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set "REPO_ROOT=%BAT_HOME%..\.."
for %%I in ("%REPO_ROOT%") do set "REPO_ROOT=%%~fI"

set "OUT_ROOT=%REPO_ROOT%\out\production"
set "MOD_DEV=%REPO_ROOT%\SHELL_Dev"
set "OUT_DEV=%OUT_ROOT%\SHELL_Dev"

set "SHARED_DIR=%REPO_ROOT%\shared"
set "SYNC_BAT=%BAT_HOME%sync.bat"
set "FLEX_CFG=flex-config.xml"

:: 库模块编译顺序（含 CORE_Components；VSCode SHELL_Dev 链可跳过 Components）
set "LIB_MODULES=LIB_Other LIB_KyoLib CORE_Shared CORE_Components CORE_KernelLogic CORE_Utils"

:: SHELL_Dev 源文件与同步产物路径
set "DEV_MAIN_AS=%MOD_DEV%\src\FighterTester.as"
set "DEV_APP_XML=%MOD_DEV%\src\FighterTester-app.xml"
set "DEV_ICON_SRC=%MOD_DEV%\lib\icon"
set "DEV_CFG=%MOD_DEV%\%FLEX_CFG%"
set "DEV_ASSETS_SRC=%SHARED_DIR%\_tmp\dev\assets"

set "OUT_APP_XML=%OUT_DEV%\FighterTester-app.xml"
set "OUT_ASSETS=%OUT_DEV%\assets"
set "OUT_ICON=%OUT_DEV%\icon"

call "%FUNC_COMMON%" EXIST "%MOD_DEV%"
if errorlevel 1 goto END
call "%FUNC_COMMON%" EXIST "%SHARED_DIR%"
if errorlevel 1 goto END
call "%FUNC_COMMON%" EXIST "%SYNC_BAT%"
if errorlevel 1 goto END

:: 确保各模块输出目录存在（compc / amxmlc 写入 out\production）
if not exist "%OUT_DEV%" mkdir "%OUT_DEV%"
for %%M in (%LIB_MODULES%) do (
	if not exist "%OUT_ROOT%\%%M" mkdir "%OUT_ROOT%\%%M"
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 3) 编译各库模块（compc + AIR config）
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

for %%M in (%LIB_MODULES%) do (
	call :COMPC_MODULE "%%M"
	if errorlevel 1 goto END
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 4) 同步素材（工作目录 = shared，与 VSCode task 一致）
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call "%FUNC_COMMON%" ECHO_LANG :SYNC_START ""
pushd "%SHARED_DIR%"
call "%SYNC_BAT%"
set SYNC_ERR=!errorlevel!
popd
if not "!SYNC_ERR!"=="0" (
	call "%FUNC_COMMON%" ECHO_LANG :SYNC_FAIL ""
	goto END
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 5) 编译 SHELL_Dev（amxmlc / AIR；不加载 sdk-external，应用 Merges 框架）
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call "%FUNC_COMMON%" EXIST "%DEV_CFG%"
if errorlevel 1 goto END
call "%FUNC_COMMON%" EXIST "%DEV_MAIN_AS%"
if errorlevel 1 goto END

call "%FUNC_COMMON%" ECHO_LANG :COMPILE_START "SHELL_Dev"
call "%AMXMLC%" -load-config+="%DEV_CFG%" "%DEV_MAIN_AS%"
if errorlevel 1 (
	call "%FUNC_COMMON%" ECHO_LANG :COMPILE_FAIL "SHELL_Dev"
	goto END
)
call "%FUNC_COMMON%" ECHO_LANG :COMPILE_OK "SHELL_Dev"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 6) 复制 ADL 运行时文件（供 debug.bat / VSCode launch 使用）
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call "%FUNC_COMMON%" EXIST "%DEV_APP_XML%"
if errorlevel 1 goto END
call "%FUNC_COMMON%" EXIST "%DEV_ASSETS_SRC%"
if errorlevel 1 goto END
call "%FUNC_COMMON%" EXIST "%DEV_ICON_SRC%"
if errorlevel 1 goto END

copy /Y "%DEV_APP_XML%" "%OUT_APP_XML%" >nul
if errorlevel 1 (
	call "%FUNC_COMMON%" ECHO_LANG :COPY_FAIL "FighterTester-app.xml"
	goto END
)

if exist "%OUT_ASSETS%" rd /s /q "%OUT_ASSETS%"
xcopy "%DEV_ASSETS_SRC%" "%OUT_ASSETS%\" /E /I /Y >nul
if errorlevel 1 (
	call "%FUNC_COMMON%" ECHO_LANG :COPY_FAIL "assets"
	goto END
)

if exist "%OUT_ICON%" rd /s /q "%OUT_ICON%"
xcopy "%DEV_ICON_SRC%" "%OUT_ICON%\" /E /I /Y >nul
if errorlevel 1 (
	call "%FUNC_COMMON%" ECHO_LANG :COPY_FAIL "icon"
	goto END
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call "%FUNC_COMMON%" ECHO_LANG :BUILD_SUCCESS ""
echo.
exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:COMPC_MODULE
:: %1 = 模块名；配置路径由 REPO_ROOT + 模块名 + FLEX_CFG 拼接
:: 先加载 sdk-external.xml，使 Flex/AIR/MX 保持 external（与 asconfig.json 一致）
set "MOD_CFG=%REPO_ROOT%\%~1\%FLEX_CFG%"
call "%FUNC_COMMON%" EXIST "%MOD_CFG%"
if errorlevel 1 exit /b 1

call "%FUNC_COMMON%" ECHO_LANG :COMPILE_START "%~1"
call "%COMPC%" +configname=air ^
	-load-config+="%SDK_EXT%" ^
	-load-config+="%MOD_CFG%"
if errorlevel 1 (
	call "%FUNC_COMMON%" ECHO_LANG :COMPILE_FAIL "%~1"
	exit /b 1
)
call "%FUNC_COMMON%" ECHO_LANG :COMPILE_OK "%~1"

:: LIB_KyoLib / CORE_Shared: embed ASDoc into SWC for IDE code hints
set "EMBED_BAT="
if /i "%~1"=="LIB_KyoLib" set "EMBED_BAT=%REPO_ROOT%\LIB_KyoLib\tools\embed_asdoc.bat"
if /i "%~1"=="CORE_Shared" set "EMBED_BAT=%BAT_HOME%embed_asdoc_shared.bat"
if defined EMBED_BAT (
	call "%FUNC_COMMON%" ECHO_LANG :ASDOC_EMBED_START "%~1"
	call "!EMBED_BAT!"
	if errorlevel 1 (
		call "%FUNC_COMMON%" ECHO_LANG :ASDOC_EMBED_FAIL "%~1"
		exit /b 1
	)
	call "%FUNC_COMMON%" ECHO_LANG :ASDOC_EMBED_OK "%~1"
)
exit /b 0

:END
echo.
exit /b 1
