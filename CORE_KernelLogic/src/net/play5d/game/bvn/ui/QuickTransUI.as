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

package net.play5d.game.bvn.ui {
import com.greensock.TweenLite;

import flash.display.Sprite;

import net.play5d.game.bvn.GameConfig;
import net.play5d.kyo.display.shapes.Box;

/**
 * 上下两块遮罩的短转场。每段 0.1 秒，完成回调挂在下面那块上。
 */
public class QuickTransUI extends Sprite {

    /**
     * 按当前画面高度各建半屏遮罩。
     */
    public function QuickTransUI() {
        super();

        _center = GameConfig.GAME_SIZE.y / 2;

        _up   = new Box(GameConfig.GAME_SIZE.x, _center);
        _down = new Box(GameConfig.GAME_SIZE.x, _center);

        addChild(_up);
        addChild(_down);
    }
    private var _up:Box;
    private var _down:Box;
    private var _center:Number = 0;

    /**
     * 先合上再打开。回调在打开结束时调用。
     *
     * @param back 完成回调。默认 null。
     * @example
     * <listing version="3.0">
     * trans.fadeInAndOut(onDone);
     * </listing>
     */
    public function fadeInAndOut(back:Function = null):void {
        fadeIn(function ():void {
            fadeOut(back);
        });
    }

    /**
     * 两块遮罩在 0.1 秒内合到画面中间。
     *
     * @param back 下面那块到位后调用。默认 null。
     * @example
     * <listing version="3.0">
     * trans.fadeIn(onClosed);
     * </listing>
     */
    public function fadeIn(back:Function = null):void {
        _up.y   = -_center;
        _down.y = GameConfig.GAME_SIZE.y;

        TweenLite.to(_up, 0.1, {y: 0});
        TweenLite.to(_down, 0.1, {y: _center, onComplete: back});
    }

    /**
     * 两块遮罩在 0.1 秒内退出画面。
     *
     * @param back 下面那块到位后调用。默认 null。
     * @example
     * <listing version="3.0">
     * trans.fadeOut(onOpen);
     * </listing>
     */
    public function fadeOut(back:Function = null):void {
        TweenLite.to(_up, 0.1, {y: -_center});
        TweenLite.to(_down, 0.1, {y: GameConfig.GAME_SIZE.y, onComplete: back});
    }


}
}
