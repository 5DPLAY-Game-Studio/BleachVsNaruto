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

package net.play5d.kyo.utils
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	public class AJAX
	{
		public function AJAX()
		{
		}

		public static function post(url:String , data:URLVariables = null , back:Function = null):void{
			loadurl(url,data,URLRequestMethod.POST,back);
		}

		public static function get(url:String , data:URLVariables = null , back:Function = null):void{
			loadurl(url,data,URLRequestMethod.GET,back);
		}

		private static function loadurl(url:String , obj:Object , method:String ,back:Function):void{
			var rq:URLRequest = new URLRequest(url);
			rq.data = obj;
			rq.method = method;
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE,function():void{
				trace('url访问成功');
				if(back != null) back(l.data);
			});
			l.load(rq);
		}


	}
}
