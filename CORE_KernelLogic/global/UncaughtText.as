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
import flash.events.ErrorEvent;
import flash.events.UncaughtErrorEvent;

/**
 * 取出未捕获错误的堆栈或文本。
 *
 * <p>不读取语言包。发行播放器里 <code>getStackTrace</code> 可能为空，此时退回 <code>toString</code>。</p>
 *
 * @param event 未捕获错误事件。
 * @return 堆栈或错误文本。
 * @example
 * <listing version="3.0">
 * var text:String = UncaughtText(event);
 * </listing>
 * @see flash.events.UncaughtErrorEvent
 */
public function UncaughtText(event:UncaughtErrorEvent):String {
    var error:Error = event.error as Error;
    if (error) {
        return error.getStackTrace() || error.toString();
    }

    var errorEvent:ErrorEvent = event.error as ErrorEvent;
    if (errorEvent) {
        return errorEvent.text;
    }

    return String(event.error);
}
}
