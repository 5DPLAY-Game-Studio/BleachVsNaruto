package net.play5d.game.bvn.ui.mosou.enemy
{
	import flash.display.DisplayObject;
	
	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.fighter.FighterMain;

	public class EnemyHpFollowUI
	{
		private var _ui:mosou_enemyhpbarmc2;
		private var _fighter:FighterMain;
		private var _bar:DisplayObject;
		private var _showDelay:int;
		
		public function EnemyHpFollowUI(fighter:FighterMain)
		{
			_ui = new mosou_enemyhpbarmc2();
			_ui.scaleX = _ui.scaleY = 0.5;
			_bar = _ui.getChildByName('barmc');
			_fighter = fighter;
			
			_ui.visible = false;
		}
		
		public function getFighter():FighterMain{
			return _fighter;
		}
		
		public function getUI():DisplayObject{
			return _ui;
		}
		
		public function active():void{
			_ui.visible = true;
			_showDelay = GameConfig.FPS_GAME * 3;
		}
		
		public function render():Boolean{
			if(!_fighter) return false;
			
			if(!_ui.visible) return _fighter.isAlive;
			
			var val:Number = _fighter.hp / _fighter.hpMax;
			if(val < 0.0001) val = 0.0001;
			if(val > 1) val = 1;
			
			_ui.x = _fighter.x;
			_ui.y = _fighter.y - 50;
			
			_bar.scaleX = val;
			
			if(--_showDelay <= 0){
				_ui.visible = false;
			}
			
			return _fighter.isAlive;
		}
		
		public function destory():void{
			_fighter = null;
			_bar = null;
			_ui = null;
		}
		
		
	}
}