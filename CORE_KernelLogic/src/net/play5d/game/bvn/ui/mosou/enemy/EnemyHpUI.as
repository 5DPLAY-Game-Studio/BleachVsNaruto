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

package net.play5d.game.bvn.ui.mosou.enemy
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import net.play5d.game.bvn.ctrler.AssetManager;
	import net.play5d.game.bvn.fighter.FighterMain;

	public class EnemyHpUI
	{
		include '../../../../../../../../include/_INCLUDE_.as';

		private var _ui:mosou_enemyhpbarmc;
		private var _fighter:FighterMain;
		private var _bar:DisplayObject;
		private var _faceCt:Sprite;

		public function EnemyHpUI(fighter:FighterMain)
		{
			_ui = new mosou_enemyhpbarmc();
			_bar = _ui.getChildByName('bar');
			_faceCt = _ui.getChildByName('ct_face') as Sprite;
			_fighter = fighter;

			var faceImg:DisplayObject = AssetManager.I.getFighterFace(_fighter.data);
			if(faceImg){
				_faceCt.addChild(faceImg);
			}
		}

		public function getFighter():FighterMain{
			return _fighter;
		}

		public function getUI():DisplayObject{
			return _ui;
		}

		public function render():Boolean{
			var val:Number = _fighter.hp / _fighter.hpMax;
			if(val < 0.0001) val = 0.0001;
			if(val > 1) val = 1;

			_bar.scaleX = val;

			return _fighter.isAlive;
		}

		public function destory():void{

		}


	}
}
