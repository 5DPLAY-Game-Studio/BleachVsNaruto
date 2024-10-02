package net.play5d.game.bvn.ui.mosou.enemy
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.fighter.FighterMain;

	public class EnemyHpUI
	{
		private var _ui:mosou_enemyhpbarmc;
		private var _fighter:FighterMain;
		private var _bar:DisplayObject;
		private var _faceCt:Sprite;
		
		public function EnemyHpUI(fighter:FighterMain)
		{
			_ui = new mosou_enemyhpbarmc();
			_bar = _ui.getChildByName('bar');
			_faceCt = _ui.getChildByName('ct_face') as Sprite;
			_fighter = fighter;
			
			var faceImg:DisplayObject = AssetManager.I.getFighterFace(_fighter.data);
			if(faceImg){
				_faceCt.addChild(faceImg);
			}
		}
		
		public function getFighter():FighterMain{
			return _fighter;
		}
		
		public function getUI():DisplayObject{
			return _ui;
		}
		
		public function render():Boolean{
			var val:Number = _fighter.hp / _fighter.hpMax;
			if(val < 0.0001) val = 0.0001;
			if(val > 1) val = 1;
			
			_bar.scaleX = val;
			
			return _fighter.isAlive;
		}
		
		public function destory():void{
			
		}
		
		
	}
}