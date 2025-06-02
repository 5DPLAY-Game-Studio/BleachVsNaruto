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
	echo 标签为空！
	goto :EOF
)

goto %1

:NOT_EXIST
echo 文件不存在：%~2
goto :EOF

:SYNC_SUCCESS
echo 同步素材成功！
goto :EOF

:DEL_DIR_SUCCESS
echo 删除目录成功：%~2
goto :EOF

:DEL_DIR_FAIL
echo 删除目录失败：%~2
goto :EOF

:COPY_DIR_SUCCESS
echo 复制目录成功：%~2
goto :EOF

:COPY_DIR_FAIL
echo 复制目录失败：%~2
goto :EOF

