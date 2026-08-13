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

package net.play5d.game.bvn.interfaces {

/**
 * 日志记录器注入契约。
 *
 * <p>由入口注入实现，供玩法侧经统一入口输出诊断信息。</p>
 */
public interface ILogger {

    /**
     * 记录日志。
     *
     * @param msg 日志内容。
     * @example
     * <listing version="3.0">
     * logger.log('select fighter ready');
     * </listing>
     */
    function log(msg:String):void;
}
}
