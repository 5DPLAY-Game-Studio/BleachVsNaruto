@echo off
:: Maps REPO_ROOT to a free drive when the path contains &.
:: ASDoc writes sourcefile into XML without escaping &, which breaks the parser.
:: No setlocal: ASDOC_DRIVE is written back to the caller.
:: Requires the caller to have enabledelayedexpansion.
::   call asdoc_drive.bat MOUNT
::   call asdoc_drive.bat UNMOUNT
if "%~1"=="" exit /b 1
call :%~1
exit /b

:MOUNT
set "ASDOC_DRIVE="
if "!REPO_ROOT!"=="!REPO_ROOT:&=!" exit /b 0
for %%D in (Z Y X W V U T S R Q P O N M) do (
	if not defined ASDOC_DRIVE if not exist %%D:\ set "ASDOC_DRIVE=%%D"
)
if not defined ASDOC_DRIVE (
	echo No free drive letter for ASDoc.
	exit /b 1
)
echo Mapping !ASDOC_DRIVE!: for ASDoc.
subst !ASDOC_DRIVE!: "!REPO_ROOT!"
if errorlevel 1 (
	echo Failed to map !ASDOC_DRIVE!: for ASDoc.
	set "ASDOC_DRIVE="
	exit /b 1
)
exit /b 0

:UNMOUNT
if not defined ASDOC_DRIVE exit /b 0
subst !ASDOC_DRIVE!: /d >nul 2>&1
set "ASDOC_DRIVE="
exit /b 0
