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
title リソースを公開する
goto :EOF

:PUBLISH_START
echo Flash/Animate 経由で BleachVsNaruto_FlashSrc をパブリッシュ中...
goto :EOF

:NO_EXE
echo Animate.exe / Flash.exe が次の場所に見つかりません: %~2
goto :EOF

:USE_EXE
echo 使用するもの： %~2
goto :EOF

:WRITE_FAIL
echo 書き込みに失敗しました: %~2
goto :EOF

:LAUNCH
echo Flash/Animate (JSFL) を起動します。ウィンドウが開く場合がありますので、完了するまでお待ちください...
goto :EOF

:NO_RESULT
echo パブリッシュ結果ファイルが見つかりません（JSFL の起動に失敗した可能性があります）： %~2
goto :EOF

:PUBLISH_SUCCESS
echo FlashSrc の公開が正常に完了しました！
goto :EOF

:PUBLISH_FAIL
echo FlashSrc の公開に失敗しました。コード=%~2
goto :EOF
