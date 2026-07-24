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
	echo 태그가 비어 있습니다!
	goto :EOF
)

goto %1

:NOT_EXIST
echo 파일이 없습니다: %~2
goto :EOF

:UNDEFINE
echo 환경 변수 %~2가 정의되지 않았습니다!
goto :EOF

:INVALID_MODE
echo 잘못된 MODE=%~2 (full 또는 embed 사용)
goto :EOF

:TITLE_FULL
title CORE_Shared - ASDoc
goto :EOF

:TITLE_EMBED
title CORE_Shared - ASDoc 삽입
goto :EOF

:SKIP_ALREADY_EMBEDDED
echo SWC에 ASDoc이 이미 삽입되어 있습니다. 건너뜁니다.
goto :EOF

:SWC_NOT_FOUND
echo SWC를 찾을 수 없습니다: %~2
goto :EOF

:BUILD_MODULE_FIRST
echo 먼저 %~2를 빌드하세요.
goto :EOF

:GEN_HTML_START
echo CORE_Shared ASDoc 생성 중...
goto :EOF

:GEN_XML_START
echo SWC용 CORE_Shared ASDoc XML 생성 중...
goto :EOF

:OUTPUT_DIR
echo 출력: %~2
goto :EOF

:GEN_FAIL
echo ASDoc 생성에 실패했습니다.
goto :EOF

:GEN_OK_HTML
echo ASDoc 생성됨: %~2
goto :EOF

:GEN_OK_XML
echo ASDoc XML 생성됨: %~2
goto :EOF

:SKIP_SWC_WARN
echo [경고] SKIP_SWC=1: SWC docs 삽입을 건너뛰었습니다.
goto :EOF

:TEMPDITA_MISSING
echo tempdita가 없어 SWC에 삽입할 수 없습니다.
goto :EOF

:SWC_MISSING_WARN
echo [경고] SWC를 찾을 수 없습니다: %~2
goto :EOF

:BUILD_THEN_RERUN
echo [경고] 먼저 %~2를 빌드한 뒤 다시 실행하여 문서를 삽입하세요.
goto :EOF

:EMBED_START
echo SWC에 ASDoc 삽입 중: %~2
goto :EOF

:EMBED_FAIL
echo SWC에 ASDoc 삽입 실패.
goto :EOF

:EMBED_OK
echo ASDoc이 SWC docs/에 삽입되었습니다
goto :EOF

:SWC_NOT_READY
echo ASDoc 삽입을 위해 SWC가 준비되지 않았습니다: %~2
goto :EOF

:EMBED_LIBS_START
echo 라이브러리 SWC에 ASDoc 삽입 중...
goto :EOF

:EMBED_LIBS_OK
echo 라이브러리 SWC ASDoc 삽입 완료.
goto :EOF
