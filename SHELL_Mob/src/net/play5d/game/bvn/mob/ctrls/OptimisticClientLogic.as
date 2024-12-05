package net.play5d.game.bvn.mob.ctrls {
import flash.utils.ByteArray;
import flash.utils.getTimer;

import net.play5d.game.bvn.cntlr.game_ctrls.GameCtrl;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.mob.input.InputManager;
import net.play5d.game.bvn.mob.utils.LANUtils;

/**
 * 乐观锁帧算法，客户端
 */
public class OptimisticClientLogic {

    public function OptimisticClientLogic() {
    }
    public var enabled:Boolean = true;
    private var _updateCache:Object = {};
    private var _clientK:int;
    private var _serverK:int;
    private var _clientFrame:uint;
    private var _serverFrame:uint;
    private var _serverNextFrame:uint;
    private var _lastSendK:int;
    private var _delayTimer:int = 0;

    public function reset():void {
        _updateCache     = {};
        _clientK         = 0;
        _serverK         = 0;
        _clientFrame     = 0;
        _serverFrame     = 0;
        _serverNextFrame = 0;
        _lastSendK       = 0;
    }

    public function dispose():void {
        _updateCache = {};
    }

    public function receiveUpdate(data:Object):Boolean {
        if (data is ByteArray) {
            var msgArr:ByteArray = data as ByteArray;

            msgArr.position = 0;

            var key:int = msgArr.readByte();

            if (key != LANUtils.INPUT_KEY) {
                return false;
            }

            _serverFrame += LANUtils.LOCK_KEYFRAME;

            _serverK = msgArr.readShort();
            _clientK = msgArr.readShort();

//				var syncArr:Array = msgArr.readObject();
//				if(syncArr){
//					_updateCache = {};
//					syncRenderGame(syncArr);
//				}

            _serverNextFrame = _serverFrame + LANUtils.LOCK_KEYFRAME;

            cacheUpdate();

            var delay:int = getTimer() - _delayTimer;
            LANClientCtrl.I.updateDelay(delay);

            _delayTimer = getTimer();

            sendCtrl(true);

            return true;
        }

        if (data is Array) {
            _updateCache = {};
            syncRenderGame(data as Array);
            return true;
        }

        return false;

    }

    public function render():Boolean {

        if (!enabled) {
            return true;
        }

        if (_serverNextFrame == 0 && _serverFrame == 0) {
            //通知服务端，客户端已准备
            var byte:ByteArray = new ByteArray();
            byte.writeByte(LANUtils.INPUT_KEY);
//				byte.writeShort(0);
            byte.writeShort(0);
            LANClientCtrl.I.sendTCP(byte);
            return false;
        }

        if (_clientFrame < _serverNextFrame) {
            _clientFrame++;
            sendCtrl();
            renderUpdate();
            return true;
        }
        return false;
    }

    private function syncRenderGame(arr:Array):void {
        //frame,round,time,p1hp,p1x,p1y,p2hp,p2x,p2y

        var frame:int = arr[0];
        var round:int = arr[1];
        var time:int  = arr[2];

        var p1hp:int = arr[3];
        var p1qi:int = arr[4];
        var p1x:int  = arr[5];
        var p1y:int  = arr[6];

        var p2hp:int = arr[7];
        var p2qi:int = arr[8];
        var p2x:int  = arr[9];
        var p2y:int  = arr[10];

        _serverFrame = frame;

//			_renderFrame = _serverFrame - LANUtils.LOCK_KEYFRAME;
        _clientFrame = _serverFrame;

        try {

            if (GameCtrl.I.gameRunData.round != round) {
                LANClientCtrl.I.syncError(true);
                return;
            }

            GameCtrl.I.gameRunData.gameTime = time;

            var p1:FighterMain = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
            var p2:FighterMain = GameCtrl.I.gameRunData.p2FighterGroup.currentFighter;

            p1.hp = p1hp;
            p1.qi = p1qi;
            p1.x  = p1x;
            p1.y  = p1y;

            p2.hp = p2hp;
            p2.qi = p2qi;
            p2.x  = p2x;
            p2.y  = p2y;

            if (p1.hp > 0 && !p1.isAlive) {
                p1.relive();
            }

            if (p2.hp > 0 && !p1.isAlive) {
                p2.relive();
            }

            LANClientCtrl.I.resetSyncError();
        }
        catch (e:Error) {
            trace(e);
            LANClientCtrl.I.syncError(true);
        }
    }

    private function sendCtrl(sendAnyWay:Boolean = false):void {
//			InputManager.I.socket_input_p2.renderInput();

        var k:int = InputManager.I.socket_input_p2.getSocketData();
        if (_lastSendK == k && !sendAnyWay) {
            return;
        }

        InputManager.I.socket_input_p2.resetInput();
//			LANClientCtrl.I.send([_clientFrame , k]);

        var byte:ByteArray = new ByteArray();
        byte.writeByte(LANUtils.INPUT_KEY);
//			byte.writeShort(_clientFrame);
        byte.writeShort(k);
        LANClientCtrl.I.sendTCP(byte);

        _lastSendK = k;
    }


    private function cacheUpdate():void {
        for (var i:int = _serverFrame; i < _serverNextFrame; i++) {
            _updateCache[i] = [_serverK, _clientK];
        }
    }

    private function renderUpdate():void {
        var cacheKeys:Array = _updateCache[_clientFrame];
        if (cacheKeys) {
            InputManager.I.socket_input_p1.setSocketData(cacheKeys[0]);
            InputManager.I.socket_input_p2.setSocketData(cacheKeys[1]);
        }
    }


}
}
