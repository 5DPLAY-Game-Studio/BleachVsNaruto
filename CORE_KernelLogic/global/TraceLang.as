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
 * 按调试级别输出一条跟踪文案。
 *
 * <p>等价于 <code>LogLang(GameLogger.DEBUG, 'trace', event, params)</code>。
 * 语言包键为 <code>log.debug.trace.{event}</code>。</p>
 *
 * @param event 事件路径，如 <code>game_ctrl.current_mode</code>。
 * @param params 占位符名到替换值的映射；可为 <code>null</code>。
 * @example
 * <listing version="3.0">
 * TraceLang('game_ctrl.time_over');
 * TraceLang('game_ctrl.current_mode', {mode: GameMode.currentMode});
 * </listing>
 * @see LogLang
 * @see net.play5d.game.bvn.utils.GameLogger#debug()
 */
public function TraceLang(event:String, params:Object = null):void {
    LogLang(GameLogger.DEBUG, 'trace', event, params);
}
}
