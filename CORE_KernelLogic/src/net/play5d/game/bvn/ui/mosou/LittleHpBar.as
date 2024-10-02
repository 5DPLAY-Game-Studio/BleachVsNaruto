package net.play5d.game.bvn.ui.mosou
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.fighter.FighterMain;

	public class LittleHpBar
	{
		private var _ui:mosou_little_hpbar_mc;
		private var _fighter:FighterMain;
		public function LittleHpBar(ui:mosou_little_hpbar_mc)
		{
			_ui = ui;
		}
		
		public function setFighter(f:FighterMain):void{
			_fighter = f;
			updateFace();
		}
		
		private function updateFace():void{
			var ct:Sprite = _ui.face.getChildByName('ct') as Sprite;
			if(ct){
				var faceImg:DisplayObject = AssetManager.I.getFighterFace(_fighter.data);
				if(faceImg){
					ct.removeChildren();
					ct.addChild(faceImg);
				}
			}
			
		}
		
		
//		public function render():void{
//			
//		}
		
		public function renderAnimate():void{
			if(!_fighter) return;
			_ui.bar_hp.scaleX = getScale(_fighter.hp, _fighter.hpMax);
			_ui.bar_qi.scaleX = getScale(_fighter.qi, 300);
		}
		
		private function getScale(val:Number, max:Number):Number{
			var rate:Number = val / max;
			if(rate < 0.0001) rate = 0.0001;
			if(rate > 1) rate = 1;
			return rate;
		}
		
	}
}