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

package net.play5d.game.bvn.win.views.lan
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.data.GameMode;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.game.bvn.win.ctrls.LANClientCtrl;
	import net.play5d.game.bvn.win.ctrls.LANServerCtrl;
	//import net.play5d.game.bvn.win.ctrls.LANUDPCtrler;
	import net.play5d.game.bvn.win.data.HostVO;
	import net.play5d.game.bvn.win.data.LanGameModel;
	import net.play5d.game.bvn.win.utils.LockFrameLogic;
	import net.play5d.game.bvn.win.utils.UIAssetUtil;
	import net.play5d.kyo.stage.IStage;
	import net.play5d.kyo.utils.KyoBtnUtils;
	import net.play5d.kyo.utils.KyoUtils;

	public class LANRoomState implements IStage
	{
		private var _ui:MovieClip;
		private var _txtChart:*;
		private var _host:HostVO;

		private var _isOwner:Boolean;

		private var _playerMap:Object = {};

		private var _startTimer:Timer;

		public function LANRoomState()
		{
		}

		public function get display():DisplayObject
		{
			return _ui;
		}

		public function build():void
		{
			_ui = UIAssetUtil.I.createDisplayObject("room_mc");
			_ui.input_chart.addEventListener("enter" , submitChart);

			KyoBtnUtils.initBtn(_ui.btn_chart,submitChart);
			KyoBtnUtils.initBtn(_ui.btn_start,startGame);
			KyoBtnUtils.initBtn(_ui.btn_exit,exit);

			SoundCtrl.I.BGM(AssetManager.I.getSound('continue'));
		}

		public function setStartAble(v:Boolean):void{
			if(_ui.btn_start && _ui.btn_start.visible){
				(_ui.btn_start as SimpleButton).mouseEnabled = v;
				KyoUtils.grayMC(_ui.btn_start , v);
			}
		}

		public function hostMode():void{
			_isOwner = true;
			_host = LANServerCtrl.I.host;
			LANServerCtrl.I.setRoom(this);
			initUI();
		}

		public function clientMode(host:HostVO):void{
			LANClientCtrl.I.setRoom(this);
			addPlayer("self",LanGameModel.I.playerName);
			_isOwner = false;
			_host = host;
			initUI();
		}

		private function initUI():void{
			_ui.txt_name.text = _host.name;
			_ui.txt_mode.text = _host.getGameModeStr();
			_ui.txt_pass.text = _host.password ? "密码："+_host.password : "";
			_ui.btn_start.visible = _isOwner;
			_ui.txt_start.visible = _isOwner;
			_txtChart = _ui.txt_chart;
			addOwner();
		}


		public function afterBuild():void
		{
		}

		public function destory(back:Function=null):void
		{

			if(_startTimer){
				_startTimer.removeEventListener(TimerEvent.TIMER , startTimerHandler);
				_startTimer.removeEventListener(TimerEvent.TIMER_COMPLETE , startTimerHandler);
				_startTimer.stop();
				_startTimer = null;
			}

			if(_isOwner){
				if(!LANServerCtrl.I.active){
					LANServerCtrl.I.stopServer();
				}
			}else{
				if(!LANClientCtrl.I.active){
					LANClientCtrl.I.dispose();
				}

			}

			try{
				_ui.input_chart.removeEventListener("enter" , submitChart);
				KyoBtnUtils.disposeBtn(_ui.btn_chart);
				KyoBtnUtils.disposeBtn(_ui.btn_start);
				KyoBtnUtils.disposeBtn(_ui.btn_exit);
			}catch(e:Error){}
		}

		private function submitChart(...params):void{
			var chart:String = _ui.input_chart.text;
			if(chart == "") return;

			_ui.input_chart.text = "";

			if(_isOwner){
				LANServerCtrl.I.sendChart(chart , LanGameModel.I.playerName);
			}else{
				LANClientCtrl.I.sendChart(chart);
			}

		}

		private function startGame():void{
			if(_isOwner){
				SoundCtrl.I.sndConfrim();
				LANServerCtrl.I.sendStart();
			}
		}

		public function startGameTimer():void{
			if(_startTimer) return;
			_startTimer = new Timer(1000,5);
			_startTimer.addEventListener(TimerEvent.TIMER , startTimerHandler);
			_startTimer.addEventListener(TimerEvent.TIMER_COMPLETE , startTimerHandler);

			_startTimer.start();
		}

		private function startTimerHandler(e:TimerEvent):void{
			if(e.type == TimerEvent.TIMER){

//				if(_startTimer.currentCount == 2){
//					lockStart();
//				}

				pushChart((_startTimer.repeatCount - _startTimer.currentCount + 1) + "秒后开始游戏" , null);
			}

			if(e.type == TimerEvent.TIMER_COMPLETE){
				if(_isOwner){
					LANServerCtrl.I.gameStart();
				}else{
					LANClientCtrl.I.gameStart();
				}

				switch(_host.gameMode){
					case 1:
						GameMode.currentMode = GameMode.TEAM_VS_PEOPLE;
						break;
					case 2:
						GameMode.currentMode = GameMode.SINGLE_VS_PEOPLE;
						break;
				}
				MainGame.I.goSelect();
			}
		}

		private function exit():void{
			var ls:LANGameState = new LANGameState();
			MainGame.stageCtrl.goStage(ls);

			if(!_isOwner){
				ls.showHostList();
			}

		}

		private function addOwner():void{
			var item:MovieClip = UIAssetUtil.I.createDisplayObject("player_item_mc");
			item.txt.text = _host.ownerName;
			item.type.gotoAndStop(1);
			item.btn_out.visible = false;

			var ct_player:Sprite = _ui.ct_player;
			ct_player.addChild(item);
		}

		public function addPlayer(id:String , name:String):void{

			if(_playerMap[id]){
				trace("player:"+id+"已存在！");
				return;
			}

			var item:LANRoomPlayerItem = new LANRoomPlayerItem(id,name);
			item.enableOut();

			_playerMap[id] = item;

			var ct_player:Sprite = _ui.ct_player;
			item.ui.y = 60;
			ct_player.addChild(item.ui);
		}

		public function removePlayer(id:String):void{
			var item:LANRoomPlayerItem = _playerMap[id];
			if(item){
				try{
					_ui.ct_player.removeChild(item.ui);
				}catch(e:Error){}
				item.destory();
			}

			delete _playerMap[id];
		}

		public function pushChart(str:String , name:String = null):void{
			var chartStr:String = name ? name+" : "+str : str;
			_txtChart.appendText(chartStr+"\n");
		}

//		public function pushMsg(msg:String):void{
//			_txtChart.appendText(msg+"\n");
//		}

		public function exitRoom(msg:String = null):void{
			exit();
			if(msg){
				GameUI.alert("EXIT",msg);
			}
		}

		/**
		 * 开始前的操作锁定
		 */
		public function lockStart():void{
			if(_ui.btn_start && _ui.btn_start.visible){
				(_ui.btn_start as SimpleButton).mouseEnabled = false;
				KyoUtils.grayMC(_ui.btn_start);
			}
			if(_ui.btn_exit && _ui.btn_exit.visible){
				(_ui.btn_exit as SimpleButton).mouseEnabled = false;
				KyoUtils.grayMC(_ui.btn_exit);
			}
		}

	}
}
