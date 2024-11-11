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

package net.play5d.kyo.display.ui.ppt {
import flash.events.Event;

public class PicPointerEvent extends Event {
    public static const CHANGE_START:String  = 'CHANGE_START';
    public static const CHANGE_FINISH:String = 'CHANGE_FINISH';
    public static const MOUSE_UP:String      = 'MOUSE_UP';

    public static const LOAD_PROCESS:String  = 'LOAD_PROCESS';
    public static const LOAD_COMPLETE:String = 'LOAD_COMPLETE';

    public function PicPointerEvent(type:String, data:Object = null) {
        super(type, false, false);
        this.data = data;
    }

    public var data:Object;
}
}
