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
title 리소스 게시
goto :EOF

:PUBLISH_START
echo Flash/Animate 를 통해 BleachVsNaruto_FlashSrc 게시 중...
goto :EOF

:NO_EXE
echo 다음 위치에서 Animate.exe / Flash.exe 를 찾을 수 없습니다: %~2
goto :EOF

:USE_EXE
echo 사용: %~2
goto :EOF

:WRITE_FAIL
echo 쓰기 실패: %~2
goto :EOF

:LAUNCH
echo Flash/Animate(JSFL) 를 실행합니다. 창이 열릴 수 있으니 완료될 때까지 기다려 주십시오...
goto :EOF

:NO_RESULT
echo 게시 결과 파일이 없습니다(JSFL 시작에 실패했을 수 있음): %~2
goto :EOF

:PUBLISH_SUCCESS
echo FlashSrc 게시가 성공적으로 완료되었습니다!
goto :EOF

:PUBLISH_FAIL
echo FlashSrc 게시 실패. 코드=%~2
goto :EOF
