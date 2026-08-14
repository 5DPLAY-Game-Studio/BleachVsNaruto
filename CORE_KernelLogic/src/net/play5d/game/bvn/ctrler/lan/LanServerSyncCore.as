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
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.lan.LanSyncType;
import net.play5d.game.bvn.data.vos.GameRunDataVO;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.fighter.FighterMain;

/**
 * 局域网服务端锁帧同步内核。
 *
 * <p>监听对局/回合事件并向客户端发送 SYNC；会话发现、房间与 TCP 仍由壳负责。</p>
 *
 * @see LockFrameServerLogic
 * @see LanClientSyncCore
 * @see LanSyncType
 */
public class LanServerSyncCore {

    /**
     * 构造同步内核。
     */
    public function LanServerSyncCore() {
    }

    /** @private */
    private var _lockFrame:LockFrameServerLogic;
    /** @private */
    private var _sendTCP:Function;
    /** @private */
    private var _bound:Boolean;

    /**
     * 绑定锁帧逻辑与 TCP 发送。
     *
     * @param lockFrame 服务端锁帧逻辑。
     * @param sendTCP 向所有客户端发送载荷，签名 <code>Function(Object):void</code>。
     */
    public function bind(lockFrame:LockFrameServerLogic, sendTCP:Function):void {
        unbind();
        _lockFrame = lockFrame;
        _sendTCP   = sendTCP;
        _bound     = true;

        GameEvent.addEventListener(GameEvent.ROUND_END, onGameRoundEnd);
        GameEvent.addEventListener(GameEvent.GAME_START, onGameStart);
        GameEvent.addEventListener(GameEvent.GAME_END, onGameEnd);
        GameEvent.addEventListener(GameEvent.ROUND_START, onRoundStart);
    }

    /**
     * 解除事件监听与引用。
     */
    public function unbind():void {
        if (_bound) {
            GameEvent.removeEventListener(GameEvent.ROUND_END, onGameRoundEnd);
            GameEvent.removeEventListener(GameEvent.GAME_START, onGameStart);
            GameEvent.removeEventListener(GameEvent.GAME_END, onGameEnd);
            GameEvent.removeEventListener(GameEvent.ROUND_START, onRoundStart);
            _bound = false;
        }
        _lockFrame = null;
        _sendTCP   = null;
    }

    private function onGameStart(e:GameEvent):void {
        //SYNC,type,round
        if (_lockFrame) {
            _lockFrame.enabled = true;
            _lockFrame.reset();
        }
        if (_sendTCP != null) {
            _sendTCP(['SYNC', LanSyncType.GAME_START]);
        }
    }

    private function onGameEnd(e:GameEvent):void {
        if (_lockFrame) {
            _lockFrame.enabled = false;
            _lockFrame.reset();
        }
        if (_sendTCP != null) {
            _sendTCP(['SYNC', LanSyncType.GAME_FINISH]);
        }
    }

    private function onRoundStart(e:GameEvent):void {
        //SYNC,type,round
        if (_lockFrame) {
            _lockFrame.enabled = true;
        }
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
        if (_sendTCP != null) {
            _sendTCP(data);
        }
        if (_lockFrame) {
            _lockFrame.enabled = false;
            _lockFrame.reset();
        }
    }
}
}
