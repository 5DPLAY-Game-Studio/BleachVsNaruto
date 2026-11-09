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

/**
 * 一条闯关：漫画类型、模式和小关列表。
 *
 * <p>攻击或体力倍率没写、写成 0 或负数时，小关保持默认 1。没有 <code>stage</code> 时初始化会抛错。</p>
 *
 * @see MissionStageVO
 */
public class MissionVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 漫画类型。0 为死神，1 为火影。
     *
     * @default 0
     */
    public var comicType:int;
    /**
     * 模式。0 为组队，1 为单人。
     *
     * @default 0
     */
    public var gameMode:int;
    /**
     * 小关列表。
     *
     * @default null
     */
    public var stageList:Vector.<MissionStageVO>;

    /**
     * 用一条关卡记录填写字段。
     *
     * @param obj 含 <code>comic_type</code>、<code>game_mode</code>、<code>stage</code> 的对象。
     * @example
     * <listing version="3.0">
     * vo.initByObject(obj);
     * </listing>
     */
    public function initByObject(obj:Object):void {
        comicType = obj['comic_type'];
        gameMode  = obj['game_mode'];

        stageList = new Vector.<MissionStageVO>();

        var stageArr:Array = obj['stage'];
        for each (var stageObj:Object in stageArr) {
            var msv:MissionStageVO = new MissionStageVO();

            msv.mission  = this;
            msv.fighters = stageObj['fighter'];
            msv.assister = stageObj['assistant'];
            msv.map      = stageObj['map'];

            var propertiesObj:Object = stageObj['properties'];
            if (propertiesObj) {
                if (propertiesObj['attack_rate']) {
                    msv.attackRate =
                            propertiesObj['attack_rate'] > 0
                            ? propertiesObj['attack_rate']
                            : 1;
                }
                if (propertiesObj['hp_rate']) {
                    msv.hpRate =
                            propertiesObj['hp_rate'] > 0
                            ? propertiesObj['hp_rate']
                            : 1;
                }
            }

            stageList.push(msv);
        }
    }

}
}
