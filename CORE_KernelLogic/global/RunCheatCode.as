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
import flash.events.KeyboardEvent;

import net.play5d.kyo.input.KyoKeyCode;
import net.play5d.kyo.input.KyoKeyVO;

/**
 * 全局函数，作弊函数，按下指定组合键后可以执行自定义函数
 * <p/>
 * 下列代码演示如何使用全局方法 <code>RunCheatCode()</code> 执行作弊函数：
 * <listing version="3.0">
 RunCheatCode("W|W|S|S|A|D|A|D|B|A|B|A", function():void {
	 trace('作弊码1被激活');
});
 RunCheatCode("W|H|O|S|Y|O|U|R|D|A|D|D|Y", function():void {
	 trace('作弊码2被激活');
}, true);
 * </listing>
 *
 * @param         cheatCodeString 作弊字符串，每个定义的按键之间需要使用 “<b>|</b>” 分割
 * @param         success         成功回调
 * @param         isRunOnce       是否只允许输入一次
 *
 * @see           String
 * @see           Function
 * @see           Boolean
 *
 * @langversion   3.0
 * @playerversion Flash 9, Lite 4
 */
public function RunCheatCode(cheatCodeString:String, success:Function, isRunOnce:Boolean = false):void {
    if (!STAGE) {
        return;
    }

    // 作弊码分隔符
    const SEPARATOR:String = '|';
    var cheatCodeArray:Array;

    // 如果在作弊码字符串内没有找到分隔符 “|”
    // 则直接赋值给 cheatCodeArray
    if (cheatCodeString.indexOf(SEPARATOR) == -1) {
        cheatCodeArray = [cheatCodeString];
    }
    else {
        // 将字符串以分隔符 “|” 为分隔，分割成数组
        cheatCodeArray = cheatCodeString.split(SEPARATOR) as Array;
    }

    var cheatCode:Array = [];
    var len:int         = cheatCodeArray.length;

    // 提取作弊码
    for (var i:int = 0; i < len; i++) {
        var cheatCodeVarName:String = cheatCodeArray[i] as String;
        if (!cheatCodeVarName) {
            return;
        }

        if (!KyoKeyCode[cheatCodeVarName]) {
            return;
        }

        var cheatCodeVO:KyoKeyVO = KyoKeyCode[cheatCodeVarName] as KyoKeyVO;
        if (!cheatCodeVO) {
            return;
        }

        cheatCode.push(cheatCodeVO);
    }

    // 当前按键深度索引
    var keyIndex:int      = 0;
    // 是否成功执行
    var successes:Boolean = false;

    /**
     * 按键侦听事件
     * @param e 按键事件
     */
    function keyDownHandler(e:KeyboardEvent):void {
        // 如果运行成功并且只允许运行一次，返回
        if (successes && isRunOnce) {
            remove();
            return;
        }

        if (e.keyCode == cheatCode[keyIndex].code) {
            keyIndex++;

            if (keyIndex >= cheatCode.length) {
                // 如果只运行一次，运行完毕后解除侦听
                if (isRunOnce) {
                    remove();

                    // 如果要调用的函数已经失效
                    if (success == null) {
                        return;
                    }
                }

                keyIndex  = 0;
                successes = true;
                success();

                Printf('Cheat code {} is activated!', cheatCodeString);
            }

        }
        else {
            keyIndex = 0;
        }
    }

    /**
     * 移除按键侦听事件
     */
    function remove():void {
        STAGE.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
    }

    STAGE.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
}
}
