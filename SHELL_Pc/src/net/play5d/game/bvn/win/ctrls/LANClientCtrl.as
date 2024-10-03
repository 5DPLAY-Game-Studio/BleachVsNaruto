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
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	import net.play5d.game.bvn.events.GameEvent;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.interfaces.GameInterface;
	import net.play5d.game.bvn.state.GameState;
	import net.play5d.game.bvn.state.LoadingState;
	import net.play5d.game.bvn.state.SelectFighterStage;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.game.bvn.win.data.HostVO;
	import net.play5d.game.bvn.win.data.LanGameModel;
	import net.play5d.game.bvn.win.input.InputManager;
	import net.play5d.game.bvn.win.sockets.SocketClient;
	import net.play5d.game.bvn.win.sockets.events.SocketEvent;
	import net.play5d.game.bvn.win.sockets.udp.UDPDataVO;
	import net.play5d.game.bvn.win.sockets.udp.UDPSocket;
	import net.play5d.game.bvn.win.utils.JsonUtils;
	import net.play5d.game.bvn.win.utils.LANUtils;
	import net.play5d.game.bvn.win.utils.LanSyncType;
	import net.play5d.game.bvn.win.utils.LockFrameLogic;
	import net.play5d.game.bvn.win.utils.MsgType;
	import net.play5d.game.bvn.win.utils.SocketMsgFactory;
	import net.play5d.game.bvn.win.views.lan.LANGameState;
	import net.play5d.game.bvn.win.views.lan.LANRoomState;
	import net.play5d.kyo.utils.KyoTimeout;
	//import net.play5d.kyo.utils.setFrameOut;

	public class LANClientCtrl
	{
		private static var _i:LANClientCtrl;

		public static function get I():LANClientCtrl{
			_i ||= new LANClientCtrl();
			return _i;
		}

		public var active:Boolean;

		private var _delayText:TextField;

		private var _socket:SocketClient;
		private var _udpSocket:UDPSocket;
		private var _room:LANRoomState;

		private var _joinBack:Function;

		private var _syncErrorTimes:int;

		private var _selectLogic:SelectFighterClientLogic;
//		private var _connGameLogic:OptimisticClientLogic;
		private var _connGameLogic:LockFrameClientLogic;

		private var _delayCache:Array = [];

		private var _syncRoundFinishInt:int;
		private var _syncGameFinishInt:int;
		private var _syncGameStartInt:int;

		private var _host:HostVO;

		private var _onFindHostBack:Function;
		private var _findHostTimer:Timer;

		public function LANClientCtrl()
		{
		}

		public function initlize():void{
			if(!_udpSocket){
				_udpSocket = new UDPSocket();
				_udpSocket.listen(LANGameCtrl.PORT_UDP_CLIENT);
				_udpSocket.addDataHandler(udpDataHandler);
			}
		}

		public function findHost(back:Function):void{
			_onFindHostBack = back;

			if(!_findHostTimer){
				_findHostTimer = new Timer(5000);
				_findHostTimer.addEventListener(TimerEvent.TIMER , findHostTimerHandler);
			}

			_findHostTimer.reset();
			_findHostTimer.start();

			findHostTimerHandler(null);
		}

		public function cancelFindHost():void{
			_onFindHostBack = null;
			if(_findHostTimer){
				_findHostTimer.stop();
				_findHostTimer.removeEventListener(TimerEvent.TIMER , findHostTimerHandler);
				_findHostTimer = null;
			}
		}

		private function findHostTimerHandler(e:TimerEvent):void{
			_udpSocket.sendBroadcast(LANGameCtrl.PORT_UDP_SERVER, SocketMsgFactory.createFindHostMsg());
		}

		private function receiveHostHandler(data:UDPDataVO):Boolean{
			if(!_findHostTimer) return false;
			var dataObj:Object = data.getDataObject();
			if(dataObj && dataObj.type != MsgType.FIND_HOST_BACK) return false;

			if(_onFindHostBack != null){
				var hv:HostVO = new HostVO();
				hv.readJson(dataObj.host);
				hv.ip = data.fromIP;
				hv.tcpPort = LANGameCtrl.PORT_TCP;
				hv.udpPort = LANGameCtrl.PORT_UDP_SERVER;
				_onFindHostBack(hv);
			}
			return true;
		}

		public function setRoom(v:LANRoomState):void{
			_room = v;
			sendJoinIn();
		}

		/**
		 * 更新延迟（毫秒）
		 */
		public function updateDelay(v:int):void{
			if(!_delayText) return;

			_delayCache.push(v);

			if(_delayCache.length >= 10){

				var count:int = 0;
				for each(var i:int in _delayCache){
					count += i;
				}
				var delay:int = count / _delayCache.length;

				_delayCache = [];

				var color:uint = 0xff0000;
				if(delay < 200){
					color = 0x00FF00;
				}else if(delay < 500){
					color = 0xFFFF00;
				}

				delay -= 100;
				if(delay < 0) delay = 0;

				_delayText.text = delay + " ms";

				_delayText.textColor = color;

			}

		}

		public function join(host:HostVO , back:Function):void{
			_host = host;
			_joinBack = back;
			initTcp(host);
		}

		private function initTcp(host:HostVO):void{
			if(_socket) disposeTcp();
			_socket = new SocketClient();
			_socket.addEventListener(SocketEvent.CLIENT_CONNECT,socketHandler);
			_socket.addEventListener(SocketEvent.CLOSE,socketHandler);
			_socket.addEventListener(SocketEvent.RECEIVE_DATA,socketHandler);
			_socket.connect(host.ip,host.tcpPort);
		}

		private function udpDataHandler(data:UDPDataVO):void{
			if(receiveHostHandler(data)) return;
			if(_connGameLogic){
				if(_connGameLogic.receiveSyncUpdate(data.getDataByteArray())) return;
				if(_connGameLogic.receiveUpdate(data.getDataByteArray())) return;
			}
		}

		public function sendJoinIn():void{
			_socket.sendJSON(SocketMsgFactory.createJoinInMsg());
		}

		public function dispose():void{
			disposeTcp();
			disposeUdp();
			GameEvent.removeEventListener(GameEvent.GAME_START, onRoundStart);
		}

		private function disposeTcp():void{
			if(_socket){
				_socket.removeEventListener(SocketEvent.CLIENT_CONNECT,socketHandler);
				_socket.removeEventListener(SocketEvent.CLOSE,socketHandler);
				_socket.removeEventListener(SocketEvent.RECEIVE_DATA,socketHandler);
				_socket.close();
				_socket = null;
			}
		}

		private function disposeUdp():void{
			if(_udpSocket){
				_udpSocket.unListen();
				_udpSocket.removeDataHandler(udpDataHandler);
				_udpSocket = null;
			}
		}

		private function socketHandler(e:SocketEvent):void{
			switch(e.type){
				case SocketEvent.CLIENT_CONNECT:
					_socket.sendJSON(SocketMsgFactory.createJoinMsg());
					break;
				case SocketEvent.CLOSE:
					if(active){
						gameEnd();
						GameUI.alert("DISCONNECT","与主机断开连接");
					}else{
						if(_room) _room.exitRoom("连接中断");
						dispose();
					}
					break;
				case SocketEvent.RECEIVE_DATA:
					onReceiveData(e);
					break;
			}
		}

		private function onReceiveData(e:SocketEvent):void{
//			if(_connGameLogic && _connGameLogic.receiveUpdate(e.data)) return;

			var obj:Object = e.getDataObject();

			if(!obj) return;

			if(_selectLogic && _selectLogic.receiveSelect(obj)) return;

			if(receiveSync(obj)) return;

			var json:Object = JsonUtils.str2json(obj);
			if(json) receiveJson(json);

		}

		private function receiveJson(o:Object):void{
			switch(o.type){
				case MsgType.JOIN_BACK:
					var succ:Boolean = o.success;
					if(_joinBack != null){
						_joinBack(succ, o.msg);
						_joinBack = null;
					}
					break;
				case MsgType.CHART:
					if(_room) _room.pushChart(o.msg , o.name);
					break;
				case MsgType.START_GAME:
					if(_room){
						_room.startGameTimer();
						_room.lockStart();
					}
					break;
				case MsgType.KICK_OUT:
					if(_room) _room.exitRoom(o.msg);
					break;
			}
		}

		public function sendChart(chart:String):void{
			_socket.sendJSON(SocketMsgFactory.createChart(chart,LanGameModel.I.playerName));
		}

		public function sendTCP(o:Object):void{
			if(_socket) _socket.send(o);
		}

		public function sendUDP(o:Object):void{
			if(_udpSocket) _udpSocket.send(_host.ip, _host.udpPort ,o);
		}

		public function gameStart():void{

			active = true;

			_room = null;

			_delayText = new TextField();
			_delayText.text = "0ms";
			var tf:TextFormat = new TextFormat();
			tf.color = 0xffffff;
			tf.size = 16;
			_delayText.defaultTextFormat = tf;
			MainGame.I.stage.addChild(_delayText);

			_selectLogic = new SelectFighterClientLogic();
			_selectLogic.init();

//			_connGameLogic = new OptimisticClientLogic();
			_connGameLogic = new LockFrameClientLogic();

			GameCtrl.I.autoEndRoundAble = false;
			GameCtrl.I.autoStartAble = false;
			SelectFighterStage.AUTO_FINISH = false;
			LoadingState.AUTO_START_GAME = false;

			GameInterface.instance.updateInputConfig();

			LockFrameLogic.I.initClient();

			LanGameMenuCtrl.I.init();

			LANUtils.updateParams();

			GameEvent.addEventListener(GameEvent.ROUND_START , onRoundStart);
		}

		private function onRoundStart(e:GameEvent):void{
			_connGameLogic.enabled = true;
		}

		public function gameEnd():void{
			active = false;
			if(_selectLogic){
				_selectLogic.dispose();
				_selectLogic = null;
			}
			if(_connGameLogic){
				_connGameLogic.dispose();
				_connGameLogic = null;
			}

			if(_delayText){
				try{
					_delayText.parent.removeChild(_delayText);
				}catch(e:Error){
					trace(e);
				}
				_delayText = null;
			}

			GameCtrl.I.autoEndRoundAble = true;
			GameCtrl.I.autoStartAble = true;
			SelectFighterStage.AUTO_FINISH = true;
			LoadingState.AUTO_START_GAME = true;

			GameInterface.instance.updateInputConfig();

			LockFrameLogic.I.dispose();

			dispose();

			MainGame.stageCtrl.goStage(new LANGameState());

			LanGameMenuCtrl.I.dispose();
		}

		public function renderGame():Boolean{

			if(MainGame.stageCtrl.currentStage is GameState){
				return _connGameLogic.render();
			}

			InputManager.I.socket_input_p2.freeRender();

			return true;

		}


		private function receiveSync(o:Object):Boolean{

			if(o is Array){
				var arr:Array = o as Array;
				if(arr[0] == "SYNC"){

					var type:int = arr[1];

					switch(type){
						case LanSyncType.GAME_START:
							syncStartGame();
							break;
						case LanSyncType.ROUND_FINISH:
							_connGameLogic.enabled = false;
							_connGameLogic.reset();
//							syncRoundFinish(arr);
//							clearTimeout(_syncRoundFinishInt);
//							_syncRoundFinishInt = setTimeout(syncRoundFinish , 30 , arr);

							KyoTimeout.setFrameout(function():void{
								syncRoundFinish(arr);
							},1,MainGame.I.stage);
							break;
						case LanSyncType.GAME_FINISH:
							syncGameFinish();
							break;

					}

					return true;
				}
			}
			return false;
		}

		private function syncStartGame():void{
			try{
				GameCtrl.I.doStartGame();
				_syncErrorTimes = 0;
				_connGameLogic.enabled = true;
				_connGameLogic.reset();
			}catch(e:Error){
				trace("LanSyncType.GAME_START",e);
				syncError(true);
				clearTimeout(_syncGameStartInt);
				_syncGameStartInt = setTimeout(syncStartGame , 500);
			}
		}

		private function syncRoundFinish(arr:Array):void{
			//SYNC,type,round,timerover,drawgame,p1hp,p2hp

			var round:int = arr[2];
			var isTimeOver:Boolean = arr[3];
			var isDrawGame:Boolean = arr[4];
			var p1hp:int = arr[5];
			var p2hp:int = arr[6];

			try{

				if(GameCtrl.I.gameRunData.round != round){
					syncError(true);
					clearTimeout(_syncRoundFinishInt);
					_syncRoundFinishInt = setTimeout(syncRoundFinish , 500 , arr);
					return;
				}

				if(isTimeOver){
					GameCtrl.I.gameRunData.isTimerOver = true;
					GameCtrl.I.gameRunData.gameTime = 0;
				}

				var p1:FighterMain = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
				var p2:FighterMain = GameCtrl.I.gameRunData.p2FighterGroup.currentFighter;
				p1.hp = p1hp;
				p2.hp = p2hp;

				if(isDrawGame){
					GameCtrl.I.drawGame();
				}else{
					var winner:FighterMain , loser:FighterMain;

					if(p1.hp > p2.hp){
						winner = p1;
						loser = p2;
					}else{
						winner = p2;
						loser = p1;
					}

					if(!isTimeOver) loser.die();

					GameCtrl.I.doGameEnd(winner , loser);
				}

				_syncErrorTimes = 0;
			}catch(e:Error){
				trace(e);
				syncError(true);
				clearTimeout(_syncRoundFinishInt);
				_syncRoundFinishInt = setTimeout(syncRoundFinish , 500 , arr);
			}
		}

		private function syncGameFinish():void{
			_connGameLogic.enabled = false;
			_connGameLogic.reset();

			if(!GameCtrl.I.fightFinished){
				try{
					GameCtrl.I.fightFinish();
				}catch(e:Error){
					syncError(true);
					clearTimeout(_syncGameFinishInt);
					_syncGameFinishInt = setTimeout(syncGameFinish , 500);
				}

			}

		}

		public function resetSyncError():void{
			_syncErrorTimes = 0;
		}

		public function syncError(wait:Boolean = false):void{
			if(!wait){
//				trace("同步异常");
				gameEnd();
				GameUI.alert("DISCONNECT","发生异常");
				return;
			}
			_syncErrorTimes++;
			if(_syncErrorTimes > 10){
//				trace("同步错误，强制退出");
				gameEnd();
				GameUI.alert("DISCONNECT","发生异常");
//				dispose();
			}
		}

	}
}
