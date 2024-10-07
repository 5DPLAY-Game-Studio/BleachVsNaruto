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

package net.play5d.game.bvn.input
{
	import flash.display.Stage;

	public interface IGameInput
	{
		function initlize(stage:Stage):void;
		function setConfig(config:Object):void;

		function get enabled():Boolean;
		function set enabled(v:Boolean):void;

		function focus():void;

		function anyKey():Boolean;

		function back():Boolean;
		function select():Boolean;

		function up():Boolean;
		function down():Boolean;
		function left():Boolean;
		function right():Boolean;

		function attack():Boolean;
		function jump():Boolean;
		function dash():Boolean;
		function skill():Boolean;
		function superSkill():Boolean;
		function special():Boolean;

		function wankai():Boolean;

//		function isDown(code:Object):Boolean;
//		function isJustDown(code:Object):Boolean;

		function clear():void;

//		function listen(func:Function):void;
//		function unListen(func:Function):void;
	}
}
