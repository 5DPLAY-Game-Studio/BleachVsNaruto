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

package net.play5d.game.bvn.stage
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.GameLoader;
	import net.play5d.game.bvn.ctrl.KeyBoardCtrl;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.ctrl.StateCtrl;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	import net.play5d.game.bvn.data.FighterModel;
	import net.play5d.game.bvn.data.FighterVO;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.GameRunDataVO;
	import net.play5d.game.bvn.data.GameRunFighterGroup;
	import net.play5d.game.bvn.data.MapModel;
	import net.play5d.game.bvn.data.MapVO;
	import net.play5d.game.bvn.data.SelectVO;
	import net.play5d.game.bvn.debug.Debugger;
	import net.play5d.game.bvn.fighter.Assister;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.input.GameInputer;
	import net.play5d.game.bvn.map.MapMain;
	import net.play5d.kyo.stage.IStage;

	public class TestLoadingStage implements IStage
	{
		private var _ui:Sprite = new Sprite();
		private var _loadQueue:Array;

		private var _loadFin:Boolean;
		private var _loadedFighterCache:Object;

		public function TestLoadingStage()
		{
		}

		/**
		 * 显示对象
		 */
		public function get display():DisplayObject
		{
			return _ui;
		}

		/**
		 * 构建
		 */
		public function build():void
		{
			var p1selt:SelectVO = GameData.I.p1Select;
			var p2selt:SelectVO = GameData.I.p2Select;

			_loadQueue = [];

			var rd:GameRunDataVO = GameCtrl.I.gameRunData;

			var fighters:Array = [
				{id:p1selt.fighter1 , runobj:{id:'p1',group:rd.p1FighterGroup,key:'fighter1'}},
				{id:p1selt.fighter2 , runobj:{id:'p1',group:rd.p1FighterGroup,key:'fighter2'}},
				{id:p1selt.fighter3 , runobj:{id:'p1',group:rd.p1FighterGroup,key:'fighter3'}},

				{id:p2selt.fighter1 , runobj:{id:'p2',group:rd.p2FighterGroup,key:'fighter1'}},
				{id:p2selt.fighter2 , runobj:{id:'p2',group:rd.p2FighterGroup,key:'fighter2'}},
				{id:p2selt.fighter3 , runobj:{id:'p2',group:rd.p2FighterGroup,key:'fighter3'}}
			];

			var assisters:Array = [
				{id:p1selt.fuzhu , runobj:{group:'p1FighterGroup',id:'fuzhu'}},
				{id:p2selt.fuzhu , runobj:{group:'p2FighterGroup',id:'fuzhu'}}
			];

			var fighter:FighterVO;
			var fighterName:String;
			var o:Object;

			var fightBGMs:Array = [];

			for(var i:int ; i < fighters.length ; i++){
				o = fighters[i];
				if(!o.id) continue;

				fighterName = o.id;

				fighter = FighterModel.I.getFighter(o.id);
				if(fighter){
					if(fighter.bgm) fightBGMs.push({id:fighter.id , url:fighter.bgm , rate:fighter.bgmRate});
					fighterName = fighter.name;
				}

				_loadQueue.push(
					{
						msg:"正在加载角色："+fighterName,
						func:GameLoader.loadFighter,
						params:[o.id , function(fighter:FighterMain , runobj:Object):void{
							var group:GameRunFighterGroup = runobj.group;
							group[runobj.key] = fighter.data;
							loadNext();
						} , loadFail , null , o.runobj]
					}
				);
			}

			for(i = 0 ; i < assisters.length ; i++){
				o = assisters[i];
				if(!o.id) continue;

				fighter = FighterModel.I.getFighter(o.id);
				fighterName = fighter ? fighter.name : o.id;

				_loadQueue.push(
					{
						msg:"正在加载辅助角色："+fighterName,
						func:GameLoader.loadAssister,
						params:[o.id , function(fighter:Assister , runobj:Object):void{
							GameCtrl.I.gameRunData[runobj.group][runobj.id] = fighter;
							loadNext();
						} , loadFail , null , o.runobj]
					}
				);
			}

			var map:MapVO = MapModel.I.getMap(GameData.I.selectMap);
			var mapName:String = map ? map.name : GameData.I.selectMap;

			_loadQueue.push({
				msg:"正在加载场景："+mapName,
				func:GameLoader.loadMap,
				params:[GameData.I.selectMap , function(map:MapMain):void{
					if(map.data && map.data.bgm) fightBGMs.push({id:'map' , url:map.data.bgm , rate:1});
					GameCtrl.I.gameRunData.map = map.data;
					loadNext();
				} , loadFail]
			});

			if(fightBGMs.length > 0){
				_loadQueue.push(
					{
						msg:"正在加载BGM",
						func:SoundCtrl.I.loadFightBGM,
						params:[fightBGMs , loadNext , loadFail ]
					}
				);
			}

			loadNext();

		}

		private var _currentLoadBack:Function;
		private function loadNext():void{
			if(_loadQueue.length < 1){
				loadFin();
				return;
			}
			var o:Object = _loadQueue.shift();
			_currentLoadBack = o.back;

			o.func.apply(null , o.params);

			//debug
//			setTimeout(function():void{
//				o.func.apply(null , o.params);
//			},1000);

		}

		private function loadFighterComplete(fighter:FighterMain):void{
			if(_currentLoadBack){
				_currentLoadBack(fighter);
				_currentLoadBack = null;
			}
			loadNext();
		}

		private function loadFin():void{
//			trace('loadFin');
			finish();
		}

		private var _gameFinished:Boolean;

		private function finish():void{

			if(_gameFinished) return;

			_gameFinished = true;

			var p1group:GameRunFighterGroup = GameCtrl.I.gameRunData.p1FighterGroup;
			var p2group:GameRunFighterGroup = GameCtrl.I.gameRunData.p2FighterGroup;

			p1group.fighter1 = FighterModel.I.getFighter(GameData.I.p1Select.fighter1, true);
			p2group.fighter1 = FighterModel.I.getFighter(GameData.I.p2Select.fighter1, true);
//			p1group.currentFighter = p1group.fighter1;
//			p2group.currentFighter = p2group.fighter1;

			//debug
//			p1group.currentFighter.initlize();
//			MainGame.I.goContinue();
//			return;

//			StateCtrl.I.transIn(MainGame.I.goGame , false);

			MainGame.I.goGame();

//			MainGame.I.goGame();
		}

		private function loadFail(msg:String):void{
			Debugger.errorMsg(msg);
//			loadNext();
		}

		/**
		 * 稍后构建
		 */
		public function afterBuild():void
		{
		}

		/**
		 * 销毁
		 * @param back 回调函数
		 */
		public function destroy(back:Function =null):void
		{
			SoundCtrl.I.BGM(null);
			GameInputer.clearInput();
		}
	}
}
