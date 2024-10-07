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

package net.play5d.game.bvn.ui
{
	import flash.display.DisplayObject;

	public interface IGameUI
	{
		function setVolume(v:Number):void;
		function destory():void;
		function fadIn(animate:Boolean = true):void;
		function fadOut(animate:Boolean = true):void;
		function getUI():DisplayObject;
		function render():void;
		function renderAnimate():void;
		function showHits(hits:int , id:int):void;
		function hideHits(id:int):void;
		function showStart(finishBack:Function = null , params:Object = null):void;
		function showEnd(finishBack:Function = null , params:Object = null):void;
		function clearStartAndEnd():void;
		function pause():void;
		function resume():Boolean;
	}
}
