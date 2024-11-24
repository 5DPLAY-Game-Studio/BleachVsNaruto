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
	import flash.events.Event;

	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.events.SetBtnEvent;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.display.bitmap.BitmapFontText;

	public class SetBtn extends Sprite
	{
		include '../../../../../../include/_INCLUDE_.as';

		public var optionKey:String;
		public var onSelect:Function;

		private var _label:BitmapFontText;
		private var _options:Array;
		private var _optionIndex:int;

		private var _optionTxt:BitmapFontText;

		private var _prevArrow:txt_arrow_mc;
		private var _nextArrow:txt_arrow_mc;

		private var _line:SetBtnLine;

		private var _cn:String;

		public function get label():String{
			return _label.text;
		}

		public function SetBtn(label:String , cn:String)
		{
			super();

			this.buttonMode = true;
//			this.mouseChildren = false;

			_label = new BitmapFontText(AssetManager.I.getFont('font1'));
			_label.text = label;

			_cn = cn;

			_line = new SetBtnLine();
			_line.y = _label.height;
			_line.hide();
			addChild(_line);


			addChild(_label);

		}

		public function destory():void{
			if(_label){
				_label.dispose();
			}
		}

		public function hover():void{
			updateLine();
			addChild(_line);
		}

		private function updateLine():void{
			var option:Object = getOption();
			if(option){
				_line.show(width , _cn + ' - ' + option.cn);
			}else{
				_line.show(width , _cn);
			}
		}

		public function hoverOut():void{
			_line.hide();
			try{
				removeChild(_line);
			}catch(e:Error){}
		}

		public function select():void{
			var e:SetBtnEvent = new SetBtnEvent(SetBtnEvent.SELECT);
			e.selectedLabel = label;
			dispatchEvent(e);
			SoundCtrl.I.sndConfrim();
		}

		public function setOption(arr:Array):void{
			_options = arr;
			_prevArrow = ResUtils.I.createDisplayObject(ResUtils.swfLib.setting , 'txt_arrow_mc');
			_nextArrow =ResUtils.I.createDisplayObject(ResUtils.swfLib.setting , 'txt_arrow_mc');
			_prevArrow.name = 'prevArrow';
			_nextArrow.name = 'nextArrow';
			_nextArrow.scaleX = -1;
			_prevArrow.y = _nextArrow.y = 17;
			_optionTxt = new BitmapFontText(AssetManager.I.getFont('font1'));

			addChild(_prevArrow);
			addChild(_nextArrow);
			addChild(_optionTxt);

			updateOption();
		}

		public function getOption():Object{
			if(!_options) return null;
			return _options[_optionIndex];
		}

		public function nextOption():void{
			if(!_options) return;
			var toIndex:int = _optionIndex+1;
			if(toIndex > _options.length-1) toIndex = 0;
			changeOption(toIndex);
			SoundCtrl.I.sndSelect();
		}

		public function prevOption():void{
			if(!_options) return;
			var toIndex:int = _optionIndex-1;
			if(toIndex < 0) toIndex = _options.length-1;
			changeOption(toIndex);
			SoundCtrl.I.sndSelect();
		}

		public function setOptionByValue(value:Object):void{
			for(var i:int ; i < _options.length ; i++){
				var option:Object = _options[i];
				if(option.value == value){
					changeOption(i,false);
					return;
				}
			}
		}


		private function changeOption(index:int , _dispatchEvent:Boolean = true):void{
			_optionIndex = index;
			updateOption();
			updateLine();



			if(_dispatchEvent){
				var e:SetBtnEvent = new SetBtnEvent(SetBtnEvent.OPTION_CHANGE);

				var option:Object = getOption();
				if(option){
					e.optionKey = optionKey;
					e.optionValue = option.value;
					dispatchEvent(e);
				}

			}
		}

		private function updateOption():void{
			var option:String = getOption().label;
			_optionTxt.text = option;

			_prevArrow.x = _label.x + _label.width + 50;
			_optionTxt.x = _prevArrow.x + 10;
			_nextArrow.x = _optionTxt.x + _optionTxt.width + 10;
		}

	}
}
