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

package net.play5d.game.bvn.utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.ColorTransform;
	import flash.utils.Dictionary;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.kyo.utils.KyoUtils;

	public class BtnUtils
	{
		include '../../../../../../include/_INCLUDE_.as';

		private static var _btnMap:Dictionary = new Dictionary();


		public static function btnMode(btn:Sprite, buttonMode:Boolean = true, mouseChildren:Boolean = false):void{
			if(!btn) return;

			btn.buttonMode = buttonMode;
			btn.mouseChildren = mouseChildren;
		}

		public static function initBtn(btn:DisplayObject, handler:Function, target:* = null):void{
			if(!btn) return;

			target ||= btn;

			_btnMap[btn] = { handler: handler, target: target, transform: KyoUtils.cloneColorTransform(btn.transform.colorTransform)};

			if(GameConfig.TOUCH_MODE){
				btn.addEventListener(TouchEvent.TOUCH_END, touchHandler);
			}else{
				btn.addEventListener(MouseEvent.MOUSE_OVER, btnHandler);
				btn.addEventListener(MouseEvent.MOUSE_OUT, btnHandler);
				btn.addEventListener(MouseEvent.CLICK, btnHandler);
			}

		}

		private static function btnHandler(e:MouseEvent):void{
			var btn:DisplayObject = e.currentTarget as DisplayObject;

			switch(e.type){
				case MouseEvent.CLICK:
					applyBtnFunc(btn);
					break;
				case MouseEvent.MOUSE_OVER:
					overEffect(btn, true);
					break;
				case MouseEvent.MOUSE_OUT:
					overEffect(btn, false);
					break;
			}
		}

		private static function touchHandler(e:TouchEvent):void{
			var btn:DisplayObject = e.currentTarget as DisplayObject;

			switch(e.type){
				case TouchEvent.TOUCH_END:
					applyBtnFunc(btn);
					break;
			}
		}

		private static function overEffect(btn:DisplayObject, v:Boolean):void{
			var obj:Object = _btnMap[btn];
			var orgCT:ColorTransform = obj.transform;

			if(v){
				var ct:ColorTransform = KyoUtils.cloneColorTransform(orgCT);
				ct.redOffset += 30;
				ct.greenOffset += 30;
				ct.blueOffset += 30;
				btn.transform.colorTransform = ct;
				SoundCtrl.I.sndSelect();
			}else{
				btn.transform.colorTransform = orgCT;
			}
		}

		private static function applyBtnFunc(btn:DisplayObject):void{
			var o:Object = _btnMap[btn];
			if(!o || !o.handler) return;

			SoundCtrl.I.sndConfrim();
			o.handler(o.target);
		}

		public static function destoryBtn(btn:DisplayObject):void{
			if(!btn) return;

			btn.removeEventListener(TouchEvent.TOUCH_END, touchHandler);

			btn.removeEventListener(MouseEvent.MOUSE_OVER, btnHandler);
			btn.removeEventListener(MouseEvent.MOUSE_OUT, btnHandler);
			btn.removeEventListener(MouseEvent.CLICK, btnHandler);

			delete _btnMap[btn];

		}

	}
}
