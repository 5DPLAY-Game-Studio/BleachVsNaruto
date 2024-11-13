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
	import com.greensock.TweenLite;

	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class SetBtnLine extends Sprite
	{
		include "_INCLUDE_.as";

		private var _txt:TextField;
		private var _line:Sprite;
		public function SetBtnLine()
		{


			mouseChildren = mouseEnabled = false;



			_line = new Sprite();
			addChild(_line);

			if(GameUI.SHOW_CN_TEXT){
				_txt = new TextField();
				UIUtils.formatText(_txt , {color:0xfded65 , size:16 , align:TextFormatAlign.RIGHT});
				_txt.y = 4;
				addChild(_txt);
			}

//			this.filters = [new GlowFilter(0,1,3,3,3)];
		}

		public function show(width:Number ,text:String):void{
			_line.graphics.clear();
			_line.graphics.lineStyle(1,0xfded65,1);
			_line.graphics.lineTo(width,0);

			_line.scaleX = 0.1;

			TweenLite.to(_line , 0.3 , {scaleX:1});

			this.visible = true;

			if(_txt){
				_txt.width = width;
				_txt.text = text;
			}

//			WordEffect.showOneByOne(_txt,0.03);

		}

		public function hide():void{
			this.visible = false;
			if(_txt) _txt.text = "";
		}

	}
}
