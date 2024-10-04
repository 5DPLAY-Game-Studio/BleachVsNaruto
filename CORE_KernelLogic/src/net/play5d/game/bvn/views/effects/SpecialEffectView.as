package net.play5d.game.bvn.views.effects
{
	import flash.geom.ColorTransform;

	import net.play5d.game.bvn.data.EffectVO;
	import net.play5d.game.bvn.fighter.FighterActionState;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.interfaces.IGameSprite;

	/**
	 * 火、冰、雷 击中后续效果
	 */
	public class SpecialEffectView extends EffectView
	{
		private var _fighter:FighterMain;
		private var _finished:Boolean;

		public function SpecialEffectView(data:EffectVO)
		{
			super(data);
		}

		public override function setTarget(v:IGameSprite):void{
			super.setTarget(v);

			if(v is FighterMain){
				_fighter = v as FighterMain;
				if(_data.targetColorOffset){
					var ct:ColorTransform = new ColorTransform();
					ct.redOffset = _data.targetColorOffset[0];
					ct.greenOffset = _data.targetColorOffset[1];
					ct.blueOffset = _data.targetColorOffset[2];
					_fighter.changeColor(ct);
				}
			}
		}

		public override function start(x:Number=0, y:Number=0, direct:int=1, playSound:Boolean = true):void{
			super.start(x, y, direct, playSound);
			_finished = false;
		}

		public override function render():void{
			super.render();

			if(_finished) return;
			if(!_fighter) return;

			switch(_fighter.actionState){
				case FighterActionState.HURT_DOWN:
				case FighterActionState.HURT_DOWN_TAN:
				case FighterActionState.NORMAL:
					gotoAndPlay("finish");
					_finished = true;
					if(_data.targetColorOffset) _fighter.resumeColor();
					break;
				default:
					setPos(_fighter.x , _fighter.y);
			}

		}

	}
}
