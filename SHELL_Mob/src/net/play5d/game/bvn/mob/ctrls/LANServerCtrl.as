package net.play5d.game.bvn.mob.ctrls {
import flash.events.EventDispatcher;
import flash.net.Socket;
import flash.utils.ByteArray;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.GameRunDataVO;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.mob.data.ClientVO;
import net.play5d.game.bvn.mob.data.HostVO;
import net.play5d.game.bvn.mob.events.LanEvent;
import net.play5d.game.bvn.mob.input.InputManager;
import net.play5d.game.bvn.mob.sockets.SocketServer;
import net.play5d.game.bvn.mob.sockets.events.SocketEvent;
import net.play5d.game.bvn.mob.sockets.udp.UDPDataVO;
import net.play5d.game.bvn.mob.sockets.udp.UDPSocket;
import net.play5d.game.bvn.mob.utils.JsonUtils;
import net.play5d.game.bvn.mob.utils.LanSyncType;
import net.play5d.game.bvn.mob.utils.LockFrameLogic;
import net.play5d.game.bvn.mob.utils.MsgType;
import net.play5d.game.bvn.mob.utils.SocketMsgFactory;
import net.play5d.game.bvn.ui.GameUI;

public class LANServerCtrl extends EventDispatcher {
    private static var _i:LANServerCtrl;

    public static function get I():LANServerCtrl {
        _i ||= new LANServerCtrl();
        return _i;
    }

    public function LANServerCtrl() {
    }
    public var active:Boolean;
    private var _clientK:int;
    private var _serverK:int;
    private var _clients:Vector.<ClientVO> = new Vector.<ClientVO>();
    private var _udpClientIP:String;
    /**
     * 运行帧数
     */
    private var _renderFrame:uint;
    private var _renderFrameClient:uint;

    private var _renderNextFrame:uint;

    private var _renderSyncFrame:int;

//		private var _renderNextFrameDelay:int;
//		private var _updateServerInputDelay:int;

    private var _sendUpdateFrame:int;

    private var _selectLogic:SelectFighterServerLogic;
//		private var _connGameLogic:OptimisticServerLogic;
//		private var _connGameLogic:SimpleLockFrameServerLogic;
    private var _connGameLogic:LockFrameServerLogic;

    private var _playerClient:ClientVO;

    private var _udpSocket:UDPSocket;

    private var _host:HostVO;

    public function get host():HostVO {
        return _host;
    }

    public function startServer(host:HostVO):void {
        _host = host;
        SocketServer.I.bind(LANGameCtrl.PORT_TCP);
        SocketServer.I.addEventListener(SocketEvent.CLIENT_CONNECT, socketHandler);
        SocketServer.I.addEventListener(SocketEvent.CLIENT_DIS_CONNECT, socketHandler);
        SocketServer.I.addEventListener(SocketEvent.RECEIVE_DATA, socketDataHandler);

        _udpSocket = new UDPSocket();
        _udpSocket.listen(LANGameCtrl.PORT_UDP_SERVER);
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

        if (_selectLogic) {
            _selectLogic.dispose();
            _selectLogic = null;
        }
        if (_connGameLogic) {
            _connGameLogic.dispose();
            _connGameLogic = null;
        }

        _clients = new Vector.<ClientVO>();
        _host    = null;

        _udpClientIP = null;
    }

    public function gameStart():void {
        active = true;
        GameInterface.instance.updateInputConfig();
        LockFrameLogic.I.initServer();
        _renderFrame = 1;

        _selectLogic = new SelectFighterServerLogic();
        _selectLogic.init();

//			_connGameLogic = new OptimisticServerLogic();
//			_connGameLogic = new SimpleLockFrameServerLogic();
        _connGameLogic = new LockFrameServerLogic();

        initSyncEvent();

        LANGameCtrl.I.gameStart(_host);
    }

    public function gameEnd():void {
        active = false;
        GameInterface.instance.updateInputConfig();
        LockFrameLogic.I.dispose();

        if (_selectLogic) {
            _selectLogic.dispose();
            _selectLogic = null;
        }
        if (_connGameLogic) {
            _connGameLogic.dispose();
            _connGameLogic = null;
        }

        disposeSyncEvent();

        LANGameCtrl.I.gameEnd();

        gameQuit();
    }

    public function gameQuit():void {
        active = false;
        GameInterface.instance.updateInputConfig();
        LockFrameLogic.I.dispose();

        disposeSyncEvent();
        LanGameMenuCtrl.I.dispose();

        stopServer();

        MainGame.stageCtrl.goStage(new MenuState());

    }

    public function renderGame():Boolean {
        if (MainGame.stageCtrl.currentStage is GameState) {
            return _connGameLogic.render();
        }

        InputManager.I.socket_input_p1.freeRender();

        return true;
    }

    public function sendGameStart():void {
        var data:Object = SocketMsgFactory.createStartGame();
        for each(var i:ClientVO in _clients) {
            SocketServer.I.sendJson(i.socket, data);
        }
    }

    public function sendTCP(data:Object):void {
        for each(var i:ClientVO in _clients) {
            SocketServer.I.send(i.socket, data);
        }
    }

    public function sendUDP(data:Object):void {
        if (_udpClientIP) {
            _udpSocket.send(_udpClientIP, LANGameCtrl.PORT_UDP_CLIENT, data);
        }
    }

    private function udpDataHandler(d:UDPDataVO):void {

        var dataBytes:ByteArray = d.getDataByteArray();

        if (dataBytes && dataBytes.readByte() == MsgType.FIND_HOST) {
            if (!active) {
                _udpSocket.send(
                        d.fromIP, LANGameCtrl.PORT_UDP_CLIENT, SocketMsgFactory.createFindHostBackMsg());
            }
            return;
        }

        if (_connGameLogic && _connGameLogic.receiveInput(dataBytes)) {
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
        if (_clients.length > 0) {
            //超出人数限制
            //					e.clientSocket.close();
            SocketServer.I.sendJson(clientSocket, SocketMsgFactory.createJoinFailMsg('人数已满'));
            return;
        }


        var cv:ClientVO = new ClientVO();
        cv.ip           = clientSocket.remoteAddress;
        cv.name         = msgObj.name;
        cv.socket       = clientSocket;

        _clients.push(cv);
        _playerClient = cv;


        SocketServer.I.sendJson(cv.socket, SocketMsgFactory.createJoinSuccMsg());

        dispatchEvent(new LanEvent(LanEvent.CLIENT_JOIN_SUCCESS));

    }

    private function findClient(socket:Socket):ClientVO {
        for each(var i:ClientVO in _clients) {
            if (i.socket == socket) {
                return i;
            }
//				if(i.socket.remoteAddress == socket.remoteAddress) return i;
        }
        return null;
    }

    private function initSyncEvent():void {

        GameEvent.addEventListener(GameEvent.ROUND_END, onGameRoundEnd);
        GameEvent.addEventListener(GameEvent.GAME_START, onGameStart);
        GameEvent.addEventListener(GameEvent.GAME_END, onGameEnd);
        GameEvent.addEventListener(GameEvent.ROUND_START, onRoundStart);
    }

    private function disposeSyncEvent():void {
        GameEvent.removeEventListener(GameEvent.ROUND_END, onGameRoundEnd);
        GameEvent.removeEventListener(GameEvent.GAME_START, onGameStart);
        GameEvent.removeEventListener(GameEvent.GAME_END, onGameEnd);
        GameEvent.removeEventListener(GameEvent.ROUND_START, onRoundStart);
    }

    private function socketHandler(e:SocketEvent):void {
        trace(e);
        switch (e.type) {
        case SocketEvent.CLIENT_CONNECT:


            break;
        case SocketEvent.CLIENT_DIS_CONNECT:

            if (active) {
                gameEnd();
                GameUI.alert('PLAYER EXIT', '玩家退出房间');
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

        if (_selectLogic && _selectLogic.receiveSelect(obj)) {
            return;
        }

        var json:Object = JsonUtils.str2json(obj);
        if (json) {
            receiveJson(json, e.clientSocket);
        }
    }

    private function onGameStart(e:GameEvent):void {
        //SYNC,type,round

        _connGameLogic.enabled = true;
        _connGameLogic.reset();

        var data:Array = ['SYNC', LanSyncType.GAME_START];
        sendTCP(data);
    }

    private function onGameEnd(e:GameEvent):void {

        _connGameLogic.enabled = false;
        _connGameLogic.reset();

        var data:Array = ['SYNC', LanSyncType.GAME_FINISH];
        sendTCP(data);
    }

    private function onRoundStart(e:GameEvent):void {
        //SYNC,type,round
//			var data:Array = ['SYNC' , LanSyncType.ROUND_START , GameCtrl.I.gameRunData.round];
//			sendTCP(data);
        _connGameLogic.enabled = true;
    }

    private function onGameRoundEnd(e:GameEvent):void {
        //SYNC,type,round,p1hp,p2hp
        var runData:GameRunDataVO = GameCtrl.I.gameRunData;
        var p1:FighterMain        = runData.p1FighterGroup.currentFighter;
        var p2:FighterMain        = runData.p2FighterGroup.currentFighter;
        var data:Array            = [
            'SYNC', LanSyncType.ROUND_FINISH,
            runData.round, runData.isTimerOver, runData.isDrawGame,
            p1.hp << 0, p2.hp << 0
        ];
        sendTCP(data);

        _connGameLogic.enabled = false;
        _connGameLogic.reset();
    }

}
}
