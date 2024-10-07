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
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.events.SetBtnEvent;

	public class MoveListSp extends Sprite
	{
		[Embed(source="/../assets/movelist.jpg")]
		private var _picClass:Class;

		private var _pic:Bitmap;
		private var _btns:SetBtnGroup;

		public var onBackSelect:Function;

		public function MoveListSp()
		{
			super();

			_pic = new _picClass();
			_pic.width = GameConfig.GAME_SIZE.x;
			_pic.height = GameConfig.GAME_SIZE.y;

			addChild(_pic);

			_btns = new SetBtnGroup();
			_btns.setBtnData([{label:'BACK',cn:'返回'}]);
			_btns.addEventListener(SetBtnEvent.SELECT,onSelect);
			_btns.x = 250;
			_btns.y = GameConfig.GAME_SIZE.y - 130;
			addChild(_btns);
		}

		public function destory():void{
			if(_btns){
				_btns.removeEventListener(SetBtnEvent.SELECT,onSelect);
				_btns.destory();
				_btns = null;
			}
		}

		public function isShowing():Boolean{
			return this.visible;
		}

		public function show():void{

			this.visible = true;
			setTimeout(function():void{
				_btns.keyEnable = true;
			},100);
		}

		public function hide():void{
			_btns.keyEnable = false;
			this.visible = false;
		}

		private function onSelect(e:Event):void{
			if(onBackSelect != null) onBackSelect();
		}
	}
}
