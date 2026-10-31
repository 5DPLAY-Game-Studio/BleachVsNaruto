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
echo 文件不存在：!LANG_PARAM!
goto :EOF

:UNDEFINE
echo 环境变量 !LANG_PARAM! 未定义！
goto :EOF

:TITLE
title Apache fdb（Flash Player 调试器）
goto :EOF

:TITLE_ADB
title Apache fdb（Flash Player 调试器） - [!LANG_PARAM!]
goto :EOF

:NO_DEVICE
echo 未检测到设备连接...
goto :EOF

:NO_CMD
echo 未找到 !LANG_PARAM! 命令！
goto :EOF

:CONNECT
echo 已连接设备：[!LANG_PARAM!]
goto :EOF

:NOT_INSTALLED
echo 应用 [!LANG_PARAM!] 未安装！
goto :EOF

:INSTALLING
echo 正在安装应用 [!LANG_PARAM!] ...
goto :EOF

:INSTALL_FAIL
echo 应用安装失败：[!LANG_PARAM!]
goto :EOF

:START_MSG
echo 正在启动 Flash 调试器...
goto :EOF

:END_MSG
echo 调试会话已完成。
goto :EOF
