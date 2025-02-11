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

public class ShineEffectView extends Bitmap {
    include '../../../../../../../include/_INCLUDE_.as';

//		private static var _source:BitmapData = new BitmapData(GameConfig.GAME_SIZE.x / 10 , GameConfig.GAME_SIZE.y /
// 10,false,0xffffff);

    private const _skipFrameRate:Number = 1.2;

    public function ShineEffectView() {
        super(null, PixelSnapping.NEVER, false);

//			width = GameConfig.GAME_SIZE.x;
//			height = GameConfig.GAME_SIZE.y;


    }
    public var onRemove:Function;
    public var isActive:Boolean = true;
    private var _loseAlpha:Number = 1;
    private var _alpha:int;
    private var _renderGap:int = 0;
    private var _renderFrame:int;
    private var _isDestoryed:Boolean;
    private var _startTimer:int;
    private var _frameTime:int;

    public function destory():void {
        _isDestoryed = true;
        if (isActive) {
            removeSelf();
        }
    }

    public function init(color:uint = 0xffffff, alpha:Number = 0.2):void {

        if (this.bitmapData) {
            this.bitmapData.dispose();
            this.bitmapData = null;
        }

        this.bitmapData = new BitmapData(GameConfig.GAME_SIZE.x / 10, GameConfig.GAME_SIZE.y / 10, false, color);
        this.width      = GameConfig.GAME_SIZE.x;
        this.height     = GameConfig.GAME_SIZE.y;

//			this.transform.colorTransform.color = color;
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

    public function render():void {
        if (_isDestoryed) {
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

    public function removeSelf():void {

        isActive = false;

        if (bitmapData) {
            bitmapData.dispose();
            bitmapData = null;
        }

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
//			trace('skip' , _loseAlpha);
        _startTimer = getTimer();
    }

}
}
