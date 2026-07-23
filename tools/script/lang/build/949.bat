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
:: ASCII-only messages (safe under any console code page).
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off

if "%1"=="" (
	echo 태그가 비어있습니다!
	goto :EOF
)

goto %1

:NOT_EXIST
echo 파일이 존재하지 않습니다: %~2
goto :EOF

:UNDEFINE
echo 환경 변수 %~2가 정의되지 않았습니다!
goto :EOF

:TITLE
title 빌드 프로젝트
goto :EOF

:BUILD_START
echo SHELL_Dev 디버그 체인을 구축하는 중...
goto :EOF

:COMPILE_START
echo 컴파일 중: %~2
goto :EOF

:COMPILE_OK
echo 컴파일 성공: %~2
goto :EOF

:COMPILE_FAIL
echo 컴파일 실패: %~2
goto :EOF

:SYNC_START
echo 자산 동기화 중...
goto :EOF

:SYNC_FAIL
echo 자산 동기화에 실패했습니다!
goto :EOF

:COPY_FAIL
echo 복사 실패: %~2
goto :EOF

:BUILD_SUCCESS
echo SHELL_Dev 빌드가 성공적으로 완료되었습니다!
goto :EOF
