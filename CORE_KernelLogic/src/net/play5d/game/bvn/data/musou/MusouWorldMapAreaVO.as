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
 * 世界地图上的一个区域和它的关卡。
 *
 * <p>没有关卡列表，或列表是空的，<code>building</code> 为 <code>true</code>。
 * 下一关过了最后一关时返回 <code>null</code>。</p>
 *
 * @see MusouMissionVO
 */
public class MusouWorldMapAreaVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 区域 id。
     *
     * @default null
     */
    public var id:String;
    /**
     * 名字。
     *
     * @default null
     */
    public var name:String;
    /**
     * 关卡。还没读区域文件时为 <code>null</code>。
     *
     * @default null
     */
    public var missions:Vector.<MusouMissionVO>;
    /**
     * 开放前要先推进的区域。没有前置时保持 <code>null</code>。
     *
     * @default null
     */
    public var preOpens:Vector.<MusouWorldMapAreaVO>;

    /**
     * 这一版是否还没放关卡。
     *
     * @return 没有关卡时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var locked:Boolean = area.building();
     * </listing>
     */
    public function building():Boolean {
        return !missions || missions.length < 1;
    }

    /**
     * 按 id 取关卡。
     *
     * <p><code>missions</code> 为空时抛错。</p>
     *
     * @param id 关卡 id。
     * @return 关卡。没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var mission:MusouMissionVO = area.getMission(id);
     * </listing>
     */
    public function getMission(id:String):MusouMissionVO {
        for (var i:int; i < missions.length; i++) {
            if (missions[i].id == id) {
                return missions[i];
            }
        }
        return null;
    }

    /**
     * 取这个关卡的下一关。
     *
     * @param id 当前关卡 id。
     * @return 下一关。找不到，或已经是最后一关时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var next:MusouMissionVO = area.getNextMission(id);
     * </listing>
     */
    public function getNextMission(id:String):MusouMissionVO {
        var m:MusouMissionVO = getMission(id);
        if (!m) {
            return null;
        }

        var index:int = missions.indexOf(m);
        if (index == -1) {
            return null;
        }

        if (index + 1 > missions.length - 1) {
            return null;
        }

        return missions[index + 1];
    }

}
}
