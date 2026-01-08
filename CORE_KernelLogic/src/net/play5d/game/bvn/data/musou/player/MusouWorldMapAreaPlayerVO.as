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

public class MusouWorldMapAreaPlayerVO implements ISaveData, IInstanceVO {
    include '../../../../../../../../include/_INCLUDE_.as';
    include '../../../../../../../../include/Clone.as';

    public function MusouWorldMapAreaPlayerVO() {
    }
    public var id:String;

//		public var missions:Vector.<MusouMissionPlayerVO> = new Vector.<MusouMissionPlayerVO>();
    public var name:String;

//		public var isOpen:Boolean;
    private var _passedMissions:Vector.<MusouMissionPlayerVO> = new Vector.<MusouMissionPlayerVO>();

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


    public function getPassedMission(id:String):MusouMissionPlayerVO {
        for (var i:int; i < _passedMissions.length; i++) {
            if (_passedMissions[i].id == id) {
                return _passedMissions[i];
            }
        }
        return null;
    }

    public function getLastPassedMission():MusouMissionPlayerVO {
        if (_passedMissions.length < 1) {
            return null;
        }
        return _passedMissions[_passedMissions.length - 1];
    }

    public function getPassedMissionAmount():int {
        return _passedMissions.length;
    }

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
