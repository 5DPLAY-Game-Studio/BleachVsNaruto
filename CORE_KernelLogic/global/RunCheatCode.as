/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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
import net.play5d.game.bvn.utils.CheatCodeManager;

/**
 * 注册键盘作弊码，成功输入后触发回调。
 *
 * <p>委托 <code>CheatCodeManager</code>。按键以 <code>|</code> 分隔，名称与
 * <code>KyoKeyCode</code> 的常量名一致，区分大小写。<code>STAGE</code> 尚未赋值、
 * 名称为空或对不上常量时返回 <code>null</code>。<code>code</code> 为 <code>null</code> 时会抛错。</p>
 *
 * @param code 按键序列，如 <code>'W|S|A|K'</code>。
 * @param success 触发成功时的回调。
 * @param isRunOnce 为 <code>true</code> 时只触发一次；默认 <code>false</code>。
 * @return 注销函数；注册失败时为 <code>null</code>。
 * @example
 * <listing version="3.0">
 * var remove:Function = RunCheatCode('W|W|S|S|A|D|A|D|B|A|B|A', function():void {
 *     trace('activated');
 * });
 * RunCheatCode('W|H|O', onWho, true);
 * if (remove != null) {
 *     remove();
 * }
 * </listing>
 * @see STAGE
 * @see net.play5d.game.bvn.utils.CheatCodeManager
 * @see net.play5d.kyo.input.KyoKeyCode
 */
public function RunCheatCode(code:String, success:Function, isRunOnce:Boolean = false):Function {
    return CheatCodeManager.I.register(code, success, isRunOnce);
}
}
