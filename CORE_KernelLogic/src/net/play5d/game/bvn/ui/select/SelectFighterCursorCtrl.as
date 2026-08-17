/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.ui.select {
import flash.geom.Point;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.data.AssisterModel;
import net.play5d.game.bvn.data.FighterModel;
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.kyo.utils.ArrayMap;

/**
 * 选人列表光标移动 / 「更多角色」展开。
 *
 * @see SelectFighterListCtrl
 */
public class SelectFighterCursorCtrl {

    /** @private */
    private var _list:SelectFighterListCtrl;

    /**
     * 绑定列表控制器。
     *
     * @param list 列表域。
     */
    public function bind(list:SelectFighterListCtrl):void {
        _list = list;
    }

    /**
     * 释放引用。
     */
    public function destroy():void {
        _list = null;
    }

    public function moveSlt(slt:SelecterItemUI, x:int, y:int, fix:Boolean = true):Boolean {
        var sf:SelectFighterItem = _list.getFighterItemAt(x, y);
        var left:Boolean, right:Boolean, up:Boolean, down:Boolean;

        if (!sf || (
                sf && SelectFighterListCtrl.checkSelected(slt, sf)
        )) {
            if (!fix) {
                return true;
            }

            var i:int, j:int;

            if (x > slt.x) {
                right = true;
                for (i = 0; i < _list.curListConfig.HCount; i++) {
                    j = x + i;
                    if (j > _list.curListConfig.HCount - 1) {
                        j -= _list.curListConfig.HCount;
                    }
                    sf = _list.getFighterItemAt(j, slt.y);
                    if (sf && !SelectFighterListCtrl.checkSelected(slt, sf)) {
                        break;
                    }
                }
            }

            if (x < slt.x) {
                left = true;
                for (i = 0; i < _list.curListConfig.HCount; i++) {
                    j = x - i;
                    if (j < 0) {
                        j = _list.curListConfig.HCount + j;
                    }
                    sf = _list.getFighterItemAt(j, slt.y);
                    if (sf && !SelectFighterListCtrl.checkSelected(slt, sf)) {
                        break;
                    }
                }
            }

            if (y > slt.y) {
                down = true;
                if (y > _list.curListConfig.VCount - 1) {
                    y = 0;
                }
                for (i = y; i < _list.curListConfig.VCount; i++) {
                    sf = getHLineFighter(slt.x, i);
//						if(sf && !slt.isSelected(sf.selectData.fighterID)) break;
                    if (sf) {
                        break;
                    }
                }
            }

            if (y < slt.y) {
                up = true;
                if (y < 0) {
                    y = _list.curListConfig.VCount - 1;
                }
                for (i = y; i >= 0; i--) {
                    sf = getHLineFighter(slt.x, i);
//						if(sf && !slt.isSelected(sf.selectData.fighterID)) break;
                    if (sf) {
                        break;
                    }
                }
            }

        }

        if (!sf) {
            return false;
        }

        slt.x = sf.selectData.x;
        slt.y = sf.selectData.y;

        if (SelectFighterListCtrl.checkSelected(slt, sf)) {
            if (up || down) {
                // 下一行已被选中，向右移一个
                var succ:Boolean = moveSlt(slt, slt.x + 1, slt.y);
                if (!succ) {
                    // 如果上一行或下一行已经选满，继续找上一行或下一行
                    if (up) {
                        moveSlt(slt, slt.x, slt.y - 1);
                    }
                    if (down) {
                        moveSlt(slt, slt.x, slt.y + 1);
                    }
                }
            }
            return true;
        }

        moveToSelectFighter(slt, sf);

        return true;
    }

    private function isHoverFighter(slt:SelecterItemUI, sf:SelectFighterItem):Boolean {
        if (!sf.selectData) {
            return false;
        }
        return (
                       slt.x == sf.selectData.x
               ) && (
                       slt.y == sf.selectData.y
               );
    }

    public function moveToSelectFighter(slt:SelecterItemUI, sf:SelectFighterItem):void {
        if (!sf || !sf.selectData) {
            return;
        }

        slt.randoms = null;

        slt.x = sf.selectData.x;
        slt.y = sf.selectData.y;

        slt.moveTo(sf.ui.x, sf.ui.y);

        slt.currentFighter = sf.fighterData;

        if (slt.group) {
            slt.group.updateFighter(slt.currentFighter);
        }

        checkRandom(slt);

        showMoreFighters(slt, sf);
    }

    public function moveToSelectFighterMore(slt:SelecterItemUI, sf:SelectFighterItem):void {
        slt.randoms = null;

        slt.moreX = sf.position.x;
        slt.moreY = sf.position.y;

        slt.moveTo(sf.ui.x, sf.ui.y);
        slt.currentFighter = sf.fighterData;

        if (slt.group) {
            slt.group.updateFighter(slt.currentFighter);
        }
    }

    /**
     * 人物关联的更多人物。
     */
    private function showMoreFighters(slt:SelecterItemUI, sf:SelectFighterItem):void {

        if (slt.showingMoreSelecter == sf) {
            return;
        }

        var fighterItems:ArrayMap;
        var si:SelectFighterItem;
        var i:int;

        fighterItems = _list.moreFighterMap[slt];
        if (fighterItems) {
            for (i = 0; i < fighterItems.length; i++) {
                si = fighterItems.getItemByIndex(i);
                si.hideMore();
            }
            _list.moreFighterMap[slt] = null;
        }
        slt.setMoreEnabled(false);

        if (!sf.selectData.moreFighterIDs || sf.selectData.moreFighterIDs.length < 1) {
            return;
        }

        // 检查缓存 ===========================================================
        fighterItems = _list.moreFighterCache[sf.fighterData.id];
        if (fighterItems && fighterItems.length > 0) {
            for (i = 0; i < fighterItems.length; i++) {
                si = fighterItems.getItemByIndex(i);
                _list.fighterListUI.addChild(si.ui);
                si.showMore(i * 0.01);
            }
            _list.moreFighterMap[slt] = fighterItems;
            slt.setMoreEnabled(true, sf);
            return;
        }

        // 创建新的头像 =====================================================
        var fighterIds:Array = sf.selectData.moreFighterIDs;

        fighterItems = new ArrayMap();

        // 周围, 八个位置
        var posArr:Array = [
            new Point(0, -1), new Point(0, 1), new Point(-1, 0), new Point(1, 0), new Point(-1, -1), new Point(1, -1),
            new Point(-1, 1), new Point(1, 1)
        ];
        var posSN:int    = 0;

        for (i = 0; i < fighterIds.length; i++) {
            var fid:String = fighterIds[i];
            trace(fid);

            var fv:FighterVO = _list.selectState == SelectFighterListCtrl.SELECT_STATE_ASSIST ? AssisterModel.I.getAssister(fid) :
                               FighterModel.I.getFighter(fid);
            if (!fv) {
                Debugger.log(GetLang('debug.log.data.select_fighter_stage.fighter_data_missing', {fighterId: fid}));
                continue;
            }

            var unitWidth:Number  = 60;
            var unitHeight:Number = 60;

            var morePosition:Point = null;
            var addN:int           = 0;
            var fighterPos:Point   = null;
            while (morePosition == null) {
                var psn:int = posSN % 8;
                posSN++;

                var pos:Point = posArr[psn];
                if (!pos) {
                    Debugger.log(GetLang('debug.log.data.select_fighter_stage.pos_undefined', {
                        psn  : psn + ' / ',
                        posSN: posSN
                    }));
                    continue;
                }

                var mmx:Number = sf.ui.x + (
                        pos.x * (
                                unitWidth + 5
                        )
                );
                var mmy:Number = sf.ui.y + (
                        pos.y * (
                                unitHeight + 5
                        )
                );

                if (mmx < 0 || mmx > GameConfig.GAME_SIZE.x) {
                    Debugger.log(GetLang('debug.log.data.select_fighter_stage.pos_x_oob', {
                        detail: '(' + mmx + ')  ' + psn + ' / ' + posSN
                    }));
                    continue;
                }
                if (mmy < 0 || mmy > GameConfig.GAME_SIZE.y) {
                    Debugger.log(GetLang('debug.log.data.select_fighter_stage.pos_y_oob', {
                        detail: '(' + mmy + ')  ' + psn + ' / ' + posSN
                    }));
                    continue;
                }

                fighterPos   = pos.clone();
                morePosition = new Point(mmx, mmy);
            }

            si = new SelectFighterItem(fv, null, true);
            trace(posSN, morePosition, si.fighterData.id);

            _list.bindItemInput(si);

            si.position = fighterPos;

            si.initMoreTween(new Point(sf.ui.x, sf.ui.y), morePosition);
            _list.fighterListUI.addChild(si.ui);

            addN++;

            si.showMore(addN * 0.01);

            fighterItems.push(si.positionId, si);
            _list.moreFighterMap[slt]                 = fighterItems;
            _list.moreFighterCache[sf.fighterData.id] = fighterItems;

        }

        slt.setMoreEnabled(true, sf);
    }

    private function moveMoreSlt(slt:SelecterItemUI, x:int, y:int):Boolean {
        var moreFighters:ArrayMap = _list.moreFighterMap[slt];

        if (!moreFighters || moreFighters.length < 1) {
            return false;
        }

        if (x == 0 && y == 0 && slt.showingMoreSelecter) {
            slt.moreX = 0;
            slt.moreY = 0;

            slt.moveTo(slt.showingMoreSelecter.ui.x, slt.showingMoreSelecter.ui.y);
            slt.currentFighter = slt.showingMoreSelecter.fighterData;
            if (slt.group) {
                slt.group.updateFighter(slt.currentFighter);
            }
            return true;
        }

        var itemId:String          = SelectFighterItem.getIdByPoint(x, y);
        var item:SelectFighterItem = moreFighters.getItemById(itemId);

        if (!item) {
            return false;
        }

        if (slt.isSelected(item.fighterData.id)) {
            return false;
        }

        slt.randoms = null;

        slt.moreX = item.position.x;
        slt.moreY = item.position.y;

        slt.moveTo(item.ui.x, item.ui.y);
        slt.currentFighter = item.fighterData;

        if (slt.group) {
            slt.group.updateFighter(slt.currentFighter);
        }

        return true;
    }

    /**
     * *******************************************************************************************************************************************************
     */

    private function checkRandom(slt:SelecterItemUI):Boolean {
        if (slt.currentFighter.id.indexOf('random') != -1) {
            switch (_list.selectState) {
            case SelectFighterListCtrl.SELECT_STATE_FIGHTER:
                slt.randoms = FighterModel.I.getFighters(slt.currentFighter.comicType, function (fv:FighterVO):Boolean {
                    return fv.id.indexOf('random') == -1 && GameLogic.canSelectFighter(fv.id) &&
                           !slt.selectVO.isSelected(fv.id);
                });
                break;
            case SelectFighterListCtrl.SELECT_STATE_ASSIST:
                slt.randoms = AssisterModel.I.getAssisters(
                        slt.currentFighter.comicType, function (fv:FighterVO):Boolean {
                            return fv.id.indexOf('random') == -1 && GameLogic.canSelectAssist(fv.id);
                        });
                break;
            default:
                return false;
            }
            slt.randFrame = 0;
            SelectFighterListCtrl.renderRandom(slt);
            return true;
        }

        return false;
    }

    private function getHLineFighter(startX:int, Y:int):SelectFighterItem {
        var X:int, k:int;
        var sf:SelectFighterItem;
        while (true) {
            X = startX + k;
            if (X >= 0 && X < _list.curListConfig.HCount) {
                sf = _list.getFighterItemAt(X, Y);
                if (sf) {
                    return sf;
                }
            }

            if (k == 0) {
                k = 1;
            }
            else if (k > 0) {
                k *= -1;
            }
            else {
                if (k < -_list.curListConfig.HCount) {
                    return null;
                }
                k *= -1;
                k++;
            }
        }
        return null;
    }

    public function moveSelecter(slt:SelecterItemUI, addX:int, addY:int):void {
        if (slt.moreEnabled()) {
            if (moveMoreSlt(slt, slt.moreX + addX, slt.moreY + addY)) {
                return;
            }
            else {
                slt.setMoreEnabled(false);
            }
        }

        moveSlt(slt, slt.x + addX, slt.y + addY);
    }

}
}
