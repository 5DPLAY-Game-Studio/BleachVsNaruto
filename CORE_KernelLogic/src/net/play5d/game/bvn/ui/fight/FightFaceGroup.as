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

	import net.play5d.game.bvn.data.GameRunFighterGroup;

	public class FightFaceGroup
	{
		include '../../../../../../../include/_INCLUDE_.as';

		private var _ui:hpbar_facegroup;

		private var _face1:FightFaceUI;
		private var _face2:FightFaceUI;
		private var _face3:FightFaceUI;

		public function get ui():DisplayObject{
			return _ui;
		}

		public function FightFaceGroup(ui:hpbar_facegroup)
		{
			_ui = ui;

			_ui.cacheAsBitmap = true;

			_face1 = new FightFaceUI(_ui.face);
			_face2 = new FightFaceUI(_ui.face2);
			_face3 = new FightFaceUI(_ui.face3);
		}

		public function setFighter(fighterGroup:GameRunFighterGroup = null):void{

			_ui.cacheAsBitmap = false;

			if(!fighterGroup.currentFighter) return;

			_face1.setData(fighterGroup.currentFighter.data);
			switch(fighterGroup.currentFighter.data){
				case fighterGroup.fighter1:
					_face2.setData(fighterGroup.fighter2);
					_face3.setData(fighterGroup.fighter3);
					break;
				case fighterGroup.fighter2:
					_face2.setData(fighterGroup.fighter3);
					_face3.setData(null);
					break;
				case fighterGroup.fighter3:
					_face2.setData(null);
					_face3.setData(null);
					break;
			}

			_ui.cacheAsBitmap = true;
		}

		public function setDirect(v:int):void{
			_face1.setDirect(v);
			_face2.setDirect(v);
			_face3.setDirect(v);
		}

	}
}
