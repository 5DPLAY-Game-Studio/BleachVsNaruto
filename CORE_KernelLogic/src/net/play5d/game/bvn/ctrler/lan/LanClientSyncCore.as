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
import flash.text.TextField;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.lan.LanSyncType;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.kyo.utils.KyoTimeout;

/**
 * 局域网客户端锁帧同步内核。
 *
 * <p>处理 SYNC 消息、延迟显示与同步错误计数；会话发现/TCP/房间仍由壳负责。</p>
 *
 * @see LockFrameClientLogic
 * @see LanSyncType
 */
public class LanClientSyncCore {

    /**
     * @param delayBiasMs 延迟显示修正（毫秒），Mob 常用 200，Pc 常用 100。
     */
    public function LanClientSyncCore(delayBiasMs:int = 100) {
        _delayBiasMs = delayBiasMs;
    }

    /** @private */
    private var _lockFrame:LockFrameClientLogic;
    /** @private */
    private var _onFatalError:Function;
    /** @private */
    private var _delayText:TextField;
    /** @private */
    private var _delayBiasMs:int;
    /** @private */
    private var _delayCache:Array = [];
    /** @private */
    private var _syncErrorTimes:int;
    /** @private */
    private var _syncStartInt:int;
    /** @private */
    private var _syncRoundInt:int;
    /** @private */
    private var _syncFinishInt:int;

    /**
     * 绑定锁帧逻辑与致命错误回调。
     *
     * @param lockFrame 锁帧客户端逻辑。
     * @param onFatalError 致命同步错误时回调（通常结束对局并弹窗）。
     * @param delayText 延迟显示文本；可为 null。
     */
    public function bind(
            lockFrame   :LockFrameClientLogic,
            onFatalError:Function,
            delayText   :TextField = null
    ):void {
        unbind();
        _lockFrame    = lockFrame;
        _onFatalError = onFatalError;
        _delayText    = delayText;
    }

    /**
     * 解除绑定并清理重试定时器。
     */
    public function unbind():void {
        clearTimeout(_syncStartInt);
        clearTimeout(_syncRoundInt);
        clearTimeout(_syncFinishInt);
        _lockFrame      = null;
        _onFatalError   = null;
        _delayText      = null;
        _delayCache     = [];
        _syncErrorTimes = 0;
    }

    /**
     * 更新延迟显示（采样平均后着色）。
     *
     * @param v 原始延迟毫秒。
     */
    public function updateDelay(v:int):void {
        if (!_delayText) {
            return;
        }

        _delayCache.push(v);

        if (_delayCache.length < 10) {
            return;
        }

        var count:int = 0;
        for each(var i:int in _delayCache) {
            count += i;
        }
        var delay:int = count / _delayCache.length;

        _delayCache = [];

        delay -= _delayBiasMs;
        if (delay < 0) {
            delay = 0;
        }

        var color:uint = 0xff0000;
        if (delay < 200) {
            color = 0x00FF00;
        }
        else if (delay < 500) {
            color = 0xFFFF00;
        }

        _delayText.text      = delay + ' ms';
        _delayText.textColor = color;
    }

    /**
     * 清除同步错误计数。
     */
    public function resetSyncError():void {
        _syncErrorTimes = 0;
    }

    /**
     * 报告同步错误。
     *
     * @param wait 为 true 时累计错误；超过阈值或 wait=false 时触发致命回调。
     */
    public function syncError(wait:Boolean = false):void {
        if (!wait) {
            if (_onFatalError != null) {
                _onFatalError();
            }
            return;
        }
        _syncErrorTimes++;
        if (_syncErrorTimes > 10) {
            if (_onFatalError != null) {
                _onFatalError();
            }
        }
    }

    /**
     * 处理 SYNC 数组消息。
     *
     * @param o 可能为 <code>['SYNC', type, ...]</code>。
     * @return 若已消费返回 true。
     */
    public function receiveSync(o:Object):Boolean {
        if (!(o is Array)) {
            return false;
        }

        var arr:Array = o as Array;
        if (arr[0] != 'SYNC') {
            return false;
        }

        var type:int = arr[1];
        switch (type) {
        case LanSyncType.GAME_START:
            syncStartGame();
            break;
        case LanSyncType.ROUND_FINISH:
            if (_lockFrame) {
                _lockFrame.enabled = false;
                _lockFrame.reset();
            }
            KyoTimeout.setFrameTimeout(function ():void {
                syncRoundFinish(arr);
            }, 1, MainGame.I.stage);
            break;
        case LanSyncType.GAME_FINISH:
            syncGameFinish();
            break;
        }

        return true;
    }

    /**
     * 回合开始时启用锁帧。
     */
    public function onRoundStart():void {
        if (_lockFrame) {
            _lockFrame.enabled = true;
        }
    }

    private function syncStartGame():void {
        try {
            GameCtrl.I.doStartGame();
            _syncErrorTimes = 0;
            if (_lockFrame) {
                _lockFrame.enabled = true;
                _lockFrame.reset();
            }
        }
        catch (e:Error) {
            trace('LanSyncType.GAME_START', e);
            syncError(true);
            clearTimeout(_syncStartInt);
            _syncStartInt = setTimeout(syncStartGame, 500);
        }
    }

    private function syncRoundFinish(arr:Array):void {
        //SYNC,type,round,timerover,drawgame,p1hp,p2hp
        var round:int          = arr[2];
        var isTimeOver:Boolean = arr[3];
        var isDrawGame:Boolean = arr[4];
        var p1hp:int           = arr[5];
        var p2hp:int           = arr[6];

        try {
            if (GameCtrl.I.gameRunData.round != round) {
                syncError(true);
                clearTimeout(_syncRoundInt);
                _syncRoundInt = setTimeout(syncRoundFinish, 500, arr);
                return;
            }

            if (isTimeOver) {
                GameCtrl.I.gameRunData.isTimerOver = true;
                GameCtrl.I.gameRunData.gameTime    = 0;
            }

            var p1:FighterMain = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
            var p2:FighterMain = GameCtrl.I.gameRunData.p2FighterGroup.currentFighter;
            p1.hp              = p1hp;
            p2.hp              = p2hp;

            if (isDrawGame) {
                GameCtrl.I.drawGame();
            }
            else {
                var winner:FighterMain;
                var loser:FighterMain;

                if (p1.hp > p2.hp) {
                    winner = p1;
                    loser  = p2;
                }
                else {
                    winner = p2;
                    loser  = p1;
                }

                if (!isTimeOver) {
                    loser.die();
                }

                GameCtrl.I.doGameEnd(winner, loser);
            }

            _syncErrorTimes = 0;
        }
        catch (e:Error) {
            trace(e);
            syncError(true);
            clearTimeout(_syncRoundInt);
            _syncRoundInt = setTimeout(syncRoundFinish, 500, arr);
        }
    }

    private function syncGameFinish():void {
        if (_lockFrame) {
            _lockFrame.enabled = false;
            _lockFrame.reset();
        }

        if (!GameCtrl.I.fightFinished) {
            try {
                GameCtrl.I.fightFinish();
            }
            catch (e:Error) {
                syncError(true);
                clearTimeout(_syncFinishInt);
                _syncFinishInt = setTimeout(syncGameFinish, 500);
            }
        }
    }
}
}
