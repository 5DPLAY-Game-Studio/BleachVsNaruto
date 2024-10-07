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

package net.play5d.game.bvn.fighter.events
{
	import flash.events.EventDispatcher;

	import net.play5d.game.bvn.interfaces.BaseGameSprite;

	public class FighterEventDispatcher
	{
		private static var _dispatcher:EventDispatcher = new EventDispatcher();

		private static var _addedEvents:Object = {};

		public static function hasEventListener(type:String):Boolean{
			return _addedEvents[type] != null;
		}

		public static function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void{
			_addedEvents[type] = listener;
			_dispatcher.addEventListener(type,listener,useCapture,priority,useWeakReference);
		}

		public static function removeEventListener(type:String,listener:Function,useCapture:Boolean=false):void{
			delete _addedEvents[type];
			_dispatcher.removeEventListener(type,listener,useCapture);
		}

		public static function removeAllListeners():void{
			for(var i:String in _addedEvents){
				_dispatcher.removeEventListener(i,_addedEvents[i]);
			}
			_addedEvents = {};
		}

		public static function dispatchEvent(fighter:BaseGameSprite , event:String , params:Object = null):void{
			var fv:FighterEvent = new FighterEvent(event,false,false);
			fv.fighter = fighter;
			fv.params = params;
			_dispatcher.dispatchEvent(fv);
		}

	}
}
