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
import net.play5d.game.bvn.utils.GameLogger;

/**
 * 按语言包路径取文案（可带命名占位符），再按调试级别输出。
 *
 * <p>语言包可用时等价于 <code>Trace(GetLang(tree, params))</code>。
 * 取文案失败或得到 <code>[N/A]</code> 时改为输出路径本身。
 * 当前阈值低于 <code>DEBUG</code> 时不输出。</p>
 *
 * @param tree 点分树形路径。
 * @param params 占位符名到替换值的映射；可为 <code>null</code>。
 * @example
 * <listing version="3.0">
 * TraceLang('debug.trace.prefix');
 * TraceLang('debug.trace.data.game_ctrl.current_mode', {mode: GameMode.currentMode});
 * </listing>
 * @see GetLang
 * @see Trace
 * @see net.play5d.game.bvn.utils.GameLogger#debug()
 */
public function TraceLang(tree:String, params:Object = null):void {
    if (GameLogger.threshold < GameLogger.DEBUG) {
        return;
    }

    var text:String;
    try {
        text = GetLang(tree, params);
    }
    catch (error:Error) {
        text = tree;
    }
    if (!text || text == '[N/A]') {
        text = tree;
    }

    Trace(text);
}
}
