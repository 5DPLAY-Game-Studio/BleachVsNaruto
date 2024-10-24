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

package net.play5d.game.bvn.interfaces
{
	import flash.utils.ByteArray;

	public class GameInterface
	{

//		private static var _i:GameInterface;
//		public static function get I():GameInterface{
//			_i ||= new GameInterface();
//			return _i;
//		}

		public static var instance:IGameInterface;

		public function GameInterface()
		{
		}

		public static function getDefaultMenu():Array{
			var a:Array = [

				{txt:'TEAM PLAY',cn:GetLangText('package.interfaces.GameInterface.getDefaultMenu.team_play.txt'),children:[
					{txt:'TEAM ACRADE',cn:GetLangText('package.interfaces.GameInterface.getDefaultMenu.team_play.child.team_acrade.txt')},
					{txt:'TEAM VS PEOPLE',cn:GetLangText('package.interfaces.GameInterface.getDefaultMenu.team_play.child.team_vs_people.txt')},
					{txt:'TEAM VS CPU',cn:GetLangText('package.interfaces.GameInterface.getDefaultMenu.team_play.child.team_vs_cpu.txt')},
						{txt:'TEAM WATCH',cn:'观战电脑'}
				]},

				{txt:'SINGLE PLAY',cn:GetLangText('package.interfaces.GameInterface.getDefaultMenu.single_play.txt'),children:[
					{txt:'SINGLE ACRADE',cn:GetLangText('package.interfaces.GameInterface.getDefaultMenu.single_play.child.single_acrade.txt')},
					{txt:'SINGLE VS PEOPLE',cn:GetLangText('package.interfaces.GameInterface.getDefaultMenu.single_play.child.single_vs_people.txt')},
					{txt:'SINGLE VS CPU',cn:GetLangText('package.interfaces.GameInterface.getDefaultMenu.single_play.child.single_vs_cpu.txt')},
						{txt:'SINGLE WATCH',cn:'观战电脑'}
				]},

				{txt:'MUSOU PLAY',cn:GetLangText('package.interfaces.GameInterface.getDefaultMenu.musou_play.txt'),children:[
					{txt:'MUSOU ACRADE',cn:GetLangText('package.interfaces.GameInterface.getDefaultMenu.musou_play.child.musou_acrade.txt')}
				]},

				{txt:'OPTION',cn:GetLangText('package.interfaces.GameInterface.getDefaultMenu.option.txt')},
				{txt:'TRAINING',cn:GetLangText('package.interfaces.GameInterface.getDefaultMenu.training.txt')},
				{txt:'CREDITS',cn:GetLangText('package.interfaces.GameInterface.getDefaultMenu.credits.txt')},
				{txt:'MORE GAMES',cn:GetLangText('package.interfaces.GameInterface.getDefaultMenu.more_games.txt')}
			];
			return a;
		}

		public static function checkFile(url:String, file:ByteArray):Boolean{
			if(instance) return instance.checkFile(url, file);
			return true;
		}

		public static function addMoney(back:Function):void{
			function addMoneyBack(money:*):void{
				var mm:int = int(money);
				if(mm < 1) return;
				if(mm > 5000) return;
				back(mm);
			}

			if(instance){
				instance.addMosouMoney(addMoneyBack);
				return;
			}
			addMoneyBack(100 + Math.random() * 500);
		}

//		public var moreGames:Function;
//		public var


	}
}
