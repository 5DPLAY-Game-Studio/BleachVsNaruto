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
import flash.utils.getTimer;

import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.win.input.InputManager;
import net.play5d.game.bvn.win.utils.LANUtils;

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
    private var _renderFrame:uint;
    private var _serverFrame:uint;
    private var _serverNextFrame:uint;
    private var _lastSendK:int;
    private var _delayTimer:int = 0;

    public function reset():void {
        _updateCache     = {};
        _clientK         = 0;
        _serverK         = 0;
        _renderFrame     = 0;
        _serverFrame     = 0;
        _serverNextFrame = 0;
        _lastSendK       = 0;
    }

    public function dispose():void {
        _updateCache = {};
    }

    public function receiveUpdate(data:Object):Boolean {
        if (data is Array) {
            var msgArr:Array = data as Array;

            _serverK = msgArr[0];
            _clientK = msgArr[1];

            _serverFrame += LANUtils.LOCK_KEYFRAME;

            if (msgArr[2]) {
                _updateCache = {};
                syncRenderGame(msgArr[2]);
            }

            _serverNextFrame = _serverFrame + LANUtils.LOCK_KEYFRAME * 2;

            cacheUpdate();

            var delay:int = getTimer() - _delayTimer;
            LANClientCtrl.I.updateDelay(delay);

            _delayTimer = getTimer();

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
            LANClientCtrl.I.sendTCP(0);
            return false;
        }

        if (_renderFrame < _serverNextFrame) {
            _renderFrame++;
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
        _renderFrame = _serverFrame;

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

    private function sendCtrl():void {
        InputManager.I.socket_input_p2.renderInput();
        var k:int = InputManager.I.socket_input_p2.getSocketData();
        InputManager.I.socket_input_p2.resetInput();
        if (k != _lastSendK) {
            _lastSendK = k;
            LANClientCtrl.I.sendTCP(k);
        }
    }


    private function cacheUpdate():void {
        for (var i:int = _serverFrame; i < _serverNextFrame; i++) {
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
