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
	echo タグが空です!
	goto :EOF
)

goto %1

:NOT_EXIST
echo ファイルが存在しません: %~2
goto :EOF

:UNDEFINE
echo 環境変数 %~2 が未定義です。
goto :EOF

:TITLE
title SHELL_Pc をパッケージ
goto :EOF

:PACKAGE_START
echo SDK adt で SHELL_Pc キャプティブランタイムをパッケージ中...
goto :EOF

:SDK_INFO
echo SDK: %~2
goto :EOF

:OUT_INFO
echo 出力: %~2
goto :EOF

:PACKAGE_FAIL
echo パッケージに失敗しました！
goto :EOF

:PACKAGE_SUCCESS
echo パッケージ完了: %~2
goto :EOF
