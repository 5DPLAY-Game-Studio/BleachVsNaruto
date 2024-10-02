package net.play5d.game.bvn.ui.mosou.enemy
{
	import flash.display.Sprite;
	
	import net.play5d.game.bvn.fighter.FighterMain;

	public class EnemyHpUIGroup
	{
		private var _uis:Vector.<EnemyHpUI>;
		private var _ct:Sprite;
		public function EnemyHpUIGroup(ct:Sprite)
		{
			_ct = ct;
			_uis = new Vector.<EnemyHpUI>();
		}
		
		public function updateFighter(f:FighterMain):void{
			var i:int;
			for(i = 0; i < _uis.length; i++){
				if(_uis[i].getFighter() == f) return;
			}
			
			addUI(f);
		}
		
		public function removeByFighter(f:FighterMain):void{
			var i:int;
			
			for(i = 0; i < _uis.length; i++){
				if(_uis[i] && _uis[i].getFighter() == f){
					removeUI(_uis[i])
				}
			}
			
			sortUI();
		}
		
		public function render():void{
			var i:int;
			
			var removes:Vector.<EnemyHpUI> = new Vector.<EnemyHpUI>();
			for(i = 0; i < _uis.length; i++){
				if(!_uis[i].render()){
					removes.push(_uis[i]);
				}
			}
			
			if(removes.length > 0){
				while(removes.length > 0){
					var e:EnemyHpUI = removes.shift();
					removeUI(e);
				}
				sortUI();
			}
			
		}
		
		
		private function addUI(f:FighterMain):void{
			var ui:EnemyHpUI = new EnemyHpUI(f);
			_uis.push(ui);
			sortUI();
		}
		
		private function removeUI(ui:EnemyHpUI):void{
			var index:int = _uis.indexOf(ui);
			if(index != -1){
				_uis.splice(index, 1);
			}
//			_ct.removeChild(ui.getUI());
		}
		
		private function sortUI():void{
			var i:int,x:int,y:int;
			var len:int = Math.min(_uis.length, 12);
			
			_ct.removeChildren();
			
			for(i = 0; i < len; i++){
				_uis[i].getUI().x = x;
				_uis[i].getUI().y = y;
				
				x -= 110;
				if((i+1) % 4 == 0){
					x = 0;
					y += 30;
				}
				
				_ct.addChild(_uis[i].getUI());
			}
		}
		
	}
}