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

package net.play5d.game.bvn.win.sockets
{
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;

	public class PacketUtils
	{
		public function PacketUtils()
		{
		}

		/**
		 * 创建一个包含头（数据长度）的数据文件
		 */
		public static function createByteArrayWithHead(data:*):ByteArray{
			var byte:ByteArray = new ByteArray();

			byte.position = 2;
			byte.writeObject(data);

			byte.position = 0;
			byte.writeShort(byte.bytesAvailable-2); //表头

			byte.position = 0;

			return byte;
		}

		public static function addByteArrayHead(byte:ByteArray):ByteArray{
			byte.position = 0;
			var len:int = byte.bytesAvailable;
			if(len < 0) return null;

			var newbyte:ByteArray = new ByteArray();
			newbyte.writeShort(len);
			newbyte.writeBytes(byte,0,byte.bytesAvailable);
			newbyte.position = 0;

			return newbyte;
		}

		public static function compress(byte:ByteArray):void{
//			byte.position = 0;
//			byte.compress(CompressionAlgorithm.DEFLATE);
//			byte.position = 0;
		}

		public static function uncompress(byte:ByteArray):void{
//			byte.position = 0;
//			byte.uncompress(CompressionAlgorithm.DEFLATE);
//			byte.position = 0;
		}


	}
}
