package net.play5d.game.bvn.ctrl.game_ctrls
{
	import net.play5d.game.bvn.ctrl.EffectCtrl;
	import net.play5d.game.bvn.data.GameRunFighterGroup;
	import net.play5d.game.bvn.fighter.Assister;
	import net.play5d.game.bvn.fighter.Bullet;
	import net.play5d.game.bvn.fighter.FighterAttacker;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.fighter.events.FighterEvent;
	import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;

	public class BaseFighterEventCtrl
	{
		private var _attackers:Array = [];
		
		public function BaseFighterEventCtrl()
		{
		}
		
		public function initlize():void{
			FighterEventDispatcher.removeAllListeners();
			
			FighterEventDispatcher.addEventListener(FighterEvent.FIRE_BULLET,fireBullet);
			FighterEventDispatcher.addEventListener(FighterEvent.ADD_ATTACKER,addAttacker);
			
		}
		
		/**
		 * 发射子弹 ，通过事件帧听
		 */
		private function fireBullet(event:FighterEvent):void{
			var params:Object = event.params;
			if(!params || !params.mc) return;
			
			var bullet:Bullet = new Bullet(params.mc , params);
			bullet.onRemove = removeBullet;
			bullet.setHitVO(params.hitVO);
			
			GameCtrl.I.addGameSprite(event.fighter.team.id , bullet);
		}
		
		/**
		 * 移除子弹 , 通过bullet.onRemove传入
		 */
		private function removeBullet(bullet:Bullet):void{
			GameCtrl.I.removeGameSprite(bullet);
		}
		
		private function addAttacker(event:FighterEvent):void{
			var params:Object = event.params;
			if(!params || !params.mc) return;
			
			var attacker:FighterAttacker = new FighterAttacker(params.mc , params);
			attacker.onRemove = removeAttacker;
			attacker.setOwner(event.fighter);
			attacker.init();
			
			_attackers.push(attacker);
			
			GameCtrl.I.addGameSprite(event.fighter.team.id , attacker);
		}
		
		private function removeAttacker(attacker:FighterAttacker):void{
			GameCtrl.I.removeGameSprite(attacker);
			var id:int = _attackers.indexOf(attacker);
			if(id != -1) _attackers.splice(id,1);
		}
		
		public function getAttacker(name:String , team:int):FighterAttacker{
			for each(var i:FighterAttacker in _attackers){
				if(i.name == name && i.team.id == team){
					return i;
				}
			}
			return null;
		}
		
		public function destory():void{
			FighterEventDispatcher.removeAllListeners();
		}
		
		
	}
}