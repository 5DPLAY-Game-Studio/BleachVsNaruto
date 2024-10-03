package net.play5d.game.bvn.win.sockets.udp
{
	import flash.events.DatagramSocketDataEvent;
	import flash.net.DatagramSocket;
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.utils.ByteArray;

	/**
	 * UDP协议收发消息管理器 
	 */
	public class UDPSocket
	{
		private var _udpsocket:DatagramSocket;
		private var _dataBacks:Vector.<Function>;
		private var _onLineClients:Array;
		private var _broadCastAddress:String;
		
		public function UDPSocket()
		{
			trace("DatagramSocket.isSupported = ",DatagramSocket.isSupported);
			_udpsocket = new DatagramSocket();
		}
		
		/**
		 * 侦听端口，用于接收消息 
		 * @param port 端口号
		 */
		public function listen(port:int):void{
			_udpsocket.bind(port);
			_udpsocket.receive();
		}
		
		/**
		 * 停止侦听端口 
		 */
		public function unListen():void{
			_udpsocket.close();
		}
		
		/**
		 * 绑定接收消息事件 
		 * @param func
		 */
		public function addDataHandler(func:Function):void{
			_dataBacks ||= new Vector.<Function>();
			if(_dataBacks.indexOf(func) == -1) _dataBacks.push(func);
			
			if(_udpsocket.hasEventListener(DatagramSocketDataEvent.DATA)) return;
			_udpsocket.addEventListener(DatagramSocketDataEvent.DATA , dataHandler);
		}
		
		/**
		 * 移除绑定接收消息事件 
		 * @param func
		 * 
		 */
		public function removeDataHandler(func:Function):void{
			var id:int = _dataBacks.indexOf(func);
			if(id != -1){
				_dataBacks.splice(id,1);
			}
		}
		
		/**
		 * 接收到消息事件响应 
		 * @param e
		 */
		private function dataHandler(e:DatagramSocketDataEvent):void{
			
			var data:UDPDataVO = new UDPDataVO();
			data.fromIP = e.srcAddress;
			data.fromPort = e.srcPort;
			
			var byte:ByteArray = e.data;
			var type:int = byte.readByte();
			switch(type){
				case 1:
					data.dataType = UdpDataType.STRING;
					data.setData(byte.readUTFBytes(byte.bytesAvailable));
					break;
				case 2:
					data.dataType = UdpDataType.BYTEARRAY;
					var tmp:ByteArray = new ByteArray();
					tmp.writeBytes(byte, 1, byte.bytesAvailable);
					tmp.position = 0;
					data.setData(tmp);
					break;
				case 3:
					data.dataType = UdpDataType.OBJECT;
					data.setData(byte.readObject());
					break;
			}
			
			for each(var f:Function in _dataBacks){
				if(f != null) f(data);
			}
		}
		
		
		/**
		 * 发送消息 
		 * @param ip 目标IP
		 * @param port 端口号
		 * @param msg 消息内容
		 * 
		 */
		public function send(ip:String , port:int , msg:Object):void{
			log('UDPCtrler.send',ip,port,msg);
			
			var bytes:ByteArray = new ByteArray();
			if(msg is String){
				bytes.writeByte(1);
				bytes.writeUTFBytes(msg as String);
			}else if(msg is ByteArray){
				bytes.writeByte(2);
				bytes.writeBytes(msg as ByteArray, 0, (msg as ByteArray).bytesAvailable);
			}else{
				bytes.writeByte(3);
				bytes.writeObject(msg);
			}
			_udpsocket.send(bytes , 0 , 0 , ip , port);
		}
		
		/**
		 * 发送广播消息 (仅限AIR，WINDOWS系统，需要支持打开进程)
		 * @param port 端口
		 * @param msg 消息内容
		 * @param updateOnLineIP 是否更新IP列表
		 */
		public function sendBroadcast(port:int , msg:Object):void{
			if(!_broadCastAddress){
				var interfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
				for each(var i:NetworkInterface in interfaces){
					if(i.active){
						for each(var j:InterfaceAddress in i.addresses){
							if(j.broadcast && j.broadcast != ""){
								_broadCastAddress = j.broadcast;
							}
						}
					}
				}
			}
			
			if(_broadCastAddress){
				send(_broadCastAddress,port,msg);
			}else{
				trace("获取广播地址失败!");
			}
			
		}
		
		private function log(...params):void{
//			trace.apply(null, params);
		}
		
	}
}