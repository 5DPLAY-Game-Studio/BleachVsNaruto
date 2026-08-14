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
 * @see IUdpTransport
 */
public class UdpHandlerList {
    include '../../../../../../../include/ImportVersion.as';

    /** @private */
    private var _handlers:Vector.<Function>;

    /**
     * 当前回调数量。
     */
    public function get length():int {
        return _handlers ? _handlers.length : 0;
    }

    /**
     * 注册收包回调（去重）。
     *
     * @param func <code>Function(UDPDataVO):void</code>。
     * @return 若本次为首次加入列表返回 true（便于壳注册底层监听）。
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
     */
    public function remove(func:Function):void {
        if (!_handlers) {
            return;
        }
        var id:int = _handlers.indexOf(func);
        if (id != -1) {
            _handlers.splice(id, 1);
        }
    }

    /**
     * 向所有回调派发数据。
     *
     * @param data 解码后的 UDP 数据。
     */
    public function dispatch(data:UDPDataVO):void {
        if (!_handlers) {
            return;
        }
        for each(var f:Function in _handlers) {
            if (f != null) {
                f(data);
            }
        }
    }
}
}
