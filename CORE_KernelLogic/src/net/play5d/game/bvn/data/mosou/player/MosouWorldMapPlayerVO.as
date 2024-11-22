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

package net.play5d.game.bvn.data.mosou.player
{
	import net.play5d.game.bvn.data.ISaveData;

	public class MosouWorldMapPlayerVO implements ISaveData
	{
		include '../../../../../../../../include/_INCLUDE_.as';

		public var id:String;
//		public var areas:Vector.<MosouWorldMapAreaPlayerVO> = new Vector.<MosouWorldMapAreaPlayerVO>();
		private var _openAreas:Vector.<MosouWorldMapAreaPlayerVO> = new Vector.<MosouWorldMapAreaPlayerVO>();

		public function MosouWorldMapPlayerVO()
		{
		}

		public function getOpenArea(id:String):MosouWorldMapAreaPlayerVO{
			for(var i:int; i < _openAreas.length; i++){
				if(_openAreas[i].id == id) return _openAreas[i];
			}
			return null;
		}

		public function openArea(id:String):void{
			if(!getOpenArea(id)){
				var av:MosouWorldMapAreaPlayerVO = new MosouWorldMapAreaPlayerVO();
				av.id = id;
				_openAreas.push(av);
			}
		}

		public function toSaveObj():Object
		{
			var o:Object = {};
			o.id = id;

			o.areas = [];
			for(var i:int; i < _openAreas.length; i++){
				var ad:Object = _openAreas[i].toSaveObj();
				o.areas.push(ad);
			}

			return o;
		}

		public function readSaveObj(o:Object):void
		{
			if(o.id) id = o.id;

			if(o.areas){
				_openAreas = new Vector.<MosouWorldMapAreaPlayerVO>();
				for(var i:int; i < o.areas.length; i++){
					var ad:Object = o.areas[i];
					var av:MosouWorldMapAreaPlayerVO = new MosouWorldMapAreaPlayerVO();
					av.readSaveObj(ad);
					_openAreas.push(av);
				}
			}
		}

	}
}
