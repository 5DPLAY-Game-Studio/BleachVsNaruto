::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Copyright (C) 2021-2024, 5DPLAY Game Studio
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

:: 工作目录
set WORK_SPACE=%CD%
echo WORK_SPACE: %WORK_SPACE%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 文件夹名
set ASSETS_NAME=assets
set TMP_NAME=_tmp
:: 目录
set ASSETS_DIR=%WORK_SPACE%\%ASSETS_NAME%
set TMP_DIR=%WORK_SPACE%\%TMP_NAME%

call :EXIST "%ASSETS_DIR%"
call :EXIST "%TMP_DIR%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 外壳通道
set SHELL_PC=pc
set SHELL_DEV=dev
set SHELL_MOB=mob
:: 外壳通道目录
set SHELL_DIR_PC=%TMP_DIR%\%SHELL_PC%
set SHELL_DIR_DEV=%TMP_DIR%\%SHELL_DEV%
set SHELL_DIR_MOB=%TMP_DIR%\%SHELL_MOB%

call :EXIST "%SHELL_DIR_PC%"
call :EXIST "%SHELL_DIR_DEV%"
call :EXIST "%SHELL_DIR_MOB%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 外壳通道的素材文件夹
set ASSETS_DIR_SHELL_PC=%SHELL_DIR_PC%\%ASSETS_NAME%
set ASSETS_DIR_SHELL_DEV=%SHELL_DIR_DEV%\%ASSETS_NAME%
set ASSETS_DIR_SHELL_MOB=%SHELL_DIR_MOB%\%ASSETS_NAME%

:: 清空外壳通道目录下的素材文件夹
call :DEL "%ASSETS_DIR_SHELL_PC%"
call :DEL "%ASSETS_DIR_SHELL_DEV%"
call :DEL "%ASSETS_DIR_SHELL_MOB%"

:: 复制素材到外壳通道素材
call :COPY "%ASSETS_DIR%" "%ASSETS_DIR_SHELL_PC%"
call :COPY "%ASSETS_DIR%" "%ASSETS_DIR_SHELL_DEV%"
call :COPY "%ASSETS_DIR%" "%ASSETS_DIR_SHELL_MOB%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 结束操作
echo.
echo Sync assets successfully.
exit

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
:: pause >nul
exit -1

:: 判断文件是否存在，不存在给出提示信息
:EXIST
if not exist %1 (
	echo [%~1] does not exist.
	goto END
)
goto :EOF

:: 删除文件
:DEL
if exist %1 (
	del /f /s /q "%~1\*.*" >nul
	rd /s /q %1 >nul
	
	if !errorlevel!==0 (
		echo Delete directory [%~1] successfully.
	) else (
		echo Failed to delete directory [%~1].
		goto END
	)
)
goto :EOF

:: 复制文件
:COPY
echo D|xcopy %1 %2 /E /y >nul
if !errorlevel!==0 (
	echo Copy directory [%~2] successfully.
) else (
	echo Failed to copy directory [%~2].
	goto END
)
goto :EOF