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

package net.play5d.kyo.loader
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	public class SWFLoader extends Loader
	{
		public var headInfo:SwfHeaderInfo;

		public function SWFLoader(url:String , back:Function = null)
		{
			loadSwf(url,back);
		}

		public function loadSwf(url:String , back:Function , fail:Function = null):void{
			loadHead(url,function():void{
				loadFlash(url,back);
			},fail);
		}

		private function loadHead(url:String , back:Function , fail:Function):void{
			KyoURLoader.load(url,ulcom,fail,{dataFormat:URLLoaderDataFormat.BINARY});

			function ulcom(b:ByteArray):void{
				if(!b){
					if(fail != null) fail();
					return;
				}
				headInfo = new SwfHeaderInfo(b);
				if(back != null) back();
			}

		}


		private function loadFlash(url:String,back:Function):void{
			contentLoaderInfo.addEventListener(Event.COMPLETE,loadCom);
			load(new URLRequest(url));

			function loadCom(e:Event):void{
				contentLoaderInfo.removeEventListener(Event.COMPLETE,loadCom);
				if(back != null) back();
			}
		}

	}
}
