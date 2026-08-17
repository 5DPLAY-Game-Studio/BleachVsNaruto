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
import net.play5d.game.bvn.stage.GameStage;

/**
 * 震屏域：持续震与脉冲震。
 *
 * @see EffectCtrl
 */
public class EffectShakeHandler {

    private const SHAKE_POW_MAX:int = 10;

    /** @private */
    private var _gameStage:GameStage;
    /** @private */
    private var _shakeHoldX:int   = 0;
    /** @private */
    private var _shakeHoldY:int   = 0;
    /** @private */
    private var _shakePowX:int    = 0;
    /** @private */
    private var _shakePowY:int    = 0;
    /** @private */
    private var _shakeXDirect:int = 1;
    /** @private */
    private var _shakeYDirect:int = 1;
    /** @private */
    private var _shakeFrameX:int  = 0;
    /** @private */
    private var _shakeFrameY:int  = 0;
    /** @private */
    private var _shakeLoseX:int   = 0;
    /** @private */
    private var _shakeLoseY:int   = 0;

    /**
     * 绑定对局舞台。
     *
     * @param gameStage 游戏主舞台。
     * @example
     * <listing version="3.0">
     * handler.initialize(stage);
     * </listing>
     */
    public function initialize(gameStage:GameStage):void {
        _gameStage = gameStage;
    }

    /**
     * 结束震动并释放舞台引用。
     *
     * @example
     * <listing version="3.0">
     * handler.destroy();
     * </listing>
     */
    public function destroy():void {
        endShake();
        _gameStage = null;
    }

    /**
     * 开始持续震（按帧叠加位移）。
     *
     * @param sx X 向强度。
     * @param sy Y 向强度。
     * @example
     * <listing version="3.0">
     * handler.startShake(2, 0);
     * </listing>
     */
    public function startShake(sx:Number, sy:Number):void {
        _shakeHoldX = sx;
        _shakeHoldY = sy;
    }

    /**
     * 结束震动并复位舞台坐标。
     *
     * @example
     * <listing version="3.0">
     * handler.endShake();
     * </listing>
     */
    public function endShake():void {
        _shakeHoldX = 0;
        _shakeHoldY = 0;
        if (_gameStage) {
            _gameStage.x = 0;
            _gameStage.y = 0;
        }
    }

    /**
     * 脉冲震动。
     *
     * @param powX X 强度。
     * @param powY Y 强度。
     * @param time 衰减时长（毫秒）。
     * @example
     * <listing version="3.0">
     * handler.shake(0, 3, 500);
     * </listing>
     */
    public function shake(powX:Number = 0, powY:Number = 3, time:int = 500):void {
        if (!EffectCtrl.SHAKE_ENABLED) {
            return;
        }

        if (isNaN(powX) || isNaN(powY)) {
            return;
        }

        if (Math.abs(_shakePowX) > Math.abs(powX) || Math.abs(_shakePowY) > Math.abs(powY)) {
            return;
        }

        if (powX != 0) {
            if (_shakePowX == 0) {
                _shakeXDirect = powX > 0 ? 1 : -1;
                _shakePowX    = Math.abs(powX);
            }
            else {
                _shakePowX += Math.abs(powX) * 0.5;
            }

            if (_shakePowX > SHAKE_POW_MAX) {
                _shakePowX = SHAKE_POW_MAX;
            }
        }

        if (powY != 0) {
            if (_shakePowY == 0) {
                _shakeYDirect = powY > 0 ? 1 : -1;
                _shakePowY    = Math.abs(powY);
            }
            else {
                _shakePowY += Math.abs(powY) * 0.5;
            }
            if (_shakePowY > SHAKE_POW_MAX) {
                _shakePowY = SHAKE_POW_MAX;
            }
        }

        if (time <= 0) {
            time = 500;
        }

        var shakeFrames:Number = time * 0.001 * GameConfig.FPS_ANIMATE;
        _shakeLoseX = Math.ceil(_shakePowX / shakeFrames);
        _shakeLoseY = Math.ceil(_shakePowY / shakeFrames);

        if (_shakeLoseX < 1) {
            _shakeLoseX = 1;
        }
        if (_shakeLoseY < 1) {
            _shakeLoseY = 1;
        }
    }

    /**
     * 动画帧：更新 X/Y 震屏。
     *
     * @example
     * <listing version="3.0">
     * handler.renderAnimate();
     * </listing>
     */
    public function renderAnimate():void {
        renderShakeX();
        renderShakeY();
    }

    /** @private */
    private function renderShakeX():void {
        var shakeX:Number = _shakeHoldX + _shakePowX;
        if (shakeX > 0) {
            _gameStage.x = shakeX * _shakeXDirect;
            if (_shakePowX > 0 && _shakeFrameX % 2 == 0) {
                _shakePowX -= _shakeLoseX;
                if (_shakePowX < _shakeLoseX) {
                    _shakePowX   = 0;
                    _gameStage.x = 0;
                    _shakeFrameX = 0;
                    _shakeLoseX  = 0;
                    return;
                }
            }
            _shakeFrameX++;
            _shakeXDirect *= -1;
        }
    }

    /** @private */
    private function renderShakeY():void {
        var shakeY:Number = _shakeHoldY + _shakePowY;
        if (shakeY > 0) {
            _gameStage.y = shakeY * _shakeYDirect;
            if (_shakePowY > 0 && _shakeFrameY % 2 == 0) {
                _shakePowY -= _shakeLoseY;

                if (_shakePowY < _shakeLoseY) {
                    _shakePowY   = 0;
                    _gameStage.y = 0;
                    _shakeFrameY = 0;
                    _shakeLoseY  = 0;
                    return;
                }
            }

            _shakeYDirect *= -1;
            _shakeFrameY++;
        }
    }
}
}
