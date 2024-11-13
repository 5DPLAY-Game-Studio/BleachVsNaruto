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

	import net.play5d.game.bvn.events.SetBtnEvent;

	public class ContinueBtn extends Sprite
	{
		include "_INCLUDE_.as";

		private var _btnGroup:SetBtnGroup;
		private var _onClick:Function;

		public function ContinueBtn()
		{
			super();

			_btnGroup = new SetBtnGroup();
			_btnGroup.startX = 0;
			_btnGroup.startY = 0;
			_btnGroup.setBtnData([
				{label: "CONTINUE", cn: "继续游戏"}
			], 2);
			addChild(_btnGroup);
		}

		public function onClick(callBack:Function):void{
			_onClick = callBack;
			if(_btnGroup.hasEventListener(SetBtnEvent.SELECT)){
				return;
			}
			_btnGroup.addEventListener(SetBtnEvent.SELECT, onBtnClick);
		}

		private function onBtnClick(e:SetBtnEvent):void{
			if(_onClick != null) _onClick(this);
		}

		public function destory():void{
			if(_btnGroup){
				_btnGroup.destory();
			}
		}
	}
}
