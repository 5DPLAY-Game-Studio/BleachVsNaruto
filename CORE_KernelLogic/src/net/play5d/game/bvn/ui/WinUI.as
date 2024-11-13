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
	import flash.display.DisplayObject;
	import flash.display.MovieClip;

	import net.play5d.game.bvn.data.FighterVO;

	public class WinUI
	{
		include "_INCLUDE_.as";

		private var _ui:winmc;
		private var _team:int;

		public function get ui():DisplayObject{
			return _ui;
		}

		public function WinUI(ui:winmc , team:int)
		{
			_ui = ui;
			_team = team;
		}

		public function show(fighter:FighterVO , wins:int):void{
			if(!fighter) return;

			var playmc:MovieClip;

			switch(wins){
				case 1:
					playmc = _team == 1 ? _ui.w1 : _ui.w2;
					break;
				case 2:
					playmc = _team == 1 ? _ui.w2 : _ui.w1;
					break;
			}

			if(!playmc) return;

			switch(fighter.comicType){
				case 0:
					playmc.gotoAndPlay('in_bleach');
					break;
				case 1:
					playmc.gotoAndPlay('in_naruto');
					break;
			}

		}

	}
}
