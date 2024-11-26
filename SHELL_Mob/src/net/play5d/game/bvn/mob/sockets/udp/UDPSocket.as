package net.play5d.game.bvn.mob.sockets.udp {
import flash.utils.ByteArray;

/**
 * UDP协议收发消息管理器
 */
public class UDPSocket {

    public static const BUFFER_LENGTH:int    = 50;
    public static const RECEIVE_TIME_OUT:int = 10;

    public function UDPSocket() {
    }
    private var _dataBacks:Vector.<Function>;

    /**
     * 侦听端口，用于接收消息
     * @param port 端口号
     */
    public function listen(port:int):void {
        AndroidUDP.getInstace().setReceiveBufferLength(BUFFER_LENGTH);
        AndroidUDP.getInstace().setReceiveBufferTimeout(RECEIVE_TIME_OUT);
        AndroidUDP.getInstace().listen(port);
    }

    /**
     * 停止侦听端口
     */
    public function unListen():void {
        AndroidUDP.getInstace().unListen();
    }

    /**
     * 绑定接收消息事件
     * @param func
     */
    public function addDataHandler(func:Function):void {
        _dataBacks ||= new Vector.<Function>();
        if (_dataBacks.indexOf(func) == -1) {
            _dataBacks.push(func);
        }

        if (AndroidUDP.getInstace().hasEventListener(AndroidUDPEvent.RECEIVE)) {
            return;
        }
        AndroidUDP.getInstace().addEventListener(AndroidUDPEvent.RECEIVE, dataHandler);
    }

    /**
     * 移除绑定接收消息事件
     * @param func
     *
     */
    public function removeDataHandler(func:Function):void {
        var id:int = _dataBacks.indexOf(func);
        if (id != -1) {
            _dataBacks.splice(id, 1);
        }
    }

    /**
     * 发送消息
     * @param ip 目标IP
     * @param port 端口号
     * @param msg 消息内容
     *
     */
    public function send(ip:String, port:int, msg:Object):void {
        var bytes:ByteArray = getSendBytes(msg);
        log('UDP send', ip, port, msg, bytes.length);
        AndroidUDP.getInstace().send(ip, port, bytes);
    }

    /**
     * 发送广播消息
     * @param port 端口
     * @param msg 消息内容
     * @param updateOnLineIP 是否更新IP列表
     */
    public function sendBroadcast(port:int, msg:Object):void {
        var bytes:ByteArray = getSendBytes(msg);
        AndroidUDP.getInstace().sendBoardcast(port, bytes);
    }

    /**
     * 接收到消息事件响应
     * @param e
     */
    private function dataHandler(e:AndroidUDPEvent):void {

        var data:UDPDataVO = new UDPDataVO();
        data.fromIP        = e.ip;
        data.fromPort      = e.port;

        var byte:ByteArray = e.data;
        log('UDP receive', byte, byte.length);
        var type:int = byte.readByte();
        switch (type) {
        case 1:
            data.dataType = UdpDataType.STRING;
            data.setData(byte.readUTFBytes(byte.bytesAvailable));
            break;
        case 2:
            data.dataType     = UdpDataType.BYTEARRAY;
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

        for each(var f:Function in _dataBacks) {
            if (f != null) {
                f(data);
            }
        }
    }

    private function getSendBytes(msg:Object):ByteArray {
        var bytes:ByteArray = new ByteArray();
        if (msg is String) {
            bytes.writeByte(1);
            bytes.writeUTFBytes(msg as String);
        }
        else if (msg is ByteArray) {
            bytes.writeByte(2);
            bytes.writeBytes(msg as ByteArray, 0, (
                    msg as ByteArray
            ).bytesAvailable);
        }
        else {
            bytes.writeByte(3);
            bytes.writeObject(msg);
        }
        bytes.position = 0;

        if (bytes.length > BUFFER_LENGTH) {
            throw new Error('byteArray.length is over buffer length!');
        }

        return bytes;
    }

    private function log(...params):void {
//			trace.apply(null, params);
    }

}
}
