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

package net.play5d.game.bvn.win.views
{
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.stage.SettingState;
	import net.play5d.game.bvn.win.GameInterfaceManager;
	import net.play5d.game.bvn.win.data.ExtendConfig;
	import net.play5d.game.bvn.win.input.JoyStickConfigVO;
	import net.play5d.kyo.stage.Istage;

	public class ViewManager
	{
		private static var _i:ViewManager;
		public static function get I():ViewManager{
			_i ||= new ViewManager();
			return _i;
		}

		public function ViewManager()
		{
		}

		public function goP1JoyStickSet():void{
			goJoyStickSet(1 , GameInterfaceManager.config.joy1Config);
		}

		public function goP2JoyStickSet():void{
			goJoyStickSet(2 , GameInterfaceManager.config.joy2Config);
		}

		private function goJoyStickSet(player:int , config:JoyStickConfigVO):void{
			var curStg:Istage = MainGame.stageCtrl.currentStage;
			if(!curStg is SettingState) return;
			var setStg:SettingState = curStg as SettingState;
			var joyStickSetUI:JoyStickSetUI = new JoyStickSetUI();
			joyStickSetUI.setConfig(player , config);
			setStg.goInnerSetPage(joyStickSetUI);
		}

	}
}
