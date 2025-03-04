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

package net.play5d.game.bvn.data {
import net.play5d.game.bvn.data.vos.TeamVO;

public class TeamMap {
    include '../../../../../../include/_INCLUDE_.as';

    public function TeamMap() {
    }
    public var teams:Vector.<TeamVO> = new Vector.<TeamVO>();
    private var _teamObj:Object      = {};

    public function clear():void {
        _teamObj = {};
    }

    public function getTeam(id:int):TeamVO {
        return _teamObj[id];
    }

    public function getOtherTeams(id:int):Vector.<TeamVO> {
        var teams:Vector.<TeamVO> = new Vector.<TeamVO>();
        for each(var i:TeamVO in _teamObj) {
            if (i.id != id) {
                teams.push(i);
            }
        }
        return teams;
    }

    public function add(v:TeamVO):void {
        _teamObj[v.id] = v;
        refreshTeams();
    }

    public function remove(v:TeamVO):void {
        delete _teamObj[v.id];
        refreshTeams();
    }

    private function refreshTeams():void {
        teams = new Vector.<TeamVO>();
        for each(var i:TeamVO in _teamObj) {
            if (i) {
                teams.push(i);
            }
        }
    }

}
}
