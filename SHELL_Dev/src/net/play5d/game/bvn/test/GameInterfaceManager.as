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

package net.play5d.game.bvn.test
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.ByteArray;

	import net.play5d.game.bvn.data.ConfigVO;
	import net.play5d.game.bvn.input.GameKeyInput;
	import net.play5d.game.bvn.input.IGameInput;
	import net.play5d.game.bvn.interfaces.IExtendConfig;
	import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
	import net.play5d.game.bvn.interfaces.IGameInterface;
	import net.play5d.kyo.KyoSharedObject;
	import net.play5d.kyo.utils.WebUtils;

	public class GameInterfaceManager implements IGameInterface
	{
		public function GameInterfaceManager()
		{
		}

		public function initTitleUI(ui:DisplayObject):void
		{
		}

		public function moreGames():void
		{
			WebUtils.getURL("http://www.1212321.com");
		}

		public function submitScore(score:int):void
		{
		}

		public function showRank():void
		{
		}

		public function saveGame(data:Object):void
		{
		}

		public function loadGame():Object
		{
			return null;
		}

		public function getFighterCtrl(player:int):IFighterActionCtrl
		{
			return null;
		}

		public function getGameMenu():Array
		{
			return null;
		}

		public function getSettingMenu():Array
		{
			return null;
		}

		public function getGameInput(type:String):Vector.<IGameInput>
		{
			var vec:Vector.<IGameInput> = new Vector.<IGameInput>();
			vec.push(new GameKeyInput());

			return vec;
		}

		public function getConfigExtend():IExtendConfig
		{
			return null;
		}

		public function afterBuildGame():void
		{
		}

		/**
		 * 更新输入设置
		 */
		public function updateInputConfig():Boolean
		{
			return false;
		}

		public function applyConfig(config:ConfigVO):void
		{
		}

		public function getCreadits(creditsInfo:String):Sprite
		{
			return null;
		}

		public function checkFile(url:String, file:ByteArray):Boolean
		{
			return true;
		}

		public function addMosouMoney(back:Function):void
		{
			back(100 + Math.random() * 200);
		}
	}
}
