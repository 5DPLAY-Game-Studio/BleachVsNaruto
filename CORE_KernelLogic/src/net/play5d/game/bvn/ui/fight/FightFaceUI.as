package net.play5d.game.bvn.ui.fight
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.data.FighterVO;

	public class FightFaceUI
	{
		private var _ui:hpbar_facemc;
		public function FightFaceUI(ui:hpbar_facemc)
		{
			_ui = ui;
		}
		
		public function setData(v:FighterVO):void{
			if(!v){
				_ui.visible = false;
				return;
			}
			
			_ui.visible = true;
			
			var faceImg:DisplayObject = AssetManager.I.getFighterFaceBar(v);
			if(faceImg) _ui.ct.addChild(faceImg);
		}
		
		public function setDirect(v:int):void{
		}
		
	}
}