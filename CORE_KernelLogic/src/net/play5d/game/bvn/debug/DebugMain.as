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
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Rectangle;

import net.play5d.game.bvn.ctrler.GameRender;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.fighter.Assister;
import net.play5d.game.bvn.fighter.Bullet;
import net.play5d.game.bvn.fighter.FighterAttacker;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.ctrler.FighterCtrler;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.utils.MCUtils;
import net.play5d.kyo.utils.KyoColor;

/**
 * 判定面调试叠加层。
 *
 * <p>开启后在游戏图层顶部用单个 <code>Shape</code> 绘制被打面、攻击面与判定面，
 * 每帧清屏重绘，避免反复创建子显示对象。</p>
 *
 * @example
 * <listing version="3.0">
 * DebugMain.I.initialize();
 * DebugMain.I.isRender = true;
 * </listing>
 * @see #initialize()
 * @see #isRender
 */
public class DebugMain {
    /** @private */
    private static var _i:DebugMain;

    /**
     * 单例。
     * @return 全局实例。
     */
    public static function get I():DebugMain {
        if (!_i) {
            _i = new DebugMain();
        }

        return _i;
    }

    /** @private 面填充透明度 */
    private static const FILL_ALPHA:Number = 0.33;

    /**
     * 是否绘制判定面。
     * @default false
     */
    public var isRender:Boolean = false;

    /** @private 是否已注册渲染回调 */
    private var _isInitialized:Boolean;
    /** @private 当前游戏图层 */
    private var _gameLayer:Sprite;
    /** @private 叠加绘制层（单 Shape） */
    private var _overlay:Shape;

    /**
     * 注册帧后渲染回调（幂等）。
     * @example
     * <listing version="3.0">
     * DebugMain.I.initialize();
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
     * 每帧：关闭时卸层；开启时确保叠加层并重绘全部面。
     */
    private function render():void {
        if (!isRender) {
            if (_overlay) {
                cleanOverlay();
            }

            return;
        }

        if (!GameCtrl.I.gameState) {
            return;
        }

        if (!P1 || !P2) {
            cleanOverlay();

            return;
        }

        if (!ensureOverlay()) {
            return;
        }

        _overlay.graphics.clear();
        renderAllMain();
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

        // 场景切换后图层引用失效，需重建挂载
        if (_gameLayer != layer) {
            cleanOverlay();
            _gameLayer = layer;
        }

        if (!_overlay) {
            _overlay      = new Shape();
            _overlay.name = 'debugHitOverlay';
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
     * 绘制本帧全部判定相关矩形。
     */
    private function renderAllMain():void {
        renderFighterMain(P1);
        renderFighterMain(P2);
        MCUtils.renderGameSpritesCB(onGameSprite);
    }

    /**
     * 遍历游戏精灵时的绘制回调。
     * @param sp 当前精灵。
     */
    private function onGameSprite(sp:IGameSprite):void {
        if (!sp) {
            return;
        }

        if (sp is Assister || sp is Bullet || sp is FighterAttacker) {
            renderHitMain(sp.getCurrentHits());
        }

        if (sp is Assister) {
            var assist:Assister = sp as Assister;
            var aChecker:String = assist.getCtrler().hitTargetChecker;
            if (aChecker) {
                renderCheckerArea(assist.getHitCheckRect(aChecker));
            }
        }
        else if (sp is FighterAttacker) {
            var attacker:FighterAttacker = sp as FighterAttacker;
            var tChecker:String          = attacker.getCtrler().hitTargetChecker;
            if (tChecker) {
                renderCheckerArea(attacker.getHitCheckRect(tChecker));
            }
        }
    }

    /**
     * 绘制攻击面列表。
     * @param hitVOs 攻击值对象数组。
     */
    private function renderHitMain(hitVOs:Array):void {
        if (!hitVOs || hitVOs.length == 0) {
            return;
        }

        for each (var hitVO:HitVO in hitVOs) {
            var hitArea:Rectangle = hitVO.currentArea;
            if (hitArea && !hitArea.isEmpty()) {
                drawArea(KyoColor.RED, hitArea);
            }
        }
    }

    /**
     * 绘制角色被打面、攻击面与判定面。
     * @param fighter 目标角色。
     */
    private function renderFighterMain(fighter:FighterMain):void {
        if (!fighter) {
            return;
        }

        var bodyArea:Rectangle = fighter.getBodyArea();
        if (bodyArea && !bodyArea.isEmpty()) {
            drawArea(KyoColor.LIME, bodyArea);
        }

        renderHitMain(fighter.getCurrentHits());

        var ctrler:FighterCtrler = fighter.getCtrler();
        var checker:String       = ctrler.getMcCtrl().getAction().hitTargetChecker;
        if (checker) {
            renderCheckerArea(ctrler.getHitCheckRect(checker));
        }
    }

    /**
     * 绘制判定面矩形。
     * @param area 判定区域；空则跳过。
     */
    private function renderCheckerArea(area:Rectangle):void {
        if (area && !area.isEmpty()) {
            drawArea(KyoColor.YELLOW, area);
        }
    }

    /**
     * 在叠加层上绘制半透明矩形。
     * @param color 填充色。
     * @param rect 世界/图层坐标矩形。
     */
    private function drawArea(color:uint, rect:Rectangle):void {
        var g:Graphics = _overlay.graphics;
        g.beginFill(color, FILL_ALPHA);
        g.drawRect(rect.x, rect.y, rect.width, rect.height);
        g.endFill();
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

        _gameLayer = null;
    }
}
}
