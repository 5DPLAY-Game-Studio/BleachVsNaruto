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
 * <p>基于 <code>JoySticker</code> 与 <code>JoyStickConfigVO</code>。
 * 设备变更回调由壳注入 <code>onDevicesChanged</code>，避免依赖壳单例。</p>
 *
 * @see JoySticker
 * @see JoyStickConfigVO
 * @see IGameInput
 */
public class GameJoystickInput implements IGameInput {

    /**
     * @param player 玩家编号（壳侧标识用）。
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
     * 是否启用本输入。
     */
    public function get enabled():Boolean {
        return _enabled;
    }

    /** @private */
    public function set enabled(v:Boolean):void {
        _enabled = v;
    }

    /**
     * 当前绑定的设备 ID。
     *
     * @return 设备 ID。
     */
    public function getDeviceId():String {
        return _config.deviceId;
    }

    /**
     * 设置绑定设备 ID。
     *
     * @param id 设备 ID。
     */
    public function setDeviceId(id:String):void {
        _config.deviceId = id;
    }

    /**
     * 初始化手柄轮询。
     *
     * @param stage 舞台（JoySticker 内部使用）。
     */
    public function initialize(stage:Stage):void {
        JoySticker.initialize(onDevicesChanged);
    }

    /**
     * @param config <code>JoyStickConfigVO</code>。
     */
    public function setConfig(config:Object):void {
        this._config = config as JoyStickConfigVO;
    }

    public function focus():void {
    }

    public function anyKey():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoySticker.isDownAnyKey(_config.deviceId);
    }

    public function back():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoySticker.isDown(_config.deviceId, _config.back) || JoySticker.isDown(_config.deviceId, _config.select);
    }

    public function select():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoySticker.isDown(_config.deviceId, _config.jump);
    }

    public function up():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoySticker.isDown(_config.deviceId, _config.up) || JoySticker.isDown(_config.deviceId, _config.up2);
    }

    public function down():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoySticker.isDown(_config.deviceId, _config.down) || JoySticker.isDown(_config.deviceId, _config.down2);
    }

    public function left():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoySticker.isDown(_config.deviceId, _config.left) || JoySticker.isDown(_config.deviceId, _config.left2);
    }

    public function right():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoySticker.isDown(_config.deviceId, _config.right) ||
               JoySticker.isDown(_config.deviceId, _config.right2);
    }

    public function attack():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoySticker.isDown(_config.deviceId, _config.attack);
    }

    public function jump():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoySticker.isDown(_config.deviceId, _config.jump);
    }

    public function dash():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoySticker.isDown(_config.deviceId, _config.dash);
    }

    public function skill():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoySticker.isDown(_config.deviceId, _config.skill);
    }

    public function superSkill():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoySticker.isDown(_config.deviceId, _config.superSkill);
    }

    public function special():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoySticker.isDown(_config.deviceId, _config.special);
    }

    public function wankai():Boolean {
        if (!_enabled) {
            return false;
        }
        return JoySticker.isDown(_config.deviceId, _config.waikai);
    }

    public function clear():void {
    }
}
}
