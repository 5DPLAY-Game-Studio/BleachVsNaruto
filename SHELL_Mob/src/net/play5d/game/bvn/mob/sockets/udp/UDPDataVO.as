package net.play5d.game.bvn.mob.sockets.udp {
import flash.utils.ByteArray;

//	import flash.utils.ByteArray;

public class UDPDataVO {

    //		public var byte:ByteArray;

    public function UDPDataVO() {
    }
    public var dataType:int;

    public var fromIP:String;
    public var fromPort:int;
    private var _data:Object;
    private var _jsonData:Object;

    public function getDataByteArray():ByteArray {
        if (dataType == UdpDataType.BYTEARRAY) {
            (
                    _data as ByteArray
            ).position = 0;
            return _data as ByteArray;
        }
        return null;
    }

    public function getDataString():String {
        return dataType == UdpDataType.STRING ? _data as String : null;
    }

    public function getDataObject():Object {
        return dataType == UdpDataType.OBJECT ? _data : null;
    }

    public function setData(v:Object):void {
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
