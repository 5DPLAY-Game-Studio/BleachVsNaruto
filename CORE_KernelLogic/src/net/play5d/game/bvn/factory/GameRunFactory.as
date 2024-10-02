package net.play5d.game.bvn.factory
{
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	
	import net.play5d.game.bvn.ctrl.game_stage_loader.GameStageLoadCtrl;
	import net.play5d.game.bvn.data.FighterModel;
	import net.play5d.game.bvn.data.FighterVO;
	import net.play5d.game.bvn.data.MapVO;
	import net.play5d.game.bvn.data.mosou.MosouEnemyVO;
	import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
	import net.play5d.game.bvn.fighter.Assister;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.map.MapMain;

	public class GameRunFactory
	{
		private static var _fighterCache:Dictionary = new Dictionary();
		
		public function GameRunFactory()
		{
		}
		
		public static function createEnemyByData(data:MosouEnemyVO):FighterMain{
			var fv:FighterVO = FighterModel.I.getFighter(data.fighterID, true);
			if(!fv) return null;
			
			var fighter:FighterMain = createFighterByData(fv, "2");
			if(!fighter) return null;
			
			fighter.mosouEnemyData = data;
			fighter.hp = fighter.hpMax = data.maxHp;
			return fighter;
		}
		
		public static function createFighterByData(data:FighterVO, playerId:String):FighterMain{
			var mc:MovieClip = GameStageLoadCtrl.I.getFighterMc(data.fileUrl, playerId);
			var fighter:FighterMain = new FighterMain(mc);
			fighter.data = data;
			return fighter;
		}
		
		public static function createFighterByMosouData(data:FighterVO, mosouData:MosouFighterVO, playerId):FighterMain{
			var fighter:FighterMain = createFighterByData(data, playerId);
			if(!fighter) return null;
			
			fighter.initMosouFighter(mosouData);
			return fighter;
		}
		
//		public static function getCacheFighter(data:FighterVO):FighterMain{
//			if(_fighterCache[data]) return _fighterCache[data];
//			
//			var fm:FighterMain = createFighterByData(data);
//			_fighterCache[data] = fm;
//			
//			return fm;
//		}
		
		public static function createMapByData(data:MapVO):MapMain{
			var mc:MovieClip = GameStageLoadCtrl.I.getMapMc(data.fileUrl);
			var map:MapMain = new MapMain(mc);
			map.data = data;
			return map;
		}
		
		public static function createAssisterByData(data:FighterVO, playerId:String):Assister{
			var mc:MovieClip = GameStageLoadCtrl.I.getAssisterMc(data.fileUrl, playerId);
			var assister:Assister = new Assister(mc);
			assister.data = data;
			return assister;
		}
		
	}
}