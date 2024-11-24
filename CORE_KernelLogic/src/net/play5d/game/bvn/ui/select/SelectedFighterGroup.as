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

package net.play5d.game.bvn.ui.select
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;

	import flash.display.Sprite;

	import net.play5d.game.bvn.data.FighterVO;

	public class SelectedFighterGroup extends Sprite
	{
		include '../../../../../../../include/_INCLUDE_.as';

		private var _uiClass:Class;
		private var _uis:Array = [];
		private var _curUI:SelectedFighterUI;
		public function SelectedFighterGroup(uiClass:Class)
		{
			_uiClass = uiClass;
		}

		public function destory():void{
			if(_curUI){
				_curUI.destory();
				_curUI = null;
			}
		}

		public function addFighter(vo:FighterVO):void{
			var ui:SelectedFighterUI;
			var addy:Number = 20 - (_uis.length-1) * 3;
			var ty:Number = _uis.length * -20;
			var alpha:Number =  0.7 - (_uis.length-1) * 0.3;
			var scale:Number = 0.85 - (_uis.length-1) * 0.15;

			for(var i:int ; i < _uis.length ; i ++){
				ui = _uis[i];

				TweenLite.to(ui.ui,0.1,{y:ty,alpha:alpha,scaleX:scale,scaleY:scale});

				ty += addy;
				alpha += 0.3;
				scale += 0.15;
			}

			ui = new SelectedFighterUI(new _uiClass());
			if(vo) ui.setFighter(vo);

			ui.ui.y = 50;
			TweenLite.to(ui.ui,0.1,{y:0,delay:0.05});

			addChild(ui.ui);
			_uis.push(ui);
			if(_curUI){
				_curUI.destory();
				_curUI = null;
			}
			_curUI = ui;
		}

		public function updateFighter(vo:FighterVO):void{
			_curUI.setFighter(vo);
		}


	}
}
