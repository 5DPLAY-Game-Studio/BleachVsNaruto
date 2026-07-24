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
::   Generate ASDoc for CORE_Shared and/or embed ASDoc XML into the
::   production SWC (docs/) for IDE code hints.
::
:: Usage
::   CORE_Shared\tools\asdoc.bat
::     MODE=full (default): HTML + embed into SWC.
::
::   set MODE=embed&& CORE_Shared\tools\asdoc.bat
::     XML-only (skip-xsl) + embed. Used by embed_asdoc.bat / post-build.
::
::   set OPEN=1&& CORE_Shared\tools\asdoc.bat
::   set SKIP_SWC=1&& CORE_Shared\tools\asdoc.bat
::   set SWC_PATH=D:\path\CORE_Shared.swc&& CORE_Shared\tools\asdoc.bat
::   set IF_MISSING=1&& ...   Skip when SWC already has docs/packages.dita
::   set NO_PAUSE=1&& ...     No pause on failure (for build.bat / IDE hooks)
::
:: Prerequisites
::   1. FLEX_HOME -> Flex/AIR SDK (bin, lib\asdoc.jar, frameworks, asdoc\templates)
::   2. JRE/JDK that can run asdoc.jar (do NOT use SDK asdoc.bat on Java 9+)
::   3. For embed: production SWC must exist (compc / IDEA / VSCode build first)
::
:: Layout (MODULE_ROOT = CORE_Shared)
::   tools\asdoc.bat / tools\embed_asdoc.bat
::   tools\asdoc\build_terms_zh.ps1 / inject_docs_swc.ps1 / templates / zh_CN
::   out\asdoc\         HTML (MODE=full)
::   out\asdoc_embed\   XML-only temp (MODE=embed)
::
:: Notes
::   ASCII-only console messages. No chcp / lang packs.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

set BAT_HOME=%~dp0

if /i "%MODE%"=="" set MODE=full
if /i not "%MODE%"=="embed" if /i not "%MODE%"=="full" (
	echo Invalid MODE=%MODE% ^(use full or embed^)
	goto END
)

if /i "%MODE%"=="embed" (
	title CORE_Shared - ASDoc embed
) else (
	title CORE_Shared - ASDoc
)

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

set ASDOC_JAR=%FLEX_HOME%\lib\asdoc.jar
call :EXIST "%ASDOC_JAR%"

set FLEX_FRAMEWORKS=%FLEX_HOME%\frameworks
call :EXIST "%FLEX_FRAMEWORKS%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 2) Module paths and target SWC
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set MODULE_ROOT=%BAT_HOME%..
for %%I in ("%MODULE_ROOT%") do set MODULE_ROOT=%%~fI

set SHARED_SRC=%MODULE_ROOT%\src
set SHARED_GLOBAL=%MODULE_ROOT%\global
call :EXIST "%SHARED_SRC%"
call :EXIST "%SHARED_GLOBAL%"

set REPO_ROOT=%MODULE_ROOT%\..
for %%I in ("%REPO_ROOT%") do set REPO_ROOT=%%~fI

if "%SWC_PATH%"=="" (
	set SWC_PATH=%REPO_ROOT%\out\production\CORE_Shared\CORE_Shared.swc
)

if /i "%MODE%"=="embed" (
	set DOC_OUT=%MODULE_ROOT%\out\asdoc_embed
) else (
	set DOC_OUT=%MODULE_ROOT%\out\asdoc
)
if not exist "%DOC_OUT%" mkdir "%DOC_OUT%"

:: File Watcher / re-entry: skip when SWC already has docs
if /i "%IF_MISSING%"=="1" (
	if exist "%SWC_PATH%" (
		powershell -NoProfile -ExecutionPolicy Bypass -File "%MODULE_ROOT%\tools\asdoc\inject_docs_swc.ps1" -SwcPath "%SWC_PATH%" -TestHasDocs >nul 2>&1
		if not errorlevel 1 (
			echo ASDoc already embedded in SWC; skip.
			echo.
			exit /b 0
		)
	)
)

:: Post-build embed requires SWC; fail fast
if /i "%MODE%"=="embed" (
	if not exist "%SWC_PATH%" (
		echo SWC not found: %SWC_PATH%
		echo Build CORE_Shared first.
		goto END
	)
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 3) Chinese UI chrome: terms + local templates
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

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

if /i "%MODE%"=="embed" (
	echo Generating CORE_Shared ASDoc XML for SWC...
) else (
	echo Generating CORE_Shared ASDoc...
)
echo Output: %DOC_OUT%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 4) Run asdoc.jar
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if /i "%MODE%"=="embed" (
	java -Xmx1024m -classpath "%ASDOC_JAR%" flex2.tools.ASDoc ^
		+flexlib="%FLEX_FRAMEWORKS%" ^
		-templates-path "%ASDOC_TMPL%" ^
		-compiler.source-path "%SHARED_SRC%" "%SHARED_GLOBAL%" ^
		-doc-sources "%SHARED_SRC%" "%SHARED_GLOBAL%" ^
		-compiler.external-library-path "%FLEX_FRAMEWORKS%\libs" "%FLEX_FRAMEWORKS%\libs\air" "%FLEX_FRAMEWORKS%\libs\mx" ^
		-lenient ^
		-keep-xml=true ^
		-skip-xsl=true ^
		-main-title "CORE_Shared API" ^
		-window-title "CORE_Shared ASDoc" ^
		-footer "5DPLAY Game Studio - CORE_Shared" ^
		-output "%DOC_OUT%"
) else (
	java -Xmx1024m -classpath "%ASDOC_JAR%" flex2.tools.ASDoc ^
		+flexlib="%FLEX_FRAMEWORKS%" ^
		-templates-path "%ASDOC_TMPL%" ^
		-compiler.source-path "%SHARED_SRC%" "%SHARED_GLOBAL%" ^
		-doc-sources "%SHARED_SRC%" "%SHARED_GLOBAL%" ^
		-compiler.external-library-path "%FLEX_FRAMEWORKS%\libs" "%FLEX_FRAMEWORKS%\libs\air" "%FLEX_FRAMEWORKS%\libs\mx" ^
		-lenient ^
		-keep-xml=true ^
		-main-title "CORE_Shared API" ^
		-window-title "CORE_Shared ASDoc" ^
		-footer "5DPLAY Game Studio - CORE_Shared" ^
		-output "%DOC_OUT%"
)

if errorlevel 1 (
	echo ASDoc generation failed.
	goto END
)

if /i "%MODE%"=="full" (
	echo ASDoc generated: %DOC_OUT%\index.html
) else (
	echo ASDoc XML generated: %DOC_OUT%\tempdita
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 5) Embed tempdita into SWC docs/
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set TEMPDITA=%DOC_OUT%\tempdita

if /i "%SKIP_SWC%"=="1" (
	echo [WARN] SKIP_SWC=1: SWC docs embedding skipped.
	goto AFTER_SWC
)

if not exist "%TEMPDITA%" (
	echo tempdita missing; cannot embed into SWC.
	goto END
)

if not exist "%SWC_PATH%" (
	echo [WARN] SWC not found: %SWC_PATH%
	echo [WARN] Build CORE_Shared first, then re-run to embed docs.
	if /i "%MODE%"=="embed" goto END
	goto AFTER_SWC
)

echo Embedding ASDoc into SWC: %SWC_PATH%
powershell -NoProfile -ExecutionPolicy Bypass -File "%MODULE_ROOT%\tools\asdoc\inject_docs_swc.ps1" -SwcPath "%SWC_PATH%" -TempDitaDir "%TEMPDITA%"
if errorlevel 1 (
	echo Failed to embed ASDoc into SWC.
	goto END
)
echo ASDoc embedded into SWC docs/

:AFTER_SWC

if /i "%OPEN%"=="1" (
	if exist "%DOC_OUT%\index.html" start "" "%DOC_OUT%\index.html"
)

echo.
exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
if /i not "%NO_PAUSE%"=="1" pause >nul
exit /b 1

:EXIST
if not exist %1 (
	echo File does not exist: %~1
	goto END
)
goto :EOF
