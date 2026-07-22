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
::   Batch-publish BleachVsNaruto_FlashSrc (fla/xfl) via Flash/Animate JSFL.
::   Does not modify tools/jsfl/Batch Release.jsfl (manual browse workflow).
::
:: Usage
::   tools\script\publish.bat
::
:: Prerequisites
::   FLASH_HOME points at Flash/Animate install dir (contains Animate.exe
::   or Flash.exe), e.g. E:\Program Files\Adobe\Adobe Animate 2022
::
:: Notes
::   Launch uses -run-jsfl (Animate 2022+ hidden option). Old -AlwaysRunJSFL
::   is not present in modern Animate.exe and has no effect.
::   Also sets AppData Application.xml: DontPromptForJSFLOpen + RunJSFLAsCommand
::   (same as checking "Don't show again" and choosing Run).
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

set BAT_HOME=%~dp0

call :ECHO_LANG :TITLE ""
call :ECHO_LANG :PUBLISH_START ""

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 1) FLASH_HOME + exe
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if "%FLASH_HOME%"=="" (
	call :ECHO_LANG :UNDEFINE "FLASH_HOME"
	goto END
)
call :EXIST "%FLASH_HOME%"

set FLASH_EXE=
if exist "%FLASH_HOME%\Animate.exe" set FLASH_EXE=%FLASH_HOME%\Animate.exe
if "%FLASH_EXE%"=="" if exist "%FLASH_HOME%\Flash.exe" set FLASH_EXE=%FLASH_HOME%\Flash.exe
if "%FLASH_EXE%"=="" if exist "%FLASH_HOME%\Support Files\Animate.exe" set FLASH_EXE=%FLASH_HOME%\Support Files\Animate.exe
if "%FLASH_EXE%"=="" if exist "%FLASH_HOME%\Support Files\Flash.exe" set FLASH_EXE=%FLASH_HOME%\Support Files\Flash.exe

if "%FLASH_EXE%"=="" (
	call :ECHO_LANG :NO_EXE "%FLASH_HOME%"
	goto END
)
call :ECHO_LANG :USE_EXE "%FLASH_EXE%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 2) Repo / FlashSrc / JSFL paths
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set REPO_ROOT=%BAT_HOME%..\..
for %%I in ("%REPO_ROOT%") do set REPO_ROOT=%%~fI

set FLASH_SRC=%REPO_ROOT%\BleachVsNaruto_FlashSrc
call :EXIST "%FLASH_SRC%"

set JSFL=%REPO_ROOT%\tools\jsfl\publish_flashsrc.jsfl
call :EXIST "%JSFL%"

set ROOT_FILE=%REPO_ROOT%\tools\jsfl\_publish_root.txt
set RESULT_FILE=%BAT_HOME%_publish_result.txt

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 3) Write root path for JSFL; clear previous result
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

> "%ROOT_FILE%" echo %FLASH_SRC%
if errorlevel 1 (
	call :ECHO_LANG :WRITE_FAIL "%ROOT_FILE%"
	goto END
)

if exist "%RESULT_FILE%" del /f /q "%RESULT_FILE%" >nul 2>&1

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 3b) Suppress Open-JSFL Run/Edit prompt (prefs + CLI)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call :ENSURE_JSFL_NO_PROMPT

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 4) Launch Flash/Animate with JSFL (blocks until quit)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call :ECHO_LANG :LAUNCH ""
:: -run-jsfl: "always run jsfl files as a command" (Animate.exe hidden option)
start "" /wait "%FLASH_EXE%" -run-jsfl "%JSFL%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 5) Read JSFL result (Adobe exit codes are unreliable)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if not exist "%RESULT_FILE%" (
	call :ECHO_LANG :NO_RESULT "%RESULT_FILE%"
	goto END
)

set PUBLISH_CODE=1
for /f "usebackq tokens=1 delims= " %%a in ("%RESULT_FILE%") do (
	set PUBLISH_CODE=%%a
	goto :HAVE_CODE
)
:HAVE_CODE

if "!PUBLISH_CODE!"=="0" (
	call :ECHO_LANG :PUBLISH_SUCCESS ""
	echo.
	exit /b 0
)

call :ECHO_LANG :PUBLISH_FAIL "!PUBLISH_CODE!"
goto END

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
echo.
exit /b 1

:EXIST
if not exist %1 (
	call :ECHO_LANG :NOT_EXIST %1
	goto END
)
goto :EOF

:: Patch %APPDATA%\Adobe\Animate\<ver>\Application.xml so Open-JSFL dialog is skipped.
:ENSURE_JSFL_NO_PROMPT
set ANIMATE_APPDATA=%APPDATA%\Adobe\Animate
if not exist "%ANIMATE_APPDATA%" goto :EOF
powershell -NoProfile -ExecutionPolicy Bypass -File "%BAT_HOME%ensure_jsfl_no_prompt.ps1"
goto :EOF

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
