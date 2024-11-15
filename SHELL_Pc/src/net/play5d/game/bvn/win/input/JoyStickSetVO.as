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

package net.play5d.game.bvn.win.input {
public class JoyStickSetVO {
    public function JoyStickSetVO(id:int, value:Number = 1) {
        this.id    = id;
        this.value = value;
    }
    public var id:int;

//		public function get ID():String{
//			return id+'_'+value;
//		}
    public var value:Number = 0;

    public function readObj(o:Object):void {
        this.id    = o.id;
        this.value = o.value;
    }

    public function toObj():Object {
        var o:Object = {};
        o.id         = this.id;
        o.value      = this.value;
        return o;
    }

}
}
