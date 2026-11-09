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
 * 按 <code>GameLogger</code> 的级别和分类取语言包文案并输出。
 *
 * <p>键为 <code>log.{级别}.{分类}.{事件}</code>。级别名与
 * <code>ERROR</code> / <code>WARN</code> / <code>INFO</code> / <code>DEBUG</code> 对应，
 * 分类与本次 <code>GameLogger</code> 调用相同。
 * 级别高于当前阈值时不取文案、不输出。
 * 不是 <code>ERROR</code> / <code>WARN</code> / <code>INFO</code> / <code>DEBUG</code> 时，文案键和输出都按 debug 处理。
 * 分类为空时，语言键里会留下空的一段，例如 <code>log.debug..事件</code>；<code>GameLogger</code> 输出时才把分类写成 <code>sys</code>。
 * 取文案失败或得到 <code>[N/A]</code> 时改为输出完整键。</p>
 *
 * @param level <code>GameLogger</code> 级别常量。
 * @param category 分类；空串时由 <code>GameLogger</code> 记为 <code>sys</code>。
 * @param event 事件路径，如 <code>game_ctrl.time_over</code>。
 * @param params 占位符名到替换值的映射；可为 <code>null</code>。
 * @example
 * <listing version="3.0">
 * LogLang(GameLogger.DEBUG, 'trace', 'game_ctrl.time_over');
 * LogLang(GameLogger.ERROR, 'load', 'game_stage_load_ctrl.get_map_data_fail');
 * </listing>
 * @see TraceLang
 * @see GetLang
 * @see net.play5d.game.bvn.utils.GameLogger
 */
public function LogLang(level:int, category:String, event:String, params:Object = null):void {
    if (level > GameLogger.threshold) {
        return;
    }

    var rank:String;
    switch (level) {
    case GameLogger.ERROR:
        rank = 'error';
        break;
    case GameLogger.WARN:
        rank = 'warn';
        break;
    case GameLogger.INFO:
        rank = 'info';
        break;
    default:
        rank = 'debug';
        break;
    }

    var key:String = 'log.' + rank + '.' + category + '.' + event;
    var text:String;
    try {
        text = GetLang(key, params);
    }
    catch (error:Error) {
        text = key;
    }
    if (!text || text == '[N/A]') {
        text = key;
    }

    switch (level) {
    case GameLogger.ERROR:
        GameLogger.error(category, text);
        break;
    case GameLogger.WARN:
        GameLogger.warn(category, text);
        break;
    case GameLogger.INFO:
        GameLogger.info(category, text);
        break;
    default:
        GameLogger.debug(category, text);
        break;
    }
}
}
