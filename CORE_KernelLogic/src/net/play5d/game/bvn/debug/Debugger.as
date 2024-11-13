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

package net.play5d.game.bvn.debug
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import net.play5d.kyo.input.KyoKeyCode;

	public class Debugger
	{
		include "_INCLUDE_.as";

		public static var onErrorMsgCall:Function;
		public static const DRAW_AREA:Boolean = false;
		public static const SAFE_MODE:Boolean = false;
		public static const DEBUG_ENABLED:Boolean = false;

		public static const HIDE_MAP:Boolean = false;
		public static const HIDE_HITEFFECT:Boolean = false;

		public function Debugger()
		{
		}

		public static function log(...params):void{
			trace.call(null,params);
		}

		public static function errorMsg(msg:String):void{
			trace('Debugger.errorMsg:',msg);
			if(onErrorMsgCall != null) onErrorMsgCall(msg);
		}


		private static var _stage:Stage;
		public static function initDebug(stage:Stage):void{
			_stage = stage;
			showFPS();
		}

		public static function addChild(d:DisplayObject):void{
			_stage.addChild(d);
		}

		public static function showFPS():void{

			var currentTime:int = 0;
			var n:int = 0;
			var fpsCount:int;
			var fpsText:TextField;

			fpsText = new TextField();
			fpsText.textColor = 0xffff00;
			fpsText.mouseEnabled = false;
			_stage.addChild(fpsText);
			_stage.addEventListener(Event.ENTER_FRAME,countFPS);

			var fpsTimer:Timer = new Timer(1000,0);
			fpsTimer.addEventListener(TimerEvent.TIMER,updateFPS);
			fpsTimer.start();

			function countFPS(e:Event):void{
				fpsCount++;
			}

			function updateFPS(e:TimerEvent):void{
				fpsText.text = 'fps:'+fpsCount;
				fpsCount = 0;
			}

		}

		public static function runScriect(stage:Stage , success:Function):void{
			var _scriect:Array = [KyoKeyCode.P,KyoKeyCode.L,KyoKeyCode.A,KyoKeyCode.Y];
			var _keyIndex:int;
			var _successed:Boolean;

			stage.addEventListener(KeyboardEvent.KEY_DOWN,function(e:KeyboardEvent):void{

				if(_successed) return;

				if(e.keyCode == _scriect[_keyIndex].code){
					_keyIndex++;

					if(_keyIndex >= _scriect.length){
						_successed = true;
						success();
					}

				}else{
					_keyIndex = 0;
				}

			},false,0,true);


		}


	}
}
