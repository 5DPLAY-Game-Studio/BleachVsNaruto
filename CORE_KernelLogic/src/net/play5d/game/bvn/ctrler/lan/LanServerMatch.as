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

import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.interfaces.lan.ILanServerLockLink;
import net.play5d.game.bvn.interfaces.lan.ILanSocketInput;

/**
 * 局域网主机锁帧会话。
 *
 * <p>负责选人同步、锁帧和 SYNC 绑定。房间界面、寻主机和结束后的场景由壳负责。</p>
 *
 * @see LanServerRoom
 * @see LockFrameServerLogic
 */
public class LanServerMatch {

    /** @private */
    private var _select:SelectFighterServerLogic;
    /** @private */
    private var _lock:LockFrameServerLogic;
    /** @private */
    private var _sync:LanServerSyncCore;

    /**
     * 打开锁帧监听。
     *
     * @param render 每帧回调，返回是否继续。
     * @example
     * <listing version="3.0">
     * match.activate(renderGame);
     * </listing>
     */
    public function activate(render:Function):void {
        GameInterface.instance.updateInputConfig();
        LockFrameLogic.I.initServer(render);
    }

    /**
     * 挂上选人同步和锁帧逻辑。
     *
     * @param link 壳侧 UDP 发送。
     * @param inputP1 左侧输入。
     * @param inputP2 右侧输入。
     * @param sendTCP 向客户端发送 TCP 的函数。
     * @example
     * <listing version="3.0">
     * match.attach(link, inputP1, inputP2, sendTCP);
     * </listing>
     */
    public function attach(
            link   :ILanServerLockLink,
            inputP1:ILanSocketInput,
            inputP2:ILanSocketInput,
            sendTCP:Function
    ):void {
        _select = new SelectFighterServerLogic();
        _select.init(sendTCP);
        _lock = new LockFrameServerLogic();
        _lock.init(link, inputP1, inputP2);
    }

    /**
     * 绑定 SYNC 发送。
     *
     * @param sendTCP 向客户端发送 TCP 的函数。
     * @example
     * <listing version="3.0">
     * match.bindSync(sendTCP);
     * </listing>
     */
    public function bindSync(sendTCP:Function):void {
        _sync ||= new LanServerSyncCore();
        _sync.bind(_lock, sendTCP);
    }

    /**
     * 关闭锁帧监听并恢复输入配置。
     *
     * @example
     * <listing version="3.0">
     * match.releaseLock();
     * </listing>
     */
    public function releaseLock():void {
        GameInterface.instance.updateInputConfig();
        LockFrameLogic.I.dispose();
    }

    /**
     * 解除 SYNC 绑定。
     *
     * @example
     * <listing version="3.0">
     * match.unbindSync();
     * </listing>
     */
    public function unbindSync():void {
        if (_sync) {
            _sync.unbind();
        }
    }

    /**
     * 释放选人同步和锁帧逻辑。
     *
     * @example
     * <listing version="3.0">
     * match.disposeLogics();
     * </listing>
     */
    public function disposeLogics():void {
        if (_select) {
            _select.dispose();
            _select = null;
        }
        if (_lock) {
            _lock.dispose();
            _lock = null;
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
     * 交给锁帧处理一条 UDP 输入。
     *
     * @param bytes 载荷。
     * @return 已消费时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * match.receiveInput(bytes);
     * </listing>
     */
    public function receiveInput(bytes:ByteArray):Boolean {
        return _lock && _lock.receiveInput(bytes);
    }

    /**
     * 推进一帧。不在对战场景时改为空转输入。
     *
     * @param inFight 当前是否在对战场景。
     * @param freeRender 空转输入，签名为 <code>function():void</code>。
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
}
}
