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
import flash.display.Stage;

import net.play5d.game.bvn.interfaces.IGameInput;

/**
 * 手柄输入实现。
 *
 * <p>基于 <code>JoyStick</code> 与 <code>JoyStickConfigVO</code>。
 * 关闭后按键查询直接返回 false。<code>focus</code> 和 <code>clear</code> 是空的。
 * 返回键同时认 <code>back</code> 和 <code>select</code>。确认读的是 <code>jump</code>。
 * 方向同时认十字键和摇杆。卍解读单独的 <code>bankai</code>。
 * 还没 <code>setConfig</code> 时，读设备或查询会抛错。
 * <code>initialize</code> 不使用舞台，只把当时的 <code>onDevicesChanged</code> 交给 <code>JoyStick</code>。传 null 不会清掉已经记下的回调。之后只改字段、不再次初始化，手柄仍调用旧函数。</p>
 *
 * @see JoyStick
 * @see JoyStickConfigVO
 * @see IGameInput
 */
public class GameJoystickInput implements IGameInput {

    /**
     * 记下玩家编号。查询不看这个数。
     *
     * @param player 玩家编号。
     */
    public function GameJoystickInput(player:int) {
        this.player = player;
    }

    /**
     * 玩家编号。
     */
    public var player:int;

    /**
     * 手柄设备列表变更时回调（通常刷新壳侧 joy 配置）。
     */
    public var onDevicesChanged:Function;

    /** @private */
    private var _config:JoyStickConfigVO;
    /** @private */
    private var _enabled:Boolean = true;

    /**
     * 是否启用。关掉后按键查询返回 false。
     *
     * @return 当前是否启用。
     * @default true
     */
    public function get enabled():Boolean {
        return _enabled;
    }

    /** @private */
    public function set enabled(v:Boolean):void {
        _enabled = v;
    }

    /**
     * 当前绑定的设备 ID。还没配置时抛错。
     *
     * @return 设备 ID。
     * @throws TypeError 还没有配置时。
     */
    public function getDeviceId():String {
        return _config.deviceId;
    }

    /**
     * 改绑定的设备 ID。还没配置时抛错。
     *
     * @param id 设备 ID。
     * @throws TypeError 还没有配置时。
     */
    public function setDeviceId(id:String):void {
        _config.deviceId = id;
    }

    /**
     * 初始化手柄轮询。舞台不使用。
     *
     * @param stage 保留参数，本实现不读。
     */
    public function initialize(stage:Stage):void {
        JoyStick.initialize(onDevicesChanged);
    }

    /**
     * 换手柄配置。不是 <code>JoyStickConfigVO</code> 时记成 null。
     *
     * @param config 手柄配置。
     * @example
     * <listing version="3.0">
     * input.setConfig(config);
     * </listing>
     */
    public function setConfig(config:Object):void {
        this._config = config as JoyStickConfigVO;
    }

    /**
     * 空实现。
     */
    public function focus():void {
    }

    /**
     * 该设备是否有控件超过按下阈值。
     *
     * @return 有则 true。关闭时为 false。
     * @throws TypeError 启用但还没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.anyKey();
     * </listing>
     */
    public function anyKey():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoyStick.isDownAnyKey(_config.deviceId);
    }

    /**
     * 返回或确认控件是否按下。
     *
     * @return 任一按下时为 true。关闭时为 false。
     * @throws TypeError 启用但还没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.back();
     * </listing>
     */
    public function back():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoyStick.isDown(_config.deviceId, _config.back) || JoyStick.isDown(_config.deviceId, _config.select);
    }

    /**
     * 跳控件是否按下。确认走这条。
     *
     * @return 按下时为 true。关闭时为 false。
     * @throws TypeError 启用但还没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.select();
     * </listing>
     */
    public function select():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoyStick.isDown(_config.deviceId, _config.jump);
    }

    /**
     * 上是否按下。十字键和摇杆都算。
     *
     * @return 任一按下时为 true。关闭时为 false。
     * @throws TypeError 启用但还没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.up();
     * </listing>
     */
    public function up():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoyStick.isDown(_config.deviceId, _config.up) || JoyStick.isDown(_config.deviceId, _config.up2);
    }

    /**
     * 下是否按下。十字键和摇杆都算。
     *
     * @return 任一按下时为 true。关闭时为 false。
     * @throws TypeError 启用但还没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.down();
     * </listing>
     */
    public function down():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoyStick.isDown(_config.deviceId, _config.down) || JoyStick.isDown(_config.deviceId, _config.down2);
    }

    /**
     * 左是否按下。十字键和摇杆都算。
     *
     * @return 任一按下时为 true。关闭时为 false。
     * @throws TypeError 启用但还没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.left();
     * </listing>
     */
    public function left():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoyStick.isDown(_config.deviceId, _config.left) || JoyStick.isDown(_config.deviceId, _config.left2);
    }

    /**
     * 右是否按下。十字键和摇杆都算。
     *
     * @return 任一按下时为 true。关闭时为 false。
     * @throws TypeError 启用但还没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.right();
     * </listing>
     */
    public function right():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoyStick.isDown(_config.deviceId, _config.right) ||
               JoyStick.isDown(_config.deviceId, _config.right2);
    }

    /**
     * 攻击是否按下。
     *
     * @return 按下时为 true。关闭时为 false。
     * @throws TypeError 启用但还没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.attack();
     * </listing>
     */
    public function attack():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoyStick.isDown(_config.deviceId, _config.attack);
    }

    /**
     * 跳是否按下。
     *
     * @return 按下时为 true。关闭时为 false。
     * @throws TypeError 启用但还没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.jump();
     * </listing>
     */
    public function jump():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoyStick.isDown(_config.deviceId, _config.jump);
    }

    /**
     * 冲刺是否按下。
     *
     * @return 按下时为 true。关闭时为 false。
     * @throws TypeError 启用但还没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.dash();
     * </listing>
     */
    public function dash():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoyStick.isDown(_config.deviceId, _config.dash);
    }

    /**
     * 技能是否按下。
     *
     * @return 按下时为 true。关闭时为 false。
     * @throws TypeError 启用但还没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.skill();
     * </listing>
     */
    public function skill():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoyStick.isDown(_config.deviceId, _config.skill);
    }

    /**
     * 必杀是否按下。
     *
     * @return 按下时为 true。关闭时为 false。
     * @throws TypeError 启用但还没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.superSkill();
     * </listing>
     */
    public function superSkill():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoyStick.isDown(_config.deviceId, _config.superSkill);
    }

    /**
     * 特殊键是否按下。
     *
     * @return 按下时为 true。关闭时为 false。
     * @throws TypeError 启用但还没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.special();
     * </listing>
     */
    public function special():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoyStick.isDown(_config.deviceId, _config.special);
    }

    /**
     * 卍解控件是否按下。
     *
     * @return 按下时为 true。关闭时为 false。
     * @throws TypeError 启用但还没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.bankai();
     * </listing>
     */
    public function bankai():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoyStick.isDown(_config.deviceId, _config.bankai);
    }

    /**
     * 空实现。
     */
    public function clear():void {
    }
}
}
