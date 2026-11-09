/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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

package net.play5d.game.bvn.data.vos {
import net.play5d.game.bvn.interfaces.IInstanceVO;
import net.play5d.kyo.utils.KyoRandom;

/**
 * 一关里的角色、援助、地图和倍率。
 *
 * <p>组队取人时不足 3 个会用 <code>null</code> 补满，多于 3 个不会截断。单人是从列表里随机一个。</p>
 *
 * @see MissionVO
 */
public class MissionStageVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 本关角色 id。
     *
     * @default null
     */
    public var fighters:Array;
    /**
     * 援助 id。
     *
     * @default null
     */
    public var assister:String;
    /**
     * 地图 id。
     *
     * @default null
     */
    public var map:String;
    /**
     * 所属关卡。
     *
     * @default null
     */
    public var mission:MissionVO;
    /**
     * 攻击倍率。
     *
     * @default 1
     */
    public var attackRate:Number = 1;
    /**
     * 体力倍率。
     *
     * @default 1
     */
    public var hpRate:Number     = 1;

    /**
     * 按模式取出本关要上场的角色 id。
     *
     * <p>所属关卡为空时抛错。</p>
     *
     * @return 角色 id。组队长度为 3。
     * @example
     * <listing version="3.0">
     * var ids:Array = stage.getFighters();
     * </listing>
     */
    public function getFighters():Array {
        //team
        if (mission.gameMode == 0) {
            var a:Array    = [];
            a              = a.concat(fighters);
            var addlen:int = 3 - a.length;
            if (addlen > 0) {
                for (var i:int; i < addlen; i++) {
                    a.push(null);
                }
            }
            return a;
        }
        else {
            return [KyoRandom.getRandomInArray(fighters)];
        }
    }
}
}
