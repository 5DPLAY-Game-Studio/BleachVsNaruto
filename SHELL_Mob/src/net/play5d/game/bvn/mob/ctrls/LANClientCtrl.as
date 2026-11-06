package net.play5d.game.bvn.mob.ctrls {
import flash.events.TimerEvent;
import flash.utils.ByteArray;
import flash.utils.Timer;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.stage.LoadingStage;
import net.play5d.game.bvn.interfaces.lan.ILanClientLockLink;
import net.play5d.game.bvn.ctrler.lan.LanClientMatch;
import net.play5d.game.bvn.data.lan.LanPorts;
import net.play5d.game.bvn.mob.data.HostVO;
import net.play5d.game.bvn.mob.input.InputManager;
import net.play5d.kyo.air.socket.SocketClient;
import net.play5d.kyo.air.socket.events.SocketEvent;
import net.play5d.game.bvn.data.lan.UDPDataVO;
import net.play5d.game.bvn.mob.sockets.udp.UDPSocket;
import net.play5d.kyo.utils.JsonUtils;
import net.play5d.game.bvn.mob.utils.MsgType;
import net.play5d.game.bvn.mob.utils.SocketMsgFactory;
import net.play5d.game.bvn.ui.GameUI;

public class LANClientCtrl implements ILanClientLockLink {
    private static var _i:LANClientCtrl;

    public static function get I():LANClientCtrl {
        _i ||= new LANClientCtrl();
        return _i;
    }

    public var active:Boolean;
    private var _match:LanClientMatch = new LanClientMatch();
    private var _socket:SocketClient;
    private var _udpSocket:UDPSocket;
    private var _host:HostVO;
    private var _joinBack:Function;
    private var _onFindHostBack:Function;
    private var _findHostTimer:Timer;

    public function initialize():void {
        if (!_udpSocket) {
            _udpSocket = new UDPSocket();
            _udpSocket.listen(LanPorts.UDP_CLIENT);
            _udpSocket.addDataHandler(udpDataHandler);
        }
    }

    public function findHost(back:Function):void {
        _onFindHostBack = back;

        if (!_findHostTimer) {
            _findHostTimer = new Timer(2000);
            _findHostTimer.addEventListener(TimerEvent.TIMER, findHostTimerHandler);
        }

        _findHostTimer.reset();
        _findHostTimer.start();

        findHostTimerHandler(null);
    }

    public function cancelFindHost():void {
        _onFindHostBack = null;
        if (_findHostTimer) {
            _findHostTimer.stop();
            _findHostTimer.removeEventListener(TimerEvent.TIMER, findHostTimerHandler);
            _findHostTimer = null;
        }
    }

    /**
     * 更新延迟（毫秒）
     */
    public function updateDelay(v:int):void {
        _match.updateDelay(v);
    }

    public function join(host:HostVO, back:Function):void {
        _host     = host;
        _joinBack = back;
        initTcp(host);
    }

    public function sendJoinIn():void {
        _socket.sendJSON(SocketMsgFactory.createJoinInMsg());
    }

    public function dispose():void {
        cancelFindHost();
        disposeTcp();
        disposeUdp();
        _match.unlistenRound();
    }

    public function sendTCP(o:Object):void {
        if (_socket) {
            _socket.send(o);
        }
    }

    public function sendUDP(o:Object):void {
        if (_udpSocket) {
            _udpSocket.send(_host.ip, LanPorts.UDP_SERVER, o);
        }
    }

    public function gameStart(host:HostVO):void {
        active = true;

        _match.showDelay();
        _match.attach(
                200,
                this,
                InputManager.I.socket_input_p1,
                InputManager.I.socket_input_p2,
                sendTCP,
                onSyncFatalError
        );
        _match.arm(function ():Boolean {
            return LANClientCtrl.I.renderGame();
        }, function (enabled:Boolean):void {
            LoadingStage.AUTO_START_GAME = enabled;
        });
        _match.listenRound();

        LANGameCtrl.I.gameStart(host);

    }

    public function gameEnd():void {
        active = false;
        _match.detach();
        _match.disarm(function (enabled:Boolean):void {
            LoadingStage.AUTO_START_GAME = enabled;
        });

        dispose();

        LANGameCtrl.I.gameEnd();
    }

    public function renderGame():Boolean {
        return _match.render(MainGame.stageCtrl.currentStage is GameState, function ():void {
            InputManager.I.socket_input_p2.freeRender();
        });
    }

    public function resetSyncError():void {
        _match.resetSyncError();
    }

    public function syncError(wait:Boolean = false):void {
        _match.syncError(wait);
    }

    private function onSyncFatalError():void {
        gameEnd();
        GameUI.alert(
                GetLang('lan.disconnect.title'),
                GetLang('lan.disconnect_error')
        );
    }

    private function receiveHostHandler(data:UDPDataVO):Boolean {
        if (!_findHostTimer) {
            return false;
        }
        var dataBytes:ByteArray = data.getDataByteArray();
        if (dataBytes && dataBytes.readByte() != MsgType.FIND_HOST_BACK) {
            return false;
        }

        if (_onFindHostBack != null) {
            var hv:HostVO = new HostVO();
            hv.readByteArray(dataBytes);
            hv.ip = data.fromIP;
            _onFindHostBack(hv);
        }
        return true;
    }

    private function udpDataHandler(data:UDPDataVO):void {
        if (receiveHostHandler(data)) {
            return;
        }
        if (_match.receiveUdp(data.getDataByteArray())) {
            return;
        }
    }

    private function initTcp(host:HostVO):void {
        if (_socket) {
            dispose();
        }
        _socket = new SocketClient();
        _socket.addEventListener(SocketEvent.CLIENT_CONNECT, socketHandler);
        _socket.addEventListener(SocketEvent.CLOSE, socketHandler);
        _socket.addEventListener(SocketEvent.RECEIVE_DATA, socketHandler);
        _socket.connect(host.ip, LanPorts.TCP);
    }

    private function disposeTcp():void {
        if (_socket) {
            _socket.removeEventListener(SocketEvent.CLIENT_CONNECT, socketHandler);
            _socket.removeEventListener(SocketEvent.CLOSE, socketHandler);
            _socket.removeEventListener(SocketEvent.RECEIVE_DATA, socketHandler);
            _socket.close();
            _socket = null;
        }
    }

    private function disposeUdp():void {
        if (_udpSocket) {
            _udpSocket.unListen();
            _udpSocket.removeDataHandler(udpDataHandler);
            _udpSocket = null;
        }
    }

    private function receiveJson(o:Object):void {
        switch (o.type) {
        case MsgType.JOIN_BACK:
            var succ:Boolean = o.success;
            if (_joinBack != null) {
                _joinBack(succ);
                _joinBack = null;
            }
            if (!succ) {
                dispose();
            }
            break;
        case MsgType.START_GAME:
            gameStart(_host);
            break;
        }
    }

    private function findHostTimerHandler(e:TimerEvent):void {
        _udpSocket.sendBroadcast(LanPorts.UDP_SERVER, SocketMsgFactory.createFindHostMsg());
    }

    private function socketHandler(e:SocketEvent):void {
        switch (e.type) {
        case SocketEvent.CLIENT_CONNECT:
            _socket.sendJSON(SocketMsgFactory.createJoinMsg());
            break;
        case SocketEvent.CLOSE:
            if (active) {
                gameEnd();
                GameUI.alert(
                        GetLang('lan.disconnect.title'),
                        GetLang('lan.disconnect_host')
                );
            }
            else {
                dispose();
            }
            break;
        case SocketEvent.RECEIVE_DATA:
            onReceiveData(e);
            break;
        }
    }

    private function onReceiveData(e:SocketEvent):void {
        var obj:Object = e.getDataObject();

        if (!obj) {
            return;
        }

        if (_match.receiveSelect(obj)) {
            return;
        }

        if (_match.receiveSync(obj)) {
            return;
        }

        var json:Object = JsonUtils.str2json(obj);
        if (json) {
            receiveJson(json);
        }

    }

}
}
