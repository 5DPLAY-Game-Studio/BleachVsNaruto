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
::   Generate ASDoc HTML for CORE_Shared (Chinese UI chrome + source ASDoc body).
::
:: Usage
::   CORE_Shared\tools\asdoc.bat
::   set OPEN=1 && CORE_Shared\tools\asdoc.bat
::     OPEN=1 opens index.html in the default browser after success.
::
:: Prerequisites
::   1. FLEX_HOME points at Flex/AIR SDK root (bin, lib\asdoc.jar, frameworks,
::      asdoc\templates).
::   2. A JRE/JDK that can run asdoc.jar. Do NOT use SDK asdoc.bat
::      (-Xbootclasspath/p breaks on Java 9+).
::
:: Layout (relative to MODULE_ROOT = CORE_Shared)
::   src\                      Documented package sources (-doc-sources)
::   global\                   Top-level functions (CheckVersion, ...)
::   include\                  Included by sources (not a separate -doc-sources)
::   tools\asdoc.bat           This entry
::   tools\asdoc\              Terms script, zh terms, local template cache
::     build_terms_zh.ps1      Build Chinese ASDoc_terms.xml from SDK English
::     zh_CN\ASDoc_terms.xml   Generated terms (refreshed each run)
::     templates\              SDK template copy (gitignore; synced on first run)
::   out\asdoc\                HTML output
::
:: Flow
::   Check SDK -> build Chinese terms -> sync/overlay templates
::   -> run asdoc.jar -> optional open browser
::
:: Notes
::   No chcp / no lang packs: keep the caller console code page unchanged.
::   Console messages are ASCII-only for encoding safety.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

:: Directory of this bat (...\CORE_Shared\tools\)
set BAT_HOME=%~dp0

title CORE_Shared - ASDoc

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 1) Flex / AIR SDK
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if "%FLEX_HOME%"=="" (
	echo Environment variable FLEX_HOME is undefined!
	goto END
)
call :EXIST "%FLEX_HOME%"

set FLEX_BIN=%FLEX_HOME%\bin
call :EXIST "%FLEX_BIN%"

:: Invoke jar directly; SDK asdoc.bat breaks on Java 9+
set ASDOC_JAR=%FLEX_HOME%\lib\asdoc.jar
call :EXIST "%ASDOC_JAR%"

set FLEX_FRAMEWORKS=%FLEX_HOME%\frameworks
call :EXIST "%FLEX_FRAMEWORKS%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 2) Module paths
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: MODULE_ROOT = CORE_Shared (parent of tools\)
set MODULE_ROOT=%BAT_HOME%..
for %%I in ("%MODULE_ROOT%") do set MODULE_ROOT=%%~fI

set SHARED_SRC=%MODULE_ROOT%\src
set SHARED_GLOBAL=%MODULE_ROOT%\global
call :EXIST "%SHARED_SRC%"
call :EXIST "%SHARED_GLOBAL%"

set DOC_OUT=%MODULE_ROOT%\out\asdoc
if not exist "%DOC_OUT%" mkdir "%DOC_OUT%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 3) Chinese UI chrome: terms + local templates
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: ASDoc has no locale switch. Chrome labels come from ASDoc_terms.xml:
::   a) build_terms_zh.ps1 writes Chinese terms from SDK English table
::   b) First run copies SDK asdoc\templates locally (gitignore)
::   c) Overlay Chinese ASDoc_terms.xml into that templates dir
::   d) asdoc -templates-path points at the local copy
::

set PATH=%FLEX_BIN%;%PATH%

set ASDOC_TMPL=%MODULE_ROOT%\tools\asdoc\templates
set ASDOC_ZH_TERMS=%MODULE_ROOT%\tools\asdoc\zh_CN\ASDoc_terms.xml

powershell -NoProfile -ExecutionPolicy Bypass -File "%MODULE_ROOT%\tools\asdoc\build_terms_zh.ps1"
if not exist "%ASDOC_ZH_TERMS%" (
	echo ASDoc generation failed.
	goto END
)

if not exist "%ASDOC_TMPL%\asdoc-util.xslt" (
	mkdir "%ASDOC_TMPL%" 2>nul
	robocopy "%FLEX_HOME%\asdoc\templates" "%ASDOC_TMPL%" /E /NFL /NDL /NJH /NJS /nc /ns /np >nul
	set RC=!ERRORLEVEL!
	if !RC! GEQ 8 (
		echo ASDoc generation failed.
		goto END
	)
)
copy /Y "%ASDOC_ZH_TERMS%" "%ASDOC_TMPL%\ASDoc_terms.xml" >nul

echo Generating CORE_Shared ASDoc...
echo Output: %DOC_OUT%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 4) Run asdoc.jar
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::   +flexlib                  Flex frameworks root
::   -templates-path           Local templates with Chinese terms
::   -compiler.source-path     src + global
::   -doc-sources              Document src + global APIs
::   -compiler.external-library-path
::                             SDK libs only (this module has no SWC deps)
::   -lenient                  Softer checks on edge cases
::   -keep-xml=false           Drop intermediate XML
::

java -Xmx1024m -classpath "%ASDOC_JAR%" flex2.tools.ASDoc ^
	+flexlib="%FLEX_FRAMEWORKS%" ^
	-templates-path "%ASDOC_TMPL%" ^
	-compiler.source-path "%SHARED_SRC%" "%SHARED_GLOBAL%" ^
	-doc-sources "%SHARED_SRC%" "%SHARED_GLOBAL%" ^
	-compiler.external-library-path "%FLEX_FRAMEWORKS%\libs" "%FLEX_FRAMEWORKS%\libs\air" "%FLEX_FRAMEWORKS%\libs\mx" ^
	-lenient ^
	-keep-xml=false ^
	-main-title "CORE_Shared API" ^
	-window-title "CORE_Shared ASDoc" ^
	-footer "5DPLAY Game Studio - CORE_Shared" ^
	-output "%DOC_OUT%"

if errorlevel 1 (
	echo ASDoc generation failed.
	goto END
)

echo ASDoc generated: %DOC_OUT%\index.html

if /i "%OPEN%"=="1" (
	if exist "%DOC_OUT%\index.html" start "" "%DOC_OUT%\index.html"
)

echo.
exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
pause >nul
exit /b 1

:EXIST
if not exist %1 (
	echo File does not exist: %~1
	goto END
)
goto :EOF
