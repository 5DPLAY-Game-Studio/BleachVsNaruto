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
import flash.geom.Point;

import net.play5d.game.bvn.interfaces.IInstanceVO;

public class SelectStageConfigVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';


    public var x:Number      = 0;
    public var y:Number      = 0;
    public var width:Number  = 800;
    public var height:Number = 600;
    public var top:Number    = 0;
    public var bottom:Number = 0;
    public var left:Number   = 0;

//		public var itemGap:Point = new Point(10,10);
    public var right:Number = 0;
    public var charList:SelectCharListConfigVO;
    public var assistList:SelectCharListConfigVO;

    //	public var HCount:int; //列数
    //	public var VCount:int; //行数
    public var unitSize:Point = new Point(50, 50);

    /**
     * 通过对象进行初始化
     *
     * @param obj 对象
     */
    public function initByObject(obj:Object):void {
        var layoutObj:Object = obj['stage_setting']['layout'];

        x      = Number(layoutObj['x']);
        y      = Number(layoutObj['y']);
        width  = Number(layoutObj['width']);
        height = Number(layoutObj['height']);

        top    = Number(layoutObj['top']);
        bottom = Number(layoutObj['bottom']);
        left   = Number(layoutObj['left']);
        right  = Number(layoutObj['right']);

        charList   = newListByObject(obj['char_list'] as Array);
        assistList = newListByObject(obj['assist_list'] as Array);
    }

    private function newListByObject(listArr:Array):SelectCharListConfigVO {
        var sv:SelectCharListConfigVO = new SelectCharListConfigVO();

        sv.VCount = listArr.length;

        for (var y:int = 0; y < listArr.length; y++) {
            var row:Object  = listArr[y];
            var items:Array = row['item'] as Array;

            var rowOffset:Point    = null;
            var rowOffsetArr:Array = row['offset'] as Array;
            if (rowOffsetArr && rowOffsetArr.length >= 2) {
                rowOffset = new Point(rowOffsetArr[0], rowOffsetArr[1]);
            }

            if (sv.HCount < items.length) {
                sv.HCount = items.length;
            }

            for (var x:int = 0; x < items.length; x++) {
                var item:Object = items[x];

                var fighterID:String = null;
                var moreIds:Array    = null;
                var offset:Point     = rowOffset ? rowOffset.clone() : null;

                if (item) {
                    if (item['id']) {
                        fighterID = item['id'];
                    }

                    moreIds = item['more_fighter'] as Array;

                    var offsetArr:Array = item['offset'] as Array;
                    if (offsetArr && offsetArr.length >= 2) {
                        if (offset) {
                            offset.x += Number(offsetArr[0]);
                            offset.y += Number(offsetArr[1]);
                        }
                        else {
                            offset = new Point(offsetArr[0], offsetArr[1]);
                        }
                    }
                }

                var cv:SelectCharListItemVO = new SelectCharListItemVO(x, y, fighterID, offset);
                cv.moreFighterIDs           = moreIds;
                sv.list.push(cv);
            }
        }

        return sv;
    }

}
}
