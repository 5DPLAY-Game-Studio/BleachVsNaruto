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

package net.play5d.game.bvn.input {

/**
 * 手柄扩展配置公共逻辑。
 *
 * <p>供各壳 <code>ExtendConfig</code> 复用默认设备绑定与菜单手柄同步。</p>
 *
 * @see JoyStickConfigVO
 * @see JoySticker
 */
public class JoyStickExtendConfigHelper {

    /**
     * 若未手动设置设备，则绑定指定序号的默认手柄。
     *
     * @param joy 手柄配置。
     * @param index 设备序号。
     */
    public static function setDefaultDevice(joy:JoyStickConfigVO, index:int):void {
        if (!joy.deviceIsSet && joy.deviceId == null) {
            joy.deviceId = JoySticker.getDeviceId(index);
        }
    }

    /**
     * 将菜单手柄设备 ID 同步为 P1 设备。
     *
     * @param menu 菜单手柄配置。
     * @param p1 P1 手柄配置。
     */
    public static function syncMenuDeviceFromP1(menu:JoyStickConfigVO, p1:JoyStickConfigVO):void {
        menu.deviceId = p1.deviceId;
    }
}
}
