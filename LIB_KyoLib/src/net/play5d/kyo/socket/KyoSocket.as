package net.play5d.kyo.socket
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	public class KyoSocket
	{
		/**
		 * 字符串编码格式 
		 */
		public var charset:String = 'UTF-8';
		/**
		 * 断线后自动重新连接服务器 
		 */
		public var autoConnect:Boolean;
		/**
		 * 自动重连时间间隔（秒） 
		 */
		public var autoConnectGap:int = 1;
		
		public var on_error:Function;
		public var on_connect:Function;
		public var on_close:Function;
		public var on_data:Function;
		
		private var _socket:Socket;
		public function get connected():Boolean{
			return _socket.connected;
		}
		
		public function KyoSocket()
		{
		}
		private var _host:String,_port:int;
		public function connect(host:String = 'localhost' , port:int = 0):void{
			_host = host;
			_port = port;
			
			_socket = new Socket(host,port);
			_socket.addEventListener(Event.CLOSE,closeHandler);
			_socket.addEventListener(Event.CONNECT,connectHandler);
			_socket.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,ercurityErrorHandler);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA,dataHandler);
		}
		
		public function sendMsg(msg:* , length:int = 32):void{
			if(!connected) return;
			if(msg is int){
				_socket.writeInt(msg);
				_socket.flush();
				return;
			}
			if(msg is String){
				var b:ByteArray = new ByteArray();
				b.writeMultiByte(msg,charset);
				b.length = length;
				sendByteArray(b);
				_socket.flush();
				return;
			}
		}
		public function sendByteArray(b:ByteArray):void{
			if(!_socket.connected) return;
			_socket.writeBytes(b);
			_socket.flush();
		}
		public function sendObject(o:Object):void{
			if(!_socket.connected) return;
			_socket.writeObject(o);
			_socket.flush();
		}
		
		private function onConnectClose():void{
			if(autoConnect) setTimeout(reConnect , autoConnectGap * 1000);
			if(on_close != null) on_close();
		}
		
		private function closeHandler(e:Event):void{
			trace('连接中断');
			onConnectClose();
		}
		private function connectHandler(e:Event):void{
			trace('连接成功');
			if(on_connect != null) on_connect();
		}
		private function ioErrorHandler(e:IOErrorEvent):void{
			trace('IO错误');
			if(on_error != null) on_error('IO错误');
			onConnectClose();
		}
		private function ercurityErrorHandler(e:SecurityErrorEvent):void{
			trace('安全性错误');
			if(on_error != null) on_error('安全性错误');
			onConnectClose();
		}
		private function dataHandler(e:ProgressEvent):void{
			trace('接收到数据');
			if(on_data != null){
				var buffer:ByteArray = new ByteArray();
				e.currentTarget.readBytes(buffer,0,e.currentTarget.bytesAvailable);
				on_data(buffer);
			}
		}
		
		public function reConnect():void{
			if(_socket.connected) return;
			_socket.connect(_host,_port);
		}
		
	}
}