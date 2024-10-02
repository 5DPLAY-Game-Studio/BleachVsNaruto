package net.play5d.game.bvn.ui.fight
{
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.display.MCNumber;

	public class FightScoreUI
	{
		private var _ui:score_mc;
		private var _nummc:MCNumber;
		public function FightScoreUI(ui:score_mc)
		{
			_ui = ui;
			
			var txtCls:Class = ResUtils.I.getItemClass(ResUtils.swfLib.fight , 'txtmc_score');
			
			_nummc = new MCNumber(txtCls,0,1,10,10);
			_ui.ct.addChild(_nummc);
		}
		
		public function setScore(v:int):void{
			_nummc.number = v;
		}
		
	}
}