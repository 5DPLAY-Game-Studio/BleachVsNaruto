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
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.ctrl.EffectCtrl;
	import net.play5d.game.bvn.ctrl.GameLogic;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	import net.play5d.game.bvn.data.FighterVO;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.GameMode;
	import net.play5d.game.bvn.data.GameRunFighterGroup;
	import net.play5d.game.bvn.debug.Debugger;
	import net.play5d.game.bvn.events.GameEvent;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.interfaces.IGameSprite;
	import net.play5d.game.bvn.map.MapMain;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.kyo.stage.IStage;

	public class GameStage extends Sprite implements IStage
	{
		private var _gameLayer:Sprite = new Sprite(); //主游戏层
		private var _playerLayer:Sprite = new Sprite(); //游戏角色层

		private var _gameSprites:Vector.<IGameSprite> = new Vector.<IGameSprite>(); //游戏元件列表
		private var _map:MapMain; //游戏地图

		public var camera:GameCamera;

		private var _cameraFocus:Array;

		public var gameUI:GameUI;

		public function get gameLayer():Sprite{
			return _gameLayer;
		}

		public function getMap():MapMain{
			return _map;
		}

		public function setVisibleByClass(cls:Class, visible):void{
			for each(var d:IGameSprite in _gameSprites){
				var className:String = getQualifiedClassName(d);
				var ds:Class = getDefinitionByName(className) as Class;
				if(ds == cls) d.getDisplay().visible = visible;
			}
		}

		public function getFighterByData(data:FighterVO):FighterMain{
			for each(var d:IGameSprite in _gameSprites){
				if(d is FighterMain && (d as FighterMain).data == data) return d as FighterMain;
			}
			return null;
		}

//		private var _renderAnimateGap:int = 0; //刷新动画间隔
//		private var _renderAnimateFrame:int = 0;

		public function GameStage()
		{
			super();
//			this.scrollRect = new Rectangle(0,0,GameConfig.GAME_SIZE.x , GameConfig.GAME_SIZE.y);

			_gameLayer.mouseChildren = _gameLayer.mouseEnabled = false;
		}

		public function get display():DisplayObject
		{
			return this;
		}

		public function getGameSpriteGlobalPosition(sp:IGameSprite , offsetX:Number = 0 , offsetY:Number = 0):Point{
			var zoom:Number = camera.getZoom(true);
			var rect:Rectangle = camera.getScreenRect(true);
			return new Point(
				(-rect.x + sp.x+offsetX) * zoom,
				(-rect.y + sp.y+offsetY) * zoom
			);

		}

		public function getGameSprites():Vector.<IGameSprite>{
			return _gameSprites;
		}

		public function addGameSprite(sp:IGameSprite):void{
			sp.setActive(true);
			if(_gameSprites.indexOf(sp) != -1) return;
			_gameSprites.push(sp);
			_playerLayer.addChild(sp.getDisplay());
			sp.setVolume(GameData.I.config.soundVolume);
		}

		public function addGameSpriteAt(sp:IGameSprite, index:int):void{
			sp.setActive(true);
			if(_gameSprites.indexOf(sp) != -1) return;
			_gameSprites.push(sp);
			_playerLayer.addChildAt(sp.getDisplay(), index);
			sp.setVolume(GameData.I.config.soundVolume);
		}

		public function removeGameSprite(sp:IGameSprite, isDispose:Boolean = false):void{
			if(isDispose){
				sp.destory(true);
			}else{
				sp.setActive(false);
			}

			var index:int = _gameSprites.indexOf(sp);
			if(index == -1) return;
			_gameSprites.splice(index , 1);
			try{
				_playerLayer.removeChild(sp.getDisplay());
			}catch(e:Error){}
		}

		public function build():void
		{
			GameCtrl.I.initlize(this);
			EffectCtrl.I.initlize(this , _playerLayer);
			gameUI = new GameUI();

			GameEvent.dispatchEvent(GameEvent.FIGHT_START);

		}

		public function initFight(p1group:GameRunFighterGroup , p2group:GameRunFighterGroup , map:MapMain):void{
			_map = map;
			_map.gameState = this;

			if(_map.bgLayer) addChild(_map.bgLayer);

			addChild(_gameLayer);

			if(_map.mapLayer) _gameLayer.addChild(_map.mapLayer);
			_gameLayer.addChild(_playerLayer);
			if(_map.frontFixLayer) _gameLayer.addChild(_map.frontFixLayer);
			if(_map.frontLayer) _gameLayer.addChild(_map.frontLayer);

			_cameraFocus = [];

			var p1:FighterMain = p1group.currentFighter;
			var p2:FighterMain = p2group.currentFighter;

			if(p1){
				GameLogic.resetFighterHP(p1);
				p1.x = _map.p1pos.x;
				p1.y = _map.p1pos.y;
				p1.direct = 1;
				p1.updatePosition();
				_cameraFocus.push(p1.getDisplay());
			}
			if(p2){
				GameLogic.resetFighterHP(p2);
				if(GameMode.isAcrade()) GameLogic.setMessionEnemyAttack(p2);
				p2.x = _map.p2pos.x;
				p2.y = _map.p2pos.y;
				p2.direct = -1;
				p2.updatePosition();
				_cameraFocus.push(p2.getDisplay());
			}

			var stageSize:Point
			if(_map.mapLayer){
//				stageSize = new Point(_map.mapLayer.width , _map.mapLayer.height);
				stageSize = new Point(_map.mapLayer.width , GameConfig.GAME_SIZE.y);
			}else{
				throw new Error('map is error! :: mapLayer is null!');
			}

			initCamera();
			camera.focus(_cameraFocus);

			gameUI.initFight(p1group , p2group);
			addChild(gameUI.getUIDisplay());
		}

		public function resetFight(p1group:GameRunFighterGroup , p2group:GameRunFighterGroup):void{
			var p1:FighterMain = p1group.currentFighter;
			var p2:FighterMain = p2group.currentFighter;

			_cameraFocus = [];


			if(p1){
				GameLogic.resetFighterHP(p1);
				p1.x = _map.p1pos.x;
				p1.y = _map.p1pos.y;
				p1.direct = 1;
				p1.idle();
				p1.updatePosition();
				_cameraFocus.push(p1.getDisplay());
			}

			if(p2){
				GameLogic.resetFighterHP(p2);
				p2.x = _map.p2pos.x;
				p2.y = _map.p2pos.y;
				p2.direct = -1;
				p2.idle();
				p2.updatePosition();
				_cameraFocus.push(p2.getDisplay());
			}

			gameUI.initFight(p1group , p2group);

			cameraResume();
		}

		public function cameraFocusOne(display:DisplayObject):void{
			camera.focus([display]);
//			camera.setZoom(camera.autoZoomMax,false);
			camera.setZoom(3.5);
			camera.tweenSpd = GameConfig.CAMERA_TWEEN_SPD / GameConfig.SPEED_PLUS_DEFAULT;
		}

		public function updateCameraFocus(displays:Array):void{
			_cameraFocus = displays;
			camera.focus(displays);
			camera.setZoom(2);
			camera.tweenSpd = GameConfig.CAMERA_TWEEN_SPD / GameConfig.SPEED_PLUS_DEFAULT;
		}

		public function cameraResume():void{
			camera.focus(_cameraFocus);
			if(_cameraFocus.length < 2) camera.setZoom(2);
			camera.tweenSpd = GameConfig.CAMERA_TWEEN_SPD / GameConfig.SPEED_PLUS_DEFAULT;
		}

		private function initCamera():void{

			if(camera){
				throw new Error("camera inited!");
				return;
			}

			var stageSize:Point = _map.getStageSize();
			camera = new GameCamera(_gameLayer,GameConfig.GAME_SIZE,stageSize,true);
			camera.focusX = true;
			camera.focusY = true;
			camera.offsetY = _map.getMapBottomDistance();
			camera.setStageBounds(new Rectangle(0,-1000,stageSize.x , stageSize.y));

			camera.autoZoom = true;
			camera.autoZoomMin = 1;
			camera.autoZoomMax = 2.5;
			camera.tweenSpd = GameConfig.CAMERA_TWEEN_SPD / GameConfig.SPEED_PLUS_DEFAULT;

			//缓动进入场景
			var startZoom:Number = 2;
			var startX:Number = (stageSize.x / 2) * startZoom - 350;
			var startY:Number = _map.bottom - 200;

			camera.setZoom(startZoom);
			camera.setX(-startX);
			camera.setY(-startY);
			camera.updateNow();

		}

		public function render():void{
			if(Debugger.DRAW_AREA) clearDrawGameRect();
			if(camera) camera.render();
			if(gameUI) gameUI.render();
			if(_map && camera){
				var rect:Rectangle = camera.getScreenRect(true);
				_map.render(-rect.x , -rect.y , camera.getZoom(true));
			}
		}


//		public function renderAnimate():void{
//			if(gameUI) gameUI.renderAnimate();
//		}

		public function drawGameRect(rect:Rectangle , color:uint = 0xff0000 , alpha:Number = 0.5 , clear:Boolean = false):void{
//			trace('drawGameRect' , rect);

			if(clear) _gameLayer.graphics.clear();

			_gameLayer.graphics.beginFill(color,alpha);
			_gameLayer.graphics.drawRect(rect.x,rect.y,rect.width,rect.height);
			_gameLayer.graphics.endFill();
		}
		public function clearDrawGameRect():void{
			_gameLayer.graphics.clear();
		}

		public function afterBuild():void
		{
		}

		public function destory(back:Function=null):void
		{
			this.removeChildren();

			if(_gameSprites){
				while(_gameSprites.length > 0){
					removeGameSprite(_gameSprites.shift(), true);
				}
//				var gs:Array = _gameSprites.concat();
//				for each(var i:IGameSprite in gs){
//					removeGameSprite(i);
//				}
				_gameSprites = null;
			}

			if(_playerLayer){
				_playerLayer.removeChildren();
				_playerLayer = null;
			}

			if(_gameLayer){
				_gameLayer.removeChildren();
				_gameLayer = null;
			}

			if(camera){
				camera = null;
			}

			if(gameUI){
				gameUI.destory();
				gameUI = null;
			}

			EffectCtrl.I.destory();

			GameCtrl.I.destory();

			if(_map){
				_map.destory();
				_map = null;
			}

		}

		/********************************************************************************************************************/
		public function initMosouFight(p1group:GameRunFighterGroup , map:MapMain):void{
			_map = map;
			_map.gameState = this;

			if(_map.bgLayer) addChild(_map.bgLayer);

			addChild(_gameLayer);

			if(_map.mapLayer) _gameLayer.addChild(_map.mapLayer);
			_gameLayer.addChild(_playerLayer);
			if(_map.frontFixLayer) _gameLayer.addChild(_map.frontFixLayer);
			if(_map.frontLayer) _gameLayer.addChild(_map.frontLayer);

			_cameraFocus = [];

			var p1:FighterMain = p1group.currentFighter;

			if(p1){
//				GameLogic.resetFighterHP(p1);
				p1.x = _map.p1pos.x;
				p1.y = _map.p1pos.y;
				p1.direct = 1;
				p1.updatePosition();
				_cameraFocus.push(p1.getDisplay());
			}

			var stageSize:Point
			if(_map.mapLayer){
				stageSize = new Point(_map.mapLayer.width , GameConfig.GAME_SIZE.y);
			}else{
				throw new Error('map is error! :: mapLayer is null!');
			}

			initCamera();
			camera.focus(_cameraFocus);

			gameUI.initMission(p1group);
			addChild(gameUI.getUIDisplay());
		}

	}
}
