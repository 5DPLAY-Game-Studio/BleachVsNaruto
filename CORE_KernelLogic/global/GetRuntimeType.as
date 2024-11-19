/*
 * Copyright (C) 2021-2024, 5DPLAY Game Studio
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package {
import flash.system.Capabilities;

/**
 * 全局函数，获取运行时类型详细数据
 * <p/>
 * 下列代码演示如何使用全局方法 <code>GetRuntimeType()</code> 获取运行时详细数据：
 * <listing version="3.0">
 var type:Object = GetRuntimeType();
 trace("平台          ：" + type.platform);
 trace("主版本号      ：" + type.majorVersion);
 trace("次版本号      ：" + type.minorVersion);
 trace("生成版本号    ：" + type.buildNumber);
 trace("内部生成版本号：" + type.internalBuildNumber);
 * </listing>
 *
 * @see           Object
 * @return        Objetct，包含如下属性：<br/>
 * <ul>
 * <li>platform            平台，返回如下字符串：
 *   <ul>
 *   <li>WIN - Windows平台</li>
 *   <li>MAC - MacOS平台</li>
 *   <li>LNX - Linux平台</li>
 *   <li>AND - Android平台</li>
 *   </ul>
 * </li>
 * <li>majorVersion        主版本号</li>
 * <li>minorVersion        次版本号</li>
 * <li>buildNumber         生成版本号</li>
 * <li>internalBuildNumber 内部生成版本号</li>
 * </ul>
 *
 * @langversion   3.0
 * @playerversion Flash 9, Lite 4
 */
public function GetRuntimeType():Object {
    // 版本正则表达式
    var reg:RegExp = /^(\w*) (\d*),(\d*),(\d*),(\d*)$/;

    // 按照正则表达式规则取出数据并存入数组
    var tmp:Array = reg.exec(Capabilities.version) as Array;
    if (!tmp) {
        return null;
    }

    // 赋值
    var obj:Object          = {};
    obj.platform            = tmp[1];
    obj.majorVersion        = tmp[2];
    obj.minorVersion        = tmp[3];
    obj.buildNumber         = tmp[4];
    obj.internalBuildNumber = tmp[5];

    return obj;
}
}
