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
::   Post-build hook: embed ASDoc into CORE_Shared.swc (no HTML).
::   Called by build.bat, VSCode tasks, and IDEA External Tool
::   (EmbedSharedAsDoc / Before Launch after Make).
::
:: Usage
::   CORE_Shared\tools\embed_asdoc.bat
::   CORE_Shared\tools\embed_asdoc.bat "D:\...\CORE_Shared.swc"
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

set "BAT_HOME=%~dp0"
set "MODE=embed"
set "NO_PAUSE=1"

set "MODULE_ROOT=%BAT_HOME%.."
for %%I in ("%MODULE_ROOT%") do set "MODULE_ROOT=%%~fI"
set "REPO_ROOT=%MODULE_ROOT%\.."
for %%I in ("%REPO_ROOT%") do set "REPO_ROOT=%%~fI"

if "%SWC_PATH%"=="" (
	set "SWC_PATH=%REPO_ROOT%\out\production\CORE_Shared\CORE_Shared.swc"
)

if not "%~1"=="" (
	set "SWC_PATH=%~f1"
)

:: IDEA may still hold the SWC briefly after Make
powershell -NoProfile -ExecutionPolicy Bypass -File "%BAT_HOME%asdoc\wait_swc_ready.ps1" -SwcPath "!SWC_PATH!" -TimeoutSec 45
if errorlevel 1 (
	echo SWC not ready for ASDoc embed: !SWC_PATH!
	exit /b 1
)

call "%BAT_HOME%asdoc.bat"
exit /b %ERRORLEVEL%
