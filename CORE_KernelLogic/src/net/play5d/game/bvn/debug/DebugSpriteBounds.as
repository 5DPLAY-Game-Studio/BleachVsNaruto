/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.debug {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import net.play5d.game.bvn.ctrler.GameRender;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.fighter.Assister;
import net.play5d.game.bvn.fighter.Bullet;
import net.play5d.game.bvn.fighter.FighterAttacker;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.kyo.utils.KyoColor;
import net.play5d.game.bvn.ctrler.game_ctrls.GameSpriteUtil;

/**
 * 战斗实体线框叠加层（调试用）。
 *
 * <p>开启后在游戏图层顶部用单个 <code>Shape</code> 按类型颜色绘制
 * 显示对象相对游戏层的 <code>getBounds</code>（当前帧可视/重绘区域）线框（透明度 0.33）。
 * 鼠标掠过时最顶层命中 MC 半透明填充；左键点击锁定跟踪（锁定目标亦保持填充）；
 * 右键清除跟踪。跟踪实体销毁后自动清空，等待下次点击锁定。
 * 仅处理角色、援助、子弹与独立道具。</p>
 *
 * @example
 * <listing version="3.0">
 * DebugSpriteBounds.I.initialize();
 * DebugSpriteBounds.I.isRender = true;
 * var sp:IGameSprite = DebugSpriteBounds.I.trackedSprite;
 * </listing>
 * @see #initialize()
 * @see #isRender
 * @see #trackedSprite
 * @see #clearTrack()
 */
public class DebugSpriteBounds {
    /** @private */
    private static var _i:DebugSpriteBounds;

    /**
     * 单例。
     * @return 全局实例。
     */
    public static function get I():DebugSpriteBounds {
        _i ||= new DebugSpriteBounds();

        return _i;
    }

    /** @private 线框线宽 */
    private static const LINE_THICKNESS:Number = 1;
    /** @private 边框与跟踪填充透明度 */
    private static const DRAW_ALPHA:Number = 0.33;

    /**
     * 是否绘制精灵线框。
     * @default false
     */
    public var isRender:Boolean = false;

    /** @private 是否已注册渲染回调 */
    private var _isInitialized:Boolean;
    /** @private 当前游戏图层 */
    private var _gameLayer:Sprite;
    /** @private 叠加绘制层（单 Shape） */
    private var _overlay:Shape;
    /** @private 本帧待绘项（复用，避免每帧 new Array） */
    private var _items:Array = [];
    /** @private 路径比较临时缓冲 */
    private var _pathA:Vector.<int> = new Vector.<int>();
    /** @private */
    private var _pathB:Vector.<int> = new Vector.<int>();
    /** @private 本帧最顶层悬停实体（供点击锁定） */
    private var _hoveredSprite:IGameSprite;
    /** @private 点击确认的跟踪实体 */
    private var _trackedSprite:IGameSprite;
    /** @private 是否已绑定舞台鼠标 */
    private var _inputBound:Boolean;
    /** @private 绑定输入的舞台 */
    private var _stage:Stage;

    /**
     * 点击锁定的跟踪实体；未锁定或已清除时为 <code>null</code>。
     * @return 当前跟踪实体。
     * @default null
     */
    public function get trackedSprite():IGameSprite {
        return _trackedSprite;
    }

    /**
     * 注册帧后渲染回调（幂等）。
     * @example
     * <listing version="3.0">
     * DebugSpriteBounds.I.initialize();
     * </listing>
     */
    public function initialize():void {
        if (_isInitialized) {
            return;
        }

        _isInitialized = true;
        GameRender.addAfter(render);
    }

    /**
     * 清除跟踪锁定，回到等待点击确认状态。
     * @example
     * <listing version="3.0">
     * DebugSpriteBounds.I.clearTrack();
     * </listing>
     */
    public function clearTrack():void {
        _trackedSprite = null;
    }

    /**
     * 每帧：关闭时卸层；开启且有对局状态时重绘战斗实体线框。
     */
    private function render():void {
        if (!isRender) {
            clearTrack();
            _hoveredSprite = null;
            unbindInput();
            if (_overlay) {
                cleanOverlay();
            }

            return;
        }

        if (!GameCtrl.I.gameState) {
            clearTrack();
            _hoveredSprite = null;
            unbindInput();
            if (_overlay) {
                _overlay.graphics.clear();
            }

            return;
        }

        if (!ensureOverlay()) {
            _hoveredSprite = null;

            return;
        }

        bindInput();

        if (_trackedSprite && _trackedSprite.isDestroyed()) {
            clearTrack();
        }

        _overlay.graphics.clear();
        _items.length = 0;
        GameSpriteUtil.renderGameSpritesCB(collectSprite);
        drawCollected();
    }

    /**
     * 确保叠加层挂在当前游戏图层顶层。
     * @return 图层可用且叠加层已就绪。
     */
    private function ensureOverlay():Boolean {
        var layer:Sprite = GameCtrl.I.gameState.gameLayer;
        if (!layer) {
            return false;
        }

        if (_gameLayer != layer) {
            unbindInput();
            cleanOverlay();
            _gameLayer = layer;
        }

        if (!_overlay) {
            _overlay      = new Shape();
            _overlay.name = 'debugSpriteBoundsOverlay';
        }

        if (_overlay.parent != _gameLayer) {
            _gameLayer.addChild(_overlay);
        }
        else if (_gameLayer.getChildIndex(_overlay) != _gameLayer.numChildren - 1) {
            _gameLayer.setChildIndex(_overlay, _gameLayer.numChildren - 1);
        }

        return true;
    }

    /**
     * 绑定舞台左键锁定 / 右键清除。
     */
    private function bindInput():void {
        if (_inputBound || !_gameLayer || !_gameLayer.stage) {
            return;
        }

        _stage = _gameLayer.stage;
        _stage.addEventListener(MouseEvent.CLICK, onStageClick);
        _stage.addEventListener(MouseEvent.RIGHT_CLICK, onStageRightClick);
        _inputBound = true;
    }

    /**
     * 移除舞台鼠标监听。
     */
    private function unbindInput():void {
        if (!_inputBound) {
            return;
        }

        if (_stage) {
            _stage.removeEventListener(MouseEvent.CLICK, onStageClick);
            _stage.removeEventListener(MouseEvent.RIGHT_CLICK, onStageRightClick);
        }

        _stage     = null;
        _inputBound = false;
    }

    /**
     * 左键：将最顶层悬停实体锁定为跟踪目标。
     * @param e 鼠标事件。
     */
    private function onStageClick(e:MouseEvent):void {
        if (!isRender || !_hoveredSprite) {
            return;
        }

        _trackedSprite = _hoveredSprite;
    }

    /**
     * 右键：清除跟踪，回到等待点击确认。
     * @param e 鼠标事件。
     */
    private function onStageRightClick(e:MouseEvent):void {
        if (!isRender) {
            return;
        }

        clearTrack();
    }

    /**
     * 收集本帧可绘的战斗实体。
     * @param sp 当前精灵。
     */
    private function collectSprite(sp:IGameSprite):void {
        if (!sp || sp.isDestroyed()) {
            return;
        }

        var color:uint = 0;
        if (sp is FighterMain) {
            color = KyoColor.LIME;
        }
        else if (sp is Assister) {
            color = KyoColor.ORANGE;
        }
        else if (sp is Bullet) {
            color = KyoColor.MAGENTA;
        }
        else if (sp is FighterAttacker) {
            color = KyoColor.CYAN;
        }
        else {
            return;
        }

        var display:DisplayObject = sp.getDisplay();
        if (!display || !display.parent) {
            return;
        }

        var area:Rectangle = display.getBounds(_gameLayer);
        if (!area || area.isEmpty()) {
            return;
        }

        var hovered:Boolean = false;
        if (display.stage) {
            hovered = display.hitTestPoint(display.stage.mouseX, display.stage.mouseY, true);
        }

        _items[_items.length] = {
            color  : color,
            area   : area.clone(),
            display: display,
            hovered: hovered,
            sprite : sp
        };
    }

    /**
     * 绘制全部线框；最顶层悬停与已锁定跟踪实体半透明填充。
     */
    private function drawCollected():void {
        var topIndex:int = -1;
        var i:int;

        for (i = 0; i < _items.length; i++) {
            if (!_items[i].hovered) {
                continue;
            }
            if (topIndex < 0 || isDisplayAbove(_items[i].display, _items[topIndex].display)) {
                topIndex = i;
            }
        }

        _hoveredSprite = topIndex >= 0 ? (_items[topIndex].sprite as IGameSprite) : null;

        for (i = 0; i < _items.length; i++) {
            var item:Object     = _items[i];
            var sp:IGameSprite = item.sprite as IGameSprite;
            var fill:Boolean   = i == topIndex || (_trackedSprite != null && sp == _trackedSprite);
            drawWireframe(item.color, item.area as Rectangle, fill);
        }
    }

    /**
     * 判断 <code>a</code> 在 <code>_gameLayer</code> 下是否比 <code>b</code> 更靠上。
     * @param a 显示对象 A。
     * @param b 显示对象 B。
     * @return A 更靠上时为 <code>true</code>。
     */
    private function isDisplayAbove(a:DisplayObject, b:DisplayObject):Boolean {
        if (!fillChildPath(a, _pathA) || !fillChildPath(b, _pathB)) {
            return false;
        }

        var n:int = _pathA.length < _pathB.length ? _pathA.length : _pathB.length;
        for (var i:int = 0; i < n; i++) {
            if (_pathA[i] != _pathB[i]) {
                return _pathA[i] > _pathB[i];
            }
        }

        // 公共前缀相同：更深的子节点视为更靠上（位于祖先内部）
        return _pathA.length > _pathB.length;
    }

    /**
     * 填写从 <code>_gameLayer</code> 到目标的子索引路径。
     * @param d 目标显示对象。
     * @param path 输出路径（从根到叶）。
     * @return 成功写入为 <code>true</code>。
     */
    private function fillChildPath(d:DisplayObject, path:Vector.<int>):Boolean {
        path.length = 0;
        var node:DisplayObject = d;
        while (node && node != _gameLayer) {
            var p:DisplayObjectContainer = node.parent as DisplayObjectContainer;
            if (!p) {
                return false;
            }
            path.unshift(p.getChildIndex(node));
            node = p;
        }

        return node == _gameLayer;
    }

    /**
     * 绘制线框；悬停或跟踪锁定时同色半透明填充。
     * @param color 线/填充色。
     * @param rect 世界/图层坐标矩形。
     * @param fill 是否填充。
     */
    private function drawWireframe(color:uint, rect:Rectangle, fill:Boolean):void {
        var g:Graphics = _overlay.graphics;
        g.lineStyle(LINE_THICKNESS, color, DRAW_ALPHA);
        if (fill) {
            g.beginFill(color, DRAW_ALPHA);
        }
        g.drawRect(rect.x, rect.y, rect.width, rect.height);
        if (fill) {
            g.endFill();
        }
    }

    /**
     * 从显示列表移除叠加层并清空引用。
     */
    private function cleanOverlay():void {
        if (_overlay) {
            if (_overlay.parent) {
                _overlay.parent.removeChild(_overlay);
            }
            _overlay.graphics.clear();
            _overlay = null;
        }

        _gameLayer     = null;
        _hoveredSprite = null;
        _items.length  = 0;
    }
}
}
