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
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;

	import fl.motion.ColorMatrix;

	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.kyo.display.bitmap.BitmapFontText;
	import net.play5d.kyo.input.KyoKeyCode;

	public class KeyMapping{
		public var name:String;
		public var mc:Sprite;
		public var keyId:String;
		public var cn:String;

		private var _keyTxt:BitmapFontText;

		public function KeyMapping(mc:Sprite , keyId:String , name:String , cn:String){
			this.mc = mc;
			this.keyId = keyId;
			this.name = name;
			this.cn = cn;

			_keyTxt = new BitmapFontText(AssetManager.I.getFont('font1'));

			var matrix:ColorMatrix = new ColorMatrix();
			matrix.SetBrightnessMatrix(-100);
			matrix.SetSaturationMatrix(0);
			_keyTxt.filters = [new ColorMatrixFilter(matrix.GetFlatArray())];

			mc.addChild(_keyTxt);
		}

		public function setKey(code:int , keyName:String = null):void{
			keyName ||= KyoKeyCode.code2name(code);
			_keyTxt.text = keyName.toUpperCase();

			var _maxWidth:Number = 0;
			var _scale:Number = 1;
			var offsetY:Number = 0;

			if(keyId == 'up' || keyId == 'down' || keyId == 'left' || keyId == 'right'){
				_scale = 0.8;
				_maxWidth = 40;
				offsetY = 5;
			}else{
				_maxWidth = 60;
			}

			if(_keyTxt.width > _maxWidth){
				_keyTxt.width = _maxWidth;
				_keyTxt.scaleY = _keyTxt.scaleX;
			}else{
				_keyTxt.scaleX = _keyTxt.scaleY = _scale;
			}

			_keyTxt.x = -_keyTxt.width/2;
			_keyTxt.y = -_keyTxt.height/2 + offsetY;
		}

	}
}
