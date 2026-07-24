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
	echo タグが空です！
	goto :EOF
)

goto %1

:NOT_EXIST
echo ファイルが存在しません: %~2
goto :EOF

:UNDEFINE
echo 環境変数 %~2 が未定義です！
goto :EOF

:INVALID_MODE
echo 無効な MODE=%~2（full または embed を使用）
goto :EOF

:TITLE_FULL
title CORE_Shared - ASDoc
goto :EOF

:TITLE_EMBED
title CORE_Shared - ASDoc 埋め込み
goto :EOF

:SKIP_ALREADY_EMBEDDED
echo SWC に ASDoc は既に埋め込まれています。スキップします。
goto :EOF

:SWC_NOT_FOUND
echo SWC が見つかりません: %~2
goto :EOF

:BUILD_MODULE_FIRST
echo 先に %~2 をビルドしてください。
goto :EOF

:GEN_HTML_START
echo CORE_Shared の ASDoc を生成しています...
goto :EOF

:GEN_XML_START
echo SWC 用の CORE_Shared ASDoc XML を生成しています...
goto :EOF

:OUTPUT_DIR
echo 出力: %~2
goto :EOF

:GEN_FAIL
echo ASDoc の生成に失敗しました。
goto :EOF

:GEN_OK_HTML
echo ASDoc を生成しました: %~2
goto :EOF

:GEN_OK_XML
echo ASDoc XML を生成しました: %~2
goto :EOF

:SKIP_SWC_WARN
echo [警告] SKIP_SWC=1: SWC docs への埋め込みをスキップしました。
goto :EOF

:TEMPDITA_MISSING
echo tempdita がないため SWC に埋め込めません。
goto :EOF

:SWC_MISSING_WARN
echo [警告] SWC が見つかりません: %~2
goto :EOF

:BUILD_THEN_RERUN
echo [警告] 先に %~2 をビルドしてから再実行し、ドキュメントを埋め込んでください。
goto :EOF

:EMBED_START
echo SWC に ASDoc を埋め込んでいます: %~2
goto :EOF

:EMBED_FAIL
echo SWC への ASDoc 埋め込みに失敗しました。
goto :EOF

:EMBED_OK
echo ASDoc を SWC docs/ に埋め込みました
goto :EOF

:SWC_NOT_READY
echo ASDoc 埋め込みの準備ができていません: %~2
goto :EOF

:EMBED_LIBS_START
echo ライブラリ SWC に ASDoc を埋め込んでいます...
goto :EOF

:EMBED_LIBS_OK
echo ライブラリ SWC への ASDoc 埋め込みが完了しました。
goto :EOF
