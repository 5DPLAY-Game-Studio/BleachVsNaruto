/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.ctrler.lan {
import flash.utils.ByteArray;
import flash.utils.getTimer;

import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.lan.LanMsgType;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.interfaces.lan.ILanClientLockLink;
import net.play5d.game.bvn.interfaces.lan.ILanSocketInput;
import net.play5d.game.bvn.utils.LANUtils;

/**
 * 锁帧算法（客户端）。
 *
 * <p>通过 <code>init</code> 注入会话与双方 <code>ILanSocketInput</code>。</p>
 *
 * @see LockFrameServerLogic
 * @see net.play5d.game.bvn.interfaces.lan.ILanClientLockLink
 * @see net.play5d.game.bvn.interfaces.lan.ILanSocketInput
 */
public class LockFrameClientLogic {
    /**
     * 构造锁帧客户端逻辑。
     */
    public function LockFrameClientLogic() {
    }

    /**
     * 是否参与渲染推进。
     * @default true
     */
    public var enabled:Boolean = true;

    /** @private */
    private var _updateCache:Object = {};
    /** @private */
    private var _clientK:int;
    /** @private */
    private var _serverK:int;
    /** @private */
    private var _clientFrame:int;
    /** @private */
    private var _serverFrame:int;
    /** @private */
    private var _serverNextFrame:int;
    /** @private */
    private var _lastSendK:int;
    /** @private */
    private var _delayTimer:int = 0;
    /** @private */
    private var _sendAnyWay:Boolean = false;
    /** @private 准备包发送节流计数 */
    private var _sendStartFrame:int = 0;
    /** @private */
    private var _link:ILanClientLockLink;
    /** @private 本机视角下的 P1（服务端侧）输入 */
    private var _inputP1:ILanSocketInput;
    /** @private 本机采集的 P2 输入 */
    private var _inputP2:ILanSocketInput;

    /**
     * 注入会话与输入通道。
     * @param link 客户端会话。
     * @param inputP1 P1 Socket 输入。
     * @param inputP2 P2 Socket 输入。
     */
    public function init(link:ILanClientLockLink, inputP1:ILanSocketInput, inputP2:ILanSocketInput):void {
        _link    = link;
        _inputP1 = inputP1;
        _inputP2 = inputP2;
    }

    /**
     * 重置帧与缓存。
     */
    public function reset():void {
        _updateCache     = {};
        _clientK         = 0;
        _serverK         = 0;
        _clientFrame     = 0;
        _serverFrame     = 0;
        _serverNextFrame = 0;
        _lastSendK       = 0;
        _sendStartFrame  = 0;
    }

    /**
     * 释放缓存引用。
     */
    public function dispose():void {
        _updateCache = {};
        _link        = null;
        _inputP1     = null;
        _inputP2     = null;
    }

    /**
     * 处理服务端输入更新包。
     * @param msgArr 载荷。
     * @return 已识别时为 <code>true</code>。
     */
    public function receiveUpdate(msgArr:ByteArray):Boolean {
        if (!msgArr) {
            return false;
        }

        msgArr.position = 0;
        var type:int    = msgArr.readByte();
        if (type != LanMsgType.INPUT_UPDATE) {
            return false;
        }

        _serverFrame = msgArr.readShort();
        _serverK     = msgArr.readShort();
        _clientK     = msgArr.readShort();

        _serverNextFrame = _serverFrame + LANUtils.LOCK_KEYFRAME;
        cacheUpdate();

        var delay:int = getTimer() - _delayTimer;
        _link.updateDelay(delay);
        _delayTimer = getTimer();
        _sendAnyWay = true;

        return true;
    }

    /**
     * 处理服务端状态同步包。
     * @param msgArr 载荷。
     * @return 已识别时为 <code>true</code>。
     */
    public function receiveSyncUpdate(msgArr:ByteArray):Boolean {
        if (!msgArr) {
            return false;
        }

        msgArr.position = 0;
        var type:int    = msgArr.readByte();
        if (type != LanMsgType.INPUT_SYNC) {
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

        _serverFrame = frame;

        try {
            if (GameCtrl.I.gameRunData.round != round) {
                _link.syncError(true);

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

            _link.resetSyncError();
        }
        catch (e:Error) {
            trace(e);
            _link.syncError(true);
        }

        return true;
    }

    /**
     * 每帧推进；未就绪时返回 <code>false</code> 以停顿渲染。
     * @return 是否允许本帧游戏逻辑推进。
     */
    public function render():Boolean {
        if (!enabled) {
            return true;
        }

        if (_serverNextFrame == 0 && _serverFrame == 0) {
            if (_sendStartFrame++ == 0) {
                var byte:ByteArray = new ByteArray();
                byte.writeByte(LanMsgType.INPUT_SEND);
                byte.writeShort(0);
                byte.writeShort(0);
                _link.sendUDP(byte);
            }
            else if (_sendStartFrame > 5) {
                _sendStartFrame = 0;
            }

            return false;
        }

        if (_clientFrame < _serverNextFrame) {
            _clientFrame++;
            renderUpdate();
            _inputP2.renderInput();

            if (_clientFrame % 2 == 0) {
                sendCtrl();
            }

            return true;
        }

        return false;
    }

    /** @private */
    private function sendCtrl():void {
        var k:int = _inputP2.getSocketData();
        if (_lastSendK == k && !_sendAnyWay) {
            return;
        }

        _sendAnyWay = false;
        _inputP2.resetInput();

        var byte:ByteArray = new ByteArray();
        byte.writeByte(LanMsgType.INPUT_SEND);
        byte.writeShort(_clientFrame);
        byte.writeShort(k);
        _link.sendUDP(byte);

        _lastSendK = k;
    }

    /** @private */
    private function cacheUpdate():void {
        for (var i:int = _serverFrame; i < _serverNextFrame; i++) {
            _updateCache[i] = [_serverK, _clientK];
        }
    }

    /** @private */
    private function renderUpdate():void {
        var cacheKeys:Array = _updateCache[_clientFrame];
        if (cacheKeys) {
            _inputP1.setSocketData(cacheKeys[0]);
            _inputP2.setSocketData(cacheKeys[1]);
        }
    }
}
}
