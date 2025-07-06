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

package net.play5d.game.bvn.stage {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.data.GameRunFighterGroup;
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.map.MapMain;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.utils.MCUtils;
import net.play5d.kyo.stage.IStage;

public class GameStage extends Sprite implements IStage {
    include '../../../../../../include/_INCLUDE_.as';

    public function GameStage() {
//			this.scrollRect = new Rectangle(0,0,GameConfig.GAME_SIZE.x , GameConfig.GAME_SIZE.y);

        _gameLayer.mouseChildren = false;
        _gameLayer.mouseEnabled  = false;
    }

    public var camera:GameCamera;
    public var gameUI:GameUI;

    private var _playerLayer:Sprite               = new Sprite(); //游戏角色层
    private var _gameSprites:Vector.<IGameSprite> = new Vector.<IGameSprite>(); //游戏元件列表
    private var _map:MapMain; //游戏地图
    private var _cameraFocus:Array;

    private var _gameLayer:Sprite = new Sprite(); //主游戏层

    public function get gameLayer():Sprite {
        return _gameLayer;
    }

    /**
     * 显示对象
     */
    public function get display():DisplayObject {
        return this;
    }

    public function getMap():MapMain {
        return _map;
    }

//		private var _renderAnimateGap:int = 0; //刷新动画间隔
//		private var _renderAnimateFrame:int = 0;

    public function setVisibleByClass(cls:Class, visible:Boolean):void {
        MCUtils.renderGameSpritesCB(function (sp:IGameSprite):void {
            var clsName:String = getQualifiedClassName(sp);
            var defCls:Class   = getDefinitionByName(clsName) as Class;

            if (cls == defCls) {
                sp.getDisplay().visible = visible;
            }
        });
    }

    public function getFighterByData(data:FighterVO):FighterMain {
        for each(var d:IGameSprite in _gameSprites) {
            if (d is FighterMain && (
                    d as FighterMain
            ).data == data) {
                return d as FighterMain;
            }
        }
        return null;
    }

    public function getGameSpriteGlobalPosition(sp:IGameSprite, offsetX:Number = 0, offsetY:Number = 0):Point {
        var zoom:Number    = camera.getZoom(true);
        var rect:Rectangle = camera.getScreenRect(true);

        var point:Point = new Point();
        point.x         = (-rect.x + sp.x + offsetX) * zoom;
        point.y         = (-rect.y + sp.y + offsetY) * zoom;

        return point;
    }

    public function getGameSprites():Vector.<IGameSprite> {
        return _gameSprites;
    }

    public function addGameSprite(sp:IGameSprite):void {
        sp.setActive(true);
        if (_gameSprites.indexOf(sp) != -1) {
            return;
        }
        _gameSprites.push(sp);
        _playerLayer.addChild(sp.getDisplay());
        sp.setVolume(GameData.I.config.soundVolume);

        // 修复慢放 BUG
        // 刷新 sp 的 speedPlus
        sp.setSpeedRate(GameConfig.SPEED_PLUS);
    }

    public function addGameSpriteAt(sp:IGameSprite, index:int):void {
        sp.setActive(true);
        if (_gameSprites.indexOf(sp) != -1) {
            return;
        }
        _gameSprites.push(sp);
        _playerLayer.addChildAt(sp.getDisplay(), index);
        sp.setVolume(GameData.I.config.soundVolume);

        // 修复慢放 BUG
        // 刷新 sp 的 speedPlus
        sp.setSpeedRate(GameConfig.SPEED_PLUS);
    }

    public function removeGameSprite(sp:IGameSprite, isDispose:Boolean = false):void {
        if (isDispose) {
            sp.destory(true);
        }
        else {
            sp.setActive(false);
        }

        var index:int = _gameSprites.indexOf(sp);
        if (index == -1) {
            return;
        }
        _gameSprites.splice(index, 1);
        try {
            _playerLayer.removeChild(sp.getDisplay());
        }
        catch (e:Error) {
        }
    }

    /**
     * 构建
     */
    public function build():void {
        GameCtrl.I.initlize(this);
        EffectCtrl.I.initlize(this, _playerLayer);
        gameUI = new GameUI();

        GameEvent.dispatchEvent(GameEvent.FIGHT_START);

    }

    public function initFight(
            p1group:GameRunFighterGroup, p2group:GameRunFighterGroup,
            map:MapMain,
            initBack:Function = null
    ):void {
        _map           = map;
        _map.gameState = this;

        if (_map.bgLayer) {
            addChild(_map.bgLayer);
        }

        addChild(_gameLayer);

        if (_map.mapLayer) {
            _gameLayer.addChild(_map.mapLayer);
        }
        _gameLayer.addChild(_playerLayer);
        if (_map.frontFixLayer) {
            _gameLayer.addChild(_map.frontFixLayer);
        }
        if (_map.frontLayer) {
            _gameLayer.addChild(_map.frontLayer);
        }

        _cameraFocus = [];

        if (P1) {
            GameLogic.resetFighterHP(P1);
            P1.x      = _map.p1pos.x;
            P1.y      = _map.p1pos.y;
            P1.direct = 1;
            P1.updatePosition();
            _cameraFocus.push(P1.getDisplay());
        }
        if (P2) {
            GameLogic.resetFighterHP(P2);
            if (GameMode.isAcrade()) {
                GameLogic.setMessionEnemyAttack(P2);
            }
            P2.x      = _map.p2pos.x;
            P2.y      = _map.p2pos.y;
            P2.direct = -1;
            P2.updatePosition();
            _cameraFocus.push(P2.getDisplay());
        }

        // 执行 P2 变色
        var p1Id:String = p1group.currentFighterId;
        var p2Id:String = p2group.currentFighterId;
        if (p1Id && p2Id && p1Id == p2Id) {
            MCUtils.changeSpColor(P2);
        }

        var stageSize:Point;
        if (_map.mapLayer) {
//				stageSize = new Point(_map.mapLayer.width , _map.mapLayer.height);
            stageSize = new Point(_map.mapLayer.width, GameConfig.GAME_SIZE.y);
        }
        else {
            throw new Error('map is error! :: mapLayer is null!');
        }

        initCamera();
        camera.focus(_cameraFocus);

        if (initBack != null) {
            initBack();
        }

        gameUI.initFight(p1group, p2group);
        addChild(gameUI.getUIDisplay());
    }

    public function resetFight(p1group:GameRunFighterGroup, p2group:GameRunFighterGroup):void {
        _cameraFocus = [];

        if (P1) {
            GameLogic.resetFighterHP(P1);
            P1.x      = _map.p1pos.x;
            P1.y      = _map.p1pos.y;
            P1.direct = 1;
            P1.idle();
            P1.updatePosition();
            _cameraFocus.push(P1.getDisplay());
        }

        if (P2) {
            GameLogic.resetFighterHP(P2);
            P2.x      = _map.p2pos.x;
            P2.y      = _map.p2pos.y;
            P2.direct = -1;
            P2.idle();
            P2.updatePosition();
            _cameraFocus.push(P2.getDisplay());
        }

        // 执行 P2 变色
        var p1Id:String = p1group.currentFighterId;
        var p2Id:String = p2group.currentFighterId;
        if (p1Id && p2Id && p1Id == p2Id) {
            MCUtils.changeSpColor(P2);
        }

        gameUI.initFight(p1group, p2group);

        cameraResume();
    }

    public function cameraFocusOne(display:DisplayObject):void {
        var tweenSpd:int = GameConfig.CAMERA_TWEEN_SPD / GameConfig.SPEED_PLUS_DEFAULT;

        camera.focus([display]);
//			camera.setZoom(camera.autoZoomMax,false);
        camera.setZoom(3.5);
        camera.tweenSpd = tweenSpd;
    }

    public function updateCameraFocus(displays:Array):void {
        var tweenSpd:int = GameConfig.CAMERA_TWEEN_SPD / GameConfig.SPEED_PLUS_DEFAULT;

        _cameraFocus = displays;
        camera.focus(displays);
        camera.setZoom(2);
        camera.tweenSpd = tweenSpd;
    }

    public function cameraResume():void {
        var tweenSpd:int = GameConfig.CAMERA_TWEEN_SPD / GameConfig.SPEED_PLUS_DEFAULT;

        camera.focus(_cameraFocus);
        if (_cameraFocus.length < 2) {
            camera.setZoom(2);
        }
        camera.tweenSpd = tweenSpd;
    }

    public function render():void {
        if (Debugger.DRAW_AREA) {
            clearDrawGameRect();
        }
        if (camera) {
            camera.render();
        }
        if (gameUI) {
            gameUI.render();
        }
        if (_map && camera) {
            var rect:Rectangle = camera.getScreenRect(true);
            _map.render(-rect.x, -rect.y, camera.getZoom(true));
        }
    }

    public function drawGameRect(rect:Rectangle, color:uint = 0xff0000, alpha:Number = 0.5,
                                 clear:Boolean                                       = false
    ):void {
//			trace('drawGameRect' , rect);

        if (clear) {
            _gameLayer.graphics.clear();
        }

        _gameLayer.graphics.beginFill(color, alpha);
        _gameLayer.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
        _gameLayer.graphics.endFill();
    }


//		public function renderAnimate():void{
//			if(gameUI) gameUI.renderAnimate();
//		}

    public function clearDrawGameRect():void {
        _gameLayer.graphics.clear();
    }

    /**
     * 稍后构建
     */
    public function afterBuild():void {
    }

    /**
     * 销毁
     * @param back 回调函数
     */
    public function destroy(back:Function = null):void {
        this.removeChildren();

        if (_gameSprites) {
            while (_gameSprites.length > 0) {
                removeGameSprite(_gameSprites.shift(), true);
            }
//				var gs:Array = _gameSprites.concat();
//				for each(var i:IGameSprite in gs){
//					removeGameSprite(i);
//				}
            _gameSprites = null;
        }

        if (_playerLayer) {
            _playerLayer.removeChildren();
            _playerLayer = null;
        }

        if (_gameLayer) {
            _gameLayer.removeChildren();
            _gameLayer = null;
        }

        if (camera) {
            camera.destroy();
            camera = null;
        }

        if (gameUI) {
            gameUI.destory();
            gameUI = null;
        }

        EffectCtrl.I.destory();

        GameCtrl.I.destory();

        if (_map) {
            _map.destory();
            _map = null;
        }

    }

    /********************************************************************************************************************/
    public function initMosouFight(p1group:GameRunFighterGroup, map:MapMain):void {
        _map           = map;
        _map.gameState = this;

        if (_map.bgLayer) {
            addChild(_map.bgLayer);
        }

        addChild(_gameLayer);

        if (_map.mapLayer) {
            _gameLayer.addChild(_map.mapLayer);
        }
        _gameLayer.addChild(_playerLayer);
        if (_map.frontFixLayer) {
            _gameLayer.addChild(_map.frontFixLayer);
        }
        if (_map.frontLayer) {
            _gameLayer.addChild(_map.frontLayer);
        }

        _cameraFocus = [];

        var p1:FighterMain = p1group.currentFighter;

        if (p1) {
//				GameLogic.resetFighterHP(p1);
            p1.x      = _map.p1pos.x;
            p1.y      = _map.p1pos.y;
            p1.direct = 1;
            p1.updatePosition();
            _cameraFocus.push(p1.getDisplay());
        }

        var stageSize:Point;
        if (_map.mapLayer) {
            stageSize = new Point(_map.mapLayer.width, GameConfig.GAME_SIZE.y);
        }
        else {
            throw new Error('map is error! :: mapLayer is null!');
        }

        initCamera();
        camera.focus(_cameraFocus);

        gameUI.initMission(p1group);
        addChild(gameUI.getUIDisplay());
    }

    public function initCamera():void {
        if (camera) {
            throw new Error('游戏镜头已初始化！');
            return;
        }

        var stageSize:Point = _map.getStageSize();
        var rect:Rectangle  = new Rectangle(0, -1000, stageSize.x, stageSize.y);
        var tweenSpd:Number = GameConfig.CAMERA_TWEEN_SPD / GameConfig.SPEED_PLUS_DEFAULT;

        camera = new GameCamera(_gameLayer, GameConfig.GAME_SIZE, stageSize, true);
        camera.focusX      = true;
        camera.focusY      = true;
        camera.offsetY     = _map.getMapBottomDistance();
        camera.autoZoom    = true;
        camera.autoZoomMin = 1;
        camera.autoZoomMax = 2.5;
        camera.tweenSpd    = tweenSpd;

        // 缓动进入场景
        var startZoom:Number = 2;
        var startX:Number    = (stageSize.x / 2) * startZoom - 350;
        var startY:Number    = _map.bottom - 200;

        camera.setStageBounds(rect);
        camera.setZoom(startZoom);
        camera.setX(-startX);
        camera.setY(-startY);
        camera.updateNow();
    }

}
}
