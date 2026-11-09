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

package net.play5d.game.bvn.data.musou {
import net.play5d.game.bvn.interfaces.IInstanceVO;

/**
 * 一局无双的 KO 数和剩余时间。
 *
 * <p>构造时会打一条日志。</p>
 */
public class MusouGameRunDataVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 构造并打一条日志。
     *
     * @example
     * <listing version="3.0">
     * var data:MusouGameRunDataVO = new MusouGameRunDataVO();
     * </listing>
     */
    public function MusouGameRunDataVO() {
        TraceLang('musou_game_run_data_vo.main');
    }

    /**
     * KO 数。
     *
     * @default 0
     */
    public var koNum:int = 0;
    /**
     * 剩余时间，单位是动作帧。
     *
     * @default 0
     */
    public var gameTime:int;
    /**
     * 时间上限。
     *
     * @default 0
     */
    public var gameTimeMax:int;

}
}
