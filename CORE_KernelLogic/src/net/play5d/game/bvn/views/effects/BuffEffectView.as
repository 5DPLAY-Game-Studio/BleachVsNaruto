package net.play5d.game.bvn.views.effects
{
	import flash.geom.ColorTransform;
	
	import net.play5d.game.bvn.data.EffectVO;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.fighter.vos.FighterBuffVO;
	import net.play5d.game.bvn.interfaces.IGameSprite;
	
	public class BuffEffectView extends EffectView
	{
		private var _fighter:FighterMain;
		private var _buff:FighterBuffVO;
		
		public function BuffEffectView(data:EffectVO)
		{
			super(data);
			this.loopPlay = true;
		}
		
		public function setBuff(v:FighterBuffVO):void{
			_buff = v;
		}
		
		public override function setTarget(v:IGameSprite):void{
			super.setTarget(v);
			
			if(v is FighterMain){
				_fighter = v as FighterMain;
			}
			
			if(_fighter && _data.targetColorOffset){
				var ct:ColorTransform = new ColorTransform();
				ct.redOffset = _data.targetColorOffset[0];
				ct.greenOffset = _data.targetColorOffset[1];
				ct.blueOffset = _data.targetColorOffset[2];
				_fighter.changeColor(ct);
			}
		}
		
		public override function render():void{
			super.render();
			if(_buff.finished){
				if(_data.targetColorOffset && _fighter) _fighter.resumeColor();
				remove();
			}else{
				if(_fighter) setPos(_fighter.x , _fighter.y);
			}
		}
		
	}
}