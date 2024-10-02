package net.play5d.game.bvn.views.effects
{
	import flash.geom.ColorTransform;
	
	import net.play5d.game.bvn.ctrl.EffectCtrl;
	import net.play5d.game.bvn.data.EffectVO;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.interfaces.IGameSprite;
	
	public class SteelHitEffect extends EffectView
	{
		private var _fighter:FighterMain;
		
		public function SteelHitEffect(data:EffectVO)
		{
			super(data);
		}
		
		public override function setTarget(v:IGameSprite):void{
			super.setTarget(v);
			
			if(v is FighterMain){
				
				_fighter = v as FighterMain;
				
				if(_fighter.isSteelBody){
					var ct:ColorTransform = new ColorTransform();
					ct.redOffset = 150;
					ct.greenOffset = 150;
					ct.blueOffset = 150;
					
					if(_fighter.isSuperSteelBody){
						ct.blueOffset = 0;
						EffectCtrl.I.shine(0xffff00, 0.3);
					}
					
					_fighter.changeColor(ct);
					EffectCtrl.I.setOnFreezeOver(function():void{
						_fighter.resumeColor();
					});
				}
				
			}
			
			
		}
		
	}
}