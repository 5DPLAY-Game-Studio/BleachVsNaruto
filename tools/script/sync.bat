@echo off
setlocal enabledelayedexpansion

:: ����Ŀ¼
set WORK_SPACE=%CD%
echo WORK_SPACE: %WORK_SPACE%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: �ļ�����
set ASSETS_NAME=assets
set TMP_NAME=_tmp
:: Ŀ¼
set ASSETS_DIR=%WORK_SPACE%\%ASSETS_NAME%
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
if exist "%ASSETS_DIR_SHELL_PC%" (
	del /f /s /q "%ASSETS_DIR_SHELL_PC%\*.*" >nul
	rd /s /q "%ASSETS_DIR_SHELL_PC%" >nul
	
	if !errorlevel!==0 (
		echo Delete directory [%ASSETS_DIR_SHELL_PC%] successfully.
	) else (
		echo Failed to delete directory [%ASSETS_DIR_SHELL_PC%].
		goto END
	)
)
if exist "%ASSETS_DIR_SHELL_DEV%" (
	del /f /s /q "%ASSETS_DIR_SHELL_DEV%\*.*" >nul
	rd /s /q "%ASSETS_DIR_SHELL_DEV%" >nul
	
	if !errorlevel!==0 (
		echo Delete directory [%ASSETS_DIR_SHELL_DEV%] successfully.
	) else (
		echo Failed to delete directory [%ASSETS_DIR_SHELL_DEV%].
		goto END
	)
)
if exist "%ASSETS_DIR_SHELL_MOB%" (
	del /f /s /q "%ASSETS_DIR_SHELL_MOB%\*.*" >nul
	rd /s /q "%ASSETS_DIR_SHELL_MOB%" >nul
	
	if !errorlevel!==0 (
		echo Delete directory [%ASSETS_DIR_SHELL_MOB%] successfully.
	) else (
		echo Failed to delete directory [%ASSETS_DIR_SHELL_MOB%].
		goto END
	)
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: �����زĵ����ͨ���ز�
call :COPY "%ASSETS_DIR%" "%ASSETS_DIR_SHELL_PC%"
call :COPY "%ASSETS_DIR%" "%ASSETS_DIR_SHELL_DEV%"
call :COPY "%ASSETS_DIR%" "%ASSETS_DIR_SHELL_MOB%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo Sync assets successfully.
exit

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
:: pause >nul
exit -1

:: �ж��ļ��Ƿ���ڣ������ڸ�����ʾ��Ϣ
:EXIST
if not exist %1 (
	echo [%1] does not exist.
	goto END
)
goto :EOF

:: �����ļ�
:COPY
echo D|xcopy %1 %2 /E /y >nul
if !errorlevel!==0 (
	echo Copy directory [%2] successfully.
) else (
	echo Failed to copy directory [%2].
	goto END
)
goto :EOF