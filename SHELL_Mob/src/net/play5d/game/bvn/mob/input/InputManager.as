package net.play5d.game.bvn.mob.input {
public class InputManager {

    private static var _i:InputManager;

    public static function get I():InputManager {
        _i ||= new InputManager();
        return _i;
    }

    public function InputManager() {
    }
    public var screen_menu:ScreenPadInput = new ScreenPadInput();
    public var screen_p1:ScreenPadInput   = new ScreenPadInput();
    public var joy_menu:GameJoystickInput = new GameJoystickInput(1);
    public var joy_p1:GameJoystickInput   = new GameJoystickInput(1);
    public var socket_input_p1:GameSocketInput = new GameSocketInput();

//		public const defaultConfig:JoyStickConfigVO = new JoyStickConfigVO();
    public var socket_input_p2:GameSocketInput = new GameSocketInput();

//		public function updateSetting():void{
//			joy_menu.setDeviceId(joy_p1.getDeviceId());
//		}
}
}
