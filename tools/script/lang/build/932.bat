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
	echo タグが空です!
	goto :EOF
)

goto %1

:NOT_EXIST
echo ファイルが存在しません: !LANG_PARAM!
goto :EOF

:UNDEFINE
echo 環境変数 !LANG_PARAM! が未定義です。
goto :EOF

:TITLE
title ビルド プロジェクト
goto :EOF

:BUILD_START
echo SHELL_Dev デバッグチェーンと SHELL_Pc リリースパッケージを構築中...
goto :EOF

:COMPILE_START
echo コンパイル中: !LANG_PARAM!
goto :EOF

:COMPILE_OK
echo コンパイルに成功しました: !LANG_PARAM!
goto :EOF

:COMPILE_FAIL
echo コンパイルに失敗しました: !LANG_PARAM!
goto :EOF

:SYNC_START
echo アセットを同期しています...
goto :EOF

:SYNC_FAIL
echo アセットの同期に失敗しました！
goto :EOF

:COPY_FAIL
echo コピーに失敗しました: !LANG_PARAM!
goto :EOF

:BUILD_SUCCESS
echo ビルド完了（SHELL_Dev + SHELL_Pc パッケージ）！
goto :EOF

:PACKAGE_PC_START
echo SHELL_Pc キャプティブランタイムをパッケージ中...
goto :EOF

:PACKAGE_PC_FAIL
echo SHELL_Pc のパッケージに失敗しました！
goto :EOF

:PACKAGE_PC_OK
echo SHELL_Pc のパッケージが完了しました！
goto :EOF

:ASDOC_EMBED_START
echo SWC に ASDoc を埋め込んでいます: !LANG_PARAM!
goto :EOF

:ASDOC_EMBED_OK
echo ASDoc を埋め込みました: !LANG_PARAM!
goto :EOF

:ASDOC_EMBED_FAIL
echo ASDoc の埋め込みに失敗しました: !LANG_PARAM!
goto :EOF
