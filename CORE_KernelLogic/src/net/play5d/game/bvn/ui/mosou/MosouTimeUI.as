package net.play5d.game.bvn.ui.mosou
{
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	import net.play5d.kyo.utils.KyoTimerFormat;

	public class MosouTimeUI
	{
		private var _ui:Sprite;
		private var _txt:TextField;
		
		public function MosouTimeUI(ui:Sprite)
		{
			_ui = ui;
			_txt = ui.getChildByName('text') as TextField;
		}
		
		public function renderAnimate():void{
			if(_txt){
				var sec:int = GameCtrl.I.getMosouCtrl().gameRunData.gameTime / GameConfig.FPS_ANIMATE;
				_txt.text = KyoTimerFormat.secToTime(sec);
			}
		}
	}
}