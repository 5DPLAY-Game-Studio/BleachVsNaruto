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
:: Purpose
::   Build the SHELL_Dev debug chain with pure FlexSDK (compc / amxmlc),
::   without IDEA or VSCode.
::
:: Usage
::   tools\script\build.bat
::   Then optionally: tools\script\debug.bat
::
:: Prerequisites
::   FLEX_HOME points at Flex/AIR SDK root (flex4.16.1-air51.0.1.1).
::
:: Flex load-config (keep in sync with each module asconfig.json / *.iml):
::   <Module>/flex-config.xml
::   tools\script\sdk-external.xml — Flex/AIR/MX as external for library SWCs
::
:: Order:
::   LIB_Other -> LIB_KyoLib -> CORE_Shared -> CORE_Components
::   -> CORE_KernelLogic -> CORE_Utils -> sync.bat -> SHELL_Dev
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

:: Current BAT directory (...\tools\script\)
set BAT_HOME=%~dp0

call :ECHO_LANG :TITLE ""
call :ECHO_LANG :BUILD_START ""

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 1) Flex / AIR SDK
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if "%FLEX_HOME%"=="" (
	call :ECHO_LANG :UNDEFINE "FLEX_HOME"
	goto END
)
call :EXIST "%FLEX_HOME%"

set FLEX_BIN=%FLEX_HOME%\bin
call :EXIST "%FLEX_BIN%"

set COMPC=%FLEX_BIN%\compc.bat
set AMXMLC=%FLEX_BIN%\amxmlc.bat
call :EXIST "%COMPC%"
call :EXIST "%AMXMLC%"

set SDK_EXT=%BAT_HOME%sdk-external.xml
call :EXIST "%SDK_EXT%"

set PATH=%FLEX_BIN%;%PATH%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 2) Repo / output paths
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set REPO_ROOT=%BAT_HOME%..\..
for %%I in ("%REPO_ROOT%") do set REPO_ROOT=%%~fI

set OUT_ROOT=%REPO_ROOT%\out\production
set MOD_DEV=%REPO_ROOT%\SHELL_Dev
set OUT_DEV=%OUT_ROOT%\SHELL_Dev

if not exist "%OUT_ROOT%\LIB_Other" mkdir "%OUT_ROOT%\LIB_Other"
if not exist "%OUT_ROOT%\LIB_KyoLib" mkdir "%OUT_ROOT%\LIB_KyoLib"
if not exist "%OUT_ROOT%\CORE_Shared" mkdir "%OUT_ROOT%\CORE_Shared"
if not exist "%OUT_ROOT%\CORE_Components" mkdir "%OUT_ROOT%\CORE_Components"
if not exist "%OUT_ROOT%\CORE_KernelLogic" mkdir "%OUT_ROOT%\CORE_KernelLogic"
if not exist "%OUT_ROOT%\CORE_Utils" mkdir "%OUT_ROOT%\CORE_Utils"
if not exist "%OUT_DEV%" mkdir "%OUT_DEV%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 3) Compile libraries (compc + AIR config)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call :COMPC_MODULE "LIB_Other" "%REPO_ROOT%\LIB_Other\flex-config.xml"
if errorlevel 1 goto END

call :COMPC_MODULE "LIB_KyoLib" "%REPO_ROOT%\LIB_KyoLib\flex-config.xml"
if errorlevel 1 goto END

call :COMPC_MODULE "CORE_Shared" "%REPO_ROOT%\CORE_Shared\flex-config.xml"
if errorlevel 1 goto END

call :COMPC_MODULE "CORE_Components" "%REPO_ROOT%\CORE_Components\flex-config.xml"
if errorlevel 1 goto END

call :COMPC_MODULE "CORE_KernelLogic" "%REPO_ROOT%\CORE_KernelLogic\flex-config.xml"
if errorlevel 1 goto END

call :COMPC_MODULE "CORE_Utils" "%REPO_ROOT%\CORE_Utils\flex-config.xml"
if errorlevel 1 goto END

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 4) SyncAssets (cwd = shared, same as VSCode task)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call :ECHO_LANG :SYNC_START ""
pushd "%REPO_ROOT%\shared"
cmd /c "%BAT_HOME%sync.bat"
set SYNC_ERR=!errorlevel!
popd
if not "!SYNC_ERR!"=="0" (
	call :ECHO_LANG :SYNC_FAIL ""
	goto END
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 5) Compile SHELL_Dev (amxmlc / AIR; no sdk-external — app Merges framework)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call :ECHO_LANG :COMPILE_START "SHELL_Dev"
call "%AMXMLC%" -load-config+="%MOD_DEV%\flex-config.xml" "%MOD_DEV%\src\FighterTester.as"
if errorlevel 1 (
	call :ECHO_LANG :COMPILE_FAIL "SHELL_Dev"
	goto END
)
call :ECHO_LANG :COMPILE_OK "SHELL_Dev"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 6) Runtime files for ADL (debug.bat / VSCode launch)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

copy /Y "%MOD_DEV%\src\FighterTester-app.xml" "%OUT_DEV%\FighterTester-app.xml" >nul
if errorlevel 1 (
	call :ECHO_LANG :COPY_FAIL "FighterTester-app.xml"
	goto END
)

if exist "%OUT_DEV%\assets" rd /s /q "%OUT_DEV%\assets"
xcopy "%REPO_ROOT%\shared\_tmp\dev\assets" "%OUT_DEV%\assets\" /E /I /Y >nul
if errorlevel 1 (
	call :ECHO_LANG :COPY_FAIL "assets"
	goto END
)

if exist "%OUT_DEV%\icon" rd /s /q "%OUT_DEV%\icon"
xcopy "%MOD_DEV%\lib\icon" "%OUT_DEV%\icon\" /E /I /Y >nul
if errorlevel 1 (
	call :ECHO_LANG :COPY_FAIL "icon"
	goto END
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call :ECHO_LANG :BUILD_SUCCESS ""
echo.
exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:COMPC_MODULE
:: %1 = module label, %2 = module flex-config.xml
:: sdk-external.xml first: Flex/AIR/MX stay external (same as asconfig.json)
call :ECHO_LANG :COMPILE_START %1
call "%COMPC%" +configname=air ^
	-load-config+="%SDK_EXT%" ^
	-load-config+="%~2"
if errorlevel 1 (
	call :ECHO_LANG :COMPILE_FAIL %1
	exit /b 1
)
call :ECHO_LANG :COMPILE_OK %1
exit /b 0

:END
echo.
exit /b 1

:: Path must exist
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
	if "%%a"=="!CURRENT_CODEPAGE!" (
		set IS_SUPPORT=1
		goto LANG_CHK
	)
)
:LANG_CHK
if !IS_SUPPORT!==0 (
	set CURRENT_CODEPAGE=437
)

set LANG_BAT=%BAT_HOME%lang\%~n0\!CURRENT_CODEPAGE!.bat
if not exist "!LANG_BAT!" (
	echo ECHO_LANG [N/A]
	goto :EOF
)

call "!LANG_BAT!" %1 %2
goto :EOF
