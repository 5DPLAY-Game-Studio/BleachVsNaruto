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
import flash.display.MovieClip;
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
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.map.MapMain;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.kyo.stage.IStage;
import net.play5d.kyo.utils.KyoDisplayUtils;
import net.play5d.game.bvn.ctrler.game_ctrls.GameSpriteUtil;

/**
 * 对局画面。
 *
 * <p>角色层在构造时就关掉鼠标。双方站位用全局的 <code>P1</code>、<code>P2</code>，分组参数交给界面。
 * 主层缺失时 <code>initFight</code> 记错并返回，镜头和界面都还没建。
 * 已经在列表里的精灵再次加入时，只先把活动写成 true 就返回，音量和速度比率不改。
 * 释放移除时显示对象已经是 null，列表和父级都不再摘掉。
 * 镜头已经建过时 <code>initCamera</code> 记错并返回。恢复镜头时焦点少于两个会把缩放设成 2。</p>
 *
 * @see GameCamera
 * @see net.play5d.game.bvn.map.MapMain
 */
public class GameStage extends Sprite implements IStage {

    /**
     * 记下对局和特效控制器，并关掉角色层的鼠标。
     *
     * @param gameCtrl 对局控制器。null 时 <code>build</code> 会抛错。
     * @param effectCtrl 特效控制器。null 时 <code>build</code> 会抛错。
     */
    public function GameStage(gameCtrl:GameCtrl, effectCtrl:EffectCtrl) {
        _gameCtrl   = gameCtrl;
        _effectCtrl = effectCtrl;

        _gameLayer.mouseChildren = false;
        _gameLayer.mouseEnabled  = false;
    }

    /**
     * 镜头。<code>initCamera</code> 之前是 null。
     *
     * @default null
     */
    public var camera:GameCamera;
    /**
     * 对局界面。<code>build</code> 时创建。
     *
     * @default null
     */
    public var gameUI:GameUI;

    /** @private */
    private var _playerLayer:Sprite               = new Sprite();
    /** @private 活列表，getGameSprites 返回它 */
    private var _gameSprites:Vector.<IGameSprite> = new Vector.<IGameSprite>();
    /** @private */
    private var _map:MapMain;
    /** @private */
    private var _cameraFocus:Array;

    /** @private 鼠标在构造时关掉 */
    private var _gameLayer:Sprite = new Sprite();
    /** @private */
    private var _gameCtrl:GameCtrl;
    /** @private */
    private var _effectCtrl:EffectCtrl;

    /**
     * 主游戏层。鼠标在构造时关掉。
     *
     * @return 主层。
     * @example
     * <listing version="3.0">
     * var layer:Sprite = stage.gameLayer;
     * </listing>
     */
    public function get gameLayer():Sprite {
        return _gameLayer;
    }

    /**
     * 显示对象
     */
    public function get display():DisplayObject {
        return this;
    }

    /**
     * 当前地图。开打前是 null。
     *
     * @return 地图。
     * @default null
     * @example
     * <listing version="3.0">
     * var map:MapMain = stage.getMap();
     * </listing>
     */
    public function getMap():MapMain {
        return _map;
    }

    /**
     * 按类显示或隐藏精灵的显示对象。
     *
     * <p>用限定名再取回类来比较。显示对象为 null 时抛错。</p>
     *
     * @param cls 要匹配的类。
     * @param visible 是否可见。
     * @throws TypeError 某个匹配精灵没有显示对象时。
     * @example
     * <listing version="3.0">
     * stage.setVisibleByClass(FighterMain, false);
     * </listing>
     */
    public function setVisibleByClass(cls:Class, visible:Boolean):void {
        GameSpriteUtil.renderGameSpritesCB(function (sp:IGameSprite):void {
            var clsName:String = getQualifiedClassName(sp);
            var defCls:Class   = getDefinitionByName(clsName) as Class;

            if (cls == defCls) {
                sp.getDisplay().visible = visible;
            }
        });
    }

    /**
     * 按数据对象找出场上的角色。比较的是同一个引用。
     *
     * @param data 角色数据。null 时能命中数据也是 null 的角色。
     * @return 角色。没有时为 null。
     * @example
     * <listing version="3.0">
     * var fighter:FighterMain = stage.getFighterByData(data);
     * </listing>
     */
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

    /**
     * 用缓动后的镜头把精灵坐标换成画面坐标。
     *
     * @param sp 精灵。null 时抛错。
     * @param offsetX 额外横坐标，默认 0。
     * @param offsetY 额外纵坐标，默认 0。
     * @return 新的点。
     * @throws TypeError 镜头或精灵为 null 时。
     * @example
     * <listing version="3.0">
     * var pos:Point = stage.getGameSpriteGlobalPosition(sp, 0, -20);
     * </listing>
     */
    public function getGameSpriteGlobalPosition(sp:IGameSprite, offsetX:Number = 0, offsetY:Number = 0):Point {
        var zoom:Number    = camera.getZoom(true);
        var rect:Rectangle = camera.getScreenRect(true);

        var point:Point = new Point();
        point.x         = (-rect.x + sp.x + offsetX) * zoom;
        point.y         = (-rect.y + sp.y + offsetY) * zoom;

        return point;
    }

    /**
     * 场上精灵列表。返回的是内部向量。
     *
     * @return 精灵向量。
     * @example
     * <listing version="3.0">
     * var list:Vector.&lt;IGameSprite&gt; = stage.getGameSprites();
     * </listing>
     */
    public function getGameSprites():Vector.<IGameSprite> {
        return _gameSprites;
    }

    /**
     * 把精灵标成活动并加到角色层末尾。
     *
     * <p>已经在列表里时，活动已经写成 true，然后返回，音量和速度比率不改。显示对象为 null 时抛错。</p>
     *
     * @param sp 精灵。
     * @throws TypeError 精灵、显示对象或音量配置缺失时。
     * @example
     * <listing version="3.0">
     * stage.addGameSprite(sp);
     * </listing>
     */
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

    /**
     * 把精灵插到角色层的指定层。已经在列表里时的结果和 <code>addGameSprite</code> 一样。
     *
     * @param sp 精灵。
     * @param index 层序号。超出范围时抛错。
     * @throws TypeError 精灵或显示对象缺失时。
     * @throws RangeError 层序号超出范围时。
     * @example
     * <listing version="3.0">
     * stage.addGameSpriteAt(sp, 0);
     * </listing>
     * @see #addGameSprite()
     */
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

    /**
     * 从列表和角色层移除精灵。
     *
     * <p>精灵为 null 时直接返回。释放时先 <code>destroy(true)</code>，基类精灵的显示对象随之变成 null，于是列表和父级都不再摘。</p>
     *
     * @param sp 精灵。
     * @param isDispose 默认 false。true 时先销毁。
     * @example
     * <listing version="3.0">
     * stage.removeGameSprite(sp, true);
     * </listing>
     */
    public function removeGameSprite(sp:IGameSprite, isDispose:Boolean = false):void {
        if (!sp) {
            return;
        }

        if (isDispose) {
            sp.destroy(true);
        }
        else {
            sp.setActive(false);
        }

        var index:int = _gameSprites.indexOf(sp);
        if (index == -1) {
            return;
        }

        var display:DisplayObject = sp.getDisplay();
        if (!display) {
            return;
        }

        // 处理非 BaseGameSprite 但继承了 IGameSprite 的元件
        if (!(sp is BaseGameSprite) && display is MovieClip) {
            var mc:MovieClip = display as MovieClip;

            KyoDisplayUtils.stopAllMovieClips(mc);
            mc.gotoAndStop(1);
        }

        _playerLayer.removeChild(display);
        _gameSprites.splice(index, 1);
    }

    /**
     * 构建
     */
    public function build():void {
        _gameCtrl.initialize(this);
        _effectCtrl.initialize(this, _playerLayer);
        gameUI = new GameUI();

        GameEvent.dispatchEvent(GameEvent.FIGHT_START);

    }

    /**
     * 摆上地图和双方角色，并建立镜头。
     *
     * <p>站位、朝向和血量用全局 <code>P1</code>、<code>P2</code>。街机模式还会改 <code>P2</code> 的攻击。两人是同一角色时给 <code>P2</code> 变色。
     * 没有主层时记错并返回，镜头、回调和对局界面都还没做。出生点缺失时写坐标会抛错。</p>
     *
     * @param p1group 1P 分组，交给界面。
     * @param p2group 2P 分组，交给界面。
     * @param map 地图。null 时抛错。
     * @param initBack 镜头建完后的回调。默认 null。主层缺失时不会调用。
     * @throws TypeError 地图或出生点缺失时。
     * @example
     * <listing version="3.0">
     * stage.initFight(p1, p2, map, onReady);
     * </listing>
     */
    public function initFight(
            p1group:GameRunFighterGroup, p2group:GameRunFighterGroup,
            map     :MapMain,
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
            if (GameMode.isArcade()) {
                GameLogic.setMissionEnemyAttack(P2);
            }
            P2.x      = _map.p2pos.x;
            P2.y      = _map.p2pos.y;
            P2.direct = -1;
            P2.updatePosition();
            _cameraFocus.push(P2.getDisplay());
        }

        // 执行 P2 变色
        if (_gameCtrl.gameRunData.isSameFighter) {
            GameSpriteUtil.autoChangeSpColor(P2);
        }

        var stageSize:Point;
        if (_map.mapLayer) {
            stageSize = new Point(_map.mapLayer.width, GameConfig.GAME_SIZE.y);
        }
        else {
            ThrowError(Error, 'map is error! :: mapLayer is null!');
            return;
        }

        initCamera();
        camera.focus(_cameraFocus);

        if (initBack != null) {
            initBack();
        }

        gameUI.initFight(p1group, p2group);
        addChild(gameUI.getUIDisplay());
    }

    /**
     * 把双方放回出生点并待机，再恢复镜头。
     *
     * <p>不重建图层。出生点缺失时抛错。同一角色时再次给 <code>P2</code> 变色。</p>
     *
     * @param p1group 交给界面的 1P 分组。
     * @param p2group 交给界面的 2P 分组。
     * @throws TypeError 地图或出生点缺失时。
     * @example
     * <listing version="3.0">
     * stage.resetFight(p1, p2);
     * </listing>
     */
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
        if (_gameCtrl.gameRunData.isSameFighter) {
            GameSpriteUtil.autoChangeSpColor(P2);
        }

        gameUI.initFight(p1group, p2group);

        cameraResume();
    }

    /**
     * 镜头只看一个对象，缩放设成 3.5。
     *
     * @param display 焦点。null 时之后渲染会抛错。
     * @throws TypeError 镜头还没建时。
     * @example
     * <listing version="3.0">
     * stage.cameraFocusOne(view);
     * </listing>
     */
    public function cameraFocusOne(display:DisplayObject):void {
        var tweenSpd:int = GameConfig.CAMERA_TWEEN_SPD / GameConfig.SPEED_PLUS_DEFAULT;

        camera.focus([display]);
        camera.setZoom(3.5);
        camera.tweenSpd = tweenSpd;
    }

    /**
     * 换成这组焦点，缩放设成 2。存的是传入的数组本身。
     *
     * @param displays 焦点数组。空数组时之后渲染会抛错。
     * @throws TypeError 镜头还没建，或数组为 null 时。
     * @example
     * <listing version="3.0">
     * stage.updateCameraFocus([a, b]);
     * </listing>
     */
    public function updateCameraFocus(displays:Array):void {
        var tweenSpd:int = GameConfig.CAMERA_TWEEN_SPD / GameConfig.SPEED_PLUS_DEFAULT;

        _cameraFocus = displays;
        camera.focus(displays);
        camera.setZoom(2);
        camera.tweenSpd = tweenSpd;
    }

    /**
     * 镜头回到记住的焦点。少于两个时把缩放设成 2，两个及以上不改缩放。
     *
     * @throws TypeError 镜头还没建，或记住的焦点为 null 时。
     * @example
     * <listing version="3.0">
     * stage.cameraResume();
     * </listing>
     */
    public function cameraResume():void {
        var tweenSpd:int = GameConfig.CAMERA_TWEEN_SPD / GameConfig.SPEED_PLUS_DEFAULT;

        camera.focus(_cameraFocus);
        if (_cameraFocus.length < 2) {
            camera.setZoom(2);
        }
        camera.tweenSpd = tweenSpd;
    }

    /**
     * 渲染镜头、界面和地图。
     *
     * <p>画判定区时先清掉上一帧的矩形。地图用缓动后的画面矩形取反，再传缓动后的缩放。</p>
     *
     * @example
     * <listing version="3.0">
     * stage.render();
     * </listing>
     */
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

    /**
     * 在主层上画一个矩形。
     *
     * @param rect 矩形。null 时抛错。
     * @param color 填充色，默认红色。
     * @param alpha 透明度，默认 0.5。
     * @param clear 默认 false。true 时先清掉已有图形。
     * @throws TypeError 矩形为 null 时。
     * @example
     * <listing version="3.0">
     * stage.drawGameRect(rect, 0x00ff00, 0.3, true);
     * </listing>
     */
    public function drawGameRect(rect:Rectangle, color:uint = 0xff0000, alpha:Number = 0.5,
                                 clear:Boolean                                       = false
    ):void {

        if (clear) {
            _gameLayer.graphics.clear();
        }

        _gameLayer.graphics.beginFill(color, alpha);
        _gameLayer.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
        _gameLayer.graphics.endFill();
    }

    /**
     * 清掉主层上画的矩形。
     *
     * @example
     * <listing version="3.0">
     * stage.clearDrawGameRect();
     * </listing>
     */
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
                var continueLoser:FighterMain     = _gameCtrl.gameRunData.continueLoser;
                var removedGameSprite:IGameSprite = _gameSprites.shift();
                var isDispose:Boolean             = continueLoser && removedGameSprite != continueLoser;

                removeGameSprite(removedGameSprite, isDispose);
            }

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
            gameUI.destroy();
            gameUI = null;
        }

        _effectCtrl.destroy();

        _gameCtrl.destroy();

        if (_map) {
            _map.destroy();
            _map = null;
        }

    }

    /********************************************************************************************************************/
    /**
     * 摆上无双地图和 1P 当前角色。不重置血量。
     *
     * <p>站位用分组里的当前角色，不重置血量。没有主层时记错并返回，镜头和任务界面都还没建。没有当前角色时不放人。有角色但出生点缺失时抛错。</p>
     *
     * @param p1group 1P 分组。null，或没有当前角色时不放人。
     * @param map 地图。null 时抛错。
     * @throws TypeError 地图缺失，或有角色但出生点缺失时。
     * @example
     * <listing version="3.0">
     * stage.initMusouFight(group, map);
     * </listing>
     */
    public function initMusouFight(p1group:GameRunFighterGroup, map:MapMain):void {
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
            ThrowError(Error, 'map is error! :: mapLayer is null!');
            return;
        }

        initCamera();
        camera.focus(_cameraFocus);

        gameUI.initMission(p1group);
        addChild(gameUI.getUIDisplay());
    }

    /**
     * 建立镜头。已经有镜头时记错并返回。
     *
     * <p>横向纵向都跟随，纵向偏移是地图底边和脚底的差，自动缩放在 1 到 2.5。边界顶上留出 1000。
     * 先放到两倍缩放和一段负坐标，再立刻渲染一帧。</p>
     *
     * @throws TypeError 地图还没建立时。
     * @example
     * <listing version="3.0">
     * stage.initCamera();
     * </listing>
     */
    public function initCamera():void {
        if (camera) {
            ThrowError(Error, GetLang('log.error.fight.game_stage.camera_already_init'));
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
