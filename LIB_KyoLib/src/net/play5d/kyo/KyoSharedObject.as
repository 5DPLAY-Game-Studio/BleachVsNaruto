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

package net.play5d.kyo
{
	import flash.net.SharedObject;

	public class KyoSharedObject
	{
		public function KyoSharedObject()
		{
		}

		public static function load(id:String):Object{
			var so:SharedObject = SharedObject.getLocal(id);
			var d:Object = so.data;
			so.close();
			return d;
		}

		public static function save(id:String , data:Object):void{
			var so:SharedObject = SharedObject.getLocal(id);
			so.clear();
			for(var i:String in data){
				so.data[i] = data[i];
			}
			so.flush();
			so.close();
		}

		public static function deletee(id:String):void{
			var so:SharedObject = SharedObject.getLocal(id);
			so.clear();
		}

	}
}
