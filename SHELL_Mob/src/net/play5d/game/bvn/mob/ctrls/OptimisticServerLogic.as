package net.play5d.game.bvn.mob.ctrls {
import flash.utils.ByteArray;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.vos.GameRunDataVO;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.mob.input.InputManager;
import net.play5d.game.bvn.mob.utils.LANUtils;

/**
 * 乐观锁帧算法，服务端
 */
public class OptimisticServerLogic {
    public function OptimisticServerLogic() {
    }
    public var enabled:Boolean = true;
    private var _renderFrame:uint;
    private var _renderNextFrame:uint;
    private var _renderSyncFrame:int;
    private var _clientK:int = -1;
    private var _serverK:int = 0;
    private var _syncUpdateArr:Array;
    private var _sendUpdateFrame:int;
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

//			//客户端与服务器相差时间较大，等待客户端
//			if(_renderFrame > _clientRenderFrame + LANUtils.SERVER_WAIT_CLIENT){
//				if(_sendUpdateFrame++ == 0){
//					sendUpdate(true);
//				}
//				if(_sendUpdateFrame > 5) _sendUpdateFrame = 0;
//				return false;
//			}

        InputManager.I.socket_input_p1.renderInput();

        if (_renderFrame % LANUtils.LOCK_KEYFRAME == 0) {

            var sync:Boolean = false;

            if (_renderSyncFrame > LANUtils.SYNC_GAP) {
                sync             = true;
                _renderSyncFrame = 0;
            }

            sendUpdate(sync);
        }

        _renderFrame++;
        _renderSyncFrame++;

        renderUpdate();

        if (_renderSyncFrame > LANUtils.SYNC_GAP) {
            _syncUpdateArr = getSyncUpdate();
        }

        return true;
    }

    public function receiveInput(k:Object):Boolean {
        if (k is ByteArray) {
            var kb:ByteArray = k as ByteArray;
            kb.position      = 0;
            var key:int      = kb.readByte();
            if (key != LANUtils.INPUT_KEY) {
                return false;
            }
//				_clientFrame = kb.readShort();
            _clientK = kb.readShort();
            return true;
        }
        return false;
    }

    private function sendStart():void {
        var updateArr:Array = [_serverK, 0];
        LANServerCtrl.I.sendAll(updateArr);
    }

    private function sendUpdate(sync:Boolean):void {
        _renderNextFrame = _renderFrame + LANUtils.LOCK_KEYFRAME;
//			trace("sendCtrlUpdate" , _renderFrame , _renderNextFrame , _serverK , _clientK);

        var syncArr:Array = sync ? _syncUpdateArr : null;

        _serverK = InputManager.I.socket_input_p1.getSocketData();

        InputManager.I.socket_input_p1.resetInput();

//			var updateArr:Array = [_renderFrame , _renderNextFrame , _serverK , _clientK , syncArr];
//			var updateArr:Array = [_renderFrame , _renderNextFrame , _serverK , _clientK];
//			var updateArr:Array = [_serverK , _clientK , syncArr];
//			LANServerCtrl.I.sendAll(updateArr);


        var updateByte:ByteArray = new ByteArray();
        updateByte.writeByte(LANUtils.INPUT_KEY);
//			updateByte.writeShort(_renderFrame);
        updateByte.writeShort(_serverK);
        updateByte.writeShort(_clientK);
//			if(syncArr) updateByte.writeObject(syncArr);

        LANServerCtrl.I.sendAll(updateByte);

        if (sync) {
            _updateCache = {};
        }

        cacheUpdate();

    }

    //伪客户端逻辑 ***************************************************************************************

    private function getSyncUpdate():Array {

        //frame,round,time,p1hp,p1x,p1y,p2hp,p2x,p2y

        var curStg:Istage = MainGame.stageCtrl.currentStage;

        if (curStg is GameState) {
            if (GameCtrl.I.actionEnable) {
                var runData:GameRunDataVO = GameCtrl.I.gameRunData;
                var p1:FighterMain        = runData.p1FighterGroup.currentFighter;
                var p2:FighterMain        = runData.p2FighterGroup.currentFighter;
                var data:Array            = [
                    _renderFrame, runData.round, runData.gameTime,
                    p1.hp << 0, p1.qi << 0, p1.x << 0, p1.y << 0,
                    p2.hp << 0, p2.qi << 0, p2.x << 0, p2.y << 0
                ];
                return data;
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
