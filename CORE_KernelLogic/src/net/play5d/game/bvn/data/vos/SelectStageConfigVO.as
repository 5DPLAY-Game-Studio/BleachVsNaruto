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

/**
 * 选人界面的布局和两份列表。
 *
 * <p>初始化时缺布局数字会写成 <code>NaN</code>，不会留着字段原来的默认值。
 * 空格子也会放进列表。行偏移和格子偏移会相加。列数取最长那一行。</p>
 */
public class SelectStageConfigVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';


    /** 左边。 @default 0 */
    public var x:Number      = 0;
    /** 上边。 @default 0 */
    public var y:Number      = 0;
    /** 宽。 @default 800 */
    public var width:Number  = 800;
    /** 高。 @default 600 */
    public var height:Number = 600;
    /** 上边距。 @default 0 */
    public var top:Number    = 0;
    /** 下边距。 @default 0 */
    public var bottom:Number = 0;
    /** 左边距。 @default 0 */
    public var left:Number   = 0;

    /** 右边距。 @default 0 */
    public var right:Number = 0;
    /**
     * 角色列表。初始化前为 <code>null</code>。
     *
     * @default null
     */
    public var charList:SelectCharListConfigVO;
    /**
     * 援助列表。初始化前为 <code>null</code>。
     *
     * @default null
     */
    public var assistList:SelectCharListConfigVO;

    /**
     * 一格的默认尺寸。
     */
    public var unitSize:Point = new Point(50, 50);

    /**
     * 用选人 JSON 填写布局和两份列表。
     *
     * <p>没有 <code>stage_setting</code>、<code>char_list</code> 或 <code>assist_list</code> 时抛错。</p>
     *
     * @param obj 选人配置对象。
     * @example
     * <listing version="3.0">
     * stage.initByObject(data);
     * </listing>
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

    /** @private */
    private function newListByObject(listArr:Array):SelectCharListConfigVO {
        var selectCharListConfigVO:SelectCharListConfigVO = new SelectCharListConfigVO();

        selectCharListConfigVO.VCount = listArr.length;

        for (var y:int = 0; y < listArr.length; y++) {
            var row:Object  = listArr[y];
            var items:Array = row['item'] as Array;

            var rowOffset:Point    = null;
            var rowOffsetArr:Array = row['offset'] as Array;
            if (rowOffsetArr && rowOffsetArr.length >= 2) {
                rowOffset = new Point(rowOffsetArr[0], rowOffsetArr[1]);
            }

            if (selectCharListConfigVO.HCount < items.length) {
                selectCharListConfigVO.HCount = items.length;
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
                selectCharListConfigVO.list.push(cv);
            }
        }

        return selectCharListConfigVO;
    }

}
}
