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
	echo �±װ� ����ֽ��ϴ�!
	goto :EOF
)

goto %1

:NOT_EXIST
echo ������ �������� �ʽ��ϴ�: %~2
goto :EOF

:SYNC_SUCCESS
echo �ڻ� ����ȭ�� ���������� �Ϸ�Ǿ����ϴ�!
goto :EOF

:DEL_DIR_SUCCESS
echo ���丮�� ���������� �����Ǿ����ϴ�: %~2
goto :EOF

:DEL_DIR_FAIL
echo ���丮 ������ �����߽��ϴ�: %~2
goto :EOF

:COPY_DIR_SUCCESS
echo ���丮�� ���������� ����Ǿ����ϴ�: %~2
goto :EOF

:COPY_DIR_FAIL
echo ���丮 ���翡 �����߽��ϴ�: %~2
goto :EOF

