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
 * 手柄设备轮询。
 *
 * <p>平台不支持时只打日志并返回，下次仍会再试。支持时只完成一次初始化。
 * 回调在初始化之前就记下，传 null 不会清掉已有回调。
 * 接入时设备总数已经不少于 3 就不再收入，所以同时留在表里的不超过两台。拔掉或不可用时移出表，但不调用回调。
 * 按下阈值固定是大于 0.5 或小于 -0.5，键值只取正负，0 永远不算按下。
 * 成功初始化之前，设备列表是 null，按 id 查询会抛错。</p>
 *
 * @see JoyStickSetVO
 * @see flash.ui.GameInput
 */
public class JoyStick {

    /** @private */
    private static var _gameInput:GameInput;
    /** @private */
    private static var _inited:Boolean;

    /** @private */
    private static var _gameDevices:Vector.<GameInputDevice>;

    /** @private */
    private static var _deviceMap:Object;
    /** @private 上次返回的按下键，松开会留着 */
    private static var _downKey:JoyStickSetVO;
    /** @private 设备列表变更回调（可选） */
    private static var _onDevicesChanged:Function;

    /**
     * 开始监听手柄。
     *
     * <p>传入非 null 的回调会立刻记下，已初始化时也会换成这次的函数。null 不会清掉已有回调。
     * 平台不支持时只打日志并返回，下次调用还会再试。支持时设备监听只挂一次。</p>
     *
     * @param onDevicesChanged 设备加入后的回调，可为 null。
     * @example
     * <listing version="3.0">
     * JoyStick.initialize(onDevicesChanged);
     * </listing>
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

    /**
     * 当前已加入的设备。初始化成功前是 null，返回的是内部向量。
     *
     * @return 设备列表；还没初始化时为 null。
     * @example
     * <listing version="3.0">
     * var list:Vector.&lt;GameInputDevice&gt; = JoyStick.getAllDevices();
     * </listing>
     */
    public static function getAllDevices():Vector.<GameInputDevice> {
        return _gameDevices;
    }

    /**
     * 按加入顺序取设备 ID。
     *
     * @param index 从 0 开始。超出长度，或该位没有设备时返回 null。
     * @return 设备 ID。
     * @throws TypeError 还没初始化成功时。
     * @throws RangeError 序号为负时。
     * @example
     * <listing version="3.0">
     * var id:String = JoyStick.getDeviceId(0);
     * </listing>
     */
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

    /**
     * 该设备是否还在表里并且启用。
     *
     * @param deviceId 设备 ID。找不到时结果为假。
     * @return 启用时为 true。
     * @throws TypeError 还没初始化成功时。
     * @example
     * <listing version="3.0">
     * var on:Boolean = JoyStick.isActive(deviceId);
     * </listing>
     */
    public static function isActive(deviceId:String):Boolean {
        var device:GameInputDevice = getDevice(deviceId);
        return device && device.enabled;
    }

    /**
     * 指定控件是否越过按下阈值。
     *
     * <p>键值为正时看控件值是否大于 0.5，为负时看是否小于 -0.5，为 0 时返回 false。控件序号大于设备控件数时返回 false。</p>
     *
     * @param deviceId 设备 ID。
     * @param key 控件序号和方向。null 时抛错。
     * @return 按下时为 true。没有这台设备时为 false。
     * @throws TypeError 还没初始化成功，或 <code>key</code> 为 null 时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = JoyStick.isDown(deviceId, key);
     * </listing>
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

    /**
     * 是否有任意控件越过按下阈值。
     *
     * @param deviceId 设备 ID。
     * @return 有则 true。没有这台设备时为 false。
     * @throws TypeError 还没初始化成功时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = JoyStick.isDownAnyKey(deviceId);
     * </listing>
     */
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

    /**
     * 取当前第一个越过阈值的控件。
     *
     * <p>和上次是同一控件、同一方向时，<code>isJustDown</code> 为 true 返回 null，为 false 返回上次那份对象。换了控件则返回新建的一份。
     * 全部松开时不清除上次记录，同一控件松开后再按下，仍会当成还按着。</p>
     *
     * @param deviceID 设备 ID。
     * @param isJustDown 为 true 时，重复的控件返回 null。
     * @return 新按下的控件；没有设备或没有按下时为 null。
     * @throws TypeError 还没初始化成功时。
     * @example
     * <listing version="3.0">
     * var key:JoyStickSetVO = JoyStick.getDownKey(deviceId, true);
     * </listing>
     */
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
