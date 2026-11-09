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

package net.play5d.game.bvn.data.musou.player {
import net.play5d.game.bvn.interfaces.ISaveData;
import net.play5d.game.bvn.interfaces.IInstanceVO;

/**
 * 玩家在一个区域里的通关记录。
 *
 * <p>第一次通过返回 <code>true</code>，再通过只改星数并返回 <code>false</code>。
 * 最后一条记录是按通过顺序的最后一次，不是 id 最大的那关。
 * 读取时没有 <code>missions</code> 会把已有记录清掉。</p>
 *
 * @see MusouMissionPlayerVO
 */
public class MusouWorldMapAreaPlayerVO implements ISaveData, IInstanceVO {

    include '../../../../../../../../include/Clone.as';

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

    /** @private */
    private var _passedMissions:Vector.<MusouMissionPlayerVO> = new Vector.<MusouMissionPlayerVO>();

    /**
     * 记下通关并写上星数。
     *
     * @param missionId 关卡 id。
     * @param starts 星数。默认 1。已通过时也会覆盖原来的星数。
     * @return 这次是不是第一次通过。
     * @example
     * <listing version="3.0">
     * var first:Boolean = area.passMission(id, 1);
     * </listing>
     */
    public function passMission(missionId:String, starts:int = 1):Boolean {
        var isNewPassed:Boolean = false;

        var mv:MusouMissionPlayerVO = getPassedMission(missionId);
        if (!mv) {
            isNewPassed = true;
            mv          = new MusouMissionPlayerVO();
            mv.id       = missionId;
            _passedMissions.push(mv);
        }

        mv.stars = starts;

        return isNewPassed;
    }


    /**
     * 按关卡 id 取通关记录。
     *
     * @param id 关卡 id。
     * @return 记录。没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var passed:MusouMissionPlayerVO = area.getPassedMission(id);
     * </listing>
     */
    public function getPassedMission(id:String):MusouMissionPlayerVO {
        for (var i:int; i < _passedMissions.length; i++) {
            if (_passedMissions[i].id == id) {
                return _passedMissions[i];
            }
        }
        return null;
    }

    /**
     * 最后一次通过的关卡。
     *
     * @return 记录。还没通过时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var last:MusouMissionPlayerVO = area.getLastPassedMission();
     * </listing>
     */
    public function getLastPassedMission():MusouMissionPlayerVO {
        if (_passedMissions.length < 1) {
            return null;
        }
        return _passedMissions[_passedMissions.length - 1];
    }

    /**
     * 已通过的关卡数。
     *
     * @return 数量。
     * @example
     * <listing version="3.0">
     * var n:int = area.getPassedMissionAmount();
     * </listing>
     */
    public function getPassedMissionAmount():int {
        return _passedMissions.length;
    }

    /**
     * 存区域 id、名字和通关列表。
     *
     * @return 存档对象。
     * @example
     * <listing version="3.0">
     * var o:Object = area.toSaveObj();
     * </listing>
     */
    public function toSaveObj():Object {
        var o:Object = {};
        o.id         = id;
        o.name       = name;

        o.missions = [];
        for (var i:int; i < _passedMissions.length; i++) {
            o.missions.push(_passedMissions[i].toSaveObj());
        }
        return o;
    }

    /**
     * 读区域和通关列表。
     *
     * <p>对象为空时抛错。没有 <code>missions</code> 时通关列表变成空的。</p>
     *
     * @param o 存档对象。
     * @example
     * <listing version="3.0">
     * area.readSaveObj(o);
     * </listing>
     */
    public function readSaveObj(o:Object):void {
        id   = o.id;
        name = o.name;

        _passedMissions = new Vector.<MusouMissionPlayerVO>();
        if (o.missions) {
            for (var i:int; i < o.missions.length; i++) {
                var mv:MusouMissionPlayerVO = new MusouMissionPlayerVO();
                mv.readSaveObj(o.missions[i]);
                _passedMissions.push(mv);
            }
        }

    }
}
}
