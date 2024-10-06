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

package net.play5d.kyo.sound
{
	import flash.media.Sound;
	import flash.utils.ByteArray;

	public class BytesSound extends Sound
	{
//		private var _bytes:ByteArray;

		public function BytesSound(bytes:ByteArray = null)
		{
			super(null, null);
			if(bytes) loadBytes(bytes);
		}

		public function loadBytes(v:ByteArray):void{
//			_bytes = v;

			v.position = 0;

//			var _this:BytesSound = this;
//
//			function loadNext():void{
//				if(v.bytesAvailable < 1){
//					trace("loadBytes finish");
//					return;
//				}
//
//				var bytes:ByteArray = new ByteArray();
//
//				var start:uint = v.position;
//
//				var len:uint = Math.min(v.bytesAvailable, 40 * 1024);
//				v.readBytes(bytes, 0, len);
//
//				var end:uint = start + len;
//
//				trace("loadCompressedDataFromByteArray", start, "-", end);
//				_this.loadCompressedDataFromByteArray(bytes, bytes.bytesAvailable);
//
//				setTimeout(loadNext, 1);
//			}
//			loadNext();

			while(v.bytesAvailable > 0){
				var bytes:ByteArray = new ByteArray();

//				var start:uint = v.position;

				var len:uint = Math.min(v.bytesAvailable, 40 * 1024);
				v.readBytes(bytes, 0, len);

//				trace("loadCompressedDataFromByteArray", start, "-", start + bytes.bytesAvailable);
				this.loadCompressedDataFromByteArray(bytes, bytes.bytesAvailable);
			}

			v.clear();

		}


	}
}
