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
import flash.text.TextFormat;
import flash.utils.ByteArray;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.interfaces.lan.ILanClientLockLink;
import net.play5d.game.bvn.interfaces.lan.ILanSocketInput;
import net.play5d.game.bvn.stage.SelectFighterStage;

/**
 * 局域网客户端锁帧会话。
 *
 * <p>负责延迟显示、选人同步、锁帧和对局自动开始开关。寻主机、TCP 和结束后的场景由壳负责。</p>
 *
 * @see LockFrameClientLogic
 * @see LanClientSyncCore
 */
public class LanClientMatch {

    /** @private */
    private var _delayText:TextField;
    /** @private */
    private var _select:SelectFighterClientLogic;
    /** @private */
    private var _lock:LockFrameClientLogic;
    /** @private */
    private var _sync:LanClientSyncCore;

    /**
     * 创建并显示延迟文本。
     *
     * @example
     * <listing version="3.0">
     * match.showDelay();
     * </listing>
     */
    public function showDelay():void {
        _delayText                   = new TextField();
        _delayText.text              = '0ms';
        var format:TextFormat        = new TextFormat();
        format.color                 = 0xffffff;
        format.size                  = 16;
        _delayText.defaultTextFormat = format;
        MainGame.I.stage.addChild(_delayText);
    }

    /**
     * 挂上选人同步、锁帧和 SYNC。
     *
     * @param delayMs 延迟显示初值毫秒。
     * @param link 壳侧 UDP 发送。
     * @param inputP1 左侧输入。
     * @param inputP2 右侧输入。
     * @param sendTCP 发送 TCP 的函数。
     * @param onFatal 致命同步错误回调。
     * @example
     * <listing version="3.0">
     * match.attach(100, link, inputP1, inputP2, sendTCP, onFatal);
     * </listing>
     */
    public function attach(
            delayMs:int,
            link   :ILanClientLockLink,
            inputP1:ILanSocketInput,
            inputP2:ILanSocketInput,
            sendTCP:Function,
            onFatal:Function
    ):void {
        _select = new SelectFighterClientLogic();
        _select.init(sendTCP);
        _lock = new LockFrameClientLogic();
        _lock.init(link, inputP1, inputP2);
        _sync ||= new LanClientSyncCore(delayMs);
        _sync.bind(_lock, onFatal, _delayText);
    }

    /**
     * 禁止本机自动开局并打开客户端锁帧。
     *
     * @param render 每帧回调，返回是否继续。
     * @param setAutoStart 设置加载界面是否自动开始，签名为 <code>function(enabled:Boolean):void</code>。
     * @example
     * <listing version="3.0">
     * match.arm(renderGame, setAutoStart);
     * </listing>
     */
    public function arm(render:Function, setAutoStart:Function):void {
        GameCtrl.I.autoEndRoundAble    = false;
        GameCtrl.I.autoStartAble       = false;
        SelectFighterStage.AUTO_FINISH = false;
        setAutoStart(false);
        GameInterface.instance.updateInputConfig();
        LockFrameLogic.I.initClient(render);
    }

    /**
     * 监听回合开始以推进 SYNC。
     *
     * @example
     * <listing version="3.0">
     * match.listenRound();
     * </listing>
     */
    public function listenRound():void {
        GameEvent.addEventListener(GameEvent.ROUND_START, onRoundStart);
    }

    /**
     * 停止监听回合开始。
     *
     * @example
     * <listing version="3.0">
     * match.unlistenRound();
     * </listing>
     */
    public function unlistenRound():void {
        GameEvent.removeEventListener(GameEvent.ROUND_START, onRoundStart);
    }

    /**
     * 释放锁帧对象和延迟文本。
     *
     * @example
     * <listing version="3.0">
     * match.detach();
     * </listing>
     */
    public function detach():void {
        if (_select) {
            _select.dispose();
            _select = null;
        }
        if (_sync) {
            _sync.unbind();
        }
        if (_lock) {
            _lock.dispose();
            _lock = null;
        }
        removeDelayText();
    }

    /**
     * 恢复本机自动开局并关闭锁帧。
     *
     * @param setAutoStart 设置加载界面是否自动开始。
     * @example
     * <listing version="3.0">
     * match.disarm(setAutoStart);
     * </listing>
     */
    public function disarm(setAutoStart:Function):void {
        GameCtrl.I.autoEndRoundAble    = true;
        GameCtrl.I.autoStartAble       = true;
        SelectFighterStage.AUTO_FINISH = true;
        setAutoStart(true);
        GameInterface.instance.updateInputConfig();
        LockFrameLogic.I.dispose();
    }

    /**
     * 更新延迟显示。
     *
     * @param ms 原始延迟毫秒。
     * @example
     * <listing version="3.0">
     * match.updateDelay(30);
     * </listing>
     */
    public function updateDelay(ms:int):void {
        if (!_sync) {
            return;
        }
        _sync.updateDelay(ms);
    }

    /**
     * 清零同步错误计数。
     *
     * @example
     * <listing version="3.0">
     * match.resetSyncError();
     * </listing>
     */
    public function resetSyncError():void {
        if (_sync) {
            _sync.resetSyncError();
        }
    }

    /**
     * 记录一次同步错误。
     *
     * @param wait 是否等待重试。
     * @example
     * <listing version="3.0">
     * match.syncError(false);
     * </listing>
     */
    public function syncError(wait:Boolean = false):void {
        if (_sync) {
            _sync.syncError(wait);
        }
    }

    /**
     * 交给选人同步处理一条 TCP 对象。
     *
     * @param obj 收到的对象。
     * @return 已消费时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (match.receiveSelect(obj)) {
     *     return;
     * }
     * </listing>
     */
    public function receiveSelect(obj:Object):Boolean {
        return _select && _select.receiveSelect(obj);
    }

    /**
     * 交给 SYNC 处理一条 TCP 对象。
     *
     * @param obj 收到的对象。
     * @return 已消费时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (match.receiveSync(obj)) {
     *     return;
     * }
     * </listing>
     */
    public function receiveSync(obj:Object):Boolean {
        return _sync && _sync.receiveSync(obj);
    }

    /**
     * 交给锁帧处理一条 UDP 包。先尝试状态同步，再尝试输入更新。
     *
     * @param bytes 载荷。
     * @return 已消费时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * match.receiveUdp(bytes);
     * </listing>
     */
    public function receiveUdp(bytes:ByteArray):Boolean {
        if (!_lock) {
            return false;
        }
        if (_lock.receiveSyncUpdate(bytes)) {
            return true;
        }

        return _lock.receiveUpdate(bytes);
    }

    /**
     * 推进一帧。不在对战场景时改为空转输入。
     *
     * @param inFight 当前是否在对战场景。
     * @param freeRender 空转输入。
     * @return 锁帧允许继续时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * match.render(inFight, freeRender);
     * </listing>
     */
    public function render(inFight:Boolean, freeRender:Function):Boolean {
        if (inFight) {
            return _lock.render();
        }

        freeRender();

        return true;
    }

    /**
     * 回合开始时推进 SYNC。
     *
     * @param event 回合事件。
     */
    private function onRoundStart(event:GameEvent):void {
        _sync && _sync.onRoundStart();
    }

    /** @private */
    private function removeDelayText():void {
        if (!_delayText) {
            return;
        }
        try {
            _delayText.parent.removeChild(_delayText);
        }
        catch (e:Error) {
            trace(e);
        }
        _delayText = null;
    }
}
}
