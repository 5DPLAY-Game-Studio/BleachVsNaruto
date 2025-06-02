::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Copyright (C) 2021-2025, 5DPLAY Game Studio
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
echo File does not exist: %~2
goto :EOF

:SYNC_SUCCESS
echo Synchronizing assets successfully!
goto :EOF

:DEL_DIR_SUCCESS
echo The directory was deleted successfully: %~2
goto :EOF

:DEL_DIR_FAIL
echo Failed to delete directory: %~2
goto :EOF

:COPY_DIR_SUCCESS
echo The directory was copied successfully: %~2
goto :EOF

:COPY_DIR_FAIL
echo Failed to copy directory: %~2
goto :EOF

