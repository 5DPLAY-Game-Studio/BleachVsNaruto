package net.play5d.game.bvn.win.data
{
	import net.play5d.game.bvn.interfaces.IExtendConfig;
	import net.play5d.game.bvn.win.input.JoyStickConfigVO;
	import net.play5d.game.bvn.win.input.JoySticker;

	public class ExtendConfig implements IExtendConfig
	{
		
		public var joyMenuConfig:JoyStickConfigVO = new JoyStickConfigVO();
		public var joy1Config:JoyStickConfigVO = new JoyStickConfigVO();
		public var joy2Config:JoyStickConfigVO = new JoyStickConfigVO();
		
		public var isFullScreen:Boolean = true;
		
		private var _isInitDefaultJoystick:Boolean;
		
		public function ExtendConfig()
		{
		}
		
		public function toSaveObj():Object{
			var o:Object = {};
			o.joy_menu = joyMenuConfig.toObj();
			o.joy_p1 = joy1Config.toObj();
			o.joy_p2 = joy2Config.toObj();
			o.isFullScreen = isFullScreen;
			o.lan_name = LanGameModel.I.playerName;
			return o;
		}
		
		public function readSaveObj(obj:Object):void{
			if(!obj) return;
			joyMenuConfig.readObj(obj.joy_menu);
			joy1Config.readObj(obj.joy_p1);
			joy2Config.readObj(obj.joy_p2);
			isFullScreen = obj.isFullScreen;
			updateJoyConfig();
			
			if(obj.lan_name) LanGameModel.I.playerName = obj.lan_name;
			
		}
		
		public function updateJoyConfig():void{
			initDefaultDevices();
			joyMenuConfig.deviceId = joy1Config.deviceId;
		}
		
		private function initDefaultDevices():void{
			if(_isInitDefaultJoystick) return;
			
			trace('initDefaultDevices');
			
			_isInitDefaultJoystick = true;
			
			setDefaultDevice(joy1Config , 0);
			setDefaultDevice(joy2Config , 1);
		}
		
		private function setDefaultDevice(joy:JoyStickConfigVO , index:int):void{
			if(!joy.deviceIsSet && joy.deviceId == null) joy.deviceId = JoySticker.getDeviceId(index);
		}
		
	}
}