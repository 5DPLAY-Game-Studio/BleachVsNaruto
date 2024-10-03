package net.play5d.game.bvn.win.views
{
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.state.SettingState;
	import net.play5d.game.bvn.win.GameInterfaceManager;
	import net.play5d.game.bvn.win.data.ExtendConfig;
	import net.play5d.game.bvn.win.input.JoyStickConfigVO;
	import net.play5d.kyo.stage.Istage;

	public class ViewManager
	{
		private static var _i:ViewManager;
		public static function get I():ViewManager{
			_i ||= new ViewManager();
			return _i;
		}
		
		public function ViewManager()
		{
		}
		
		public function goP1JoyStickSet():void{
			goJoyStickSet(1 , GameInterfaceManager.config.joy1Config);
		}
		
		public function goP2JoyStickSet():void{
			goJoyStickSet(2 , GameInterfaceManager.config.joy2Config);
		}
		
		private function goJoyStickSet(player:int , config:JoyStickConfigVO):void{
			var curStg:Istage = MainGame.stageCtrl.currentStage;
			if(!curStg is SettingState) return;
			var setStg:SettingState = curStg as SettingState;
			var joyStickSetUI:JoyStickSetUI = new JoyStickSetUI();
			joyStickSetUI.setConfig(player , config);
			setStg.goInnerSetPage(joyStickSetUI);
		}
		
	}
}