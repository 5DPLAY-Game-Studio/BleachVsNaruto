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

package net.play5d.game.bvn.data.mosou
{
	public class MosouMissionVO
	{

		public var id:String;

		/**
		 * 名称
		 */
		public var name:String;

		/**
		 * 地图 (mapID)
		 */
		public var map:String;

		/**
		 * 关卡时间（秒）
		 */
		public var time:int;

		/**
		 * 敌人等级
		 */
		public var enemyLevel:int;

		/**
		 * 波次
		 */
		public var waves:Vector.<MosouWaveVO>;

		public var area:MosouWorldMapAreaVO;

		public function MosouMissionVO()
		{
		}

//		public function initByXML(xml:XML):void{
//
//			map = xml.@map;
//			time = int(xml.@time);
//			if(time < 1){
//				throw new Error("init mousou stage error!");
//			}
//			waves = new Vector.<MosouWaveVO>();
//
//			for each(var i:XML in xml.wave){
//				var wave:MosouWaveVO = MosouWaveVO.createByXML(i);
//				addWave(wave);
//			}
//		}

		public function initByJsonObject(o:Object):void{
			id = o.id;
			map = o.map;
			time = int(o.time);
			enemyLevel = int(o.enemyLevel);

			if(enemyLevel < 1) enemyLevel = 1;

			if(!map || time < 1){
				throw new Error("init mousou stage error!");
			}

			var wvs:Array = o.waves;

			waves = new Vector.<MosouWaveVO>();

			for(var i:int; i < wvs.length; i++){
				var wave:MosouWaveVO = MosouWaveVO.createByJSON(wvs[i]);
				addWave(wave);
			}
		}

		public function getAllEnemies():Vector.<MosouEnemyVO>{
			var result:Vector.<MosouEnemyVO> = new Vector.<MosouEnemyVO>();
			for(var i:int; i < waves.length; i++){
				var w:MosouWaveVO = waves[i];
				var enemies:Vector.<MosouEnemyVO> = w.getAllEnemies();
				if(enemies){
					result = result.concat(enemies);
				}
			}
			return result;
		}

		public function getAllEnemieIds():Array{
			var result:Array = [];
			for(var i:int; i < waves.length; i++){
				var w:MosouWaveVO = waves[i];
				var enemieIds:Array = w.getAllEnemieIds();
				if(enemieIds){
					for each(var e:String in enemieIds){
						if(result.indexOf(e) == -1) result.push(e);
					}
				}
			}
			return result;
		}

		public function getBossIds():Array{
			var bosses:Vector.<MosouEnemyVO> = getBosses();
			var result:Array = [];
			for each(var i:MosouEnemyVO in bosses){
				if(result.indexOf(i.fighterID) == -1) result.push(i.fighterID);
			}
			return result;
		}

		public function getBosses():Vector.<MosouEnemyVO>{
			var result:Vector.<MosouEnemyVO> = new Vector.<MosouEnemyVO>();
			for(var i:int; i < waves.length; i++){
				var w:MosouWaveVO = waves[i];
				var bosses:Vector.<MosouEnemyVO> = w.getBosses();
				if(bosses){
					for each(var e:MosouEnemyVO in bosses){
						if(result.indexOf(e) == -1) result.push(e);
					}
				}
			}
			return result;
		}

		public function addWave(wave:MosouWaveVO):void{
			waves ||= new Vector.<MosouWaveVO>();
			wave.id = waves.length + 1;
			waves.push(wave);
		}

		public function bossCount():int{
			var count:int;
			for(var i:int; i < waves.length; i++){
				var w:MosouWaveVO = waves[i];
				count += w.bossCount();
			}
			return count;
		}

	}
}
