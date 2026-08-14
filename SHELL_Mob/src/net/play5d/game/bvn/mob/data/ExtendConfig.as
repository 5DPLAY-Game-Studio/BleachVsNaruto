package net.play5d.game.bvn.mob.data {
import net.play5d.game.bvn.interfaces.IExtendConfig;
import net.play5d.game.bvn.input.JoyStickConfigVO;
import net.play5d.game.bvn.input.JoyStickExtendConfigHelper;

public class ExtendConfig implements IExtendConfig {

    public var joyMenuConfig:JoyStickConfigVO = new JoyStickConfigVO();
    public var joy1Config:JoyStickConfigVO    = new JoyStickConfigVO();
    /**
     * 屏幕尺寸定义：0=拉伸，1=居中
     */
    public var screenMode:int = 1;
    /**
     * 按键设置
     */
    public var screenPadConfig:ScreenPadConfigVO = new ScreenPadConfigVO();
    private var _isInitDefaultJoystick:Boolean;

    public function toSaveObj():Object {
        var o:Object      = {};
        o.joy_menu        = joyMenuConfig.toObj();
        o.joy_p1          = joy1Config.toObj();
        o.screenMode      = screenMode;
        o.screenPadConfig = screenPadConfig.toObj();
        return o;
    }

    public function readSaveObj(obj:Object):void {
        if (!obj) {
            return;
        }

        joyMenuConfig.readObj(obj.joy_menu);
        joy1Config.readObj(obj.joy_p1);

        if (obj.screenMode != undefined) {
            screenMode = obj.screenMode;
        }
        if (obj.screenPadConfig != undefined) {
            screenPadConfig.readObj(obj.screenPadConfig);
        }

        updateJoyConfig();
    }

    public function updateJoyConfig():void {
        initDefaultDevices();
        JoyStickExtendConfigHelper.syncMenuDeviceFromP1(joyMenuConfig, joy1Config);
    }

    private function initDefaultDevices():void {
        if (_isInitDefaultJoystick) {
            return;
        }

        trace('initDefaultDevices');

        _isInitDefaultJoystick = true;

        JoyStickExtendConfigHelper.setDefaultDevice(joy1Config, 0);
    }

}
}
