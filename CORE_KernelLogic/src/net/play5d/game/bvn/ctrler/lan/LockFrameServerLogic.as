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

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.lan.LanMsgType;
import net.play5d.game.bvn.data.vos.GameRunDataVO;
import net.play5d.game.bvn.interfaces.lan.ILanServerLockLink;
import net.play5d.game.bvn.interfaces.lan.ILanSocketInput;
import net.play5d.game.bvn.stage.GameStage;
import net.play5d.game.bvn.utils.LANUtils;
import net.play5d.kyo.stage.IStage;

/**
 * 锁帧算法（服务端）。
 *
 * <p>等待间隔与同步间隔使用 <code>LANUtils.LOCK_KEYFRAME</code> / <code>SYNC_GAP</code>。</p>
 *
 * @see LockFrameClientLogic
 * @see net.play5d.game.bvn.interfaces.lan.ILanServerLockLink
 * @see net.play5d.game.bvn.interfaces.lan.ILanSocketInput
 */
public class LockFrameServerLogic {
    /**
     * 构造锁帧服务端逻辑。
     */
    public function LockFrameServerLogic() {
    }

    /**
     * 是否参与渲染推进。
     * @default true
     */
    public var enabled:Boolean = true;

    /** @private */
    private var _clientFrame:int;
    /** @private */
    private var _renderFrame:int;
    /** @private */
    private var _renderNextFrame:int;
    /** @private */
    private var _renderSyncFrame:int;
    /** @private */
    private var _clientK:int = -1;
    /** @private */
    private var _serverK:int = 0;
    /** @private */
    private var _syncUpdateArr:ByteArray;
    /** @private */
    private var _sendUpdateFrame:int;
    /** @private */
    private var _sendUpdateSyncFrame:int;
    /** @private */
    private var _updateCache:Object = {};
    /** @private */
    private var _link:ILanServerLockLink;
    /** @private */
    private var _inputP1:ILanSocketInput;
    /** @private */
    private var _inputP2:ILanSocketInput;

    /**
     * 注入会话与输入通道。
     * @param link 服务端会话。
     * @param inputP1 服务端本机 P1 输入。
     * @param inputP2 客户端侧 P2 输入回放通道。
     */
    public function init(link:ILanServerLockLink, inputP1:ILanSocketInput, inputP2:ILanSocketInput):void {
        _link    = link;
        _inputP1 = inputP1;
        _inputP2 = inputP2;
    }

    /**
     * 重置帧与缓存。
     */
    public function reset():void {
        _renderFrame     = 0;
        _renderNextFrame = 0;
        _clientK         = -1;
        _serverK         = 0;
        _syncUpdateArr   = null;
        _sendUpdateFrame = 0;
    }

    /**
     * 释放引用。
     */
    public function dispose():void {
        _link    = null;
        _inputP1 = null;
        _inputP2 = null;
    }

    /**
     * 每帧推进；等待客户端时返回 <code>false</code>。
     * @return 是否允许本帧游戏逻辑推进。
     */
    public function render():Boolean {
        if (!enabled) {
            return true;
        }
        if (_clientK == -1) {
            return false;
        }

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

        _inputP1.renderInput();

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

    /**
     * 处理客户端输入包。
     * @param kb 载荷。
     * @return 已识别时为 <code>true</code>。
     */
    public function receiveInput(kb:ByteArray):Boolean {
        if (!kb) {
            return false;
        }

        kb.position  = 0;
        var type:int = kb.readByte();
        if (type != LanMsgType.INPUT_SEND) {
            return false;
        }

        _clientFrame = kb.readShort();
        _clientK     = kb.readShort();

        return true;
    }

    /** @private */
    private function sendUpdate():void {
        _renderNextFrame = _renderFrame + LANUtils.LOCK_KEYFRAME;

        _serverK = _inputP1.getSocketData();
        _inputP1.resetInput();

        var updateByte:ByteArray = new ByteArray();
        updateByte.writeByte(LanMsgType.INPUT_UPDATE);
        updateByte.writeShort(_renderFrame);
        updateByte.writeShort(_serverK);
        updateByte.writeShort(_clientK);

        _link.sendUDP(updateByte);
        cacheUpdate();
    }

    /** @private */
    private function sendSyncUpdate():void {
        if (!_syncUpdateArr) {
            return;
        }
        _updateCache = {};
        _link.sendUDP(_syncUpdateArr);
    }

    /** @private */
    private function getSyncUpdate():ByteArray {
        var curStg:IStage = MainGame.stageCtrl.currentStage;
        if (!(curStg is GameStage) || !GameCtrl.I.actionEnable) {
            return null;
        }

        var runData:GameRunDataVO = GameCtrl.I.gameRunData;

        return LanInputSyncCodec.encode(
                _renderFrame, runData.round, runData.gameTime,
                runData.p1FighterGroup.currentFighter,
                runData.p2FighterGroup.currentFighter
        );
    }

    /** @private */
    private function cacheUpdate():void {
        LockFrameInputCache.fill(_updateCache, _renderFrame, _renderNextFrame, _serverK, _clientK);
    }

    /** @private */
    private function renderUpdate():void {
        LockFrameInputCache.apply(_updateCache, _renderFrame, _inputP1, _inputP2);
    }
}
}
