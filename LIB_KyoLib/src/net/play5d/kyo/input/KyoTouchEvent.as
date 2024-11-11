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

package net.play5d.kyo.input {
import flash.events.Event;

public class KyoTouchEvent extends Event {
    public static const SLIDE:String = 'event-slide';

    public static const DIRECT_UP:int    = 0;
    public static const DIRECT_DOWN:int  = 6;
    public static const DIRECT_LEFT:int  = 9;
    public static const DIRECT_RIGHT:int = 3;

    public function KyoTouchEvent(type:String, obj:Object = null) {
        for (var i:String in obj) {
            this[i] = obj[i];
        }
        super(type, false, false);
    }

    public var direct:int;
}
}
