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
import flash.events.GameInputEvent;
import flash.ui.GameInput;
import flash.ui.GameInputControl;
import flash.ui.GameInputDevice;

import net.play5d.game.bvn.utils.GameLogger;

/**
 * 游戏手柄控制类
 */
public class JoyStick {

    private static var _gameInput:GameInput;
    private static var _inited:Boolean;

    private static var _gameDevices:Vector.<GameInputDevice>;

    private static var _deviceMap:Object;
    private static var _downKey:JoyStickSetVO;
    /** @private 设备列表变更回调（可选） */
    private static var _onDevicesChanged:Function;

    /**
     * 初始化，只会调用一次。
     * @param onDevicesChanged 手柄增减后回调；可为 <code>null</code>。
     */
    public static function initialize(onDevicesChanged:Function = null):void {
        if (onDevicesChanged != null) {
            _onDevicesChanged = onDevicesChanged;
        }

        if (_inited) {
            return;
        }

        GameLogger.debug('input', 'JoyStick.initialize');

        if (!GameInput.isSupported) {
            TraceLang('joy_stick.platform_unsupported');
            return;
        }

        _inited = true;

        _gameDevices = new Vector.<GameInputDevice>();
        _deviceMap   = {};

        _gameInput = new GameInput();
        _gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, joystickHandler);
        _gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, joystickHandler);
        _gameInput.addEventListener(GameInputEvent.DEVICE_UNUSABLE, joystickHandler);
    }

    public static function getAllDevices():Vector.<GameInputDevice> {
        return _gameDevices;
    }

    public static function getDeviceId(index:int):String {
        if (index >= _gameDevices.length) {
            return null;
        }
        var device:GameInputDevice = _gameDevices[index];
        if (device) {
            return device.id;
        }
        return null;
    }

    public static function isActive(deviceId:String):Boolean {
        var device:GameInputDevice = getDevice(deviceId);
        return device && device.enabled;
    }

    /**
     * 是否按钮按键
     * @param deviceId 1或2
     * @param key
     */
    public static function isDown(deviceId:String, key:JoyStickSetVO):Boolean {
        var device:GameInputDevice = getDevice(deviceId);
        if (!device) {
            return false;
        }

        if (key.id > device.numControls) {
            return false;
        }

        var ctrl:GameInputControl = device.getControlAt(key.id);
        if (!ctrl) {
            return false;
        }

        if (key.value > 0) {
            return ctrl.value > 0.5;
        }

        if (key.value < 0) {
            return ctrl.value < -0.5;
        }

        return false;
    }

    public static function isDownAnyKey(deviceId:String):Boolean {
        var device:GameInputDevice = getDevice(deviceId);
        if (!device) {
            return false;
        }

        for (var i:int; i < device.numControls; i++) {
            if (checkDownValue(device, i)) {
                return true;
            }
        }
        return false;
    }

    public static function getDownKey(deviceID:String, isJustDown:Boolean):JoyStickSetVO {
        var device:GameInputDevice = getDevice(deviceID);
        if (!device) {
            return null;
        }

        for (var i:int; i < device.numControls; i++) {
            var val:Number = checkDownValue(device, i);
            if (val != 0) {

                if (_downKey) {
                    var id:String     = i + '_' + val;
                    var downId:String = _downKey.id + '_' + _downKey.value;
                    if (downId == id) {
                        return isJustDown ? null : _downKey;
                    }
                }

                var jv:JoyStickSetVO = new JoyStickSetVO(i, val);
                _downKey             = jv;
                GameLogger.debug('input', 'isDown ' + jv.id + '_' + jv.value);

                return jv;
            }
        }

        return null;
    }

    /**
     * 输出设备信息
     * @param device
     */
    private static function outputDeviceInfo(device:GameInputDevice):void {
        var buttons:Array = [];
        for (var i:int; i < device.numControls; i++) {
            var ctrl:GameInputControl = device.getControlAt(i);
            buttons.push(i + ':' + ctrl.id);
        }
        GameLogger.debug('input', 'device enabled=' + device.enabled
                + ' id=' + device.id
                + ' name=' + device.name
                + ' numControls=' + device.numControls
                + ' sampleInterval=' + device.sampleInterval
                + ' maxBuffer=' + GameInputDevice.MAX_BUFFER_SIZE
                + ' buttons=' + buttons.join(','));
    }

    /**
     * 启用设备
     * @param device
     */
    private static function addDevice(device:GameInputDevice):void {
        device.enabled = true;
        _gameDevices.push(device);
        var id:String  = device.id;
        _deviceMap[id] = device;
        GameLogger.debug('input', 'addDevice ' + id);
    }

    /**
     * 移除设备
     * @param device
     */
    private static function removeDevice(device:GameInputDevice):void {
        device.enabled = false;
        var id:int     = _gameDevices.indexOf(device);
        if (id != -1) {
            _gameDevices.splice(id, 1);
        }

        for (var i:String in _deviceMap) {
            if (_deviceMap[i] == device) {
                delete _deviceMap[i];
            }
        }

    }

    private static function getDevice(deviceId:String):GameInputDevice {
        return _deviceMap[deviceId];
    }

    private static function checkDownValue(device:GameInputDevice, key:int):Number {
        if (key > device.numControls) {
            return 0;
        }

        var ctrl:GameInputControl = device.getControlAt(key);
        if (!ctrl) {
            return 0;
        }

        var val:Number = ctrl.value;

        if (val == 1 || val > 0.5) {
            return 1;
        }
        if (val < -0.5) {
            return -1;
        }

        return 0;

    }

    private static function joystickHandler(e:GameInputEvent):void {
        switch (e.type) {
        case GameInputEvent.DEVICE_ADDED:
            GameLogger.debug('input', 'connected ' + e.device + ' ' + GameInput.numDevices);
            outputDeviceInfo(e.device);

            if (GameInput.numDevices < 3) {
                addDevice(e.device);
                if (_onDevicesChanged != null) {
                    _onDevicesChanged();
                }
            }

            break;
        case GameInputEvent.DEVICE_REMOVED:
            GameLogger.debug('input', 'disconnected ' + e.device);
            removeDevice(e.device);
            break;
        case GameInputEvent.DEVICE_UNUSABLE:
            GameLogger.debug('input', 'unused ' + e.device);
            removeDevice(e.device);
            break;
        }
    }

}
}
