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

public class MusouWorldMapAreaVO implements IInstanceVO {
    include '../../../../../../../include/_INCLUDE_.as';
    include '../../../../../../../include/Clone.as';

    public function MusouWorldMapAreaVO() {
    }
    public var id:String;
    public var name:String;
    public var missions:Vector.<MusouMissionVO>;
    public var preOpens:Vector.<MusouWorldMapAreaVO>;

    // 如果为true，表示当前版本未开放
    public function building():Boolean {
        return !missions || missions.length < 1;
    }

    public function getMission(id:String):MusouMissionVO {
        for (var i:int; i < missions.length; i++) {
            if (missions[i].id == id) {
                return missions[i];
            }
        }
        return null;
    }

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
