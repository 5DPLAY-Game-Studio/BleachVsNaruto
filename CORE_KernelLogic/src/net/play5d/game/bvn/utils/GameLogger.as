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

package net.play5d.game.bvn.utils {
import net.play5d.game.bvn.interfaces.ILogger;

/**
 * 游戏日志门面：按级别过滤并格式化后交给 <code>ILogger</code>，未注入时 <code>trace</code>。
 *
 * <p>行格式为 <code>HH:mm:ss.mmm LEVEL [category] message</code>。
 * 数值更小的级别更严重，仅输出小于等于 <code>threshold</code> 的级别。
 * <code>log</code> 等价于级别 <code>INFO</code>、分类 <code>sys</code>。</p>
 *
 * @example
 * <listing version="3.0">
 * GameLogger.info('load', 'init ok');
 * GameLogger.log('init...');
 * </listing>
 * @see #threshold
 * @see #log()
 * @see #info()
 * @see net.play5d.game.bvn.interfaces.ILogger
 */
public class GameLogger {

    /** 错误。 */
    public static const ERROR:int = 1;
    /** 警告。 */
    public static const WARN:int  = 2;
    /** 一般信息。发行包的自动阈值。 */
    public static const INFO:int  = 3;
    /** 调试。调试环境下的自动阈值。 */
    public static const DEBUG:int = 4;

    /** @private */
    private static var _loger:ILogger;
    /** @private 负值表示按调试环境自动选择阈值 */
    private static var _threshold:int = -1;

    /**
     * 设置日志实现。
     *
     * <p>未注入或传入 <code>null</code> 时改为 <code>trace</code>。</p>
     *
     * @param v <code>ILogger</code>，或 <code>null</code> 清除。
     * @example
     * <listing version="3.0">
     * GameLogger.setLoger(logger);
     * </listing>
     * @see net.play5d.game.bvn.interfaces.ILogger
     */
    public static function setLoger(v:Object):void {
        _loger = v as ILogger;
    }

    /**
     * 当前输出阈值。
     *
     * <p>未手动设置时，<code>IsDebugger()</code> 为真则取 <code>DEBUG</code>，否则取 <code>INFO</code>。
     * 传入负数可恢复自动选择。</p>
     *
     * @return 当前阈值。
     * @example
     * <listing version="3.0">
     * GameLogger.threshold = GameLogger.DEBUG;
     * </listing>
     * @see #DEBUG
     * @see #INFO
     * @see IsDebugger
     * @see net.play5d.game.bvn.GameConfig#DEBUG_MODE
     */
    public static function get threshold():int {
        if (_threshold < 0) {
            return IsDebugger() ? DEBUG : INFO;
        }

        return _threshold;
    }

    /** @private */
    public static function set threshold(level:int):void {
        _threshold = level;
    }

    /**
     * 记录错误。
     *
     * @param category 分类；空串时记为 <code>sys</code>。
     * @param message 正文。
     * @example
     * <listing version="3.0">
     * GameLogger.error('load', 'init fail');
     * </listing>
     * @see #ERROR
     */
    public static function error(category:String, message:String):void {
        write(ERROR, category, message);
    }

    /**
     * 记录警告。
     *
     * @param category 分类；空串时记为 <code>sys</code>。
     * @param message 正文。
     * @example
     * <listing version="3.0">
     * GameLogger.warn('asset', 'retry load');
     * </listing>
     * @see #WARN
     */
    public static function warn(category:String, message:String):void {
        write(WARN, category, message);
    }

    /**
     * 记录一般信息。
     *
     * @param category 分类；空串时记为 <code>sys</code>。
     * @param message 正文。
     * @example
     * <listing version="3.0">
     * GameLogger.info('load', 'init ok');
     * </listing>
     * @see #INFO
     */
    public static function info(category:String, message:String):void {
        write(INFO, category, message);
    }

    /**
     * 记录调试信息。
     *
     * @param category 分类；空串时记为 <code>sys</code>。
     * @param message 正文。
     * @example
     * <listing version="3.0">
     * GameLogger.debug('fight', 'round start');
     * </listing>
     * @see #DEBUG
     */
    public static function debug(category:String, message:String):void {
        write(DEBUG, category, message);
    }

    /**
     * 记录一条 <code>INFO</code> 日志，分类为 <code>sys</code>。
     *
     * @param v 正文。
     * @example
     * <listing version="3.0">
     * GameLogger.log('init...');
     * </listing>
     * @see #info()
     */
    public static function log(v:String):void {
        write(INFO, 'sys', v);
    }

    /** @private */
    private static function write(level:int, category:String, message:String):void {
        if (level > threshold) {
            return;
        }

        if (!category) {
            category = 'sys';
        }

        var line:String = formatLine(level, category, message);
        if (_loger) {
            _loger.log(line);
        }
        else {
            trace(line);
        }
    }

    /** @private */
    private static function formatLine(level:int, category:String, message:String):String {
        var now:Date     = new Date();
        var clock:String = pad2(now.hours) + ':' + pad2(now.minutes) + ':' + pad2(now.seconds)
                + '.' + pad3(now.milliseconds);

        return clock + ' ' + levelName(level) + ' [' + category + '] ' + message;
    }

    /** @private */
    private static function levelName(level:int):String {
        switch (level) {
        case ERROR:
            return 'ERROR';
        case WARN:
            return 'WARN';
        case INFO:
            return 'INFO';
        case DEBUG:
            return 'DEBUG';
        default:
            return String(level);
        }
    }

    /** @private */
    private static function pad2(value:int):String {
        if (value < 10) {
            return '0' + value;
        }

        return String(value);
    }

    /** @private */
    private static function pad3(value:int):String {
        if (value < 10) {
            return '00' + value;
        }
        if (value < 100) {
            return '0' + value;
        }

        return String(value);
    }

}
}
