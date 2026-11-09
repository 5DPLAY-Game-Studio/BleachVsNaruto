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

package net.play5d.game.bvn.map {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Point;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.data.vos.MapVO;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.stage.GameStage;
import net.play5d.game.bvn.utils.GameLogger;

/**
 * 一局对战的地图。
 *
 * <p>初始化从影片里读左右底边、<code>p1</code>、<code>p2</code> 和 <code>map</code>、<code>front</code>、<code>front_fix</code>、<code>bg</code>、<code>floor</code>。
 * 缺了的层 <code>enabled</code> 为 false，不会加进显示列表。底边缺失时按 0 算，纵向偏移就是画面高度。背景层不加这个偏移，主层和两层前景会加。
 * 再调用一次会按当时的底边再偏移一遍，并换上新层，旧层不销毁。
 * <code>HIDE_MAP</code> 时 <code>setVisible(true)</code> 直接返回。前景每帧跟镜头走 0.1，纵坐标不会小于初始化位置。<code>zoom</code> 不参与计算。
 * 没有角色时 <code>render</code> 连前景位移也不做。地板命中用开区间，先碰到的那条返回。</p>
 *
 * @see MapLayer
 * @see FloorVO
 */
public class MapMain {

    /**
     * 记下地图影片。这里不读子对象。
     *
     * @param mapmc 地图影片。null 时，之后 <code>initialize</code> 会抛错。
     */
    public function MapMain(mapmc:Sprite) {
        super();
        this.mapMc = mapmc;
    }

    /**
     * 主层。初始化前是 null。没有 <code>map</code> 子对象时层存在但 <code>enabled</code> 为 false。
     *
     * @default null
     */
    public var mapLayer:MapLayer;
    /**
     * 前景层。
     *
     * @default null
     */
    public var frontLayer:MapLayer;
    /**
     * 不跟镜头移动的前景层。
     *
     * @default null
     */
    public var frontFixLayer:MapLayer;
    /**
     * 背景层。初始化时不加纵向偏移。
     *
     * @default null
     */
    public var bgLayer:MapLayer;
    /**
     * 1P 出生点。没有 <code>p1</code> 时保持 null。
     *
     * @default null
     */
    public var p1pos:Point;
    /**
     * 2P 出生点。没有 <code>p2</code> 时保持 null。
     *
     * @default null
     */
    public var p2pos:Point;
    /**
     * 地图左边界。没有 <code>line_left</code> 时保持 0，初始化不会改它。
     *
     * @default 0
     */
    public var left:Number         = 0;
    /**
     * 地图右边界。没有 <code>line_right</code> 时保持 0。
     *
     * @default 0
     */
    public var right:Number        = 0;
    /**
     * 地图底边。初始化时会加上画面高度减底边的偏移。
     *
     * @default 0
     */
    public var bottom:Number       = 0;
    /**
     * 角色脚底线。没有 <code>line_player_bottom</code> 时，初始化后等于那次纵向偏移。
     *
     * @default 0
     */
    public var playerBottom:Number = 0;
    /**
     * 地图影片。销毁后为 null。
     */
    public var mapMc:Sprite;
    /**
     * 地图配置。本类不写入。
     *
     * @default null
     */
    public var data:MapVO;
    /**
     * 对局舞台。<code>render</code> 用它取角色。null 时渲染会抛错。
     *
     * @default null
     */
    public var gameState:GameStage;
    /** @private 前景初始化后的坐标 */
    private var _defaultFrontPos:Point;
    /** @private */
    private var _smoothing:Point   = new Point();
    /** @private 初始化前是 null */
    private var _floors:Array;

    /** @private */
    private var _colorTransform:ColorTransform = new ColorTransform();

    /**
     * 清掉影片的全部子对象，并销毁已经建好的层。
     *
     * <p>移除子对象失败只记日志。出生点、配置、舞台和地板列表还留着。颜色变换改成 null。</p>
     *
     * @example
     * <listing version="3.0">
     * map.destroy();
     * </listing>
     */
    public function destroy():void {
        if (mapMc) {
            try {
                mapMc.removeChildren();
            }
            catch (e:Error) {
                GameLogger.error('fight', String(e));
            }
            mapMc = null;
        }
        if (mapLayer) {
            mapLayer.destroy();
            mapLayer = null;
        }
        if (frontLayer) {
            frontLayer.destroy();
            frontLayer = null;
        }
        if (frontFixLayer) {
            frontFixLayer.destroy();
            frontFixLayer = null;
        }
        if (bgLayer) {
            bgLayer.destroy();
            bgLayer = null;
        }

        _colorTransform = null;
    }

    /**
     * 记下颜色变换，并写到每个可用的层。
     *
     * <p>不可用或还没建的层跳过。传入 null 时，写到第一个可用层会抛错，后面的层还没写到。</p>
     *
     * @param colorTransform 颜色变换。
     * @throws TypeError 变换为 null 且存在可用层时。
     * @example
     * <listing version="3.0">
     * map.setColorTransform(color);
     * </listing>
     */
    public function setColorTransform(colorTransform:ColorTransform):void {
        _colorTransform = colorTransform;

        if (mapLayer && mapLayer.enabled) {
            mapLayer.transform.colorTransform = _colorTransform;
        }

        if (frontLayer && frontLayer.enabled) {
            frontLayer.transform.colorTransform = _colorTransform;
        }

        if (frontFixLayer && frontFixLayer.enabled) {
            frontFixLayer.transform.colorTransform = _colorTransform;
        }

        if (bgLayer && bgLayer.enabled) {
            bgLayer.transform.colorTransform = _colorTransform;
        }
    }

    /**
     * 当前颜色变换。销毁后是 null。
     *
     * @return 颜色变换。
     * @example
     * <listing version="3.0">
     * var color:ColorTransform = map.getColorTransform();
     * </listing>
     */
    public function getColorTransform():ColorTransform {
        return _colorTransform;
    }

    /**
     * 换成一份默认颜色变换，并写到可用的层。
     *
     * @example
     * <listing version="3.0">
     * map.resetColorTransform();
     * </listing>
     */
    public function resetColorTransform():void {
        _colorTransform = new ColorTransform();

        setColorTransform(_colorTransform);
    }

    /**
     * 显示或隐藏每个可用的层。
     *
     * <p><code>Debugger.HIDE_MAP</code> 为 true 且要显示时直接返回，当前可见性不变。不可用的层不改。</p>
     *
     * @param v 是否可见。
     * @example
     * <listing version="3.0">
     * map.setVisible(false);
     * </listing>
     */
    public function setVisible(v:Boolean):void {

        if (Debugger.HIDE_MAP && v) {
            return;
        }

        if (mapLayer && mapLayer.enabled) {
            mapLayer.visible = v;
        }
        if (frontLayer && frontLayer.enabled) {
            frontLayer.visible = v;
        }
        if (frontFixLayer && frontFixLayer.enabled) {
            frontFixLayer.visible = v;
        }
        if (bgLayer && bgLayer.enabled) {
            bgLayer.visible = v;
        }
    }

    /**
     * 当前模糊值。返回的是内部点，改它不会马上作用到层上。
     *
     * @return 横纵模糊。
     * @example
     * <listing version="3.0">
     * var blur:Point = map.getSmoothing();
     * </listing>
     */
    public function getSmoothing():Point {
        return _smoothing;
    }

    /**
     * 设置模糊。主层用原值，两层前景用两倍，背景用三倍。只写可用的层。
     *
     * @param blurX 横向模糊，默认 0。
     * @param blurY 纵向模糊，默认 0。
     * @example
     * <listing version="3.0">
     * map.setSmoothing(1, 0);
     * </listing>
     */
    public function setSmoothing(blurX:Number = 0, blurY:Number = 0):void {
        _smoothing.x = blurX;
        _smoothing.y = blurY;

        if (mapLayer && mapLayer.enabled) {
            mapLayer.setSmoothing(blurX, blurY);
        }
        if (bgLayer && bgLayer.enabled) {
            bgLayer.setSmoothing(blurX * 3, blurY * 3);
        }
        if (frontLayer && frontLayer.enabled) {
            frontLayer.setSmoothing(blurX * 2, blurY * 2);
        }
        if (frontFixLayer && frontFixLayer.enabled) {
            frontFixLayer.setSmoothing(blurX * 2, blurY * 2);
        }
    }

    /**
     * 从影片建立边界、出生点、图层和地板。
     *
     * <p>影片为 null 时抛错。缺边线时对应边界保持 0，再拿它算纵向偏移。没有地板影片时地板列表是空数组。
     * <code>HIDE_MAP</code> 时最后藏起各地层。</p>
     *
     * @throws TypeError 地图影片为 null 时。
     * @example
     * <listing version="3.0">
     * map.initialize();
     * </listing>
     */
    public function initialize():void {
        var leftLine:DisplayObject         = mapMc.getChildByName('line_left');
        var rightLine:DisplayObject        = mapMc.getChildByName('line_right');
        var bottomLine:DisplayObject       = mapMc.getChildByName('line_bottom');
        var playerBottomLine:DisplayObject = mapMc.getChildByName('line_player_bottom');

        var gamesize:Point = GameConfig.GAME_SIZE;

        if (leftLine) {
            left = leftLine.x;
        }
        if (rightLine) {
            right = rightLine.x;
        }
        if (bottomLine) {
            bottom = bottomLine.y;
        }
        if (playerBottomLine) {
            playerBottom = playerBottomLine.y;
        }

        var p1mc:DisplayObject = mapMc.getChildByName('p1');
        var p2mc:DisplayObject = mapMc.getChildByName('p2');

        if (p1mc) {
            p1pos = new Point(p1mc.x, p1mc.y);
        }
        if (p2mc) {
            p2pos = new Point(p2mc.x, p2mc.y);
        }

        mapLayer      = new MapLayer(mapMc.getChildByName('map'));
        frontLayer    = new MapLayer(mapMc.getChildByName('front'));
        frontFixLayer = new MapLayer(mapMc.getChildByName('front_fix'));
        bgLayer       = new MapLayer(mapMc.getChildByName('bg'));

        if (bgLayer.enabled) {
            bgLayer.normalize();
            mapMc.addChild(bgLayer);
        }

        var offsetY:Number = gamesize.y - bottom;

        if (mapLayer.enabled) {
            mapLayer.normalize();
            mapLayer.y += offsetY;
            mapMc.addChild(mapLayer);
        }

        if (frontLayer.enabled) {
            frontLayer.normalize();
            frontLayer.y += offsetY;
            _defaultFrontPos = new Point(frontLayer.x, frontLayer.y);
            mapMc.addChild(frontLayer);
        }

        if (frontFixLayer.enabled) {
            frontFixLayer.normalize();
            frontFixLayer.y += offsetY;
            mapMc.addChild(frontFixLayer);
        }

        playerBottom += offsetY;
        bottom += offsetY;

        if (p1pos) {
            p1pos.y += offsetY;
        }
        if (p2pos) {
            p2pos.y += offsetY;
        }

        initFloor(offsetY);

        if (Debugger.HIDE_MAP) {
            setVisible(false);
        }

        resetColorTransform();
    }

    /**
     * 舞台尺寸。宽度取主层当前宽度，高度取画面高度。每次返回新的点。
     *
     * @return 宽高。
     * @throws TypeError 主层还没建立时。
     * @example
     * <listing version="3.0">
     * var size:Point = map.getStageSize();
     * </listing>
     */
    public function getStageSize():Point {
        return new Point(mapLayer.width, GameConfig.GAME_SIZE.y);
    }

    /**
     * 地图底边减角色脚底线。两条线一起偏移后，差仍是原来的间距。
     *
     * @return 这段距离。初始化前是 0。
     * @example
     * <listing version="3.0">
     * var gap:Number = map.getMapBottomDistance();
     * </listing>
     */
    public function getMapBottomDistance():Number {
        return bottom - playerBottom;
    }

    /**
     * 按地板影片里子对象的顺序返回第一条踩中的地板。
     *
     * @param x 横坐标。
     * @param y 纵坐标。
     * @param speed 传给地板的纵向容差。
     * @return 踩中的地板。都没有时为 null。
     * @throws TypeError 还没初始化时。
     * @example
     * <listing version="3.0">
     * var floor:FloorVO = map.getFloorHitTest(x, y, speed);
     * </listing>
     * @see FloorVO#hitTest()
     */
    public function getFloorHitTest(x:Number, y:Number, speed:Number):FloorVO {
        for (var i:int; i < _floors.length; i++) {
            var fv:FloorVO = _floors[i];
            if (fv.hitTest(x, y, speed)) {
                return fv;
            }
        }
        return null;
    }

    /**
     * 移动前景并刷新两层前景的遮挡透明度。
     *
     * <p>没有舞台，或角色列表为 null、空时直接返回，前景停在原地。前景横坐标是镜头横坐标的 0.1 加上初始位置。
     * 纵坐标用镜头纵坐标加底边，同样乘 0.1，结果小于初始位置时改回初始位置。<code>zoom</code> 不使用。固定前景只做遮挡。</p>
     *
     * @param gameX 镜头横坐标。
     * @param gameY 镜头纵坐标。
     * @param zoom 不参与计算。
     * @throws TypeError 舞台为 null，或前景可用但还没有初始坐标时。
     * @example
     * <listing version="3.0">
     * map.render(gameX, gameY, zoom);
     * </listing>
     */
    public function render(gameX:Number, gameY:Number, zoom:Number):void {
        var gameSps:Vector.<IGameSprite> = gameState.getGameSprites();
        if (!gameSps || gameSps.length < 1) {
            return;
        }

        if (frontLayer && frontLayer.enabled) {
            var gx:Number = gameX;
            var gy:Number = gameY + bottom;

            frontLayer.x  = gx * 0.1 + _defaultFrontPos.x;
            var yy:Number = gy * 0.1 + _defaultFrontPos.y;
            (
                    yy < _defaultFrontPos.y
            ) && (
                    yy = _defaultFrontPos.y
            );
            frontLayer.y = yy;

            frontLayer.renderOptical(gameSps);
        }

        if (frontFixLayer && frontFixLayer.enabled) {
            frontFixLayer.renderOptical(gameSps);
        }

    }

    /** @private 没有 floor 影片时列表是空数组 */
    private function initFloor(offsetY:Number):void {
        _floors            = [];
        var floormc:Sprite = mapMc.getChildByName('floor') as Sprite;
        if (!floormc) {
            return;
        }

        for (var i:int; i < floormc.numChildren; i++) {
            var f:DisplayObject = floormc.getChildAt(i);
            if (f) {
                var fv:FloorVO = new FloorVO();
                fv.xFrom       = floormc.x + f.x;
                fv.xTo         = floormc.x + f.x + f.width;
                fv.y           = floormc.y + f.y + offsetY;
                _floors.push(fv);
            }
        }
    }

}
}
