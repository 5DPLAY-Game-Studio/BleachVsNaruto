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

public class MosouWorldMapVO implements IInstanceVO {
    include '../../../../../../../include/_INCLUDE_.as';
    include '../../../../../../../include/Clone.as';

    public function MosouWorldMapVO() {
    }
    public var id:String;
    public var name:String;
    public var areas:Vector.<MusouWorldMapAreaVO>;
    private var _areaMap:Object;

    public function initWay(way:Array):void {
        areas    = new Vector.<MusouWorldMapAreaVO>();
        _areaMap = {};

        var i:int, w:Object, mv:MusouWorldMapAreaVO;

        for (i = 0; i < way.length; i++) {
            w     = way[i];
            mv    = new MusouWorldMapAreaVO();
            mv.id = w.P;

            areas.push(mv);
            _areaMap[mv.id] = mv;
        }

        for (i = 0; i < way.length; i++) {
            w  = way[i];
            mv = _areaMap[w.P];

            if (!mv || !w.N) {
                continue;
            }

            mv.preOpens = new Vector.<MusouWorldMapAreaVO>();

            if (w.N is Array) {
                for each(var id:String in w.N) {
                    if (_areaMap[id]) {
                        mv.preOpens.push(_areaMap[id]);
                    }
                }
            }
            else {
                if (_areaMap[w.N]) {
                    mv.preOpens.push(_areaMap[w.N]);
                }
            }

        }
    }

    public function getArea(aid:String):MusouWorldMapAreaVO {
        return _areaMap[aid];
    }

}
}
