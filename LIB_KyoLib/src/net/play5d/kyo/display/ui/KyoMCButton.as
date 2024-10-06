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

package net.play5d.kyo.display.ui
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;

	public class KyoMCButton extends EventDispatcher implements IKyoButton
	{
		public var mc:MovieClip;
		private var _selectFrame:Object;
		private var _nornalFrame:Object;
		private var _overFrame:Object;
		private var _unenabledFrame:Object;

		public function KyoMCButton(mc:MovieClip , nornalFrame:Object = 1 , selectFrame:Object = null , overFrame:Object = null , unenabledFrame:Object = null)
		{
			this.mc = mc;
			mc.addEventListener(MouseEvent.CLICK,handler);
			mc.addEventListener(MouseEvent.MOUSE_DOWN,handler);
			mc.addEventListener(MouseEvent.MOUSE_UP,handler);
			_nornalFrame = nornalFrame;
			_selectFrame = selectFrame;
			_overFrame = overFrame;
			_unenabledFrame = unenabledFrame;

			goFrame(_nornalFrame);
		}

		public function set focus(v:Boolean):void{
			if(v){
				goFrame(_selectFrame);
			}else{
				goFrame(_nornalFrame);
			}
		}

		public function set enabled(v:Boolean):void{
			mc.mouseEnabled = v;
			if(v){
				goFrame(_nornalFrame);
			}else{
				goFrame(_unenabledFrame);
			}
		}

		private function goFrame(frame:Object):void{
			if(frame) mc.gotoAndStop(frame);
		}

		private function handler(e:Event):void{
			dispatchEvent(e);
		}

	}
}
