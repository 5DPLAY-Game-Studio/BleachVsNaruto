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
	public class MapVO
	{
		include '../../../../../../include/_INCLUDE_.as';

		public var id:String;
		public var name:String;
		public var fileUrl:String;
		public var picUrl:String;
		public var bgm:String;

		public function MapVO()
		{
		}

//		public function initByXML(xml:XML):void{
//			id = xml.@id;
//			name = xml.@name;
//
//			fileUrl = xml.file.@url;
//			picUrl = xml.img.@url;
//			bgm = xml.bgm.@url;
//		}

		public function initByObject(obj:Object):void {
			var pathObj:Object = obj['path'];

			id = obj['id'];
			name = obj['name'];

			if (obj['file']) {
				fileUrl = pathObj['map'] + obj['file'];
			}
			else {
				fileUrl = pathObj['map'] + obj['id'] + '.swf';
			}

			if (obj['img']) {
				picUrl = pathObj['map'] + obj['img'];
			}
			else {
				picUrl = pathObj['map'] + obj['id'] + '.png';
			}

			bgm = pathObj['bgm'] + obj['bgm']
		}

	}
}
