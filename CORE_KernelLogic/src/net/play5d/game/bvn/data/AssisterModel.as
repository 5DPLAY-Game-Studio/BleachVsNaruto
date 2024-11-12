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
	public class AssisterModel
	{
		include "_INCLUDE_.as";

		private static var _i:AssisterModel;

		public static function get I():AssisterModel{
			_i ||= new AssisterModel();
			return _i;
		}

		private var _assisterObj:Object;

		public function AssisterModel()
		{
		}

		public function getAllAssisters():Object{
			return _assisterObj;
		}

		public function getAssisters(comicType:int = -1, condition:Function = null):Vector.<FighterVO>{
			var vec:Vector.<FighterVO> = new Vector.<FighterVO>();
			for each(var i:FighterVO in _assisterObj){
				if(condition != null && !condition(i)) continue;
				if(comicType == -1 || i.comicType == comicType){
					vec.push(i);
				}
			}
			return vec;
		}

		public function getAssister(id:String , clone:Boolean = false):FighterVO{
			return _assisterObj[id];
		}

		public function initByXML(xml:XML):void{
			_assisterObj = {};

			for each(var i:XML in xml.fighter){
				var fv:FighterVO = new FighterVO();
				fv.initByXML(i);
				_assisterObj[fv.id] = fv;
			}

		}


	}
}
