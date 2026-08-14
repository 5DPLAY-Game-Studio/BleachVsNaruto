package net.play5d.game.bvn.mob.sockets.udp {
import flash.utils.ByteArray;

import net.play5d.game.bvn.data.lan.UDPDataVO;
import net.play5d.game.bvn.data.lan.UdpHandlerList;
import net.play5d.game.bvn.data.lan.UdpPacketUtils;
import net.play5d.game.bvn.interfaces.lan.IUdpTransport;

/**
 * UDP协议收发消息管理器（Mob / AndroidUDP）。
 */
public class UDPSocket implements IUdpTransport {

    public static const BUFFER_LENGTH:int    = 50;
    public static const RECEIVE_TIME_OUT:int = 10;

    private var _handlers:UdpHandlerList;

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
        _handlers ||= new UdpHandlerList();
        _handlers.add(func);

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
        _handlers && _handlers.remove(func);
    }

    /**
     * 发送消息
     * @param ip 目标IP
     * @param port 端口号
     * @param msg 消息内容
     *
     */
    public function send(ip:String, port:int, msg:Object):void {
        var bytes:ByteArray = UdpPacketUtils.encode(msg, BUFFER_LENGTH);
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
        var bytes:ByteArray = UdpPacketUtils.encode(msg, BUFFER_LENGTH);
        AndroidUDP.getInstace().sendBoardcast(port, bytes);
    }

    /**
     * 接收到消息事件响应
     * @param e
     */
    private function dataHandler(e:AndroidUDPEvent):void {
        var byte:ByteArray = e.data;
        log('UDP receive', byte, byte.length);

        var data:UDPDataVO = UdpPacketUtils.decode(byte, e.ip, e.port);

        _handlers && _handlers.dispatch(data);
    }

    private function log(...params):void {
    }

}
}
