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

public class MessionStageVO implements IInstanceVO {
    include '../../../../../../../include/_INCLUDE_.as';
    include '../../../../../../../include/Clone.as';

    public var fighters:Array;
    public var assister:String;
    public var map:String;
    public var mession:MessionVO;
    public var attackRate:Number = 1;
    public var hpRate:Number     = 1;

    public function getFighters():Array {
        //team
        if (mession.gameMode == 0) {
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
