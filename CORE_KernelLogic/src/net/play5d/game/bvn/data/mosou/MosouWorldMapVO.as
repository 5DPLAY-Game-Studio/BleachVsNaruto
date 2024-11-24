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

package net.play5d.game.bvn.data.mosou {

public class MosouWorldMapVO {
    include '../../../../../../../include/_INCLUDE_.as';

    public function MosouWorldMapVO() {
    }
    public var id:String;
    public var name:String;
    public var areas:Vector.<MosouWorldMapAreaVO>;
    private var _areaMap:Object;

    public function initWay(way:Array):void {
        areas    = new Vector.<MosouWorldMapAreaVO>();
        _areaMap = {};

        var i:int, w:Object, mv:MosouWorldMapAreaVO;

        for (i = 0; i < way.length; i++) {
            w     = way[i];
            mv    = new MosouWorldMapAreaVO();
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

            mv.preOpens = new Vector.<MosouWorldMapAreaVO>();

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

    public function getArea(aid:String):MosouWorldMapAreaVO {
        return _areaMap[aid];
    }

}
}
