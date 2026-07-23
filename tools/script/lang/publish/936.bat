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

:TITLE
title 发布资源
goto :EOF

:PUBLISH_START
echo 正在通过 Flash/Animate 发布 BleachVsNaruto_FlashSrc……
goto :EOF

:NO_EXE
echo 未在以下位置找到 Animate.exe / Flash.exe： %~2
goto :EOF

:USE_EXE
echo 使用： %~2
goto :EOF

:WRITE_FAIL
echo 写入失败： %~2
goto :EOF

:LAUNCH
echo 正在启动 Flash/Animate (JSFL)。可能会弹出窗口；请等待其完成……
goto :EOF

:NO_RESULT
echo 缺少发布结果文件（JSFL 可能未能启动）： %~2
goto :EOF

:PUBLISH_SUCCESS
echo FlashSrc 发布成功！
goto :EOF

:PUBLISH_FAIL
echo FlashSrc 发布失败。代码=%~2
goto :EOF
