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

package net.play5d.game.bvn.ui.big_map {
import flash.display.Sprite;
import flash.geom.Rectangle;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.utils.GameLogger;

/**
 * 大地图上的云层。横坐标或纵坐标传 0 时会被当成没传，改成随机横坐标或边界下方。同一帧里删掉飘走的云时，下一朵可能被跳过。销毁后再渲染会抛错。
 */
public class BigmapCloud extends Sprite {

    /**
     * 记下云的活动范围，并关掉鼠标。
     *
     * @param bounds 范围。null 时，初始化和渲染会抛错。
     */
    public function BigmapCloud(bounds:Rectangle) {
        super();
        _bounds       = bounds;
        mouseChildren = mouseEnabled = false;
    }
    private var _clouds:Vector.<CloudView> = new Vector.<CloudView>();
    private var _createFrame:int;
    private var _bounds:Rectangle;

    /**
     * 从范围上沿往下，每隔 50 放一朵云。范围为空时一朵都不放。
     *
     * @throws TypeError 范围缺失时。
     * @example
     * <listing version="3.0">
     * clouds.init();
     * </listing>
     */
    public function init():void {
        for (var i:int = _bounds.y + 100; i < _bounds.height; i += 50) {
            addCloud(getRandomX(), i);
        }
    }

    /**
     * 摘掉云。移除失败只吞掉。之后渲染会抛错。
     *
     * @example
     * <listing version="3.0">
     * clouds.destroy();
     * </listing>
     */
    public function destroy():void {
        if (_clouds) {
            for each(var i:CloudView in _clouds) {
                try {
                    this.removeChild(i.mc);
                }
                catch (e:Error) {
                }
            }
            _clouds = null;
        }
    }

    /**
     * 上移云，并按界面帧率大约每 5 秒补一朵。第一帧就会补。销毁后抛错。
     *
     * @throws TypeError 已经销毁时。
     * @example
     * <listing version="3.0">
     * clouds.render();
     * </listing>
     */
    public function render():void {
        for each(var i:CloudView in _clouds) {
            if (i.render()) {
                try {
                    GameLogger.debug('ui', 'remove cloud');
                    var index:int = _clouds.indexOf(i);
                    if (index != -1) {
                        _clouds.splice(_clouds.indexOf(i), 1);
                    }
                    this.removeChild(i.mc);
                }
                catch (e:Error) {
                    GameLogger.error('ui', 'BigmapCloud ' + e);
                }
            }
        }

        if (--_createFrame < 0) {
            addCloud();
            _createFrame = 5 * GameConfig.FPS_UI;
        }
    }

    private function addCloud(X:Number = 0, Y:Number = 0):void {
        if (X == 0) {
            X = getRandomX();
        }
        if (Y == 0) {
            Y = _bounds.y + _bounds.height + 100;
        }

        var v:CloudView = new CloudView(X, Y);
        this.addChild(v.mc);
        _clouds.push(v);
    }

    private function getRandomX():Number {
        return _bounds.x + (
                (
                        _bounds.width / 20
                ) * (
                Math.random() * 20
                )
        ) - 100;
    }

}
}
