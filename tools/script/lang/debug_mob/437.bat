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

if "%1"=="" (
	echo The tag is empty!
	goto :EOF
)

goto %1

:NOT_EXIST
echo File does not exist: !LANG_PARAM!
goto :EOF

:UNDEFINE
echo Environment variable !LANG_PARAM! is undefined!
goto :EOF

:TITLE
title Apache fdb (Flash Player Debugger)
goto :EOF

:TITLE_ADB
title Apache fdb (Flash Player Debugger) - [!LANG_PARAM!]
goto :EOF

:NO_DEVICE
echo No device connection detected...
goto :EOF

:NO_CMD
echo Command !LANG_PARAM! not found!
goto :EOF

:CONNECT
echo Connected devices: [!LANG_PARAM!]
goto :EOF

:NOT_INSTALLED
echo Application [!LANG_PARAM!] is not installed!
goto :EOF

:INSTALLING
echo Installing application [!LANG_PARAM!] ...
goto :EOF

:INSTALL_FAIL
echo Failed to install application: [!LANG_PARAM!]
goto :EOF

:START_MSG
echo Starting Flash Debugger...
goto :EOF

:END_MSG
echo Debug session completed.
goto :EOF
