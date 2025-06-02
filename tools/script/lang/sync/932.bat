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
	echo タグが空です!
	goto :EOF
)

goto %1

:NOT_EXIST
echo ファイルが存在しません: %~2
goto :EOF

:SYNC_SUCCESS
echo アセットの同期に成功しました!
goto :EOF

:DEL_DIR_SUCCESS
echo ディレクトリは正常に削除されました: %~2
goto :EOF

:DEL_DIR_FAIL
echo ディレクトリの削除に失敗しました: %~2
goto :EOF

:COPY_DIR_SUCCESS
echo ディレクトリは正常にコピーされました: %~2
goto :EOF

:COPY_DIR_FAIL
echo ディレクトリのコピーに失敗しました: %~2
goto :EOF

