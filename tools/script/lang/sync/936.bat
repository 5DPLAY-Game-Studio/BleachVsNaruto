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
	echo ��ǩΪ�գ�
	goto :EOF
)

goto %1

:NOT_EXIST
echo �ļ������ڣ�%~2
goto :EOF

:SYNC_SUCCESS
echo ͬ���زĳɹ���
goto :EOF

:DEL_DIR_SUCCESS
echo ɾ��Ŀ¼�ɹ���%~2
goto :EOF

:DEL_DIR_FAIL
echo ɾ��Ŀ¼ʧ�ܣ�%~2
goto :EOF

:COPY_DIR_SUCCESS
echo ����Ŀ¼�ɹ���%~2
goto :EOF

:COPY_DIR_FAIL
echo ����Ŀ¼ʧ�ܣ�%~2
goto :EOF

