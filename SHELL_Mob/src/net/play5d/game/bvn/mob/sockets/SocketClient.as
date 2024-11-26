package net.play5d.game.bvn.mob.sockets {
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.ObjectEncoding;
import flash.net.Socket;
import flash.utils.ByteArray;

import net.play5d.game.bvn.mob.sockets.events.SocketEvent;

public class SocketClient extends EventDispatcher {

    public function SocketClient() {
        _clientSocket                = new Socket();
        _clientSocket.objectEncoding = ObjectEncoding.AMF3;
        _clientSocket.addEventListener(Event.CONNECT, onConnect);//监听连接事件
        _clientSocket.addEventListener(Event.CLOSE, onClose);//监听连接事件
        _clientSocket.addEventListener(IOErrorEvent.IO_ERROR, onError);
        _clientSocket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);

        _packetBuffer = new PacketBuffer();
    }
    public var isConnected:Boolean;
    private var _clientSocket:Socket;
    private var _packetBuffer:PacketBuffer;

    public function getSocketServer():String {
        return _clientSocket.remoteAddress + ':' + _clientSocket.remotePort;
    }

    /**
     * 开始连接服务器
     * @param host ip地址
     * @param port 端口
     */
    public function connect(host:String, port:int):void {
        log('开始连接服务器 :: ' + host + ':' + port);
        _clientSocket.connect(host, port);
    }

    /**
     * 断开连接
     */
    public function close():void {
        log('关闭链接');
        try {
            _clientSocket.close();
        }
        catch (e:Error) {
            trace(e);
        }
    }

    public function send(msg:Object):void {
        try {
            if (_clientSocket != null && _clientSocket.connected) {
                var bytes:ByteArray;

                if (msg is ByteArray) {
                    bytes = PacketUtils.addByteArrayHead(msg as ByteArray);
                }
                else {
                    bytes = PacketUtils.createByteArrayWithHead(msg);
                }

                if (!bytes) {
                    return;
                }

                PacketUtils.compress(bytes);
                _clientSocket.writeBytes(bytes, 0, bytes.bytesAvailable);
                _clientSocket.flush();
                log('Sent message (' + msg + ' | length:' + bytes.length + ') to ' + _clientSocket.remoteAddress + ':' +
                    _clientSocket.remotePort);
            }
            else {
                log('No socket connection.');
            }
        }
        catch (error:Error) {
            log(error.message);
        }
    }

    public function sendJSON(msg:Object):void {
        var jsonStr:String = JSON.stringify(msg);
        send(jsonStr);
    }

    private function log(message:String):void {
//			trace(message);
    }

    /**
     * 连接服务器成功
     */
    private function onConnect(event:Event):void {
        log('成功连接服务器!');
        log('Connection from ' + _clientSocket.remoteAddress + ':' + _clientSocket.remotePort);
        isConnected = true;
        dispatchEvent(new SocketEvent(SocketEvent.CLIENT_CONNECT));
    }

    private function onClose(e:Event):void {
        log('服务器断开!');
        isConnected = false;
        dispatchEvent(new SocketEvent(SocketEvent.CLOSE));
    }

    /**
     * 接收到服务器发送的数据
     */
    private function onSocketData(e:ProgressEvent):void {
        var buffer:ByteArray = new ByteArray();
        _clientSocket.readBytes(buffer, 0, _clientSocket.bytesAvailable);

        PacketUtils.uncompress(buffer);

        _packetBuffer.push(buffer);

        var packets:Array = _packetBuffer.getPackets();
        for each(var data:ByteArray in packets) {
            var se:SocketEvent = new SocketEvent(SocketEvent.RECEIVE_DATA);
            se.data            = data;
            dispatchEvent(se);

            log('Received from Server ::' + data);

        }
    }

    private function onError(e:IOErrorEvent):void {
        log(e.toString());
        isConnected        = false;
        var se:SocketEvent = new SocketEvent(SocketEvent.ERROR);
        se.error           = e.toString();
        dispatchEvent(se);
    }


}
}
