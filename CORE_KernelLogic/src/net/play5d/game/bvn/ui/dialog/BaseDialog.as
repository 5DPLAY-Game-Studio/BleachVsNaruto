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

package net.play5d.game.bvn.ui.dialog
{
	import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
	import flash.display.Sprite;

	import net.play5d.game.bvn.ctrl.AssetManager;
import net.play5d.game.bvn.ui.Text;
	import net.play5d.game.bvn.utils.BtnUtils;
	import net.play5d.kyo.display.bitmap.BitmapFontText;

	public class BaseDialog
	{
		include "_INCLUDE_.as";

		protected var _backBtn:SimpleButton;
		protected var _dialogUI:Sprite;

		private var _titleTxt:BitmapFontText;

		public var offsetX:Number = 0;
		public var offsetY:Number = 0;

		public var width:Number = 0;
		public var height:Number = 0;

		protected var _cnTxt:Text;
//		protected var _ui:Sprite;

		public var yesBack:Function;
		public var noBack:Function;

		protected var _noBtn:SimpleButton;
		protected var _yesBtn:SimpleButton;

		public function BaseDialog()
		{
			super();
		}

		public function getDisplay():DisplayObject{
			return _dialogUI;
		}

		public final function init():void{
			_backBtn = _dialogUI.getChildByName("back") as SimpleButton;

			BtnUtils.initBtn(_backBtn, closeSelf);
		}

		public final function show(X:Number, Y:Number):void{
			_dialogUI.x = X + offsetX;
			_dialogUI.y = Y + offsetY;
			onShow();
		}

		public function setTitle(v:String):void{
			if(!v) return;

			if(!_titleTxt){
				_titleTxt = new BitmapFontText(AssetManager.I.getFont('font1'));
				_titleTxt.y = -10;
				_dialogUI.addChild(_titleTxt);
			}

			_titleTxt.text = v;
			_titleTxt.x = (width - _titleTxt.width) / 2;
		}

		public final function close():void{
			onClose();
		}

		public final function closeSelf(...params):void{
			DialogManager.closeDialog(this);
		}

		public final function destory():void{
			if(_titleTxt){
				_titleTxt.dispose();
				_titleTxt = null;
			}

			onDestory();
		}

		public final function hide():void{
			_dialogUI.visible = false;
			onHide();
		}

		public final function hiding():Boolean{
			return !_dialogUI.visible;
		}

		public final function resume():void{
			_dialogUI.visible = true;
			onResume();
		}

		protected function onShow():void{

		}

		protected function onHide():void{

		}

		protected function onResume():void{

		}

		protected function onClose():void{

		}

		protected function onDestory():void{

		}

		public function setMsg(en:String = null, cn:String = null):void {
		}

	}
}
