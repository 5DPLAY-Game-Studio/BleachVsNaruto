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
 * 全局作弊码注册函数
 *
 * <p>提供简便的作弊码注册接口，底层委托给 {@link CheatCodeManager} 处理。
 * 当玩家依次按下指定的按键组合时，触发对应的回调函数。</p>
 *
 * <p><b>设计目的：</b></p>
 * <ul>
 *   <li>提供向后兼容的 API，原有代码无需修改即可使用新的管理器</li>
 *   <li>简化调用方式，无需直接操作 CheatCodeManager 单例</li>
 *   <li>保留原有的函数签名，确保代码兼容性</li>
 * </ul>
 *
 * <p><b>使用示例：</b></p>
 * <pre>
 * // 注册一个可重复触发的作弊码
 * var removeCheat:Function = RunCheatCode("W|W|S|S|A|D|A|D|B|A|B|A", function():void {
 *     trace("Konami 作弊码激活！");
 * });
 *
 * // 注册一个单次触发的作弊码
 * RunCheatCode("W|H|O|S|Y|O|U|R|D|A|D|D|Y", function():void {
 *     trace("爸爸作弊码激活！");
 * }, true);
 *
 * // 注销作弊码（如果不再需要）
 * removeCheat();
 * </pre>
 *
 * <p><b>按键格式说明：</b></p>
 * <ul>
 *   <li>按键之间使用竖线 <code>|</code> 分隔</li>
 *   <li>按键名称应与 <code>KyoKeyCode</code> 中定义的常量一致</li>
 *   <li>不区分大小写</li>
 * </ul>
 *
 * <p><b>注意事项：</b></p>
 * <ul>
 *   <li>该函数必须在 STAGE 初始化完成后调用，否则注册会失败并返回 null</li>
 *   <li>建议在游戏主界面初始化完成后注册作弊码</li>
 *   <li>回调函数中应避免执行耗时操作，以免影响游戏性能</li>
 * </ul>
 *
 * @param code 作弊字符串，格式为 "按键1|按键2|按键3..."，例如 "W|S|A|K"
 * @param success 成功触发作弊码时调用的回调函数
 * @param isRunOnce 是否只允许输入一次。默认为 false，设为 true 时作弊码只会触发一次
 * @return 注销函数。调用此函数可移除该作弊码的监听。
 *         如果注册失败（如 STAGE 不可用或按键名称无效），返回 null
 *
 * @see CheatCodeManager
 * @see net.play5d.kyo.input.KyoKeyCode
 *
 * @langversion 3.0
 * @playerversion Flash 9, Lite 4
 */
public function RunCheatCode(code:String, success:Function, isRunOnce:Boolean = false):Function {
    return CheatCodeManager.I.register(code, success, isRunOnce);
}
}
