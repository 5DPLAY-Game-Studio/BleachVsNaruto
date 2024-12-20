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

package net.play5d.game.bvn.ui.fight
{
	import flash.display.DisplayObject;

	import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.display.MCNumber;

	public class FightTimeUI
	{
		include '../../../../../../../include/_INCLUDE_.as';

		private var _ui:time_mc;
		private var _numMc:MCNumber;
		private var _renderTime:Boolean;

		public function get timeUI():DisplayObject{
			return _numMc;
		}

		public function FightTimeUI(ui:time_mc)
		{
			_ui = ui;

			var time:int = GameCtrl.I.gameRunData.gameTimeMax;
			if(time == -1){
				_renderTime = false;
				_ui.wuxian.visible = true;
			}else{

				_renderTime = true;

				var timeTxtCls:Class = ResUtils.I.getItemClass(ResUtils.swfLib.fight , 'time_txtmc');

				_numMc = new MCNumber(timeTxtCls,0,1,20,2);
				_numMc.x = -22;
				_numMc.y = -15;
				_ui.addChild(_numMc);

				_ui.wuxian.visible = false;
				_numMc.number = time;
			}

		}

		public function render():void{
			if(!_renderTime) return;
			var time:int = GameCtrl.I.gameRunData.gameTime;
			_numMc.number = time;
		}

	}
}
