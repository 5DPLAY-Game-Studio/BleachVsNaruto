package net.play5d.game.bvn.win.sockets.udp
{
	import flash.utils.ByteArray;

//	import flash.utils.ByteArray;

	public class UDPDataVO
	{
		
//		public var byte:ByteArray;
		
		private var _data:Object;
		public var dataType:int;
		
		public var fromIP:String;
		public var fromPort:int;
		
		private var _jsonData:Object;
		
		public function UDPDataVO()
		{
		}
		
		public function getDataByteArray():ByteArray{
			return dataType == UdpDataType.BYTEARRAY ? _data as ByteArray : null;
		}
		
		public function getDataString():String{
			return dataType == UdpDataType.STRING ? _data as String : null;
		}
		
		public function getDataObject():Object{
			return dataType == UdpDataType.OBJECT ? _data : null;
		}
		
		public function setData(v:Object):void{
			_data = v;
		}
		
//		public function get data():String{
//			if(!byte) return null;
//			return byte.readUTFBytes(byte.bytesAvailable);
//		}
//		
//		public function get dataJson():Object{
//			if(!byte) return null;
//			if(!_jsonData){
//				var str:String = data;
//				_jsonData = JSON.parse(str);
//			}
//			return _jsonData;
//		}
		
	}
}