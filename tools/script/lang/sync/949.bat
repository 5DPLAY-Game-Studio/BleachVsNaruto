::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Copyright (C) 2021-2025, 5DPLAY Game Studio
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
	echo 태그가 비어있습니다!
	goto :EOF
)

goto %1

:NOT_EXIST
echo 파일이 존재하지 않습니다: %~2
goto :EOF

:SYNC_SUCCESS
echo 자산 동기화가 성공적으로 완료되었습니다!
goto :EOF

:DEL_DIR_SUCCESS
echo 디렉토리가 성공적으로 삭제되었습니다: %~2
goto :EOF

:DEL_DIR_FAIL
echo 디렉토리 삭제에 실패했습니다: %~2
goto :EOF

:COPY_DIR_SUCCESS
echo 디렉토리가 성공적으로 복사되었습니다: %~2
goto :EOF

:COPY_DIR_FAIL
echo 디렉토리 복사에 실패했습니다: %~2
goto :EOF

