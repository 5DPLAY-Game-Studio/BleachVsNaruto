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
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	import net.play5d.game.bvn.data.GameRunDataVO;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.state.GameState;
	import net.play5d.game.bvn.win.input.InputManager;
	import net.play5d.game.bvn.win.utils.LANUtils;
	import net.play5d.kyo.stage.Istage;

	/**
	 * 乐观锁帧算法，服务端
	 */
	public class OptimisticServerLogic
	{
		public var enabled:Boolean = true;

		private var _renderFrame:uint;
		private var _renderNextFrame:uint;
		private var _renderSyncFrame:int;

		private var _clientK:int = -1;
		private var _serverK:int = 0;

		private var _syncUpdateArr:Array;

		private var _sendUpdateFrame:int;


		public function OptimisticServerLogic()
		{
		}

		public function reset():void{
			_renderFrame = 0;
			_renderNextFrame = 0;
			_clientK = -1;
			_serverK = 0;
			_syncUpdateArr = null;
			_sendUpdateFrame = 0;
		}

		public function dispose():void{

		}

		public function render():Boolean{

			if(!enabled) return true;
			if(_clientK == -1) return false; //等待客户端

//			//客户端与服务器相差时间较大，等待客户端
//			if(_renderFrame > _clientRenderFrame + LANUtils.SERVER_WAIT_CLIENT){
//				if(_sendUpdateFrame++ == 0){
//					sendUpdate(true);
//				}
//				if(_sendUpdateFrame > 5) _sendUpdateFrame = 0;
//				return false;
//			}

			InputManager.I.socket_input_p1.renderInput();

			if(_renderFrame % LANUtils.LOCK_KEYFRAME == 0){

				var sync:Boolean = false;

				if(_renderSyncFrame > LANUtils.SYNC_GAP){
					sync = true;
					_renderSyncFrame = 0;
				}

				sendUpdate(sync);
			}

			_renderFrame++;
			_renderSyncFrame++;

			renderUpdate();

			if(_renderSyncFrame > LANUtils.SYNC_GAP){
				_syncUpdateArr = getSyncUpdate();
			}

			return true;
		}

		private function sendStart():void{
			var updateArr:Array = [_serverK , 0];
			LANServerCtrl.I.sendTCP(updateArr);
		}

		public function receiveInput(k:Object):Boolean{

			if(k is Number){
				_clientK = int(k);
				return true;
			}
			return false;
		}

		private function sendUpdate(sync:Boolean):void{
			_renderNextFrame = _renderFrame + LANUtils.LOCK_KEYFRAME;
//			trace("sendCtrlUpdate" , _renderFrame , _renderNextFrame , _serverK , _clientK);

			var syncArr:Array = sync ? _syncUpdateArr : null;

			_serverK = InputManager.I.socket_input_p1.getSocketData();

			InputManager.I.socket_input_p1.resetInput();

//			var updateArr:Array = [_renderFrame , _renderNextFrame , _serverK , _clientK , syncArr];
//			var updateArr:Array = [_renderFrame , _renderNextFrame , _serverK , _clientK];
			var updateArr:Array = [_serverK , _clientK , syncArr];
			LANServerCtrl.I.sendTCP(updateArr);

			if(sync){
				_updateCache = {};
			}

			cacheUpdate();

		}

		private function getSyncUpdate():Array{

			//frame,round,time,p1hp,p1x,p1y,p2hp,p2x,p2y

			var curStg:Istage = MainGame.stageCtrl.currentStage;

			if(curStg is GameState){
				if(GameCtrl.I.actionEnable){
					var runData:GameRunDataVO = GameCtrl.I.gameRunData;
					var p1:FighterMain = runData.p1FighterGroup.currentFighter;
					var p2:FighterMain = runData.p2FighterGroup.currentFighter;
					var data:Array = [_renderFrame , runData.round , runData.gameTime ,
						p1.hp << 0 , p1.qi << 0 , p1.x << 0 , p1.y << 0 ,
						p2.hp << 0 , p2.qi << 0 , p2.x << 0 , p2.y << 0
					];
					return data;
				}
			}

			return null;
		}

		//伪客户端逻辑 ***************************************************************************************

		private var _updateCache:Object = {};

		private function cacheUpdate():void{
			for(var i:int = _renderFrame ; i < _renderNextFrame ; i++){
				_updateCache[i] = [_serverK , _clientK];
			}
		}

		private function renderUpdate():void{
			var cacheKeys:Array = _updateCache[_renderFrame];
			if(cacheKeys){
				InputManager.I.socket_input_p1.setSocketData(cacheKeys[0]);
				InputManager.I.socket_input_p2.setSocketData(cacheKeys[1]);
			}
		}


	}
}
