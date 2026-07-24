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
:: 用途
::   为 CORE_Shared 生成 ASDoc，并可选将中间 XML 嵌入生产 SWC 的 docs/，
::   供 IDE 代码提示使用。
::
:: 用法
::   tools\script\asdoc_shared.bat
::     MODE=full（默认）：生成 HTML，并尝试嵌入 SWC。
::
::   set MODE=embed&& tools\script\asdoc_shared.bat
::     仅生成完整 tempdita 并嵌入 SWC（供 embed_asdoc_shared.bat / 构建后钩子）。
::
::   set OPEN=1&& tools\script\asdoc_shared.bat
::   set SKIP_SWC=1&& tools\script\asdoc_shared.bat
::   set SWC_PATH=D:\path\CORE_Shared.swc&& tools\script\asdoc_shared.bat
::   set IF_MISSING=1&& ...   若 SWC 已有 docs/packages.dita 则跳过
::   set NO_PAUSE=1&& ...     失败时不 pause（供 build / External Tool）
::
:: 前置条件
::   - FLEX_HOME 指向 Flex/AIR SDK（含 bin、lib\asdoc.jar、frameworks、asdoc\templates）
::   - 可用的 JRE/JDK 能直接跑 asdoc.jar（勿在 Java 9+ 上用 SDK 自带 asdoc.bat）
::   - embed 模式：须先有生产 SWC（compc / IDEA / VSCode 已编译）
::
:: 布局
::   tools\script\asdoc_shared.bat / embed_asdoc_shared.bat / embed_asdoc_libs.bat
::   tools\script\ps\              共用 inject / wait / build_terms_zh
::   tools\script\asdoc\          本地 templates、zh_CN（Shared）
::   CORE_Shared\out\asdoc\       HTML（MODE=full）
::   CORE_Shared\out\asdoc_embed\ embed 输出（含 tempdita）
::
:: 注意
::   勿使用 -skip-xsl=true（会丢掉汇总 XML，导致 SWC docs 过薄）。
::   IDEA：用 External Tool EmbedLibsAsDoc（非 File Watchers）。
::   LIB_KyoLib 因可独立运行，其 asdoc 仍留在子模块 tools\ 内（优先复用本仓库 ps\）。
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

set "BAT_HOME=%~dp0"
set "FUNC_COMMON=%BAT_HOME%func\common.bat"
call "%FUNC_COMMON%" INIT_LANG "%~n0"

if /i "%MODE%"=="" set MODE=full
if /i not "%MODE%"=="embed" if /i not "%MODE%"=="full" (
	call "%FUNC_COMMON%" ECHO_LANG :INVALID_MODE "%MODE%"
	goto END
)

if /i "%MODE%"=="embed" (
	call "%FUNC_COMMON%" ECHO_LANG :TITLE_EMBED ""
) else (
	call "%FUNC_COMMON%" ECHO_LANG :TITLE_FULL ""
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 1) Flex / AIR SDK
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if "%FLEX_HOME%"=="" (
	call "%FUNC_COMMON%" ECHO_LANG :UNDEFINE "FLEX_HOME"
	goto END
)
call "%FUNC_COMMON%" EXIST "%FLEX_HOME%"
if errorlevel 1 goto END

set "FLEX_BIN=%FLEX_HOME%\bin"
call "%FUNC_COMMON%" EXIST "%FLEX_BIN%"
if errorlevel 1 goto END

set "ASDOC_JAR=%FLEX_HOME%\lib\asdoc.jar"
call "%FUNC_COMMON%" EXIST "%ASDOC_JAR%"
if errorlevel 1 goto END

set "FLEX_FRAMEWORKS=%FLEX_HOME%\frameworks"
call "%FUNC_COMMON%" EXIST "%FLEX_FRAMEWORKS%"
if errorlevel 1 goto END

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 2) 模块路径与目标 SWC
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set "REPO_ROOT=%BAT_HOME%..\.."
for %%I in ("%REPO_ROOT%") do set "REPO_ROOT=%%~fI"

set "MODULE_ROOT=%REPO_ROOT%\CORE_Shared"
set "ASDOC_HOME=%BAT_HOME%asdoc"
set "ASDOC_PS=%BAT_HOME%ps"

set "SHARED_SRC=%MODULE_ROOT%\src"
set "SHARED_GLOBAL=%MODULE_ROOT%\global"
call "%FUNC_COMMON%" EXIST "%SHARED_SRC%"
if errorlevel 1 goto END
call "%FUNC_COMMON%" EXIST "%SHARED_GLOBAL%"
if errorlevel 1 goto END
call "%FUNC_COMMON%" EXIST "%ASDOC_HOME%"
if errorlevel 1 goto END
call "%FUNC_COMMON%" EXIST "%ASDOC_PS%"
if errorlevel 1 goto END

if "%SWC_PATH%"=="" (
	set "SWC_PATH=%REPO_ROOT%\out\production\CORE_Shared\CORE_Shared.swc"
)

if /i "%MODE%"=="embed" (
	set "DOC_OUT=%MODULE_ROOT%\out\asdoc_embed"
) else (
	set "DOC_OUT=%MODULE_ROOT%\out\asdoc"
)
if not exist "%DOC_OUT%" mkdir "%DOC_OUT%"

:: 可选：SWC 已有 docs 则跳过
if /i "%IF_MISSING%"=="1" (
	if exist "%SWC_PATH%" (
		powershell -NoProfile -ExecutionPolicy Bypass -File "%ASDOC_PS%\inject_docs_swc.ps1" -SwcPath "%SWC_PATH%" -TestHasDocs >nul 2>&1
		if not errorlevel 1 (
			call "%FUNC_COMMON%" ECHO_LANG :SKIP_ALREADY_EMBEDDED ""
			echo.
			exit /b 0
		)
	)
)

:: embed 模式必须已有 SWC
if /i "%MODE%"=="embed" (
	if not exist "%SWC_PATH%" (
		call "%FUNC_COMMON%" ECHO_LANG :SWC_NOT_FOUND "%SWC_PATH%"
		call "%FUNC_COMMON%" ECHO_LANG :BUILD_MODULE_FIRST "CORE_Shared"
		goto END
	)
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 3) 中文界面术语 + 本地 templates
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set "PATH=%FLEX_BIN%;%PATH%"

set "ASDOC_TMPL=%ASDOC_HOME%\templates"
set "ASDOC_ZH_TERMS=%ASDOC_HOME%\zh_CN\ASDoc_terms.xml"

powershell -NoProfile -ExecutionPolicy Bypass -File "%ASDOC_PS%\build_terms_zh.ps1" -OutDir "%ASDOC_HOME%\zh_CN"
if not exist "%ASDOC_ZH_TERMS%" (
	call "%FUNC_COMMON%" ECHO_LANG :GEN_FAIL ""
	goto END
)

if not exist "%ASDOC_TMPL%\asdoc-util.xslt" (
	mkdir "%ASDOC_TMPL%" 2>nul
	robocopy "%FLEX_HOME%\asdoc\templates" "%ASDOC_TMPL%" /E /NFL /NDL /NJH /NJS /nc /ns /np >nul
	set RC=!ERRORLEVEL!
	if !RC! GEQ 8 (
		call "%FUNC_COMMON%" ECHO_LANG :GEN_FAIL ""
		goto END
	)
)
copy /Y "%ASDOC_ZH_TERMS%" "%ASDOC_TMPL%\ASDoc_terms.xml" >nul

if /i "%MODE%"=="embed" (
	call "%FUNC_COMMON%" ECHO_LANG :GEN_XML_START ""
) else (
	call "%FUNC_COMMON%" ECHO_LANG :GEN_HTML_START ""
)
call "%FUNC_COMMON%" ECHO_LANG :OUTPUT_DIR "%DOC_OUT%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 4) 运行 asdoc.jar
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: 勿使用 -skip-xsl=true：会丢掉 Classes/fieldSummary 等汇总 XML，
:: 导致 SWC docs/ 过薄。embed 仅改变 -output 目录。
::

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

if errorlevel 1 (
	call "%FUNC_COMMON%" ECHO_LANG :GEN_FAIL ""
	goto END
)

if /i "%MODE%"=="full" (
	call "%FUNC_COMMON%" ECHO_LANG :GEN_OK_HTML "%DOC_OUT%\index.html"
) else (
	call "%FUNC_COMMON%" ECHO_LANG :GEN_OK_XML "%DOC_OUT%\tempdita"
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 5) 将 tempdita 嵌入 SWC docs/
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set "TEMPDITA=%DOC_OUT%\tempdita"

if /i "%SKIP_SWC%"=="1" (
	call "%FUNC_COMMON%" ECHO_LANG :SKIP_SWC_WARN ""
	goto AFTER_SWC
)

if not exist "%TEMPDITA%" (
	call "%FUNC_COMMON%" ECHO_LANG :TEMPDITA_MISSING ""
	goto END
)

if not exist "%SWC_PATH%" (
	call "%FUNC_COMMON%" ECHO_LANG :SWC_MISSING_WARN "%SWC_PATH%"
	call "%FUNC_COMMON%" ECHO_LANG :BUILD_THEN_RERUN "CORE_Shared"
	if /i "%MODE%"=="embed" goto END
	goto AFTER_SWC
)

call "%FUNC_COMMON%" ECHO_LANG :EMBED_START "%SWC_PATH%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%ASDOC_PS%\inject_docs_swc.ps1" -SwcPath "%SWC_PATH%" -TempDitaDir "%TEMPDITA%"
if errorlevel 1 (
	call "%FUNC_COMMON%" ECHO_LANG :EMBED_FAIL ""
	goto END
)
call "%FUNC_COMMON%" ECHO_LANG :EMBED_OK ""

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
