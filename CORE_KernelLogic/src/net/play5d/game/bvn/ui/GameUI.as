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

package net.play5d.game.bvn.ui
{
	import flash.display.DisplayObject;
	import flash.events.DataEvent;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.GameMode;
	import net.play5d.game.bvn.data.GameRunFighterGroup;
	import net.play5d.game.bvn.events.GameEvent;
	import net.play5d.game.bvn.ui.dialog.AlertUI;
import net.play5d.game.bvn.ui.dialog.BaseDialog;
	import net.play5d.game.bvn.ui.dialog.ConfrimUI;
	import net.play5d.game.bvn.ui.dialog.DialogManager;
import net.play5d.game.bvn.ui.dialog.MusouConfrimUI;
import net.play5d.game.bvn.ui.fight.FightUI;
	import net.play5d.game.bvn.ui.mosou.MosouUI;

	public class GameUI
	{
		include "_INCLUDE_.as";

		public static var I:GameUI;

		/**
		 * 将UI转换成BITMAP
		 */
		public static var BITMAP_UI:Boolean = true;
		public static var SHOW_CN_TEXT:Boolean = true;

		public static var SHOW_HP_TEXT:Boolean = false;

		private var _ui:IGameUI;

		private static var _confrimUI:BaseDialog;
		private static var _confrimUICls:Class;
		private static var _alertUI:AlertUI;

		private var _renderAnimateGap:int;
		private var _renderAnimateFrame:int = 0;

		public function GameUI()
		{
			I = this;

			SHOW_HP_TEXT = GameMode.currentMode == GameMode.TRAINING && GameConfig.ALLOW_SHOW_HP_TEXT;

			_renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / GameConfig.FPS_ANIMATE) - 1;
		}

		public function getUI():IGameUI{
			return _ui;
		}

		public function getUIDisplay():DisplayObject{
			return _ui.getUI();
		}

		public function initFight(p1:GameRunFighterGroup , p2:GameRunFighterGroup):void{
			var volume:Number = GameData.I.config.soundVolume;

			if(_ui){
				if(_ui is FightUI == false){
					_ui.destory();
					_ui = new FightUI();
					_ui.setVolume(volume);
				}
			}else{
				_ui = new FightUI();
				_ui.setVolume(volume);
			}

			(_ui as FightUI).initlize(p1,p2);
		}

		public function initMission(p1:GameRunFighterGroup):void{
			var volume:Number = GameData.I.config.soundVolume;

			if(_ui){
				if(_ui is FightUI == false){
					_ui.destory();
					_ui = new FightUI();
					_ui.setVolume(volume);
				}
			}else{
				_ui = new MosouUI();
				_ui.setVolume(volume);
			}

			(_ui as MosouUI).initlize(p1);
		}

		public function render():void{
			if(!_ui) return;
			_ui.render();
			if(isRenderAnimate()) renderAnimate();
		}

		private function renderAnimate():void{
			if(_ui) _ui.renderAnimate();
		}

		private function isRenderAnimate():Boolean{
			if(_renderAnimateGap > 0){
				if(_renderAnimateFrame++ >= _renderAnimateGap){
					_renderAnimateFrame = 0;
					return true;
				}else{
					return false;
				}
			}
			return true;
		}

		public function fadIn():void{
			if(_ui){
				var volume:Number = GameData.I.config.soundVolume;
				_ui.fadIn();
				_ui.setVolume(volume);
			}
		}

		public function fadOut():void{
			if(_ui){
				_ui.fadIn();
			}
		}

		public function destory():void{
			if(_ui){
				_ui.destory();
			}
		}

		public static function showingDialog():Boolean{
			return _confrimUI != null || _alertUI != null;
		}

		public static function showingConfrim():Boolean{
			return _confrimUI != null;
		}

		public static function showingAlert():Boolean{
			return _alertUI != null;
		}

		public static function confrim(enMsg:String = null , cnMsg:String = null , yes:Function = null , no:Function = null, isMusou:Boolean = false):void{
			closeConfrim();

			_confrimUICls = isMusou ? MusouConfrimUI : ConfrimUI;

			_confrimUI = new _confrimUICls();
			_confrimUI.setMsg(enMsg,cnMsg);
			_confrimUI.yesBack = yesClose;
			_confrimUI.noBack = noClose;

			GameEvent.dispatchEvent(GameEvent.UI_CONFRIM);

			DialogManager.showDialog(_confrimUI, false);

			function yesClose():void{
				if(yes != null) yes();
				closeConfrim();
//				GameEvent.dispatchEvent(GameEvent.UI_CONFRIM_CLOSE);
			}
			function noClose():void{
				if(no != null) no();
				closeConfrim();
				GameEvent.dispatchEvent(GameEvent.UI_CONFRIM_CLOSE);
			}

		}

		public static function alert(enMsg:String = null , cnMsg:String = null , close:Function = null):void{
			closeAlert();
			_alertUI = new AlertUI();
			_alertUI.setMsg(enMsg,cnMsg);
			_alertUI.yesBack = closeBack;

			DialogManager.showDialog(_alertUI, false);

			GameEvent.dispatchEvent(GameEvent.UI_ALERT, {enMsg: enMsg, cnMsg: cnMsg});

			function closeBack():void{
				if(close != null) close();
				closeAlert();
				GameEvent.dispatchEvent(GameEvent.UI_ALERT_CLOSE);
			}
		}

		public static function closeAlert():void{
			if(_alertUI){
				DialogManager.closeDialog(_alertUI);
				_alertUI = null;
			}
		}

		public static function closeConfrim():void{
			if(_confrimUI){
				DialogManager.closeDialog(_confrimUI);
				_confrimUI = null;
			}
		}

		public static function cancelConfrim():void{
			if(_confrimUI){
				if(_confrimUI.noBack != null){
					_confrimUI.noBack();
				}else{
					closeConfrim();
				}
			}
		}

//		public function showHits(hits:int , id:int):void{
//			_ui.showHits(hits,id);
//		}
//
//		public function hideHits(id:int):void{
//			_ui.hideHits(id);
//		}

//		public function showBishaFace(faceid:int , face:DisplayObject):void{
//			if(!_bishaFace){
//				_bishaFace = new BishaFaceUI();
//				(_ui as FightUI).ui.addChild(_bishaFace.ui);
//			}
//
//			_bishaFace.setFace(faceid , face);
//			_bishaFace.fadIn();
//		}
//
//		public function removeBishaFace():void{
//			if(_bishaFace){
//				_bishaFace.fadOut(function():void{
//					try{
//						(_ui as FightUI).ui.removeChild(_bishaFace.ui);
//					}catch(e:*){}
//					_bishaFace.destory();
//					_bishaFace = null;
//				});
//			}
//		}

	}
}
