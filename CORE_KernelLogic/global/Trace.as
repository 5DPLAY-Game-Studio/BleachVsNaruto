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
 * 按调试级别输出带多语言前缀的字符串。
 *
 * <p><code>params</code> 非 <code>null</code> 时先 <code>Format</code>。
 * 格式化失败时退回原文。
 * 经 <code>GameLogger.debug</code> 输出，分类为 <code>trace</code>。
 * 当前阈值低于 <code>DEBUG</code> 时不输出。
 * 需要翻译的跟踪用 <code>TraceLang</code>。</p>
 *
 * @param message 消息模板或已格式化的完整消息。
 * @param params 占位符参数；可为 <code>null</code>。
 * @example
 * <listing version="3.0">
 * Trace('今天是星期{weekday}，天气：{weather}', {weekday: 1, weather: '晴'});
 * // 调试阈值下形如："12:00:00.000 DEBUG [trace] 今天是星期1，天气：晴"
 * </listing>
 * @see Format
 * @see TraceLang
 * @see GetLangText
 * @see net.play5d.game.bvn.utils.GameLogger#debug()
 */
public function Trace(message:String, params:Object = null):void {
    if (GameLogger.threshold < GameLogger.DEBUG) {
        return;
    }

    var text:String = message;
    if (params != null) {
        try {
            text = Format(message, params);
        }
        catch (error:Error) {
            text = message;
        }
    }

    GameLogger.debug('trace', text);
}
}
