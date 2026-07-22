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
:: ASCII-only messages (safe under any console code page).
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off

if "%1"=="" (
	echo The tag is empty!
	goto :EOF
)

goto %1

:NOT_EXIST
echo File does not exist: %~2
goto :EOF

:UNDEFINE
echo Environment variable %~2 is undefined!
goto :EOF

:TITLE
title Bleach vs Naruto - Publish FlashSrc
goto :EOF

:PUBLISH_START
echo Publishing BleachVsNaruto_FlashSrc via Flash/Animate...
goto :EOF

:NO_EXE
echo Animate.exe / Flash.exe not found under: %~2
goto :EOF

:USE_EXE
echo Using: %~2
goto :EOF

:WRITE_FAIL
echo Failed to write: %~2
goto :EOF

:LAUNCH
echo Launching Flash/Animate (JSFL). Window may open; wait until it finishes...
goto :EOF

:NO_RESULT
echo Publish result file missing (JSFL may have failed to start): %~2
goto :EOF

:PUBLISH_SUCCESS
echo FlashSrc publish completed successfully!
goto :EOF

:PUBLISH_FAIL
echo FlashSrc publish failed. code=%~2
goto :EOF
