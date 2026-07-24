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
echo File does not exist: %~2
goto :EOF

:UNDEFINE
echo Environment variable %~2 is undefined!
goto :EOF

:INVALID_MODE
echo Invalid MODE=%~2 (use full or embed)
goto :EOF

:TITLE_FULL
title CORE_Shared - ASDoc
goto :EOF

:TITLE_EMBED
title CORE_Shared - ASDoc embed
goto :EOF

:SKIP_ALREADY_EMBEDDED
echo ASDoc already embedded in SWC; skip.
goto :EOF

:SWC_NOT_FOUND
echo SWC not found: %~2
goto :EOF

:BUILD_MODULE_FIRST
echo Build %~2 first.
goto :EOF

:GEN_HTML_START
echo Generating CORE_Shared ASDoc...
goto :EOF

:GEN_XML_START
echo Generating CORE_Shared ASDoc XML for SWC...
goto :EOF

:OUTPUT_DIR
echo Output: %~2
goto :EOF

:GEN_FAIL
echo ASDoc generation failed.
goto :EOF

:GEN_OK_HTML
echo ASDoc generated: %~2
goto :EOF

:GEN_OK_XML
echo ASDoc XML generated: %~2
goto :EOF

:SKIP_SWC_WARN
echo [WARN] SKIP_SWC=1: SWC docs embedding skipped.
goto :EOF

:TEMPDITA_MISSING
echo tempdita missing; cannot embed into SWC.
goto :EOF

:SWC_MISSING_WARN
echo [WARN] SWC not found: %~2
goto :EOF

:BUILD_THEN_RERUN
echo [WARN] Build %~2 first, then re-run to embed docs.
goto :EOF

:EMBED_START
echo Embedding ASDoc into SWC: %~2
goto :EOF

:EMBED_FAIL
echo Failed to embed ASDoc into SWC.
goto :EOF

:EMBED_OK
echo ASDoc embedded into SWC docs/
goto :EOF

:SWC_NOT_READY
echo SWC not ready for ASDoc embed: %~2
goto :EOF

:EMBED_LIBS_START
echo Embedding ASDoc into library SWCs...
goto :EOF

:EMBED_LIBS_OK
echo ASDoc embedded into library SWCs.
goto :EOF
