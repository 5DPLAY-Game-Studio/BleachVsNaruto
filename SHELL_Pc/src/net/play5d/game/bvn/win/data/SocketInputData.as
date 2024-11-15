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

package net.play5d.game.bvn.win.data {

public class SocketInputData {

    public function SocketInputData() {
    }
    public var up:Boolean;
    public var down:Boolean;
    public var left:Boolean;
    public var right:Boolean;
    public var attack:Boolean;
    public var jump:Boolean;
    public var dash:Boolean;
    public var skill:Boolean;
    public var superSkill:Boolean;
    public var special:Boolean;

//		public static function isInputMsg(msg:String):Boolean{
//			return msg.substr(0,6) == "INPUT|";
//		}

    public function clear():void {
        up    = false;
        down  = false;
        left  = false;
        right = false;

        attack     = false;
        jump       = false;
        dash       = false;
        skill      = false;
        superSkill = false;
        special    = false;
    }

//		public static function getMSG():String{
//			var vs:Array = [
//				GameInputer.down();
//
//			];
//			return vs.join(",");
//		}

}
}
