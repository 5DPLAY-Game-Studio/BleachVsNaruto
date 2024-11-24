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

package net.play5d.game.bvn.ui.mosou
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.fighter.FighterMain;

	public class LittleHpBar
	{
		include '../../../../../../../include/_INCLUDE_.as';

		private var _ui:mosou_little_hpbar_mc;
		private var _fighter:FighterMain;
		public function LittleHpBar(ui:mosou_little_hpbar_mc)
		{
			_ui = ui;
		}

		public function setFighter(f:FighterMain):void{
			_fighter = f;
			updateFace();
		}

		private function updateFace():void{
			var ct:Sprite = _ui.face.getChildByName('ct') as Sprite;
			if(ct){
				var faceImg:DisplayObject = AssetManager.I.getFighterFace(_fighter.data);
				if(faceImg){
					ct.removeChildren();
					ct.addChild(faceImg);
				}
			}

		}


//		public function render():void{
//
//		}

		public function renderAnimate():void{
			if(!_fighter) return;
			_ui.bar_hp.scaleX = getScale(_fighter.hp, _fighter.hpMax);
			_ui.bar_qi.scaleX = getScale(_fighter.qi, 300);
		}

		private function getScale(val:Number, max:Number):Number{
			var rate:Number = val / max;
			if(rate < 0.0001) rate = 0.0001;
			if(rate > 1) rate = 1;
			return rate;
		}

	}
}
