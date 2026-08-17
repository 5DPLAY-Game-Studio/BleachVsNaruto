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

package net.play5d.game.bvn.ctrler.effect {
import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.stage.GameStage;

/**
 * 慢镜 / 背景模糊域。
 *
 * <p>同时托管特效动画刷新间隔（慢放时拉大 gap）。</p>
 *
 * @see EffectCtrl
 */
public class EffectSlowHandler {

    /**
     * 是否允许背景模糊。
     */
    public var bgBlurEnabled:Boolean = true;

    /** @private */
    private var _gameStage:GameStage;
    /** @private */
    private var _slowDownFrame:int;
    /** @private */
    private var _blurFrame:int;
    /** @private */
    private var _renderAnimateGap:int   = 0;
    /** @private */
    private var _renderAnimateFrame:int = 0;

    /**
     * 绑定舞台并重置动画间隔。
     *
     * @param gameStage 游戏主舞台。
     * @example
     * <listing version="3.0">
     * handler.initialize(stage);
     * </listing>
     */
    public function initialize(gameStage:GameStage):void {
        _gameStage = gameStage;
        resetAnimateGap();
    }

    /**
     * 释放舞台引用。
     *
     * @example
     * <listing version="3.0">
     * handler.destroy();
     * </listing>
     */
    public function destroy():void {
        _gameStage = null;
    }

    /**
     * 恢复默认动画刷新间隔。
     *
     * @example
     * <listing version="3.0">
     * handler.resetAnimateGap();
     * </listing>
     */
    public function resetAnimateGap():void {
        _renderAnimateGap   = Math.ceil(GameConfig.FPS_GAME / GameConfig.FPS_ANIMATE) - 1;
        _renderAnimateFrame = 0;
    }

    /**
     * 本逻辑帧是否应推进特效动画。
     *
     * @return 应刷新为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (handler.isRenderAnimate()) {
     *     // ...
     * }
     * </listing>
     */
    public function isRenderAnimate():Boolean {
        if (_renderAnimateGap > 0) {
            if (_renderAnimateFrame++ >= _renderAnimateGap) {
                _renderAnimateFrame = 0;
                return true;
            }
            else {
                return false;
            }
        }
        return true;
    }

    /**
     * 慢放效果。
     *
     * @param rate 慢放倍率。
     * @param time 持续毫秒；0 表示不自动恢复。
     * @example
     * <listing version="3.0">
     * handler.slowDown(1.5, 1000);
     * </listing>
     */
    public function slowDown(rate:Number, time:int = 1000):void {
        if (GameCtrl.I.slowRate > rate) {
            return;
        }

        GameCtrl.I.slow(rate);
        bgBlur(rate * 2, 0, 250);
        _renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / (
                                      GameConfig.FPS_ANIMATE / rate
        )) - 1;
        if (time == 0) {
            _slowDownFrame = 0;
        }
        else {
            _slowDownFrame = time * 0.001 * GameConfig.FPS_GAME;
        }
    }

    /**
     * 背景模糊。
     *
     * @param blurX X 模糊。
     * @param blurY Y 模糊。
     * @param time 持续毫秒。
     * @example
     * <listing version="3.0">
     * handler.bgBlur(4, 0, 500);
     * </listing>
     */
    public function bgBlur(blurX:Number, blurY:Number, time:int = 1000):void {
        if (!EffectCtrl.BG_BULR_ENABLED) {
            return;
        }
        if (!bgBlurEnabled) {
            return;
        }
        if (_gameStage.getMap().getSmoothing().x > blurX || _gameStage.getMap().getSmoothing().y > 0) {
            return;
        }
        _gameStage.getMap().setSmoothing(blurX, blurY);
        _blurFrame = time * 0.001 * GameConfig.FPS_ANIMATE;
    }

    /**
     * 取消背景模糊。
     *
     * @example
     * <listing version="3.0">
     * handler.cancelBgBlur();
     * </listing>
     */
    public function cancelBgBlur():void {
        _blurFrame = 0;
        _gameStage.getMap().setSmoothing(0, 0);
    }

    /**
     * 立即恢复慢放。
     *
     * @example
     * <listing version="3.0">
     * handler.slowDownResume();
     * </listing>
     */
    public function slowDownResume():void {
        GameCtrl.I.slowResume();
        resetAnimateGap();
        _slowDownFrame = 0;
    }

    /**
     * 逻辑帧：慢放倒计时。
     *
     * @example
     * <listing version="3.0">
     * handler.render();
     * </listing>
     */
    public function render():void {
        if (_slowDownFrame > 0) {
            _slowDownFrame--;
            if (_slowDownFrame <= 0) {
                slowDownResume();
            }
        }
    }

    /**
     * 动画帧：背景模糊倒计时。
     *
     * @example
     * <listing version="3.0">
     * handler.renderAnimate();
     * </listing>
     */
    public function renderAnimate():void {
        if (_blurFrame > 0) {
            if (--_blurFrame <= 0) {
                cancelBgBlur();
            }
        }
    }
}
}
