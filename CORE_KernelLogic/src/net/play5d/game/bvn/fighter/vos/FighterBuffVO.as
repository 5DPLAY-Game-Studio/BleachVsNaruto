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
import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.interfaces.IInstanceVO;

/**
 * 一条限时 buff。时间按秒换算成逻辑帧。
 *
 * <p>已经结束时，<code>render</code> 一直返回 <code>true</code>，不再减帧。
 * 持续时间不大于 0 时，第一次 <code>render</code> 就结束。</p>
 *
 * @see FighterBuffCtrler
 */
public class FighterBuffVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 记下参数名，并把秒数换成逻辑帧。结束标记写成 <code>false</code>。
     *
     * @param param 要改的角色字段名。
     * @param hold 持续秒数。默认 1。
     * @example
     * <listing version="3.0">
     * var buff:FighterBuffVO = new FighterBuffVO('speed', 5);
     * </listing>
     */
    public function FighterBuffVO(param:String, hold:Number = 1) {
        this.param      = param;
        this._holdFrame = hold * GameConfig.FPS_GAME;
        this.finished   = false;
    }
    /**
     * 角色上的字段名。
     *
     * @default null
     */
    public var param:String;
    /**
     * 到期后写回的原值。
     *
     * @default 0
     */
    public var resumeValue:Number = 0;
    /**
     * 是否已经结束。
     *
     * @default false
     */
    public var finished:Boolean   = false;
    /** @private */
    private var _holdFrame:Number = 1;

    /**
     * 按新的秒数重算剩余帧，并把结束标记清掉。
     *
     * @param v 持续秒数。
     * @example
     * <listing version="3.0">
     * buff.setHold(3);
     * </listing>
     */
    public function setHold(v:Number):void {
        this._holdFrame = v * GameConfig.FPS_GAME;
        this.finished   = false;
    }

    /**
     * 走一帧。结束时返回 <code>true</code>。
     *
     * @return 这一帧已经结束时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var done:Boolean = buff.render();
     * </listing>
     */
    public function render():Boolean {

        if (finished) {
            return true;
        }

        if (--_holdFrame <= 0) {
            finished = true;
            return true;
        }
        return false;
    }

}
}
