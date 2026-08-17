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
import com.greensock.TweenLite;
import com.greensock.easing.Back;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Point;
import flash.utils.Dictionary;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.data.AssisterModel;
import net.play5d.game.bvn.data.FighterModel;
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.data.vos.SelectCharListConfigVO;
import net.play5d.game.bvn.data.vos.SelectCharListItemVO;
import net.play5d.game.bvn.data.vos.SelectStageConfigVO;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.input.GameInputer;
import net.play5d.kyo.utils.ArrayMap;
import net.play5d.kyo.utils.KyoRandom;

/**
 * 选人列表与光标导航。
 *
 * <p>由 <code>SelectFighterStage</code> 持有；负责格子构建、鼠标/触屏、方向键移动与「更多角色」展开。</p>
 *
 * @see SelectFighterStage
 * @see SelecterItemUI
 */
public class SelectFighterListCtrl {

    /** 选人阶段：角色 */
    public static const SELECT_STATE_FIGHTER:int = 0;
    /** 选人阶段：援助 */
    public static const SELECT_STATE_ASSIST:int  = 1;

    /** @private */
    private var _fighterListUI:Sprite;
    /** @private */
    private var _config:SelectStageConfigVO;
    /** @private */
    private var _curListConfig:SelectCharListConfigVO;
    /** @private */
    private var _itemObj:Object;
    /** @private */
    private var _p1Slt:SelecterItemUI;
    /** @private */
    private var _p2Slt:SelecterItemUI;
    /** @private */
    private var _selectState:int;
    /** @private */
    private var _tweenTime:int = 500;
    /** @private */
    private var _onSelectConfrim:Function;
    /** @private */
    private var _moreFighterMap:Dictionary = new Dictionary();
    /** @private */
    private var _moreFighterCache:Object   = {};

    /**
     * @param fighterListUI 角色格子容器。
     * @param config 选人舞台布局配置。
     * @example
     * <listing version="3.0">
     * var c:SelectFighterListCtrl = new SelectFighterListCtrl(listUI, cfg);
     * </listing>
     */
    public function SelectFighterListCtrl(fighterListUI:Sprite, config:SelectStageConfigVO) {
        _fighterListUI = fighterListUI;
        _config        = config;
    }

    /**
     * 设置选人阶段（角色 / 援助）。
     *
     * @param v <code>SELECT_STATE_*</code>。
     * @example
     * <listing version="3.0">
     * ctrl.selectState = SelectFighterListCtrl.SELECT_STATE_ASSIST;
     * </listing>
     */
    public function set selectState(v:int):void {
        _selectState = v;
    }

    /**
     * 当前选人阶段。
     *
     * @return 阶段常量。
     */
    public function get selectState():int {
        return _selectState;
    }

    /**
     * 绑定进场缓动时长。
     *
     * @param v 毫秒。
     * @example
     * <listing version="3.0">
     * ctrl.tweenTime = 500;
     * </listing>
     */
    public function set tweenTime(v:int):void {
        _tweenTime = v;
    }

    /**
     * 更新当前选人器引用。
     *
     * @param p1 P1 选人器。
     * @param p2 P2 选人器。
     * @example
     * <listing version="3.0">
     * ctrl.setSelecters(p1, p2);
     * </listing>
     */
    public function setSelecters(p1:SelecterItemUI, p2:SelecterItemUI):void {
        _p1Slt = p1;
        _p2Slt = p2;
    }

    /**
     * 确认选择回调（参数为 <code>SelecterItemUI</code>）。
     *
     * @param v 回调。
     * @example
     * <listing version="3.0">
     * ctrl.onSelectConfrim = playerSeltBack;
     * </listing>
     */
    public function set onSelectConfrim(v:Function):void {
        _onSelectConfrim = v;
    }

    /**
     * 释放列表资源。
     *
     * @example
     * <listing version="3.0">
     * ctrl.destroy();
     * </listing>
     */
    public function destroy():void {
        clearItems();
        _fighterListUI   = null;
        _config          = null;
        _p1Slt           = null;
        _p2Slt           = null;
        _onSelectConfrim = null;
        _moreFighterMap  = null;
        _moreFighterCache = null;
    }

    /**
     * 清空格子与「更多角色」展开项（不含选人器）。
     *
     * @example
     * <listing version="3.0">
     * ctrl.clearItems();
     * </listing>
     */
    public function clearItems():void {
        if (_itemObj) {
            for each(var i:SelectFighterItem in _itemObj) {
                i.removeEventListener(MouseEvent.MOUSE_OVER, selectFighterMouseHandler);
                i.removeEventListener(MouseEvent.CLICK, selectFighterMouseHandler);
                i.removeEventListener(TouchEvent.TOUCH_TAP, selectFighterTouchHandler);
                i.destroy();
            }
            _itemObj = null;
        }

        for each(var f:ArrayMap in _moreFighterMap) {
            if (!f) {
                continue;
            }
            for (var j:int = 0; j < f.length; j++) {
                var si:SelectFighterItem = f.getItemByIndex(j);
                si.destroy();
            }
            _moreFighterMap[f] = null;
        }
        _moreFighterMap   = new Dictionary();
        _moreFighterCache = {};
    }

    /**
     * 列表上翻一页。
     *
     * @example
     * <listing version="3.0">
     * ctrl.pageUp();
     * </listing>
     */
    public function pageUp():void {
        if (_fighterListUI.height <= GameConfig.GAME_SIZE.y) {
            return;
        }

        var toY:Number  = _fighterListUI.y + 493;
        var maxY:Number = 0;
        if (toY > maxY) {
            toY = maxY;
        }
        TweenLite.to(_fighterListUI, .2, {y: toY});
    }

    /**
     * 列表下翻一页。
     *
     * @example
     * <listing version="3.0">
     * ctrl.pageDown();
     * </listing>
     */
    public function pageDown():void {
        if (_fighterListUI.height <= GameConfig.GAME_SIZE.y) {
            return;
        }

        var toY:Number  = _fighterListUI.y - 493;
        var minY:Number = -_fighterListUI.height + 493;
        if (toY < minY) {
            toY = minY;
        }
        TweenLite.to(_fighterListUI, .2, {y: toY});
    }

    public function fadOutList(back:Function = null):void {

        GameInputer.enabled = false;

        var outX:Number = GameConfig.GAME_SIZE.x / 2 - 30;
        var outY:Number = GameConfig.GAME_SIZE.y / 2 - 30;

        for each(var i:SelectFighterItem in _itemObj) {
            var delay:Number = Math.random() * 0.1;
            TweenLite.to(i.ui, 0.2, {x: outX, y: outY, scaleX: 0, scaleY: 0, delay: delay});
        }

        for each(var f:ArrayMap in _moreFighterMap) {
            if (!f) {
                continue;
            }
            for (var j:int = 0; j < f.length; j++) {
                var si:SelectFighterItem = f.getItemByIndex(j);
                si.destroy();
            }
            _moreFighterMap[f] = null;
        }

        if (back != null) {
            TweenLite.delayedCall(0.3, back);
        }
    }

    public function buildList(list:SelectCharListConfigVO):void {
        _fighterListUI.y = 0;

        var startX:Number = _config.x + _config.left;
        var startY:Number = _config.y + _config.top;
        var gapX:Number   = list.HCount > 1 ? (
                                                      _config.width - _config.unitSize.x - _config.left - _config.right
                                              ) / (
                                                      list.HCount - 1
                                              ) : 0;
        var gapY:Number   = list.VCount > 1 ? (
                                                      _config.height - _config.unitSize.y - _config.top - _config.bottom
                                              ) / (
                                                      list.VCount - 1
                                              ) : 0;

        var charList:Array = list.list;
        _curListConfig     = list;

        _itemObj = {};

        var initX:Number = GameConfig.GAME_SIZE.x / 2 - 30;
        var initY:Number = GameConfig.GAME_SIZE.y / 2 - 30;

        for (var i:int; i < charList.length; i++) {
            var s:SelectCharListItemVO = charList[i];
            var sf:SelectFighterItem   = addFighterItem(s);
            if (!sf) {
                continue;
            }

            var tx:Number = startX + (gapX * sf.selectData.x);
            var ty:Number = startY + (gapY * sf.selectData.y);
            if (sf.selectData.offset) {
                tx += sf.selectData.offset.x;
                ty += sf.selectData.offset.y;
            }

            sf.ui.scaleX = 0;
            sf.ui.scaleY = 0;
            sf.ui.x      = initX;
            sf.ui.y      = initY;

            var delay:Number = Math.random() * (_tweenTime - 300) / 1000;

            TweenLite.to(sf.ui, 0.3,
                         {x: tx, y: ty, delay: delay, scaleX: 1, scaleY: 1, ease: Back.easeOut}
            );
        }
    }

    private function addFighterItem(sv:SelectCharListItemVO):SelectFighterItem {
        if (!sv.fighterID) {
            return null;
        }

        var fv:FighterVO = _selectState == SelectFighterListCtrl.SELECT_STATE_ASSIST ? AssisterModel.I.getAssister(sv.fighterID) :
                           FighterModel.I.getFighter(sv.fighterID);
        if (!fv) {
            Debugger.log(GetLang('debug.log.data.select_fighter_stage.fighter_data_missing', {fighterId: sv.fighterID}));
            return null;
        }

        var unitWidth:Number  = 60;
        var unitHeight:Number = 60;

        var si:SelectFighterItem = new SelectFighterItem(fv, sv);

        if (GameConfig.TOUCH_MODE) {
            si.addEventListener(TouchEvent.TOUCH_TAP, selectFighterTouchHandler);
        }
        else {
            si.addEventListener(MouseEvent.MOUSE_OVER, selectFighterMouseHandler);
            si.addEventListener(MouseEvent.CLICK, selectFighterMouseHandler);
        }

        _fighterListUI.addChild(si.ui);

//			si.ui.x = sv.x * (unitWidth + _config.itemGap.x);
//			si.ui.y = sv.y * (unitHeight + _config.itemGap.y);

        _itemObj[sv.x + ',' + sv.y] = si;

        return si;
    }

    private function selectFighterMouseHandler(type:String, target:SelectFighterItem):void {
        if (!target || (
                !target.selectData && !target.isMore
        )) {
            return;
        }

        switch (type) {
        case MouseEvent.MOUSE_OVER:
            doHover(target);
            break;
        case MouseEvent.CLICK:
            doSelect(target);
            break;
        }
    }

    private function selectFighterTouchHandler(type:String, target:SelectFighterItem):void {
        if (!target || (
                !target.selectData && !target.isMore
        )) {
            return;
        }

        var curSlt:SelecterItemUI = null;

        if (_p1Slt && _p1Slt.enabled) {
            curSlt = _p1Slt;
        }
        if (!curSlt && (
            _p2Slt && _p2Slt.enabled
        )) {
            curSlt = _p2Slt;
        }

        if (!curSlt) {
            return;
        }

//			if(isHoverFighter(curSlt, target)){
        if (curSlt.touchHoverItem == target) {
            doSelect(target);
            curSlt.touchHoverItem = null;
        }
        else {
            curSlt.touchHoverItem = target;
            doHover(target);
        }

    }

    private function doHover(target:SelectFighterItem):void {
        if (_p1Slt && _p1Slt.enabled) {

            if (_p1Slt.moreEnabled() && target.isMore) {
                moveToSelectFighterMore(_p1Slt, target);
                SoundCtrl.I.sndSelect();
                return;
            }

            if (checkSelected(_p1Slt, target)) {
                return;
            }
            moveToSelectFighter(_p1Slt, target);
            SoundCtrl.I.sndSelect();
            return;
        }
        if (_p2Slt && _p2Slt.enabled) {

            if (_p2Slt.moreEnabled() && target.isMore) {
                moveToSelectFighterMore(_p2Slt, target);
                SoundCtrl.I.sndSelect();
                return;
            }

            if (checkSelected(_p2Slt, target)) {
                return;
            }
            moveToSelectFighter(_p2Slt, target);
            SoundCtrl.I.sndSelect();
            return;
        }
    }

    private static function checkSelected(slt:SelecterItemUI, sf:SelectFighterItem):Boolean {

        if (!sf.selectData && !sf.fighterData) {
            return false;
        }

        if (!sf.selectData && sf.fighterData) {
            return slt.isSelected(sf.fighterData.id);
        }

        if (sf.selectData.moreFighterIDs) {
            for (var i:int; i < sf.selectData.moreFighterIDs.length; i++) {
                if (slt.isSelected(sf.selectData.moreFighterIDs[i])) {
                    return true;
                }
            }
        }
        return slt.isSelected(sf.selectData.fighterID);
    }

    private function doSelect(target:SelectFighterItem):void {
        if (_p1Slt && _p1Slt.enabled) {
            if (checkSelected(_p1Slt, target)) {
                return;
            }
            _p1Slt.select(_onSelectConfrim);
            SoundCtrl.I.sndConfrim();
            return;
        }
        if (_p2Slt && _p2Slt.enabled) {
            if (checkSelected(_p2Slt, target)) {
                return;
            }
            _p2Slt.select(_onSelectConfrim);
            SoundCtrl.I.sndConfrim();
            return;
        }
    }

    private function getFighterItem(x:int, y:int):SelectFighterItem {
        if (!_itemObj) {
            return null;
        }
        return _itemObj[x + ',' + y];
    }

    public function moveSlt(slt:SelecterItemUI, x:int, y:int, fix:Boolean = true):Boolean {
        var sf:SelectFighterItem = getFighterItem(x, y);
        var left:Boolean, right:Boolean, up:Boolean, down:Boolean;

        if (!sf || (
                sf && checkSelected(slt, sf)
        )) {
            if (!fix) {
                return true;
            }

            var i:int, j:int;

            if (x > slt.x) {
                right = true;
                for (i = 0; i < _curListConfig.HCount; i++) {
                    j = x + i;
                    if (j > _curListConfig.HCount - 1) {
                        j -= _curListConfig.HCount;
                    }
                    sf = getFighterItem(j, slt.y);
                    if (sf && !checkSelected(slt, sf)) {
                        break;
                    }
                }
            }

            if (x < slt.x) {
                left = true;
                for (i = 0; i < _curListConfig.HCount; i++) {
                    j = x - i;
                    if (j < 0) {
                        j = _curListConfig.HCount + j;
                    }
                    sf = getFighterItem(j, slt.y);
                    if (sf && !checkSelected(slt, sf)) {
                        break;
                    }
                }
            }

            if (y > slt.y) {
                down = true;
                if (y > _curListConfig.VCount - 1) {
                    y = 0;
                }
                for (i = y; i < _curListConfig.VCount; i++) {
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
                    y = _curListConfig.VCount - 1;
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

        if (checkSelected(slt, sf)) {
            if (up || down) {
                //涓嬩竴琛屽凡琚€変腑锛屽悜鍙崇Щ涓€涓?
                var succ:Boolean = moveSlt(slt, slt.x + 1, slt.y);
                if (!succ) {
                    //濡傛灉涓婁竴琛屾垨涓嬩竴琛屽凡缁忛€夋弧锛岀户缁壘涓婁竴琛屾垨涓嬩竴琛?
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

    private function moveToSelectFighter(slt:SelecterItemUI, sf:SelectFighterItem):void {
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

    private function moveToSelectFighterMore(slt:SelecterItemUI, sf:SelectFighterItem):void {
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
     * 浜虹墿鍏宠仈鐨勬洿澶氫汉鐗?
     */
    private function showMoreFighters(slt:SelecterItemUI, sf:SelectFighterItem):void {

        if (slt.showingMoreSelecter == sf) {
            return;
        }

        var fighterItems:ArrayMap;
        var si:SelectFighterItem;
        var i:int;

        fighterItems = _moreFighterMap[slt];
        if (fighterItems) {
            for (i = 0; i < fighterItems.length; i++) {
                si = fighterItems.getItemByIndex(i);
                si.hideMore();
            }
            _moreFighterMap[slt] = null;
        }
        slt.setMoreEnabled(false);

        if (!sf.selectData.moreFighterIDs || sf.selectData.moreFighterIDs.length < 1) {
            return;
        }


        // 妫€鏌ョ紦瀛?===========================================================
        fighterItems = _moreFighterCache[sf.fighterData.id];
        if (fighterItems && fighterItems.length > 0) {
            for (i = 0; i < fighterItems.length; i++) {
                si = fighterItems.getItemByIndex(i);
                _fighterListUI.addChild(si.ui);
                si.showMore(i * 0.01);
            }
            _moreFighterMap[slt] = fighterItems;
            slt.setMoreEnabled(true, sf);
            return;
        }

        // 鍒涘缓鏂扮殑澶村儚 =====================================================
        var fighterIds:Array = sf.selectData.moreFighterIDs;

        fighterItems = new ArrayMap();

        // 鍛ㄥ洿, 涓€鍦?涓綅缃?
        var posArr:Array = [
            new Point(0, -1), new Point(0, 1), new Point(-1, 0), new Point(1, 0), new Point(-1, -1), new Point(1, -1),
            new Point(-1, 1), new Point(1, 1)
        ];
        var posSN:int    = 0;

        for (i = 0; i < fighterIds.length; i++) {
            var fid:String = fighterIds[i];
            trace(fid);

            var fv:FighterVO = _selectState == SelectFighterListCtrl.SELECT_STATE_ASSIST ? AssisterModel.I.getAssister(fid) :
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

            if (GameConfig.TOUCH_MODE) {
                si.addEventListener(TouchEvent.TOUCH_TAP, selectFighterTouchHandler);
            }
            else {
                si.addEventListener(MouseEvent.MOUSE_OVER, selectFighterMouseHandler);
                si.addEventListener(MouseEvent.CLICK, selectFighterMouseHandler);
            }

            si.position = fighterPos;

            si.initMoreTween(new Point(sf.ui.x, sf.ui.y), morePosition);
            _fighterListUI.addChild(si.ui);

            addN++;

            si.showMore(addN * 0.01);

            fighterItems.push(si.positionId, si);
            _moreFighterMap[slt]                 = fighterItems;
            _moreFighterCache[sf.fighterData.id] = fighterItems;

        }

        slt.setMoreEnabled(true, sf);
    }

    private function moveMoreSlt(slt:SelecterItemUI, x:int, y:int):Boolean {
        var moreFighters:ArrayMap = _moreFighterMap[slt];

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
            switch (_selectState) {
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
            renderRandom(slt);
            return true;
        }

        return false;
    }

    private function getHLineFighter(startX:int, Y:int):SelectFighterItem {
        var X:int, k:int;
        var sf:SelectFighterItem;
        while (true) {
            X = startX + k;
            if (X >= 0 && X < _curListConfig.HCount) {
                sf = getFighterItem(X, Y);
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
                if (k < -_curListConfig.HCount) {
                    return null;
                }
                k *= -1;
                k++;
            }
        }
        return null;
    }

    public static function renderRandom(selt:SelecterItemUI):void {
        if (selt.randoms) {
            if (selt.randFrame > 0) {
                selt.randFrame = 0;
                return;
            }
            selt.randFrame++;
            selt.currentFighter = KyoRandom.getRandomInArray(selt.randoms, false);
            if (selt.group) {
                selt.group.updateFighter(selt.currentFighter);
            }
        }
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