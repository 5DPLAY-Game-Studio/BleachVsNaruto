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

package net.play5d.game.bvn.fighter.vos {
import flash.geom.Point;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.interfaces.IInstanceVO;

/**
 * 把目标移到指定点，或跟着某个元件走。
 *
 * <p>没传参数时坐标保持 <code>NaN</code>，速度保持 <code>null</code>。
 * 速度为 0、空，或没写时也保持 <code>null</code>，调用方会直接放到目标点。
 * 速度是一个数字时，横向和纵向都用这个数字乘上当前速度倍率。
 * <code>clear</code> 只把角色的重力开关打开，不清掉目标。</p>
 */
public class MoveTargetParamVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 从参数对象读坐标、跟随元件和速度。
     *
     * <p><code>params</code> 为空时什么都不写。缺的坐标写成 0。缺的跟随名写成 <code>null</code>。</p>
     *
     * @param params 含 <code>x</code>、<code>y</code>、<code>followmc</code>、<code>speed</code> 的对象。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var move:MoveTargetParamVO = new MoveTargetParamVO({x: 10, y: 0, speed: 2});
     * </listing>
     */
    public function MoveTargetParamVO(params:Object = null) {
        if (!params) {
            return;
        }

        x            = params.x != undefined ? params.x : 0;
        y            = params.y != undefined ? params.y : 0;
        followMcName = params.followmc != undefined ? params.followmc : null;

        if (params.speed) {
            speed = new Point();
            if (params.speed is Number) {
                speed.x = speed.y = params.speed * GameConfig.SPEED_PLUS;
            }
            else {
                speed.x = params.speed.x != undefined ? params.speed.x * GameConfig.SPEED_PLUS : 0;
                speed.y = params.speed.y != undefined ? params.speed.y * GameConfig.SPEED_PLUS : 0;
            }
        }

    }
    /**
     * 目标横坐标。没初始化时为 <code>NaN</code>。
     *
     * @default NaN
     */
    public var x:Number;
    /**
     * 目标纵坐标。没初始化时为 <code>NaN</code>。
     *
     * @default NaN
     */
    public var y:Number;
    /**
     * 要跟随的元件名。
     *
     * @default null
     */
    public var followMcName:String;
    /**
     * 被移动的对象。
     *
     * @default null
     */
    public var target:IGameSprite;
    /**
     * 每帧速度。为 <code>null</code> 时直接放到目标点。
     *
     * @default null
     */
    public var speed:Point;

    /**
     * 记下目标。目标是角色时把速度清成 0。
     *
     * @param v 被移动的对象。可以是 <code>null</code>。
     * @example
     * <listing version="3.0">
     * move.setTarget(fighter);
     * </listing>
     */
    public function setTarget(v:IGameSprite):void {
        target = v;
        if (target is BaseGameSprite) {
            (
                    target as BaseGameSprite
            ).setVelocity(0, 0);
        }
    }

    /**
     * 目标是角色时重新打开重力。目标引用还留着。
     *
     * @example
     * <listing version="3.0">
     * move.clear();
     * </listing>
     */
    public function clear():void {
        if (target) {
            if (target is BaseGameSprite) {
                (
                        target as BaseGameSprite
                ).isApplyG = true;
            }
        }
    }

}
}
