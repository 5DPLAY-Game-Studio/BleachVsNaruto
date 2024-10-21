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

/**
 * 全局函数，抛出一个错误
 * <p/>
 * 下列代码演示如何使用全局方法 <code>ThrowError()</code> 抛出错误：
 * <listing version="3.0">
 ThrowError(Error, "测试错误1");
 ThrowError(new ArgumentError(), "测试错误2");
 * </listing>
 *
 * @param         errorParam  错误参数，可以为 Error <b>类</b>或其<b>实例</b>
 * @param         message     错误信息
 * @param         isThrow     是否抛出该错误
 *
 * @see           Object
 * @see           String
 * @see           Boolean
 *
 * @throws        Error
 *
 * @langversion   3.0
 * @playerversion Flash 9, Lite 4
 */
public function ThrowError(errorParam:*, message:String = '', isThrow:Boolean = true):void {
    // 错误参数不存在则返回
    if (!errorParam) {
        Printf('Error parameter is invalid');
        return;
    }

    // 错误参数如果存在判断是否是 Error 类实例
    var error:Error = errorParam is Error ? errorParam : null;
    // 不是 Error 类实例则接着判断
    if (!error) {
        var instance:*     = null;
        // 判断错误参数是否是 Class 类型
        var errorCls:Class = errorParam is Class ? errorParam : null;
        try {
            // 如果 errorCls 类不存在或者不是 Error 类型，返回
            // 同时将实例化好的 errorCls 类赋给 instance
            if (!errorCls || !(
                    (
                            instance = new errorCls()
                    ) is Error
            )) {
                Printf('Error class is not instantiated or is of wrong type');
                return;
            }
        }
        catch (e:Error) {
            // 出现错误，一般是 errorCls 类不可以被实例化的情况
            // 递归调用自身继续抛出
            ThrowError(e, 'Failed to throw Error');
            return;
        }

        // 以上步骤都没问题则将 instance 赋给 error
        error = instance as Error;
    }

    error.message = message;
    // 打印错误栈
    Printf(error.getStackTrace());

    // 如果是调试版并且允许抛出则抛出错误
    if (IsDebugger() && isThrow) {
        throw error;
    }
}
}
