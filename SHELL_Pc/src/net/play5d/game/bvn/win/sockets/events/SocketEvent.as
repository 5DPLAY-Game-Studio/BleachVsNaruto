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

package net.play5d.game.bvn.win.sockets.events {
import flash.events.Event;
import flash.net.Socket;
import flash.utils.ByteArray;

public class SocketEvent extends Event {
    public static const CLIENT_CONNECT:String = 'SocketEvent_CLIENT_CONNECT';

    public static const CLIENT_DIS_CONNECT:String = 'SocketEvent_CLIENT_DIS_CONNECT';

    public static const RECEIVE_DATA:String = 'SocketEvent_RECEIVE_DATA';

    public static const CLOSE:String = 'SocketEvent_CLOSE';

    public static const ERROR:String = 'SocketEvent_ERROR';

    public function SocketEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }
    public var clientSocket:Socket;
    public var data:ByteArray;

//		private var _data:ByteArray;
    public var error:String;

//		public function get data():Object{
//			return _data;
//		}
    private var _quickGetData:Object;

//		public function set data(v:Object):void{
//			if(!v is ByteArray){
//				throw new Error("data必须是ByteArray类型！");
//			}
//			_quickGetData = null;
//			_data = v as ByteArray;
//		}

    public function getDataObject():Object {
        data.position  = 0;
        var obj:Object = null;
        try {
            obj = data.readObject();
        }
        catch (e:Error) {
            trace('SocketEvent.getDataObject :: ', e);
        }
        return obj;
    }
}
}
