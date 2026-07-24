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
echo ファイルが存在しません: %~2
goto :EOF

:UNDEFINE
echo 環境変数 %~2 が未定義です。
goto :EOF

:TITLE
title ビルド プロジェクト
goto :EOF

:BUILD_START
echo SHELL_Dev デバッグチェーンを構築中...
goto :EOF

:COMPILE_START
echo コンパイル中: %~2
goto :EOF

:COMPILE_OK
echo コンパイルに成功しました: %~2
goto :EOF

:COMPILE_FAIL
echo コンパイルに失敗しました: %~2
goto :EOF

:SYNC_START
echo アセットを同期しています...
goto :EOF

:SYNC_FAIL
echo アセットの同期に失敗しました！
goto :EOF

:COPY_FAIL
echo コピーに失敗しました: %~2
goto :EOF

:BUILD_SUCCESS
echo SHELL_Dev のビルドが正常に完了しました！
goto :EOF

:ASDOC_EMBED_START
echo SWC に ASDoc を埋め込んでいます: %~2
goto :EOF

:ASDOC_EMBED_OK
echo ASDoc を埋め込みました: %~2
goto :EOF

:ASDOC_EMBED_FAIL
echo ASDoc の埋め込みに失敗しました: %~2
goto :EOF
