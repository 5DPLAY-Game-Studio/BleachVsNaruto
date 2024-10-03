package net.play5d.game.bvn.win.sockets
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ObjectEncoding;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import net.play5d.game.bvn.win.sockets.events.SocketEvent;
	
	/**
	 * SOCKET服务器 
	 */
	public class SocketServer extends EventDispatcher
	{
		private static var _i:SocketServer;
		public static function get I():SocketServer{
			_i ||= new SocketServer;
			return _i;
		}
		
		public var connected:Boolean;
		
		private var _serverSocket:ServerSocket;
		private var _clients:Vector.<Socket>;
		private var _packetBuffer:PacketBuffer;
		
		public function SocketServer()
		{
		}
		
		/**
		 * 端口号 
		 */
		public function get port():int{
			return _serverSocket.localPort;
		}
		
		/**
		 * 绑定服务端ip和端口
		 * @ip ip地址
		 * @port 端口
		 */
		public function bind(port:int):void
		{
			close();
			
			_serverSocket = new ServerSocket();
			
			_serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, onClientConnect );
			//			_serverSocket.addEventListener(Event.CONNECT, onServerConnect );
			_serverSocket.addEventListener(Event.CLOSE,onClose);
			
			_clients = new Vector.<Socket>();
			
			_packetBuffer = new PacketBuffer();
			
			try{
				_serverSocket.bind(port);
				_serverSocket.listen();
				log( "SERVER SOCKET正在监听端口:" + _serverSocket.localPort );
			}catch(e:Error){
				log("监听失败，请尝试另一个端口");
			}
			
			connected = _serverSocket.bound;
			
		}
		
		public function get clients():Vector.<Socket>{
			return _clients;
		}
		
		public function close():void{
			if(_clients){
				for each(var c:Socket in _clients){
					if(c.connected) c.close();
				}
				_clients = null;
			}
			
			if(_serverSocket){
				_serverSocket.close();
				_serverSocket = null;
			}
			connected = false;
			
		}
		
		public function getClientByIP(ip:String):Socket{
			for each(var i:Socket in _clients){
				if(i.remoteAddress == ip) return i;
			}
			return null;
		}
		
		/**
		 * 成功启动服务器
		 */
		private function onClientConnect( event:ServerSocketConnectEvent):void
		{
			var clientSocket:Socket = event.socket;
			clientSocket.addEventListener(ProgressEvent.SOCKET_DATA,onClientSocketData);
			_clients.push(clientSocket);
			clientSocket.addEventListener(Event.CLOSE,onCloseClient);
			log( "Connection from " + clientSocket.localAddress + ":" + clientSocket.localPort );
			connected = true;
			
			var se:SocketEvent = new SocketEvent(SocketEvent.CLIENT_CONNECT);
			se.clientSocket = clientSocket;
			dispatchEvent(se);
			
			//trace(_clients.length,"_clients.length",Config.clientNum,"Config.clientNum");
		}
		
		private function onClose(e:Event):void
		{
			_serverSocket.removeEventListener( ServerSocketConnectEvent.CONNECT, onClientConnect );
			_serverSocket.removeEventListener(Event.CLOSE,onClose);
			
			dispatchEvent(new SocketEvent(SocketEvent.CLOSE));
			
			connected = false;
			log( "Connection Closed " );
		}
		
		private function onCloseClient(e:Event):void
		{
			var closeClient:Socket = e.target as Socket;
			
			for (var i:int=0 ; i < _clients.length ; i++){
				var client:Socket = _clients[i];
				if(client.remoteAddress == closeClient.remoteAddress && client.remotePort == closeClient.remotePort){
					
					_clients.splice(i,1); 
					log(e.target.remoteAddress+":"+e.target.remotePort+ "断开"); 
					
					var se:SocketEvent = new SocketEvent(SocketEvent.CLIENT_DIS_CONNECT);
					se.clientSocket = client;
					dispatchEvent(se);
					
				}
			}
			
		}
		/**
		 * 服务端接收客户端发送的信息
		 */
		private function onClientSocketData( event:ProgressEvent ):void
		{
			var buffer:ByteArray = new ByteArray();
			var client:Socket = event.currentTarget as Socket;
			client.readBytes( buffer, 0, client.bytesAvailable );
			
			PacketUtils.uncompress(buffer);
			
			_packetBuffer.push(buffer);
			
			var packets:Array = _packetBuffer.getPackets();  //这里就是在进行解码（包含循环）  
			for each(var data:ByteArray in packets)  
			{  
				var se:SocketEvent = new SocketEvent(SocketEvent.RECEIVE_DATA);
				se.data = data;
				se.clientSocket = client;
				dispatchEvent(se);
				
				log( "Received from Client"+ client.remoteAddress + ":" + client.remotePort+"-- " + data );
				
			}
		}
		/**
		 * 服务器向客户端发送信息
		 */
		public function sendAll(obj:Object):void
		{
			try
			{
				if (_clients.length == 0)
				{
					log('没有连接');
					return;
				}
				for (var i:int = 0; i < _clients.length; i++) 
				{
					var item:Socket = _clients[i] as Socket;
					send(item , obj);
				}
			}catch ( error:Error )
			{
				log( error.message );
			}
		}
		
		/**
		 * 以二进制，压缩的形式发送数据 
		 * @param client
		 * @param data
		 * 
		 */
		public function send(client:Socket , data:Object):void{
			if(client == null) return;
			var bytes:ByteArray;
			
			if(data is ByteArray){
				bytes = PacketUtils.addByteArrayHead(data as ByteArray);
			}else{
				bytes = PacketUtils.createByteArrayWithHead(data);
			}
			
			PacketUtils.compress(bytes);
			
			client.objectEncoding = ObjectEncoding.AMF3;
			client.writeBytes(bytes,0,bytes.bytesAvailable);
			client.flush();
		}
		
		public function sendJson(client , data:Object):void{
			var json:String = JSON.stringify(data);
			send(client , json);
		}
		
		public function sendByIP(ip:String , obj:ByteArray):void{
			var client:Socket = getClientByIP(ip);
			send(client,obj);
		}
		
		public function log(message:String):void
		{
//			trace(message);
		}
		
	}
}