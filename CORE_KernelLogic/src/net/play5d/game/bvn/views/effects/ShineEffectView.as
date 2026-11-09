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

package net.play5d.game.bvn.views.effects {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.PixelSnapping;
import flash.utils.getTimer;

import net.play5d.game.bvn.GameConfig;

/**
 * 全屏闪光。像素是画面十分之一，显示时拉到整屏。颜色大于 <code>0x7fffff</code> 用加色，否则用变暗，并把透明度乘 0.8。
 *
 * <p>内部透明度按百分数取整后往下减。减到 5 或以下就移除。帧间隔大于 0 时，不是间隔整数倍的调用直接返回。实际耗时超过预计的 1.2 倍时，会把每次减去的量加大。</p>
 */
public class ShineEffectView extends Bitmap {

    private const _skipFrameRate:Number = 1.2;

    /**
     * 创建空位图，像素对齐关闭，平滑关闭。
     */
    public function ShineEffectView() {
        super(null, PixelSnapping.NEVER, false);

    }
    /**
     * 移除时调用，参数是这个闪光。null 时不调用。
     *
     * @default null
     */
    public var onRemove:Function;
    /**
     * 是否还在显示。移除后变成 false。
     *
     * @default true
     */
    public var isActive:Boolean   = true;
    private var _loseAlpha:Number = 1;
    private var _alpha:int;
    private var _renderGap:int    = 0;
    private var _renderFrame:int;
    private var _isDestroyed:Boolean;
    private var _startTimer:int;
    private var _frameTime:int;

    /**
     * 还在显示时先移除并通知，再释放像素。
     *
     * @example
     * <listing version="3.0">
     * shine.destroy();
     * </listing>
     */
    public function destroy():void {
        _isDestroyed = true;
        if (isActive) {
            removeSelf();
        }
        if (bitmapData) {
            bitmapData.dispose();
            bitmapData = null;
        }
    }

    /**
     * 按颜色铺满画面。尺寸没变就填原像素，变了就新建。默认白色、透明度 0.2。
     *
     * @param color 填充色。默认白色。
     * @param alpha 透明度。变暗时会再乘 0.8。默认 0.2。
     * @example
     * <listing version="3.0">
     * shine.init(0xffffff, 0.2);
     * </listing>
     */
    public function init(color:uint = 0xffffff, alpha:Number = 0.2):void {
        var w:int = int(GameConfig.GAME_SIZE.x / 10);
        var h:int = int(GameConfig.GAME_SIZE.y / 10);
        if (!this.bitmapData || this.bitmapData.width != w || this.bitmapData.height != h) {
            if (this.bitmapData) {
                this.bitmapData.dispose();
            }
            this.bitmapData = new BitmapData(w, h, false, color);
        }
        else {
            this.bitmapData.fillRect(this.bitmapData.rect, color);
        }

        this.width  = GameConfig.GAME_SIZE.x;
        this.height = GameConfig.GAME_SIZE.y;

        isActive = true;

        var halfC:uint = 0xffffff >> 1;

        if (color > halfC) {
            this.blendMode = BlendMode.ADD;
        }
        else {
            this.blendMode = BlendMode.DARKEN;
            alpha *= 0.8;
        }

        this.alpha = alpha;
        _alpha     = alpha * 100;

        _renderFrame = 0;
        _renderGap   = Math.ceil(GameConfig.FPS_GAME / GameConfig.FPS_SHINE_EFFECT) - 1;


        _startTimer = 0;
        _loseAlpha  = _renderGap + 1;
        _frameTime  = 1000 / GameConfig.FPS_SHINE_EFFECT;

    }

    /**
     * 按间隔减透明度。已经销毁时直接返回。减到 5 或以下就移除。
     *
     * @example
     * <listing version="3.0">
     * shine.render();
     * </listing>
     */
    public function render():void {
        if (_isDestroyed) {
            return;
        }

        if (_renderGap > 0) {
            _renderFrame++;
            if (_renderFrame % _renderGap != 0) {
                return;
            }
        }

        skipFrame();

        _alpha -= _loseAlpha;
        if (_alpha <= 5) {
            removeSelf();
        }
        else {
            this.alpha = _alpha * .01;
        }
    }

    /**
     * 从父级移除并通知 <code>onRemove</code>。没有父级时吞掉。再调用会再次通知。
     *
     * @example
     * <listing version="3.0">
     * shine.removeSelf();
     * </listing>
     */
    public function removeSelf():void {

        isActive = false;

        if (this.parent) {
            try {
                this.parent.removeChild(this);
            }
            catch (e:Error) {
            }
        }

        if (onRemove != null) {
            onRemove(this);
        }

    }

    //跳帧处理
    private function skipFrame():void {
        if (_startTimer != 0) {
            var frameTime:int = getTimer() - _startTimer;
            var rate:Number   = frameTime / _frameTime;
            if (rate > _skipFrameRate) {
                var la:int = Math.ceil(_loseAlpha * rate);
                if (_loseAlpha < la) {
                    _loseAlpha = la;
                }
            }
        }
        _startTimer = getTimer();
    }

}
}
