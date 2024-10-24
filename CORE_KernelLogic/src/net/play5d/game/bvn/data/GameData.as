/*
 * Copyright (C) 2021-2024, 5DPLAY Game Studio
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package net.play5d.game.bvn.data
{
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.data.mosou.MosouFighterModel;
	import net.play5d.game.bvn.data.mosou.MosouFighterSellVO;
	import net.play5d.game.bvn.data.mosou.MosouMissionVO;
	import net.play5d.game.bvn.data.mosou.MosouModel;
	import net.play5d.game.bvn.data.mosou.MosouWorldMapAreaVO;
	import net.play5d.game.bvn.data.mosou.MosouWorldMapVO;
	import net.play5d.game.bvn.data.mosou.player.MosouPlayerData;
	import net.play5d.game.bvn.debug.Debugger;
	import net.play5d.game.bvn.interfaces.GameInterface;
	import net.play5d.kyo.loader.KyoURLoader;

	public class GameData
	{
		private static var _i:GameData;

		public static function get I():GameData{
			_i ||= new GameData();
			return _i;
		}

		public var config:ConfigVO = new ConfigVO();
		public var mosouData:MosouPlayerData = new MosouPlayerData();

		public var p1Select:SelectVO;
		public var p2Select:SelectVO;
		public var selectMap:String;

		public var score:int = 0;

		public var winnerId:String;

		public var isFristRun:Boolean = true;

		private const SAVE_ID:String = 'bvn3.5A';

		// 是否启动无双模式的数据保存
		private const __MOSOU_DATA_ENABLED:Boolean = true;
//		private const __MOSOU_DATA_ENABLED:Boolean = false;

		public function GameData()
		{

		}

		public function loadConfig(back:Function , fail:Function = null):void{

			AssetManager.I.loadXML("config/fighter.xml",loadFighterBack , loadFighterFail);

			function loadFighterBack(data:XML):void{
				FighterModel.I.initByXML(data);
				AssetManager.I.loadXML("config/assist.xml",loadAssetsBack , loadAssisterFail);
			}

			function loadAssetsBack(data:XML):void{
				AssisterModel.I.initByXML(data);
				AssetManager.I.loadXML("config/select.xml",loadSelectBack , loadSelectFail);
			}

			function loadSelectBack(data:XML):void{
				config.select_config.setByXML(data);
//				AssetManager.I.loadXML("config/map.xml",loadMapBack , loadMapFail);
				AssetManager.I.loadJSON('config/map.json', loadMapBack, loadMapFail);
			}

			function loadMapBack(data:Object):void{
				MapModel.I.initByObject(data);
//				AssetManager.I.loadXML("config/mission.xml",loadMissionBack , loadMissionFail);
				AssetManager.I.loadJSON('config/mission.json', loadMissionBack, loadMissionFail);
			}

			function loadMissionBack(data:Object):void{
				MessionModel.I.initByObject(data);
//				AssetManager.I.loadXML("config/mosou.xml",loadMosouMission , loadMosouMission);

				MosouModel.I.loadMapData(loadMosouDataBack, loadMosouFail);
			}

			function loadMosouDataBack():void{
				MosouFighterModel.I.init();

				validateSelect();
				validateMissionData();
				validateMosouData();

				if(back != null) back();
			}

//			function loadMosouMission(data:String):void{
//				MosouMissionModel.I.initByXML(new XML(data));
//				back();
//			}

			function loadFighterFail():void{
				Debugger.log("读取人物数据出错");
				if(fail != null) fail("读取人物数据出错");
			}

			function loadAssisterFail():void{
				Debugger.log("读取辅助角色数据出错");
				if(fail != null) fail("读取辅助角色数据出错");
			}

			function loadSelectFail():void{
				Debugger.log("读取选人场景数据出错");
				if(fail != null) fail("读取选人场景数据出错");
			}

			function loadMapFail():void{
				Debugger.log("读取地图场景数据出错");
				if(fail != null) fail("读取地图场景数据出错");
			}

			function loadMissionFail():void{
				Debugger.log("读取关卡数据出错");
				if(fail != null) fail("读取关卡数据出错");
			}

			function loadMosouFail():void{
				Debugger.log("读取无双数据出错");
				if(fail != null) fail("读取无双数据出错");
			}

		}

		public function initData():void{
			mosouData.init();
//			GameData.I.loadSaveData();
		}

		public function saveData():void{
			var o:Object = {};
			o.id = SAVE_ID;

			o.config = config.toSaveObj();
			o.mosou = mosouData.toSaveObj();


			GameInterface.instance.saveGame(o);
		}

		public function loadSaveData():void{
			var o:Object = GameInterface.instance.loadGame();
			if(!o || o.id != SAVE_ID) return;

			trace('loadSaveData', JSON.stringify(o));

			if(o.config) config.readSaveObj(o.config);

			if(o.mosou && __MOSOU_DATA_ENABLED){
				mosouData.readSaveObj(o.mosou);
			}
		}

		public function loadSelect(url:String):void{
			AssetManager.I.loadXML(url, function(data:XML):void{
				setSelectData(data);
			}, function():void{
				trace('loadSelect error!');
			});
		}

		public function loadDebugSelect(url:String):void{
			KyoURLoader.load(url, function(v:String):void{
				var data:XML = new XML(v);
				setSelectData(data);
			}, function():void{
				trace('loadSelect error!');
			});
		}

		public function setSelectData(xml:XML):void{
			config.select_config.setByXML(xml);
		}

		// 验证选人
		private function validateSelect():void{
			var missFighters:Array = [];
			var missAssisters:Array = [];

			for each(var s:SelectCharListItemVO in config.select_config.charList.list){
				for each(var f:String in s.getAllFighterIDs()){
					var fighter:FighterVO = FighterModel.I.getFighter(f);
					if(fighter == null){
						if(missFighters.indexOf(f) == -1) missFighters.push(f);
					}
				}
			}

			for each(var s:SelectCharListItemVO in config.select_config.assistList.list){

				for each(var f:String in s.getAllFighterIDs()){
					var fighter:FighterVO = AssisterModel.I.getAssister(f);
					if(fighter == null){
						if(missAssisters.indexOf(f) == -1) missAssisters.push(f);
					}
				}
			}

			if(missFighters.length > 0 || missAssisters.length > 0){
				var msg:String = "";
				if(missFighters.length > 0) msg += "fighter : " + missFighters.join(" , ") + " ; ";
				if(missAssisters.length > 0) msg += "assister : " + missAssisters.join(" , ") + " ; ";
				throw new Error("select.xml验证失败！ [" + msg + "]");
			}
		}

		// 验证关卡
		private function validateMissionData():void{
			var missFighters:Array = [];
			var missMaps:Array = [];
			var missAssisters:Array = [];

			var missions:Array = MessionModel.I.getAllMissions();
			for each(var m:MessionVO in missions){
				var ms:Vector.<MessionStageVO> = m.stageList;
				for each(var s:MessionStageVO in ms){

					for each(var f:String in s.fighters){
						var fighter:FighterVO = FighterModel.I.getFighter(f);
						if(fighter == null){
							if(missFighters.indexOf(f) == -1) missFighters.push(f);
						}
					}

					var map:MapVO = MapModel.I.getMap(s.map);
					if(map == null){
						if(missMaps.indexOf(s.map) == -1) missMaps.push(s.map);
					}

					var assister:FighterVO = AssisterModel.I.getAssister(s.assister);
					if(assister == null){
						if(missAssisters.indexOf(s.assister) == -1) missAssisters.push(s.assister);
					}

				}
			}


			if(missFighters.length > 0 || missAssisters.length > 0 || missMaps.length > 0){
				var msg:String = "";
				if(missFighters.length > 0) msg += "fighter : " + missFighters.join(" , ") + " ; ";
				if(missAssisters.length > 0) msg += "assister : " + missAssisters.join(" , ") + " ; ";
				if(missMaps.length > 0) msg += "map : " + missMaps.join(" , ") + " ; ";
				throw new Error("mission.xml验证失败！ [" + msg + "]");
			}
		}

		// 验证无双关卡
		private function validateMosouData():void{
			var mapObj:Object = MosouModel.I.getAllMap();

			for(var i:String in mapObj){

				var mwv:MosouWorldMapVO = mapObj[i];

				for each(var a:MosouWorldMapAreaVO in mwv.areas){
					for each(var mv:MosouMissionVO in a.missions){

						var mosouId:String = mwv.id + " - " + a.id + " - " + mv.id;


						var map:MapVO = MapModel.I.getMap(mv.map);
						if(map == null){
							throw new Error("mosou[" + mosouId + "]验证失败！未找到map: " + mv.map);
						}

						var ememies:Array = mv.getAllEnemieIds();
						for each(var f:String in ememies){
							var fighter:FighterVO = FighterModel.I.getFighter(f);
							if(fighter == null){
								throw new Error("mosou[" + mosouId + "]验证失败！未找到fighter: " + f);
							}
						}

					}
				}

			}


			var missFighters:Array = [];

			var fighters:Vector.<MosouFighterSellVO> = MosouFighterModel.I.fighters;
			for each(var s:MosouFighterSellVO in fighters){
				var fv:FighterVO = FighterModel.I.getFighter(s.id);
				if(!fv && missFighters.indexOf(s.id) == -1) missFighters.push(s.id);
			}

			if(missFighters.length > 0){
				var msg:String = "";
				if(missFighters.length > 0) msg += "fighter : " + missFighters.join(" , ") + " ; ";
				throw new Error("FighterModel 验证失败！ [" + msg + "]");
			}

		}

	}
}
