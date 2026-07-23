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
title 构建项目
goto :EOF

:BUILD_START
echo 正在构建 SHELL_Dev 调试链...
goto :EOF

:COMPILE_START
echo 正在编译： %~2
goto :EOF

:COMPILE_OK
echo 编译成功： %~2
goto :EOF

:COMPILE_FAIL
echo 编译失败： %~2
goto :EOF

:SYNC_START
echo 正在同步素材……
goto :EOF

:SYNC_FAIL
echo 素材同步失败！
goto :EOF

:COPY_FAIL
echo 复制失败： %~2
goto :EOF

:BUILD_SUCCESS
echo SHELL_Dev 构建成功完成！
goto :EOF
