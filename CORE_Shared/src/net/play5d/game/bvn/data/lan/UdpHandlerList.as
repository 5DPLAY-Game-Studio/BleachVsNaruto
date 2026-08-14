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

package net.play5d.game.bvn.data.lan {

/**
 * UDP 收包回调列表工具。
 *
 * <p>管理 <code>Function(UDPDataVO):void</code> 列表的增删与派发；
 * 网络收发仍由壳 <code>IUdpTransport</code> 实现。</p>
 *
 * @see UDPDataVO
 * @see net.play5d.game.bvn.interfaces.lan.IUdpTransport
 */
public class UdpHandlerList {
    include '../../../../../../../include/ImportVersion.as';

    /** @private */
    private var _handlers:Vector.<Function>;

    /**
     * 当前回调数量。
     *
     * @return 已注册回调个数；尚未初始化时为 0。
     * @default 0
     * @example
     * <listing version="3.0">
     * list.length; // 0
     * </listing>
     */
    public function get length():int {
        return _handlers ? _handlers.length : 0;
    }

    /**
     * 注册收包回调（去重）。
     *
     * @param func <code>Function(UDPDataVO):void</code>。
     * @return 本次为首次加入（列表由空变非空）时为 <code>true</code>，便于壳注册底层监听。
     * @example
     * <listing version="3.0">
     * list.add(onData);
     * </listing>
     */
    public function add(func:Function):Boolean {
        _handlers ||= new Vector.<Function>();
        if (_handlers.indexOf(func) != -1) {
            return false;
        }
        var wasEmpty:Boolean = _handlers.length == 0;
        _handlers.push(func);
        return wasEmpty;
    }

    /**
     * 移除收包回调。
     *
     * @param func 先前注册的回调。
     * @example
     * <listing version="3.0">
     * list.remove(onData);
     * </listing>
     */
    public function remove(func:Function):void {
        if (!_handlers) {
            return;
        }
        var index:int = _handlers.indexOf(func);
        if (index != -1) {
            _handlers.splice(index, 1);
        }
    }

    /**
     * 向所有回调派发数据。
     *
     * @param data 解码后的 UDP 数据。
     * @example
     * <listing version="3.0">
     * list.dispatch(vo);
     * </listing>
     */
    public function dispatch(data:UDPDataVO):void {
        if (!_handlers) {
            return;
        }
        for each(var handler:Function in _handlers) {
            if (handler != null) {
                handler(data);
            }
        }
    }
}
}
