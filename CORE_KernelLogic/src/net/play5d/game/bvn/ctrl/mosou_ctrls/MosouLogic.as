package net.play5d.game.bvn.ctrl.mosou_ctrls
{
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.mosou.MosouFighterSellVO;
	import net.play5d.game.bvn.data.mosou.MosouMissionVO;
	import net.play5d.game.bvn.data.mosou.MosouModel;
	import net.play5d.game.bvn.data.mosou.MosouWorldMapAreaVO;
	import net.play5d.game.bvn.data.mosou.MosouWorldMapVO;
	import net.play5d.game.bvn.data.mosou.player.MosouMissionPlayerVO;
	import net.play5d.game.bvn.data.mosou.player.MosouPlayerData;
	import net.play5d.game.bvn.data.mosou.player.MosouWorldMapAreaPlayerVO;
	import net.play5d.game.bvn.data.mosou.player.MosouWorldMapPlayerVO;
	import net.play5d.game.bvn.fighter.FighterActionState;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.ui.GameUI;

	public class MosouLogic
	{
		private static var _i:MosouLogic;
		
		public static function get I():MosouLogic{
			_i ||= new MosouLogic;
			return _i;
		}
		
		public function MosouLogic()
		{
		}
		
		
		private var _hitNum:int;
		private var _hitTargets:Vector.<FighterMain> = new Vector.<FighterMain>();
		
		public function checkCurrentArea(areaId:String):Boolean{
			var md:MosouPlayerData = GameData.I.mosouData;
			if(!md.getCurrentArea()) return false;
			
			return md.getCurrentArea().id == areaId;
		}
		
		public function checkAreaIsOpen(areaId:String):Boolean{
			var md:MosouPlayerData = GameData.I.mosouData;
			var map:MosouWorldMapPlayerVO = GameData.I.mosouData.getCurrentMap();
			return map.getOpenArea(areaId) != null;
		}
		
		public function getNextMission(area2:MosouWorldMapAreaVO):MosouMissionVO{
			var md:MosouPlayerData = GameData.I.mosouData;
			var map:MosouWorldMapPlayerVO = GameData.I.mosouData.getCurrentMap();
			var area:MosouWorldMapAreaPlayerVO = map.getOpenArea(area2.id);
			
			if(!area) return null;
//			
			var m1:MosouMissionPlayerVO = area.getLastPassedMission();
			
			if(!m1){
				return area2.missions[0];
			}
			
			var m2:MosouMissionVO = area2.getNextMission(m1.id);
			if(m2) return m2;
			return area2.missions[area2.missions.length - 1];
		}
		
		public function getAreaPercent(areaId:String):Number{
			var md:MosouPlayerData = GameData.I.mosouData;
			var map:MosouWorldMapPlayerVO = GameData.I.mosouData.getCurrentMap();
			var area:MosouWorldMapAreaPlayerVO = map.getOpenArea(areaId);
			if(!area) return 0;
			
			var area2:MosouWorldMapAreaVO = MosouModel.I.getMapArea(map.id, area.id);
			if(!area2 || !area2.missions) return 0;
			
			var per:Number = area.getPassedMissionAmount() / area2.missions.length;
			return per;
		}
		
		public function openMapArea(mapId:String, areaId:String):void{
			trace("openMapArea", areaId);
			
			var md:MosouPlayerData = GameData.I.mosouData;
			var map:MosouWorldMapPlayerVO = GameData.I.mosouData.getMapById(mapId);
			map.openArea(areaId);
		}
		
		public function passMission(mission:MosouMissionVO):void{
//			var md:MosouPlayerData = GameData.I.mosouData;
//			var map:MosouWorldMapPlayerVO = GameData.I.mosouData.getCurrentMap();
			
			
			var area:MosouWorldMapAreaPlayerVO = GameData.I.mosouData.getCurrentArea();
			
			if(area.passMission(mission.id)){
				GameData.I.mosouData.addMoney(2000);
			}else{
				GameData.I.mosouData.addMoney(500);
			}
			
			
			updateMapAreas();
			GameData.I.saveData();
		}
		
		public function updateMapAreas():void{
			var pmap:MosouWorldMapPlayerVO = GameData.I.mosouData.getCurrentMap();
			
			var map:MosouWorldMapVO = MosouModel.I.getMap(pmap.id);
			for each(var i:MosouWorldMapAreaVO in map.areas){
				if(i.preOpens && i.preOpens.length > 0){
					
					var isOpenArea:Boolean = true;
					
					for each(var p:MosouWorldMapAreaVO in i.preOpens){
						if(!canPassNextArea(p.id)){
							isOpenArea = false;
							break;
						}
					}
					
					if(isOpenArea) openMapArea(pmap.id, i.id);
					
				}
			}
		}
		
		private function canPassNextArea(areaId:String):Boolean{
			return getAreaPercent(areaId) > 0.6;
		}
		
		
		public function buyFighter(data:MosouFighterSellVO, succback:Function = null):void{
			var mosouData:MosouPlayerData = GameData.I.mosouData;
			if(mosouData.getMoney() < data.getPrice()){
				GameUI.alert('NEED MORE MONEY', "金币不足，需要" + data.getPrice() + "金币！");
				return;
			}
			
			GameUI.confrim('CONFRIM', "确认使用"+data.getPrice()+"金币解锁人物？", function():void{
				mosouData.loseMoney(data.getPrice());
				mosouData.addFighter(data.id);
				GameData.I.saveData();
				if(succback != null) succback();
			});
			
		}
		
		/**
		 * 敌人等级属性
		 */
		public function initEnemyProps(f:FighterMain):void{
			if(!f.mosouEnemyData) return;
			
			
			var mv:MosouMissionVO = MosouModel.I.currentMission;
			var lv:int = mv.enemyLevel;
			
			f.mosouEnemyData.level = lv;
			
			var hpRate:Number, hpAdd:Number, atk:Number, skl:Number, bs:Number;
			
			if(f.mosouEnemyData.isBoss){
				if(f.mosouEnemyData.maxHp > 0){
					f.hp = f.hpMax = f.mosouEnemyData.maxHp;
				}else{
					f.hp = f.hpMax = 1000 + ( lv * 400 );
				}
				
				f.energy = f.energyMax = 80 + ( lv * 10 );
				
				atk = lv * 13;
				skl = lv * 14;
				bs = lv * 15;
				
				f.initAttackAddDmg(atk, skl, bs);
//				f.defense = lv * 2;
				
			}else{
				if(f.mosouEnemyData.maxHp > 0){
					f.hp = f.hpMax = f.mosouEnemyData.maxHp;
				}else{
					hpRate = 1 + (lv - 1) * 0.08;
					if(hpRate > 1) f.hp = f.hpMax = f.hp * hpRate;
				}
				
				atk = lv * 5;
				skl = lv * 10;
				bs = lv * 20;
				
				f.initAttackAddDmg(atk, skl, bs);
			}
			
		}
		
		public function addHits(target:FighterMain):int{
			if(_hitTargets.indexOf(target) == -1){
				_hitTargets.push(target);
			}
			_hitNum++;
			
			if(_hitNum > 1 && GameUI.I.getUI()) GameUI.I.getUI().showHits(_hitNum, 1);
			
			return _hitNum;
		}
		
		public function removeHitTarget(target:FighterMain):void{
			var index:int = _hitTargets.indexOf(target);
			if(index == -1) return;
			
			_hitTargets.splice(index, 1);
			
			if(_hitTargets.length < 1){
				_hitNum = 0;
				if( GameUI.I && GameUI.I.getUI() ) GameUI.I.getUI().hideHits(1);
			}
			
		}
		
		public function clearHits():void{
			_hitNum = 0;
			_hitTargets = new Vector.<FighterMain>();
		}
		
		
	}
}