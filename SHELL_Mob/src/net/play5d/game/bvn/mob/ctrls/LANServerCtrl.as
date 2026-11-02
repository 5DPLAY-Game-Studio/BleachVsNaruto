package net.play5d.game.bvn.mob.ctrls {
import flash.events.EventDispatcher;
import flash.net.Socket;
import flash.utils.ByteArray;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.interfaces.lan.ILanServerLockLink;
import net.play5d.game.bvn.ctrler.lan.LanGameMenuCtrl;
import net.play5d.game.bvn.ctrler.lan.LanServerMatch;
import net.play5d.game.bvn.ctrler.lan.LanServerRoom;
import net.play5d.game.bvn.data.lan.ClientVO;
import net.play5d.game.bvn.data.lan.LanPorts;
import net.play5d.game.bvn.mob.data.HostVO;
import net.play5d.game.bvn.mob.events.LanEvent;
import net.play5d.game.bvn.mob.input.InputManager;
import net.play5d.kyo.air.socket.SocketServer;
import net.play5d.kyo.air.socket.events.SocketEvent;
import net.play5d.game.bvn.data.lan.UDPDataVO;
import net.play5d.game.bvn.mob.sockets.udp.UDPSocket;
import net.play5d.kyo.utils.JsonUtils;
import net.play5d.game.bvn.mob.utils.MsgType;
import net.play5d.game.bvn.mob.utils.SocketMsgFactory;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.utils.GameLogger;

public class LANServerCtrl extends EventDispatcher implements ILanServerLockLink {
    private static var _i:LANServerCtrl;

    public static function get I():LANServerCtrl {
        _i ||= new LANServerCtrl();
        return _i;
    }

    public var active:Boolean;
    private var _clientK:int;
    private var _serverK:int;
    private var _roster:LanServerRoom = new LanServerRoom();
    private var _match:LanServerMatch = new LanServerMatch();
    private var _udpClientIP:String;
    /**
     * 运行帧数
     */
    private var _renderFrame:uint;
    private var _renderFrameClient:uint;

    private var _renderNextFrame:uint;

    private var _renderSyncFrame:int;

    private var _sendUpdateFrame:int;

    private var _playerClient:ClientVO;

    private var _udpSocket:UDPSocket;

    private var _host:HostVO;

    public function get host():HostVO {
        return _host;
    }

    public function startServer(host:HostVO):void {
        _host = host;
        SocketServer.I.bind(LanPorts.TCP);
        SocketServer.I.addEventListener(SocketEvent.CLIENT_CONNECT, socketHandler);
        SocketServer.I.addEventListener(SocketEvent.CLIENT_DIS_CONNECT, socketHandler);
        SocketServer.I.addEventListener(SocketEvent.RECEIVE_DATA, socketDataHandler);

        _udpSocket = new UDPSocket();
        _udpSocket.listen(LanPorts.UDP_SERVER);
        _udpSocket.addDataHandler(udpDataHandler);
    }

    public function stopServer():void {
        _host = null;
        SocketServer.I.close();
        SocketServer.I.removeEventListener(SocketEvent.CLIENT_CONNECT, socketHandler);
        SocketServer.I.removeEventListener(SocketEvent.CLIENT_DIS_CONNECT, socketHandler);
        SocketServer.I.removeEventListener(SocketEvent.RECEIVE_DATA, socketDataHandler);

        if (_udpSocket) {
            _udpSocket.unListen();
            _udpSocket.removeDataHandler(udpDataHandler);
            _udpSocket = null;
        }

        _match.disposeLogics();

        _roster.clear();
        _host = null;

        _udpClientIP = null;
    }

    public function gameStart():void {
        active = true;
        _match.activate(function ():Boolean {
            return LANServerCtrl.I.renderGame();
        });
        _renderFrame = 1;

        _match.attach(
                this,
                InputManager.I.socket_input_p1,
                InputManager.I.socket_input_p2,
                sendTCP
        );
        _match.bindSync(sendTCP);

        LANGameCtrl.I.gameStart(_host);
    }

    public function gameEnd():void {
        active = false;
        _match.releaseLock();
        _match.disposeLogics();
        _match.unbindSync();

        LANGameCtrl.I.gameEnd();

        gameQuit();
    }

    public function gameQuit():void {
        active = false;
        _match.releaseLock();
        _match.unbindSync();
        LanGameMenuCtrl.I.dispose();

        stopServer();

        MainGame.stageCtrl.goStage(new MenuState());

    }

    public function renderGame():Boolean {
        return _match.render(MainGame.stageCtrl.currentStage is GameState, function ():void {
            InputManager.I.socket_input_p1.freeRender();
        });
    }

    public function sendGameStart():void {
        var data:Object = SocketMsgFactory.createStartGame();
        for each(var i:ClientVO in _roster.clients) {
            SocketServer.I.sendJson(i.socket, data);
        }
    }

    public function sendTCP(data:Object):void {
        for each(var i:ClientVO in _roster.clients) {
            SocketServer.I.send(i.socket, data);
        }
    }

    public function sendUDP(data:Object):void {
        if (_udpClientIP) {
            _udpSocket.send(_udpClientIP, LanPorts.UDP_CLIENT, data);
        }
    }

    private function udpDataHandler(d:UDPDataVO):void {

        var dataBytes:ByteArray = d.getDataByteArray();

        if (dataBytes && dataBytes.readByte() == MsgType.FIND_HOST) {
            if (!active) {
                _udpSocket.send(
                        d.fromIP, LanPorts.UDP_CLIENT, SocketMsgFactory.createFindHostBackMsg());
            }
            return;
        }

        if (_match.receiveInput(dataBytes)) {
            _udpClientIP = d.fromIP;
            return;
        }
    }

    private function receiveJson(msgObj:Object, clientSocket:Socket):void {
        switch (msgObj.type) {
        case MsgType.JOIN:
            receiveJoin(msgObj, clientSocket);
            break;
        case MsgType.JOIN_IN:
            break;
        }

    }

    private function receiveJoin(msgObj:Object, clientSocket:Socket):void {
        var cv:ClientVO = _roster.accept(clientSocket.remoteAddress, msgObj.name, clientSocket);
        if (!cv) {
            //超出人数限制
            SocketServer.I.sendJson(
                    clientSocket,
                    SocketMsgFactory.createJoinFailMsg(GetLang('txt.lan_server_ctrl.room_full'))
            );
            return;
        }

        _playerClient = cv;

        SocketServer.I.sendJson(cv.socket, SocketMsgFactory.createJoinSuccessMsg());

        dispatchEvent(new LanEvent(LanEvent.CLIENT_JOIN_SUCCESS));

    }

    private function findClient(socket:Socket):ClientVO {
        return _roster.find(socket);
    }

    private function socketHandler(e:SocketEvent):void {
        GameLogger.debug('net', String(e));
        switch (e.type) {
        case SocketEvent.CLIENT_CONNECT:


            break;
        case SocketEvent.CLIENT_DIS_CONNECT:

            if (active) {
                gameEnd();
                GameUI.alert(
                        GetLang('alert.lan_server_ctrl.player_exit_title'),
                        GetLang('alert.lan_server_ctrl.player_exit')
                );
            }

            _udpClientIP = null;

            break;
        }

    }

    private function socketDataHandler(e:SocketEvent):void {

        var obj:Object = e.getDataObject();

        if (!obj) {
            return;
        }

        if (_match.receiveSelect(obj)) {
            return;
        }

        var json:Object = JsonUtils.str2json(obj);
        if (json) {
            receiveJson(json, e.clientSocket);
        }
    }

}
}
