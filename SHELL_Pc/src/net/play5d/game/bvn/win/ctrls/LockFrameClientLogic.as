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
import flash.utils.ByteArray;
import flash.utils.getTimer;

import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.win.input.InputManager;
import net.play5d.game.bvn.win.utils.LANUtils;
import net.play5d.game.bvn.win.utils.MsgType;

/**
 * 锁帧算法，客户端
 */
public class LockFrameClientLogic {
    public function LockFrameClientLogic() {
    }
    public var enabled:Boolean = true;
    private var _updateCache:Object = {};
    private var _clientK:int;
    private var _serverK:int;
    private var _clientFrame:int;
    private var _serverFrame:int;
    private var _serverNextFrame:int;
    private var _lastSendK:int;
    private var _delayTimer:int = 0;
    private var _sendAnyWay:Boolean = false;

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

    public function receiveUpdate(msgArr:ByteArray):Boolean {
        if (!msgArr) {
            return false;
        }

        msgArr.position = 0;

        var type:int = msgArr.readByte();

        if (type != MsgType.INPUT_UPDATE) {
            return false;
        }

        _serverFrame = msgArr.readShort();
        _serverK     = msgArr.readShort();
        _clientK     = msgArr.readShort();

        _serverNextFrame = _serverFrame + LANUtils.LOCK_KEYFRAME;

        cacheUpdate();

        var delay:int = getTimer() - _delayTimer;
        LANClientCtrl.I.updateDelay(delay);

        _delayTimer = getTimer();

        _sendAnyWay = true;

        return true;
    }

    public function receiveSyncUpdate(msgArr:ByteArray):Boolean {
        if (!msgArr) {
            return false;
        }


        msgArr.position = 0;

        var type:int = msgArr.readByte();

        if (type != MsgType.INPUT_SYNC) {
            return false;
        }

        _updateCache = {};

        var frame:int = msgArr.readShort();
        var round:int = msgArr.readByte();
        var time:int  = msgArr.readByte();

        var p1hp:int = msgArr.readShort();
        var p1qi:int = msgArr.readShort();
        var p1x:int  = msgArr.readShort();
        var p1y:int  = msgArr.readShort();

        var p2hp:int = msgArr.readShort();
        var p2qi:int = msgArr.readShort();
        var p2x:int  = msgArr.readShort();
        var p2y:int  = msgArr.readShort();

//			trace('receive sync update', 'frame='+frame, 'round='+round, 'time='+time, 'p1hp='+p1hp, 'p1qi='+p1qi,
// 'p1x='+p1x, 'p1y='+p1y, ' || ' ,'p2hp='+p2hp, 'p2qi='+p2qi, 'p2x='+p2x, 'p2y='+p2y);
        _serverFrame = frame;

        try {

            if (GameCtrl.I.gameRunData.round != round) {
                LANClientCtrl.I.syncError(true);
                return true;
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

        return true;
    }

    public function render():Boolean {

        if (!enabled) {
            return true;
        }

        if (_serverNextFrame == 0 && _serverFrame == 0) {
            //通知服务端，客户端已准备
            var byte:ByteArray = new ByteArray();
            byte.writeByte(MsgType.INPUT_SEND);
            byte.writeShort(0);
            byte.writeShort(0);
            LANClientCtrl.I.sendUDP(byte);
            return false;
        }

        if (_clientFrame < _serverNextFrame) {
            _clientFrame++;
            renderUpdate();

            InputManager.I.socket_input_p2.renderInput();

            if (_clientFrame % 2 == 0) {
                sendCtrl();
            }
//				sendCtrl();

            return true;
        }
        return false;
    }

    private function sendCtrl():void {
//			InputManager.I.socket_input_p2.renderInput();

        var k:int = InputManager.I.socket_input_p2.getSocketData();
        if (_lastSendK == k && !_sendAnyWay) {
            return;
        }

        _sendAnyWay = false;

        InputManager.I.socket_input_p2.resetInput();
//			LANClientCtrl.I.send([_clientFrame , k]);

        var byte:ByteArray = new ByteArray();
        byte.writeByte(MsgType.INPUT_SEND);
        byte.writeShort(_clientFrame);
        byte.writeShort(k);
        LANClientCtrl.I.sendUDP(byte);

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
