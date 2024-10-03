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

package net.play5d.game.bvn.win.sockets.udp
{
	import flash.utils.ByteArray;

//	import flash.utils.ByteArray;

	public class UDPDataVO
	{

//		public var byte:ByteArray;

		private var _data:Object;
		public var dataType:int;

		public var fromIP:String;
		public var fromPort:int;

		private var _jsonData:Object;

		public function UDPDataVO()
		{
		}

		public function getDataByteArray():ByteArray{
			return dataType == UdpDataType.BYTEARRAY ? _data as ByteArray : null;
		}

		public function getDataString():String{
			return dataType == UdpDataType.STRING ? _data as String : null;
		}

		public function getDataObject():Object{
			return dataType == UdpDataType.OBJECT ? _data : null;
		}

		public function setData(v:Object):void{
			_data = v;
		}

//		public function get data():String{
//			if(!byte) return null;
//			return byte.readUTFBytes(byte.bytesAvailable);
//		}
//
//		public function get dataJson():Object{
//			if(!byte) return null;
//			if(!_jsonData){
//				var str:String = data;
//				_jsonData = JSON.parse(str);
//			}
//			return _jsonData;
//		}

	}
}
