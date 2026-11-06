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
import net.play5d.game.bvn.interfaces.lan.ILanServerLockLink;
import net.play5d.game.bvn.ctrler.lan.LanGameMenuCtrl;
import net.play5d.game.bvn.ctrler.lan.LanServerMatch;
import net.play5d.game.bvn.ctrler.lan.LanServerRoom;
import net.play5d.game.bvn.stage.GameStage;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.data.lan.ClientVO;
import net.play5d.game.bvn.data.lan.LanPorts;
import net.play5d.game.bvn.win.data.HostVO;
import net.play5d.game.bvn.win.input.InputManager;
import net.play5d.kyo.air.socket.SocketServer;
import net.play5d.kyo.air.socket.events.SocketEvent;
import net.play5d.game.bvn.data.lan.UDPDataVO;
import net.play5d.game.bvn.win.sockets.udp.UDPSocket;
import net.play5d.kyo.utils.JsonUtils;
import net.play5d.game.bvn.ctrler.lan.LANUtils;
import net.play5d.game.bvn.win.utils.MsgType;
import net.play5d.game.bvn.win.utils.SocketMsgFactory;
import net.play5d.game.bvn.ui.dialog.LANExitDialog;
import net.play5d.game.bvn.win.views.lan.LANGameState;
import net.play5d.game.bvn.win.views.lan.LANRoomState;
import net.play5d.game.bvn.utils.GameLogger;

public class LANServerCtrl implements ILanServerLockLink {
    private static var _i:LANServerCtrl;

    public static function get I():LANServerCtrl {
        _i ||= new LANServerCtrl();
        return _i;
    }

    public var active:Boolean;
    public var onPlayerJoinSuccess:Function;
    private var _room:LANRoomState;
    private var _clientK:int;
    private var _serverK:int;
    private var _roster:LanServerRoom = new LanServerRoom();
    private var _match:LanServerMatch = new LanServerMatch();
    private var _udpClientMap:Object  = {};
    /**
     * 运行帧数
     */
    private var _renderFrame:uint;
    private var _renderFrameClient:uint;

    private var _renderNextFrame:uint;

    private var _renderSyncFrame:int;

    private var _sendUpdateFrame:int;

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
        SocketServer.I.bind(LanPorts.TCP);
        SocketServer.I.addEventListener(SocketEvent.CLIENT_CONNECT, socketHandler);
        SocketServer.I.addEventListener(SocketEvent.CLIENT_DIS_CONNECT, socketHandler);
        SocketServer.I.addEventListener(SocketEvent.RECEIVE_DATA, tcpDataHandler);

        _udpSocket = new UDPSocket();
        _udpSocket.listen(LanPorts.UDP_SERVER);
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

        _match.disposeLogics();

        _roster.clear();
        _room = null;
        _host = null;
    }

    public function sendChat(content:String, name:String = null):void {
        sendClientsChat(content, name);
        if (_room) {
            _room.pushChat(content, name);
        }
    }

    public function sendStart():void {
        var msg:Object = SocketMsgFactory.createStartGame();
        for each(var i:ClientVO in _roster.clients) {
            SocketServer.I.sendJson(i.socket, msg);
        }
        if (_room) {
            _room.startGameTimer();
            _room.lockStart();
        }
    }

    public function kickOut(id:String):void {

        var client:ClientVO;

        for (var i:int; i < _roster.clients.length; i++) {
            if (_roster.clients[i].id == id) {
                client = _roster.clients[i];

                SocketServer.I.sendJson(
                        client.socket,
                        SocketMsgFactory.createKickOutMsg(GetLang('lan.kick_out'))
                );

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
                client.socket.close();
            }
        }


    }

    public function gameStart():void {
        active = true;
        _match.activate(function ():Boolean {
            return LANServerCtrl.I.renderGame();
        });
        _renderFrame = 1;
        LANUtils.updateParams();
        _room = null;

        _match.attach(
                this,
                InputManager.I.socket_input_p1,
                InputManager.I.socket_input_p2,
                sendTCP
        );

        LanGameMenuCtrl.I.init(new LANExitDialog(
                function ():Boolean {
                    return LANClientCtrl.I.active;
                },
                function ():Boolean {
                    return LANServerCtrl.I.active;
                },
                function ():void {
                    LANClientCtrl.I.gameEnd();
                },
                function ():void {
                    LANServerCtrl.I.gameQuit();
                }
        ));

        _match.bindSync(sendTCP);
    }

    public function gameEnd():void {
        active = false;
        _match.releaseLock();
        _match.disposeLogics();
        _match.unbindSync();

        var room:LANRoomState = new LANRoomState();
        MainGame.stageCtrl.goStage(room);
        room.hostMode();

        LanGameMenuCtrl.I.dispose();
    }

    public function gameQuit():void {
        active = false;
        _match.releaseLock();
        _match.unbindSync();
        LanGameMenuCtrl.I.dispose();

        stopServer();

        MainGame.stageCtrl.goStage(new LANGameState());

    }

    public function renderGame():Boolean {
        return _match.render(MainGame.stageCtrl.currentStage is GameStage, function ():void {
            InputManager.I.socket_input_p1.freeRender();
        });
    }

    public function sendTCP(data:Object):void {
        for each(var i:ClientVO in _roster.clients) {
            SocketServer.I.send(i.socket, data);
        }
    }

    public function sendUDP(data:Object):void {
        for each(var i:String in _udpClientMap) {
            _udpSocket.send(i, LanPorts.UDP_CLIENT, data);
        }
    }

    private function udpDataHandler(d:UDPDataVO):void {

        if (d.getDataObject() && d.getDataObject().type == MsgType.FIND_HOST) {
            if (!active) {
                _udpSocket.send(d.fromIP, d.fromPort, SocketMsgFactory.createFindHostBackMsg());
            }
            return;
        }

        if (_match.receiveInput(d.getDataByteArray())) {
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
                sendChat(GetLang('lan.player_enter', {name: msgObj.name}));
            }
            break;
        case MsgType.CHAT:
            var cv:ClientVO = findClient(clientSocket);
            if (_room) {
                _room.pushChat(msgObj.msg, cv.name);
            }
            sendClientsChat(msgObj.msg, cv.name);
            break;
        }

    }

    private function receiveJoin(msgObj:Object, clientSocket:Socket):void {
        var cv:ClientVO = _roster.accept(clientSocket.remoteAddress, msgObj.name, clientSocket);
        if (!cv) {
            //超出人数限制
            SocketServer.I.sendJson(
                    clientSocket,
                    SocketMsgFactory.createJoinFailMsg(GetLang('lan.room_full'))
            );
            return;
        }

        if (_room) {
            _room.addPlayer(cv.ip, cv.name);
            sendChat(GetLang('lan.player_entering', {name: cv.name}));
            _room.setStartAble(false);
        }

        SocketServer.I.sendJson(cv.socket, SocketMsgFactory.createJoinSuccessMsg());

        if (onPlayerJoinSuccess != null) {
            onPlayerJoinSuccess();
            onPlayerJoinSuccess = null;
        }
    }

    private function findClient(socket:Socket):ClientVO {
        return _roster.find(socket);
    }

    private function sendClientsChat(content:String, name:String):void {
        var msg:Object = SocketMsgFactory.createChat(content, name);
        for each(var i:ClientVO in _roster.clients) {
            SocketServer.I.sendJson(i.socket, msg);
        }
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
                        GetLang('lan.player_exit.title'),
                        GetLang('lan.player_exit')
                );
            }
            var client:ClientVO = _roster.remove(e.clientSocket);
            if (client && _room) {
                _room.removePlayer(client.ip);
                _room.pushChat(GetLang('lan.player_exit_chat', {name: client.name}));
                _room.setStartAble(false);
            }

            break;
        }
    }

    private function tcpDataHandler(e:SocketEvent):void {
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
