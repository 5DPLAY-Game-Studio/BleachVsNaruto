package net.play5d.game.bvn.win.sockets.events
{
	import flash.events.Event;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	public class SocketEvent extends Event
	{
		public static const CLIENT_CONNECT:String = 'SocketEvent_CLIENT_CONNECT';
		
		public static const CLIENT_DIS_CONNECT:String = 'SocketEvent_CLIENT_DIS_CONNECT';
		
		public static const RECEIVE_DATA:String = 'SocketEvent_RECEIVE_DATA';
		
		public static const CLOSE:String = 'SocketEvent_CLOSE';
		
		public static const ERROR:String = 'SocketEvent_ERROR';
		
		public var clientSocket:Socket;
		
		public var data:ByteArray;
		
		public var error:String;
		
//		private var _data:ByteArray;
		
		private var _quickGetData:Object;
		
//		public function get data():Object{
//			return _data;
//		}
		
		public function getDataObject():Object{
			data.position = 0;
			var obj:Object = null;
			try{
				obj = data.readObject();
			}catch(e:Error){
				trace("SocketEvent.getDataObject :: ",e);
			}
			return obj;
		}
		
//		public function set data(v:Object):void{
//			if(!v is ByteArray){
//				throw new Error("data必须是ByteArray类型！");
//			}
//			_quickGetData = null;
//			_data = v as ByteArray;
//		}
		
		public function SocketEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}