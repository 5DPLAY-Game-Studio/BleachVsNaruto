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
import net.play5d.kyo.utils.KyoUtils;

/**
 * 单套手柄键位配置。
 *
 * @see JoyStickSetVO
 * @see JoySticker
 */
public class JoyStickConfigVO {
    /**
     * 构造默认键位。
     */

    /**
     * 设备 id。
     */
    public var deviceId:String;
    /**
     * 是否已指定设备。
     * @default false
     */
    public var deviceIsSet:Boolean = false;

    /** 轴上 */
    public var up2:JoyStickSetVO    = new JoyStickSetVO(1, 0.5);
    /** 轴下 */
    public var down2:JoyStickSetVO  = new JoyStickSetVO(1, -0.5);
    /** 轴左 */
    public var left2:JoyStickSetVO  = new JoyStickSetVO(0, -0.5);
    /** 轴右 */
    public var right2:JoyStickSetVO = new JoyStickSetVO(0, 0.5);

    /** 方向上 */
    public var up:JoyStickSetVO    = new JoyStickSetVO(16, 1);
    /** 方向下 */
    public var down:JoyStickSetVO  = new JoyStickSetVO(17, 1);
    /** 方向左 */
    public var left:JoyStickSetVO  = new JoyStickSetVO(18, 1);
    /** 方向右 */
    public var right:JoyStickSetVO = new JoyStickSetVO(19, 1);

    /** 攻击 */
    public var attack:JoyStickSetVO     = new JoyStickSetVO(6, 1);
    /** 跳 */
    public var jump:JoyStickSetVO       = new JoyStickSetVO(4, 1);
    /** 冲刺 */
    public var dash:JoyStickSetVO       = new JoyStickSetVO(5, 1);
    /** 技能 */
    public var skill:JoyStickSetVO      = new JoyStickSetVO(7, 1);
    /** 必杀 */
    public var superSkill:JoyStickSetVO = new JoyStickSetVO(9, 1);
    /** 特殊 */
    public var special:JoyStickSetVO    = new JoyStickSetVO(8, 1);
    /** 万解 */
    public var waikai:JoyStickSetVO     = new JoyStickSetVO(10, 1);
    /** 返回 */
    public var back:JoyStickSetVO       = new JoyStickSetVO(12, 1);
    /** 确认 */
    public var select:JoyStickSetVO     = new JoyStickSetVO(13, 1);

    /**
     * 从普通对象填充字段。
     * @param obj 键值表。
     */
    public function readObj(obj:Object):void {
        for (var i:String in obj) {
            var o:Object = obj[i];
            if (!this.hasOwnProperty(i)) {
                continue;
            }
            if (this[i] is JoyStickSetVO) {
                (this[i] as JoyStickSetVO).readObj(o);
            }
            else {
                this[i] = o;
            }
        }
    }

    /**
     * 导出为普通对象（含嵌套 <code>JoyStickSetVO</code>）。
     * @return 可序列化对象。
     */
    public function toObj():Object {
        var vs:Array = KyoUtils.getItemVariables(this);
        var o:Object = {};
        for each (var i:String in vs) {
            var item:* = this[i];
            if (item is JoyStickSetVO) {
                o[i] = (this[i] as JoyStickSetVO).toObj();
            }
            else {
                o[i] = this[i];
            }
        }

        return KyoUtils.itemToObject(this);
    }
}
}
