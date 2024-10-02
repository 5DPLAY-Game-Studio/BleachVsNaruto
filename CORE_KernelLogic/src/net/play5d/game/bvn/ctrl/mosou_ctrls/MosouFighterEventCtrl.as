package net.play5d.game.bvn.ctrl.mosou_ctrls
{
	import net.play5d.game.bvn.ctrl.EffectCtrl;
	import net.play5d.game.bvn.ctrl.game_ctrls.BaseFighterEventCtrl;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.GameRunFighterGroup;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.fighter.events.FighterEvent;
	import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
	import net.play5d.game.bvn.interfaces.IGameSprite;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.game.bvn.ui.mosou.MosouUI;

	public class MosouFighterEventCtrl extends BaseFighterEventCtrl
	{
		
		public function MosouFighterEventCtrl()
		{
		}
		
		public override function initlize():void{
			super.initlize();
			
			FighterEventDispatcher.addEventListener(FighterEvent.HIT_TARGET,onHitTarget);
			
			FighterEventDispatcher.addEventListener(FighterEvent.BIRTH,onEnemyEvent);
			FighterEventDispatcher.addEventListener(FighterEvent.HURT,onEnemyEvent);
			FighterEventDispatcher.addEventListener(FighterEvent.DEFENSE,onEnemyEvent);
//			FighterEventDispatcher.addEventListener(FighterEvent.DEAD, onEnemyEvent);
			FighterEventDispatcher.addEventListener(FighterEvent.IDLE, onEnemyEvent);
			FighterEventDispatcher.addEventListener(FighterEvent.HURT_RESUME, onEnemyEvent);
			FighterEventDispatcher.addEventListener(FighterEvent.HURT_DOWN, onEnemyEvent);
			
			FighterEventDispatcher.addEventListener(FighterEvent.DO_SPECIAL, changeFighter);
//			FighterEventDispatcher.addEventListener(FighterEvent.IDLE,onIdle);
			FighterEventDispatcher.addEventListener(FighterEvent.DIE,onDie);
			FighterEventDispatcher.addEventListener(FighterEvent.DEAD,onDead);
		}
		
		private function onEnemyEvent(event:FighterEvent):void{
			var f:FighterMain = event.fighter as FighterMain;
			if(!f.mosouEnemyData) return;
			
			switch(event.type){
				case FighterEvent.BIRTH:
					onEnemyBirth(f);
					break;
				case FighterEvent.HURT:
				case FighterEvent.DEFENSE:
					onEnemyBeHit(f);
					break;
//				case FighterEvent.DEAD:
//					MosouLogic.I.removeHitTarget(f);
//					onEnemyDead(f);
//					break;
				case FighterEvent.IDLE:
				case FighterEvent.HURT_RESUME:
				case FighterEvent.HURT_DOWN:
					MosouLogic.I.removeHitTarget(f);
					break;
			}
		}
		
		private function onHitTarget(e:FighterEvent):void{
			addHits(e.fighter as FighterMain,e.params.target);
		}
		
		private function onEnemyBeHit(f:FighterMain):void{
//			var ui:MosouUI = GameUI.I.getUI() as MosouUI;
//			if(ui) ui.updateEnemyHp(f);
			
			GameCtrl.I.getMosouCtrl().updateEnemy(f);
		}
		
		private function onEnemyBirth(f:FighterMain):void{
			if(f.mosouEnemyData.isBoss){
				GameCtrl.I.getMosouCtrl().onBossBirth(f);
			}
			GameCtrl.I.getMosouCtrl().updateEnemy(f);
		}
		
		private function onEnemyDead(f:FighterMain):void{
			GameCtrl.I.getMosouCtrl().gameRunData.koNum++;
			(GameUI.I.getUI() as MosouUI).updateKONum();
			
			GameData.I.mosouData.addMoney(f.mosouEnemyData.getMoney());
			GameData.I.mosouData.addFighterExp(f.mosouEnemyData.getExp());
			
			if(f.mosouEnemyData.isBoss){
				GameCtrl.I.getMosouCtrl().onBossDead(f);
				
				var ui:MosouUI = GameUI.I.getUI() as MosouUI;
				if(ui) ui.updateBossHp();
				
				return;
			}
			
			EffectCtrl.I.removeEnemyEffect(f, function():void{
				GameCtrl.I.getMosouCtrl().removeEnemy(f);
			});
		}
		
		private function changeFighter(event:FighterEvent):void{
			var f:FighterMain = event.fighter as FighterMain;
			if(f.team && f.team.id != 1) return;
			
			changeNextFighter();
		}
		
		private function changeNextFighter():Boolean{
			var group:GameRunFighterGroup = GameCtrl.I.gameRunData.p1FighterGroup;
			var nextFighter:FighterMain = group.getNextAliveFighter();
			if(!nextFighter) return false;
			
			GameCtrl.I.getMosouCtrl().changeFighter(group.currentFighter, nextFighter);
			
			return true;
		}
		
		private function onDie(event:FighterEvent):void{
			var f:FighterMain = event.fighter as FighterMain;
			if(f.team.id == 1) {
				GameCtrl.I.getMosouCtrl().onSelfDie(f);
			}
			if(f.team.id == 2) {
				MosouLogic.I.removeHitTarget(f);
				
				var isBoss:Boolean = f.mosouEnemyData && f.mosouEnemyData.isBoss;
				if(isBoss) GameCtrl.I.getMosouCtrl().onBossDie(f);
			}
		}
		
		private function onDead(event:FighterEvent):void{
			var f:FighterMain = event.fighter as FighterMain;
			if(f.team.id == 1) {
				GameCtrl.I.getMosouCtrl().onSelfDead(f);
			}
			if(f.team.id == 2) {
//				MosouLogic.I.removeHitTarget(f);
				onEnemyDead(f);
			}
		}
		
		//显示连击数字
		private function addHits(fighter:FighterMain , target:IGameSprite):void{
			if(!(target is FighterMain)) return;
			if(fighter.team.id != 1) return;
			
			MosouLogic.I.addHits(target as FighterMain);
		}
		
	}
}