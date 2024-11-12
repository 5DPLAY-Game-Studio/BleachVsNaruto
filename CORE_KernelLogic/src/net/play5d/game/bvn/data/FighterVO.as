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

package net.play5d.game.bvn.data
{
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.kyo.utils.KyoRandom;

	public class FighterVO
	{
		include "_INCLUDE_.as";

		public var id:String;
		public var name:String;
		public var comicType:int; //0=死神,1=火影

		public var fileUrl:String;
		public var startFrame:int;

		public var faceUrl:String;
		public var faceBigUrl:String;
		public var faceBarUrl:String;
		public var faceWinUrl:String;

		public var contactFriends:Array;
		public var contactEnemys:Array;

		public var says:Array;

		public var bgm:String;
		public var bgmRate:Number = 1;

		public var isAlive:Boolean;

//		public var fighter:FighterMain;

		private var _cloneKey:Array = ['id','name','comicType','fileUrl','startFrame','faceUrl','contactFriends','contactEnemys','says','faceBigUrl','faceBarUrl','bgm','bgmRate'];

		public function FighterVO()
		{
		}

		public function initByXML(xml:XML):void{

			id = xml.@id;
			name = xml.@name;
			comicType = int(xml.@comic_type);

			fileUrl = xml.file.@url;
			startFrame = int(xml.file.@startFrame);

			faceUrl = xml.face.@url;
			faceBigUrl = xml.face.@big_url;
			faceBarUrl = xml.face.@bar_url;
			faceWinUrl = xml.face.@win_url;

			contactFriends = xml.contact.friend.toString().split(",");

			contactEnemys = xml.contact.enemy.toString().split(",");

			bgm = xml.bgm.@url;
			bgmRate = Number(xml.bgm.@rate) / 100;

			says = [];
			for each(var i:XML in xml.says.say_item){
				says.push(i.children().toString());
			}

			if(startFrame != 0 && !bgm){
				TraceLang('debug.trace.data.fighter_vo.undefined_bgm', id);
			}

		}

		public function getRandSay():String{
			return KyoRandom.getRandomInArray(says);
		}

		public function clone():FighterVO{
			var fv:FighterVO = new FighterVO();
			for each(var i:String in _cloneKey){
				fv[i] = this[i];
			}
			return fv;
		}

	}
}
