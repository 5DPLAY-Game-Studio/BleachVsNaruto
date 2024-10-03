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

	public class PacketBuffer
	{
		private var buf:ByteArray = new ByteArray();
		public function PacketBuffer()
		{
		}
		public function push(ba:ByteArray):void
		{
			if(buf == null)
			{
				buf = ba;
			}else
			{
				buf.position = buf.length;
				buf.writeBytes(ba);
			}
		}
		public function getPackets():Array
		{
			var ps:Array = [];
			buf.position = 0;
			while(buf.bytesAvailable >= 2)  //这里是说当可用数据大于包头时，一个包==包头(body的长度)+包体(body)，也就是说包里如果一旦有数据就开始执行
			{                                //2其实是readShort()后，少了的2个字节，也就是body有数据的时候才开始解码
				var len:uint = buf.readShort();
				//不足一个包，这里完全有可能，当只读取完包头len，但是body却没有读取到末尾
				if(buf.bytesAvailable < len)
				{
					var ba:ByteArray = new ByteArray();
					ba.writeBytes(buf, 0, buf.bytesAvailable);
					buf = ba;
					//返回
					return ps;
				}
//				buf.position += 2;
				var mb:ByteArray = new ByteArray();
				buf.readBytes(mb, 0, len);   //len为body的长度，将body的数据放入mb
				mb.position = 0;

				ps.push(mb);
				/*
				var data:Object = mb.readObject();
//				buf.position=0;
				ps.push(data);  //放入数组
				*/
				//下一个包  while语句进行下一个循环
			}
			if(buf.bytesAvailable <= 0)buf = null;
			return ps;
		}
		public function clear():void
		{
			buf=null;
		}
	}



}
