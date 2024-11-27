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

public class SelectStageConfigVO implements IInstanceVO {
    include '../../../../../../include/_INCLUDE_.as';
    include '../../../../../../include/Clone.as';

    public function SelectStageConfigVO() {
    }
    public var x:Number      = 0;
    public var y:Number      = 0;
    public var width:Number  = 800;
    public var height:Number = 600;
    public var top:Number    = 0;
    public var bottom:Number = 0;
    public var left:Number   = 0;

//		public var itemGap:Point = new Point(10,10);
    public var right:Number  = 0;
    public var charList:SelectCharListConfigVO;
    public var assistList:SelectCharListConfigVO;

    //	public var HCount:int; //列数
    //	public var VCount:int; //行数
    public var unitSize:Point = new Point(50, 50);

    public function setByXML(xml:XML):void {

        var layoutXML:Object = xml.stage_setting.layout;

        x      = Number(layoutXML.@x);
        y      = Number(layoutXML.@y);
        width  = Number(layoutXML.@width);
        height = Number(layoutXML.@height);

        top    = Number(layoutXML.@top);
        bottom = Number(layoutXML.@bottom);
        left   = Number(layoutXML.@left);
        right  = Number(layoutXML.@right);

        charList   = newListByXML(xml.char_list);
        assistList = newListByXML(xml.assist_list);

    }


    private function newListByXML(xml:XMLList):SelectCharListConfigVO {
        var sv:SelectCharListConfigVO = new SelectCharListConfigVO();

        sv.VCount = xml.children().length();

        for (var y:int; y < xml.children().length(); y++) {
            var row:XML = xml.children()[y];

            var rowOffset:Point     = null;
            var rowOffsetStr:String = row.@offset;

            if (rowOffsetStr && rowOffsetStr.length > 0) {
                var rowOffsetArr:Array = rowOffsetStr.split(',');
                rowOffset              = new Point(rowOffsetArr[0], rowOffsetArr[1]);
            }

            if (sv.HCount < row.children().length()) {
                sv.HCount = row.children().length();
            }

            for (var x:int = 0; x < row.children().length(); x++) {
                var item:XML = row.children()[x];

                var moreIds:Array     = null;
                var moreIdsStr:String = item.@moreFighter;
                if (moreIdsStr && moreIdsStr.length > 0) {
                    moreIds = moreIdsStr.split(',');
                }

                var fighterID:String = item.toString();
                if (fighterID && fighterID.length < 1) {
                    fighterID = null;
                }
                var offset:Point     = rowOffset ? rowOffset.clone() : null;
                var offsetStr:String = item.@offset;
                if (offsetStr && offsetStr.length > 0) {
                    var offsetArr:Array = offsetStr.split(',');
                    if (offset) {
                        offset.x += Number(offsetArr[0]);
                        offset.y += Number(offsetArr[1]);
                    }
                    else {
                        offset = new Point(offsetArr[0], offsetArr[1]);
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
