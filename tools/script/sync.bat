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
setlocal enabledelayedexpansion

:: ��ǰ BAT Ŀ¼
set BAT_HOME=%~dp0
echo BAT_HOME: %BAT_HOME%

:: ����Ŀ¼
set WORK_SPACE=%CD%
echo WORK_SPACE: %WORK_SPACE%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: �ļ�����
set ASSETS_NAME=assets
set TMP_NAME=_tmp
:: Ŀ¼
set ASSETS_DIR=%WORK_SPACE%\%ASSETS_NAME%\%ASSETS_NAME%
set TMP_DIR=%WORK_SPACE%\%TMP_NAME%

call :EXIST "%ASSETS_DIR%"
call :EXIST "%TMP_DIR%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: ���ͨ��
set SHELL_PC=pc
set SHELL_DEV=dev
set SHELL_MOB=mob
:: ���ͨ��Ŀ¼
set SHELL_DIR_PC=%TMP_DIR%\%SHELL_PC%
set SHELL_DIR_DEV=%TMP_DIR%\%SHELL_DEV%
set SHELL_DIR_MOB=%TMP_DIR%\%SHELL_MOB%

call :EXIST "%SHELL_DIR_PC%"
call :EXIST "%SHELL_DIR_DEV%"
call :EXIST "%SHELL_DIR_MOB%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: ���ͨ�����ز��ļ���
set ASSETS_DIR_SHELL_PC=%SHELL_DIR_PC%\%ASSETS_NAME%
set ASSETS_DIR_SHELL_DEV=%SHELL_DIR_DEV%\%ASSETS_NAME%
set ASSETS_DIR_SHELL_MOB=%SHELL_DIR_MOB%\%ASSETS_NAME%

:: ������ͨ��Ŀ¼�µ��ز��ļ���
call :DEL "%ASSETS_DIR_SHELL_PC%"
call :DEL "%ASSETS_DIR_SHELL_DEV%"
call :DEL "%ASSETS_DIR_SHELL_MOB%"

:: �����زĵ����ͨ���ز�
call :COPY "%ASSETS_DIR%" "%ASSETS_DIR_SHELL_PC%"
call :COPY "%ASSETS_DIR%" "%ASSETS_DIR_SHELL_DEV%"
call :COPY "%ASSETS_DIR%" "%ASSETS_DIR_SHELL_MOB%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: ��������
echo.
call :ECHO_LANG :SYNC_SUCCESS ""
exit

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
:: pause >nul
exit -1

:: �ж��ļ��Ƿ���ڣ������ڸ�����ʾ��Ϣ
:EXIST
if not exist %1 (
	call :ECHO_LANG :NOT_EXIST %1
	goto END
)
goto :EOF

:: ɾ���ļ�
:DEL
if exist %1 (
	del /f /s /q "%~1\*.*" >nul
	rd /s /q %1 >nul
	
	if !errorlevel!==0 (
		call :ECHO_LANG :DEL_DIR_SUCCESS %1
	) else (
		call :ECHO_LANG :DEL_DIR_FAIL %1
		goto END
	)
)
goto :EOF

:: �����ļ�
:COPY
echo D|xcopy %1 %2 /E /y >nul
if !errorlevel!==0 (
	call :ECHO_LANG :COPY_DIR_SUCCESS %2
) else (
	call :ECHO_LANG :COPY_DIR_FAIL %2
	goto END
)
goto :EOF

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:ECHO_LANG
for /f "tokens=2 delims=:" %%a in ('chcp') do (
	for /f "tokens=1" %%b in ("%%a") do set CURRENT_CODEPAGE=%%b
)

set LANG_BAT=%BAT_HOME%lang\sync\%CURRENT_CODEPAGE%.bat
if not exist "%LANG_BAT%" (
	echo ECHO_LANG [N/A]
	goto :EOF
)

:: echo Code Page: %CURRENT_CODEPAGE%
call "%LANG_BAT%" %1 %2
goto :EOF