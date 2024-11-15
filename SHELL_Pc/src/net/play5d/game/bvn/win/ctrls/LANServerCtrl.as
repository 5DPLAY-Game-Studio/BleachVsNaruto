/*
 * Copyright (C) 2021-2024, 5DPLAY Game Studio
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package net.play5d.game.bvn.win.ctrls {
import flash.net.Socket;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.GameRunDataVO;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.stage.GameStage;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.win.data.ClientVO;
import net.play5d.game.bvn.win.data.HostVO;
import net.play5d.game.bvn.win.input.InputManager;
import net.play5d.game.bvn.win.sockets.SocketServer;
import net.play5d.game.bvn.win.sockets.events.SocketEvent;
import net.play5d.game.bvn.win.sockets.udp.UDPDataVO;
import net.play5d.game.bvn.win.sockets.udp.UDPSocket;
import net.play5d.game.bvn.win.utils.JsonUtils;
import net.play5d.game.bvn.win.utils.LANUtils;
import net.play5d.game.bvn.win.utils.LanSyncType;
import net.play5d.game.bvn.win.utils.LockFrameLogic;
import net.play5d.game.bvn.win.utils.MsgType;
import net.play5d.game.bvn.win.utils.SocketMsgFactory;
import net.play5d.game.bvn.win.views.lan.LANGameState;
import net.play5d.game.bvn.win.views.lan.LANRoomState;

public class LANServerCtrl {
    private static var _i:LANServerCtrl;

    public static function get I():LANServerCtrl {
        _i ||= new LANServerCtrl();
        return _i;
    }

    public function LANServerCtrl() {
    }
    public var active:Boolean;
    public var onPlayerJoinSuccess:Function;
    private var _room:LANRoomState;
    private var _clientK:int;
    private var _serverK:int;
    private var _clients:Vector.<ClientVO> = new Vector.<ClientVO>();
    private var _udpClientMap:Object       = {};
    /**
     * 运行帧数
     */
    private var _renderFrame:uint;
    private var _renderFrameClient:uint;

    private var _renderNextFrame:uint;

    private var _renderSyncFrame:int;

    private var _sendUpdateFrame:int;

    private var _selectLogic:SelectFighterServerLogic;
    private var _connGameLogic:LockFrameServerLogic;

    private var _udpSocket:UDPSocket;
    private var _kickTimeoutInt:int;

    private var _host:HostVO;

    public function get host():HostVO {
        return _host;
    }

    public function setRoom(v:LANRoomState):void {
        _room = v;
        _room.setStartAble(false);
    }

    public function startServer(host:HostVO):void {
        _host = host;
        SocketServer.I.bind(LANGameCtrl.PORT_TCP);
        SocketServer.I.addEventListener(SocketEvent.CLIENT_CONNECT, socketHandler);
        SocketServer.I.addEventListener(SocketEvent.CLIENT_DIS_CONNECT, socketHandler);
        SocketServer.I.addEventListener(SocketEvent.RECEIVE_DATA, tcpDataHandler);

        _udpSocket = new UDPSocket();
        _udpSocket.listen(LANGameCtrl.PORT_UDP_SERVER);
        _udpSocket.addDataHandler(udpDataHandler);

    }

    public function stopServer():void {
        _host = null;
        SocketServer.I.close();
        SocketServer.I.removeEventListener(SocketEvent.CLIENT_CONNECT, socketHandler);
        SocketServer.I.removeEventListener(SocketEvent.CLIENT_DIS_CONNECT, socketHandler);
        SocketServer.I.removeEventListener(SocketEvent.RECEIVE_DATA, tcpDataHandler);

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
        _room    = null;
        _host    = null;
    }

    public function sendChart(chart:String, name:String = null):void {
        sendClientsChart(chart, name);
        if (_room) {
            _room.pushChart(chart, name);
        }
    }

    public function sendStart():void {
        var msg:Object = SocketMsgFactory.createStartGame();
        for each(var i:ClientVO in _clients) {
            SocketServer.I.sendJson(i.socket, msg);
        }
        if (_room) {
            _room.startGameTimer();
            _room.lockStart();
        }
    }

    public function kickOut(id:String):void {

        var client:ClientVO;

        for (var i:int; i < _clients.length; i++) {
            if (_clients[i].id == id) {
                client = _clients[i];

                SocketServer.I.sendJson(client.socket, SocketMsgFactory.createKickOutMsg('你已被踢出房间'));

                if (_kickTimeoutInt == 0) {
                    _kickTimeoutInt = setTimeout(kickTimeout, 3000);
                }
                else {
                    clearTimeout(_kickTimeoutInt);
                    kickTimeout();
                }

                return;
            }
        }

        function kickTimeout():void {

            _kickTimeoutInt = 0;

            if (client && client.socket.connected) {
//					view.removePlayer(id);
//					_clients.splice(i,1);
                client.socket.close();
            }
        }


    }

    public function gameStart():void {
        active = true;
        GameInterface.instance.updateInputConfig();
        LockFrameLogic.I.initServer();
        _renderFrame = 1;
        LANUtils.updateParams();
        _room = null;

        _selectLogic = new SelectFighterServerLogic();
        _selectLogic.init();

        _connGameLogic = new LockFrameServerLogic();

        LanGameMenuCtrl.I.init();

        initSyncEvent();
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

        var room:LANRoomState = new LANRoomState();
        MainGame.stageCtrl.goStage(room);
        room.hostMode();

        LanGameMenuCtrl.I.dispose();
    }

    public function gameQuit():void {
        active = false;
        GameInterface.instance.updateInputConfig();
        LockFrameLogic.I.dispose();

        disposeSyncEvent();
        LanGameMenuCtrl.I.dispose();

        stopServer();

        MainGame.stageCtrl.goStage(new LANGameState());

    }

    public function renderGame():Boolean {
        if (MainGame.stageCtrl.currentStage is GameStage) {
            return _connGameLogic.render();
        }

        InputManager.I.socket_input_p1.freeRender();

        return true;
    }

    public function sendTCP(data:Object):void {
        for each(var i:ClientVO in _clients) {
            SocketServer.I.send(i.socket, data);
        }
    }

    public function sendUDP(data:Object):void {
        for each(var i:String in _udpClientMap) {
            _udpSocket.send(i, LANGameCtrl.PORT_UDP_CLIENT, data);
        }
    }

    private function udpDataHandler(d:UDPDataVO):void {

        if (d.getDataObject() && d.getDataObject().type == MsgType.FIND_HOST) {
            if (!active) {
                _udpSocket.send(d.fromIP, d.fromPort, SocketMsgFactory.createFindHostBackMsg());
            }
            return;
        }

        if (_connGameLogic && _connGameLogic.receiveInput(d.getDataByteArray())) {
            _udpClientMap[d.fromIP + ':' + d.fromPort] = d.fromIP;
            return;
        }
    }

    private function receiveJson(msgObj:Object, clientSocket:Socket):void {
        switch (msgObj.type) {
        case MsgType.JOIN:
            receiveJoin(msgObj, clientSocket);
            break;
        case MsgType.JOIN_IN:
            if (_room) {
                _room.setStartAble(true);
                sendChart(msgObj.name + '进入房间');
            }
            break;
        case MsgType.CHART:
            var cv:ClientVO = findClient(clientSocket);
            if (_room) {
                _room.pushChart(msgObj.msg, cv.name);
            }
            sendClientsChart(msgObj.msg, cv.name);
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
        if (_room) {
            _room.addPlayer(cv.ip, cv.name);
            sendChart(cv.name + '正在进入房间...');
            _room.setStartAble(false);
        }

        SocketServer.I.sendJson(cv.socket, SocketMsgFactory.createJoinSuccMsg());

        if (onPlayerJoinSuccess != null) {
            onPlayerJoinSuccess();
            onPlayerJoinSuccess = null;
        }
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

    private function sendClientsChart(chart:String, name:String):void {
        var msg:Object = SocketMsgFactory.createChart(chart, name);
        for each(var i:ClientVO in _clients) {
            SocketServer.I.sendJson(i.socket, msg);
        }
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
            for (var i:int; i < _clients.length; i++) {
                if (_clients[i].socket == e.clientSocket) {
                    if (_room) {
                        _room.removePlayer(_clients[i].ip);
                        _room.pushChart(_clients[i].name + '退出房间');
                        _room.setStartAble(false);
                    }
                    _clients.splice(i, 1);
                }
            }

            break;
        }
    }

    private function tcpDataHandler(e:SocketEvent):void {
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
//			sendAll(data);
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
