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
import net.play5d.game.bvn.interfaces.IInstanceVO;

/**
 * 一层可踩的地面线段。
 *
 * <p><code>hitTest</code> 用开区间：横坐标在 <code>xFrom</code> 和 <code>xTo</code> 之间，纵坐标在 <code>y</code> 上下各一个 <code>SPEED</code> 之间。端点本身不算踩中。容差为负时纵向区间是空的，结果为 false。克隆由包含进来的 <code>clone</code> 提供。</p>
 *
 * @see net.play5d.game.bvn.interfaces.IInstanceVO
 */
public class FloorVO implements IInstanceVO {

    include '../../../../../../include/Clone.as';

    /**
     * 地面高度。
     *
     * @default 0
     */
    public var y:Number     = 0;
    /**
     * 线段左端，不含该点。
     *
     * @default 0
     */
    public var xFrom:Number = 0;
    /**
     * 线段右端，不含该点。
     *
     * @default 0
     */
    public var xTo:Number   = 0;


    /**
     * 拼成 <code>FloorVO::{xFrom:…,xTo:…,y:…}</code>。
     *
     * @return 这段文字。
     * @example
     * <listing version="3.0">
     * var text:String = floor.toString();
     * </listing>
     */
    public function toString():String {
        return 'FloorVO::{xFrom:' + xFrom + ',xTo:' + xTo + ',y:' + y + '}';
    }

    /**
     * 点是否落在这条地面的开区间里。
     *
     * @param X 横坐标。
     * @param Y 纵坐标。
     * @param SPEED 纵向容差。负值时结果为 false。
     * @return 落在区间内时为 true。
     * @example
     * <listing version="3.0">
     * var on:Boolean = floor.hitTest(x, y, speed);
     * </listing>
     */
    public function hitTest(X:Number, Y:Number, SPEED:Number):Boolean {
        //SPEED = 5
        return Y > y - SPEED && Y < y + SPEED && X > xFrom && X < xTo;
    }

}
}
