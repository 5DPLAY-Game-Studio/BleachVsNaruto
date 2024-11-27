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
import flash.geom.Point;

import net.play5d.game.bvn.interfaces.IInstanceVO;

public class SelectCharListItemVO implements IInstanceVO {
    include '../../../../../../include/_INCLUDE_.as';
    include '../../../../../../include/Clone.as';

    public function SelectCharListItemVO(x:int, y:int, fighterID:String, offset:Point = null) {
        this.x         = x;
        this.y         = y;
        this.fighterID = fighterID;
        this.offset    = offset;
    }
    public var x:int;
    public var y:int;
    public var fighterID:String;
    public var offset:Point;
    public var moreFighterIDs:Array;

    public function getAllFighterIDs():Array {
        var a:Array = [];
        if (fighterID) {
            a.push(fighterID);
        }
        if (moreFighterIDs && moreFighterIDs.length > 0) {
            a = a.concat(moreFighterIDs);
        }
        return a;
    }
}
}
