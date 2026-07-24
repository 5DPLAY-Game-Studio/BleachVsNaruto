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
title Build Project
goto :EOF

:BUILD_START
echo Building SHELL_Dev debug chain...
goto :EOF

:COMPILE_START
echo Compiling: %~2
goto :EOF

:COMPILE_OK
echo Compiled successfully: %~2
goto :EOF

:COMPILE_FAIL
echo Compile failed: %~2
goto :EOF

:SYNC_START
echo Synchronizing assets...
goto :EOF

:SYNC_FAIL
echo Asset sync failed!
goto :EOF

:COPY_FAIL
echo Failed to copy: %~2
goto :EOF

:BUILD_SUCCESS
echo Build SHELL_Dev completed successfully!
goto :EOF

:ASDOC_EMBED_START
echo Embedding ASDoc into SWC: %~2
goto :EOF

:ASDOC_EMBED_OK
echo ASDoc embedded: %~2
goto :EOF

:ASDOC_EMBED_FAIL
echo ASDoc embed failed: %~2
goto :EOF
