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
	echo 标签为空！
	goto :EOF
)

goto %1

:NOT_EXIST
echo 文件不存在：%~2
goto :EOF

:UNDEFINE
echo 环境变量 %~2 未定义！
goto :EOF

:INVALID_MODE
echo 无效的 MODE=%~2（请使用 full 或 embed）
goto :EOF

:TITLE_FULL
title CORE_Shared - ASDoc
goto :EOF

:TITLE_EMBED
title CORE_Shared - ASDoc 嵌入
goto :EOF

:SKIP_ALREADY_EMBEDDED
echo SWC 已嵌入 ASDoc，跳过。
goto :EOF

:SWC_NOT_FOUND
echo 未找到 SWC：%~2
goto :EOF

:BUILD_MODULE_FIRST
echo 请先编译 %~2。
goto :EOF

:GEN_HTML_START
echo 正在生成 CORE_Shared ASDoc...
goto :EOF

:GEN_XML_START
echo 正在生成 CORE_Shared ASDoc XML（用于嵌入 SWC）...
goto :EOF

:OUTPUT_DIR
echo 输出目录：%~2
goto :EOF

:GEN_FAIL
echo ASDoc 生成失败。
goto :EOF

:GEN_OK_HTML
echo ASDoc 已生成：%~2
goto :EOF

:GEN_OK_XML
echo ASDoc XML 已生成：%~2
goto :EOF

:SKIP_SWC_WARN
echo [警告] SKIP_SWC=1：已跳过嵌入 SWC docs。
goto :EOF

:TEMPDITA_MISSING
echo 缺少 tempdita，无法嵌入 SWC。
goto :EOF

:SWC_MISSING_WARN
echo [警告] 未找到 SWC：%~2
goto :EOF

:BUILD_THEN_RERUN
echo [警告] 请先编译 %~2，再重新运行以嵌入文档。
goto :EOF

:EMBED_START
echo 正在将 ASDoc 嵌入 SWC：%~2
goto :EOF

:EMBED_FAIL
echo 将 ASDoc 嵌入 SWC 失败。
goto :EOF

:EMBED_OK
echo ASDoc 已嵌入 SWC docs/
goto :EOF
