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
::   Called by build.bat, VSCode tasks, and IDEA File Watcher.
::
:: Usage
::   CORE_Shared\tools\embed_asdoc.bat
::   CORE_Shared\tools\embed_asdoc.bat "D:\...\CORE_Shared.swc"
::     Optional arg = SWC path (IDEA File Watcher passes $FilePath$).
::     When arg is set, only runs if it is CORE_Shared.swc, and skips
::     when docs/packages.dita is already present (watcher re-entry).
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

set "BAT_HOME=%~dp0"
set "MODE=embed"
set "NO_PAUSE=1"

:: Optional SWC path from IDEA File Watcher ($FilePath$)
if not "%~1"=="" (
	set "SWC_PATH=%~f1"
	echo "!SWC_PATH!" | findstr /I /C:"CORE_Shared.swc" >nul
	if errorlevel 1 (
		:: Not our SWC; ignore silently
		exit /b 0
	)
	:: Prevent File Watcher loop after we rewrite the SWC
	set "IF_MISSING=1"
)

call "%BAT_HOME%asdoc.bat"
exit /b %ERRORLEVEL%
