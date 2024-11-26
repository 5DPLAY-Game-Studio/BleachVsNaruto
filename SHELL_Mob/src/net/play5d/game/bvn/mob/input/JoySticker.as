package net.play5d.game.bvn.mob.input {
import flash.events.GameInputEvent;
import flash.ui.GameInput;
import flash.ui.GameInputControl;
import flash.ui.GameInputDevice;

import net.play5d.game.bvn.mob.GameInterfaceManager;

/**
 * 游戏手柄控制类
 */
public class JoySticker {

    private static var _gameInput:GameInput;
    private static var _inited:Boolean;

    private static var _gameDeivces:Vector.<GameInputDevice>;

    private static var _deivceMap:Object;
    private static var _downKey:JoyStickSetVO;

    /**
     * 初始化，只会调用一次
     */
    public static function initlize():void {

        if (_inited) {
            return;
        }

        trace('JoySticker.initlize');

        if (!GameInput.isSupported) {
            trace('该平台不支持手柄！');
            return;
        }

        _inited = true;

        _gameDeivces = new Vector.<GameInputDevice>();
        _deivceMap   = {};

        _gameInput = new GameInput();
        _gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, joystickHandler);
        _gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, joystickHandler);
        _gameInput.addEventListener(GameInputEvent.DEVICE_UNUSABLE, joystickHandler);
    }

    public static function getAllDeivces():Vector.<GameInputDevice> {
        return _gameDeivces;
    }

    public static function getDeviceId(index:int):String {
        if (index >= _gameDeivces.length) {
            return null;
        }
        var device:GameInputDevice = _gameDeivces[index];
        if (device) {
            return device.id;
        }
        return null;
    }

    public static function isActive(deviceId:String):Boolean {
        var device:GameInputDevice = getDeive(deviceId);
        return device && device.enabled;
    }

    /**
     * 是否按钮按键
     * @param deviceId 1或2
     * @param key
     */
    public static function isDown(deviceId:String, key:JoyStickSetVO):Boolean {
        var device:GameInputDevice = getDeive(deviceId);
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

//			if(key.value > 0){
//				return ctrl.value > key.value;
//			}

        return false;
    }

    public static function isDownAnyKey(deviceId:String):Boolean {
        var device:GameInputDevice = getDeive(deviceId);
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
        var device:GameInputDevice = getDeive(deviceID);
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
                trace('isDown', jv.id + '_' + jv.value);
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
        trace('device.enabled - ' + device.enabled);
        trace('device.id - ' + device.id);
        trace('device.name - ' + device.name);
        trace('device.numControls - ' + device.numControls);
        trace('device.sampleInterval - ' + device.sampleInterval);
        trace('device.MAX_BUFFER - ' + GameInputDevice.MAX_BUFFER_SIZE);

        trace('buttonNum', device.numControls); //这个是按钮数量
        for (var i:int; i < device.numControls; i++) {
            var ctrl:GameInputControl = device.getControlAt(i); //这里传入N，返回第几个按钮的值
            trace('button:' + i + ':' + ctrl.id);
        }

    }

    /**
     * 启用设备
     * @param device
     */
    private static function addDeivce(device:GameInputDevice):void {
        device.enabled = true;
        _gameDeivces.push(device);
//			var id:int = _gameDeivces.length;
        var id:String  = device.id;
        _deivceMap[id] = device;
        trace('addDevice:' + id, ':', device.id);
    }

    /**
     * 移除设备
     * @param device
     */
    private static function removeDevice(device:GameInputDevice):void {
        device.enabled = false;
        var id:int     = _gameDeivces.indexOf(device);
        if (id != -1) {
            _gameDeivces.splice(id, 1);
        }

        for (var i:String in _deivceMap) {
            if (_deivceMap[i] == device) {
                delete _deivceMap[i];
            }
        }

    }

//		/**
//		 * 是否移动摇杆
//		 * @param deviceID
//		 * @return -1:左(上)，1：右（下），0：没动
//		 */
//		public static function isMove(deviceID:String , key:int = 1):int{
//			var device:GameInputDevice = getDeive(deviceID);
//			if(!device) return 0;
//
//			var ctrl:GameInputControl = device.getControlAt(key);
//			if(ctrl.value < ctrl.minValue/2) return -1;
//			if(ctrl.value > ctrl.maxValue/2) return 1;
//
//			return 0;
//		}

    private static function getDeive(deviceId:String):GameInputDevice {
        return _deivceMap[deviceId];
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
//			if(val > 0.5) return 0.5;

        return 0;

    }

    public function JoySticker() {
    }

//		public static function justDownKey(deviceID:String):JoyStickSetVO{
//			var id:String =
//		}

    private static function joystickHandler(e:GameInputEvent):void {
        switch (e.type) {
        case GameInputEvent.DEVICE_ADDED:
            trace('connected', e.device, GameInput.numDevices);
            outputDeviceInfo(e.device);

            if (GameInput.numDevices < 3) {
                addDeivce(e.device);
                GameInterfaceManager.config.updateJoyConfig();
            }

            break;
        case GameInputEvent.DEVICE_REMOVED:
            trace('disconnected', e.device);
            removeDevice(e.device);
            break;
        case GameInputEvent.DEVICE_UNUSABLE:
            trace('unuse', e.device);
            removeDevice(e.device);
            break;
        }
    }

}
}
