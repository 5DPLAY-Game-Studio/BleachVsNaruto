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

package net.play5d.game.bvn.win.ctrls
{
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.events.GameEvent;
	import net.play5d.game.bvn.stage.LoadingStage;
	import net.play5d.game.bvn.stage.SelectFighterStage;
	import net.play5d.game.bvn.win.utils.SelectFighterDataType;

	public class SelectFighterServerLogic
	{

		private var _timeout:int;

		public function SelectFighterServerLogic()
		{
		}

		public function init():void{

			SelectFighterStage.AUTO_FINISH = false;
			LoadingStage.AUTO_START_GAME   = false;

			GameEvent.addEventListener(GameEvent.SELECT_FIGHTER_STEP , onSelectStep);
			GameEvent.addEventListener(GameEvent.SELECT_FIGHTER_FINISH , onSelectFinish);
			GameEvent.addEventListener(GameEvent.SELECT_FIGHTER_INDEX , onSelectFighterIndex);
		}

		public function dispose():void{
			GameEvent.removeEventListener(GameEvent.SELECT_FIGHTER_STEP , onSelectStep);
			GameEvent.removeEventListener(GameEvent.SELECT_FIGHTER_FINISH , onSelectFinish);
			GameEvent.removeEventListener(GameEvent.SELECT_FIGHTER_INDEX , onSelectFighterIndex);
		}

		public function receiveSelect(data:Object):Boolean{
			var arr:Array = data as Array;
			if(!arr || arr[0] != SelectFighterDataType.KEY) return false;

			var type:int = data[1];

			switch(type){
				case SelectFighterDataType.SELECT:
					try{
						var stg:SelectFighterStage = MainGame.stageCtrl.currentStage as SelectFighterStage;
						stg.setSelect(2,arr[2]);
						checkSelectFinish();
					}catch(e:Error){}
					break;
				case SelectFighterDataType.INDEX:
					try{
						var stg2:LoadingStage = MainGame.stageCtrl.currentStage as LoadingStage;
						stg2.setOrder(2 , data[2]);
						checkSelectIndexFinish();
					}catch(e:Error){}
					break;
			}

			return true;
		}

		private function onSelectStep(e:GameEvent):void{
			var data:Array = [SelectFighterDataType.KEY , SelectFighterDataType.SELECT , e.param];
			LANServerCtrl.I.sendTCP(data);
			checkSelectFinish();
		}

		private function checkSelectFinish():void{
//			try{
				var stg:SelectFighterStage = MainGame.stageCtrl.currentStage as SelectFighterStage;
				if(stg.p1SelectFinish && stg.p2SelectFinish){
					clearTimeout(_timeout);
					_timeout = setTimeout(function():void{
						LANServerCtrl.I.sendTCP([SelectFighterDataType.KEY , SelectFighterDataType.NEXT_STEP]);
						stg.nextStep();
					} , 1000);
				}
//			}catch(e:Error){}
		}

		private function onSelectFinish(e:GameEvent):void{
			var data:Array = [SelectFighterDataType.KEY , SelectFighterDataType.FIGHTER_FINISH ,
				GameData.I.p1Select.fighter1 , GameData.I.p1Select.fighter2 , GameData.I.p1Select.fighter3 , GameData.I.p1Select.fuzhu ,
				GameData.I.p2Select.fighter1 , GameData.I.p2Select.fighter2 , GameData.I.p2Select.fighter3 , GameData.I.p2Select.fuzhu ,
				GameData.I.selectMap
			];
			LANServerCtrl.I.sendTCP(data);

//			try{
				var stg:SelectFighterStage = MainGame.stageCtrl.currentStage as SelectFighterStage;
				stg.goLoadGame();
//			}catch(e:Error){}

		}

		private function onSelectFighterIndex(e:GameEvent):void{
			var data:Array = [SelectFighterDataType.KEY , SelectFighterDataType.INDEX , e.param];
			LANServerCtrl.I.sendTCP(data);

			checkSelectIndexFinish();
		}

		private function checkSelectIndexFinish():void{
			try{
				var stg:LoadingStage = MainGame.stageCtrl.currentStage as LoadingStage;
				if(stg.selectFinish()){
					setTimeout(function():void{

						var orders:Array = stg.getSort();

						LANServerCtrl.I.sendTCP([SelectFighterDataType.KEY , SelectFighterDataType.INDEX_FINISH , orders[0],orders[1] ]);
						stg.gotoGame(orders[0] , orders[1]);
					} , 1000);
				}
			}catch(e:Error){}
		}


	}
}
