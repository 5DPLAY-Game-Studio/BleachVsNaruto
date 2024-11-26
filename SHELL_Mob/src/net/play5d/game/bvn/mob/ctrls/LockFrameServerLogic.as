package net.play5d.game.bvn.mob.ctrls {
import flash.utils.ByteArray;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.GameRunDataVO;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.mob.input.InputManager;
import net.play5d.game.bvn.mob.utils.LANUtils;
import net.play5d.game.bvn.mob.utils.MsgType;

/**
 * 锁帧算法，服务端
 */
public class LockFrameServerLogic {
    public function LockFrameServerLogic() {
    }
    public var enabled:Boolean = true;
    private var _clientFrame:int;
    private var _renderFrame:int;
    private var _renderNextFrame:int;
    private var _renderSyncFrame:int;
    private var _clientK:int = -1;
    private var _serverK:int = 0;
    private var _syncUpdateArr:ByteArray;
    private var _sendUpdateFrame:int;
    private var _sendUpdateSyncFrame:int;
    private var _updateCache:Object = {};

    public function reset():void {
        _renderFrame     = 0;
        _renderNextFrame = 0;
        _clientK         = -1;
        _serverK         = 0;
        _syncUpdateArr   = null;
        _sendUpdateFrame = 0;
    }

    public function dispose():void {

    }

    public function render():Boolean {

        if (!enabled) {
            return true;
        }
        if (_clientK == -1) {
            return false;
        } //等待客户端

        //客户端与服务器相差时间较大，等待客户端
        if (_renderFrame > _clientFrame + LANUtils.LOCK_KEYFRAME) {
            if (_sendUpdateFrame == 0) {
                sendUpdate();
            }
            if (_sendUpdateSyncFrame == 0) {
                sendSyncUpdate();
            }

            if (++_sendUpdateFrame > LANUtils.LOCK_KEYFRAME) {
                _sendUpdateFrame = 0;
            }
            if (++_sendUpdateSyncFrame > LANUtils.SYNC_GAP) {
                _sendUpdateSyncFrame = 0;
            }
            return false;
        }

        InputManager.I.socket_input_p1.renderInput();

        if (_renderFrame % LANUtils.LOCK_KEYFRAME == 0) {

            if (_syncUpdateArr) {
                sendSyncUpdate();
                _renderSyncFrame = 0;
                _syncUpdateArr   = null;
            }

            sendUpdate();
        }

        _renderFrame++;
        _renderSyncFrame++;

        renderUpdate();

        if (_renderSyncFrame > LANUtils.SYNC_GAP) {
            _syncUpdateArr = getSyncUpdate();
        }

        return true;
    }

    public function receiveInput(kb:ByteArray):Boolean {
        if (!kb) {
            return false;
        }

        kb.position  = 0;
        var type:int = kb.readByte();

        if (type != MsgType.INPUT_SEND) {
            return false;
        }

        _clientFrame = kb.readShort();
        _clientK     = kb.readShort();

        //			_clientFrame = k[0];
        //			_clientK = k[1];
        return true;
    }

    private function sendStart():void {
        var updateArr:Array = [_serverK, 0];
        LANServerCtrl.I.sendTCP(updateArr);
    }

    private function sendUpdate():void {
        _renderNextFrame = _renderFrame + LANUtils.LOCK_KEYFRAME;

        _serverK = InputManager.I.socket_input_p1.getSocketData();

        InputManager.I.socket_input_p1.resetInput();

        var updateByte:ByteArray = new ByteArray();
        updateByte.writeByte(MsgType.INPUT_UPDATE);
        updateByte.writeShort(_renderFrame);
        updateByte.writeShort(_serverK);
        updateByte.writeShort(_clientK);

        LANServerCtrl.I.sendUDP(updateByte);

        cacheUpdate();
    }

    private function sendSyncUpdate():void {
        if (!_syncUpdateArr) {
            return;
        }
        _updateCache = {};
        LANServerCtrl.I.sendUDP(_syncUpdateArr);
    }

    //伪客户端逻辑 ***************************************************************************************

    private function getSyncUpdate():ByteArray {

        //frame,round,time,p1hp,p1x,p1y,p2hp,p2x,p2y

        var curStg:Istage = MainGame.stageCtrl.currentStage;

        if (curStg is GameState) {
            if (GameCtrl.I.actionEnable) {
                var runData:GameRunDataVO = GameCtrl.I.gameRunData;
                var p1:FighterMain        = runData.p1FighterGroup.currentFighter;
                var p2:FighterMain        = runData.p2FighterGroup.currentFighter;

                var byte:ByteArray = new ByteArray();
                byte.writeByte(MsgType.INPUT_SYNC);
                byte.writeShort(_renderFrame);
                byte.writeByte(runData.round);
                byte.writeByte(runData.gameTime);

                byte.writeShort(p1.hp << 0);
                byte.writeShort(p1.qi << 0);
                byte.writeShort(p1.x << 0);
                byte.writeShort(p1.y << 0);

                byte.writeShort(p2.hp << 0);
                byte.writeShort(p2.qi << 0);
                byte.writeShort(p2.x << 0);
                byte.writeShort(p2.y << 0);

                return byte;
            }
        }

        return null;
    }

    private function cacheUpdate():void {
        for (var i:int = _renderFrame; i < _renderNextFrame; i++) {
            _updateCache[i] = [_serverK, _clientK];
        }
    }

    private function renderUpdate():void {
        var cacheKeys:Array = _updateCache[_renderFrame];
        if (cacheKeys) {
            InputManager.I.socket_input_p1.setSocketData(cacheKeys[0]);
            InputManager.I.socket_input_p2.setSocketData(cacheKeys[1]);
        }
    }


}
}
