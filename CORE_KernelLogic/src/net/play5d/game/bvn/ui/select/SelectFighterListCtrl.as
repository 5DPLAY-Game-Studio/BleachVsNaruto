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
 * 选人列表门面。
 *
 * <p>由 <code>SelectFighterStage</code> 持有；负责格子构建与鼠标/触屏。方向键光标与「更多角色」委派 <code>SelectFighterCursorCtrl</code>。</p>
 *
 * @see SelectFighterStage
 * @see SelectFighterCursorCtrl
 * @see SelecterItemUI
 */
public class SelectFighterListCtrl {

    /** 选人阶段：角色 */
    public static const SELECT_STATE_FIGHTER:int = 0;
    /** 选人阶段：援助 */
    public static const SELECT_STATE_ASSIST:int  = 1;

    /** @private */
    private var _cursor:SelectFighterCursorCtrl;

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
    private var _moreFighterCache:Dictionary = new Dictionary();

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
        _cursor        = new SelectFighterCursorCtrl();
        _cursor.bind(this);
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
        if (_cursor) {
            _cursor.destroy();
            _cursor = null;
        }
        _fighterListUI    = null;
        _config           = null;
        _p1Slt            = null;
        _p2Slt            = null;
        _onSelectConfrim  = null;
        _moreFighterMap   = null;
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
        _moreFighterCache = new Dictionary();
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

        bindItemInput(si);

        _fighterListUI.addChild(si.ui);

//			si.ui.x = sv.x * (unitWidth + _config.itemGap.x);
//			si.ui.y = sv.y * (unitHeight + _config.itemGap.y);

        _itemObj[sv.x + ',' + sv.y] = si;

        return si;
    }

    /**
     * 绑定格子鼠标 / 触屏（供 CursorCtrl 创建「更多角色」时复用）。
     *
     * @param si 格子。
     */
    public function bindItemInput(si:SelectFighterItem):void {
        if (GameConfig.TOUCH_MODE) {
            si.addEventListener(TouchEvent.TOUCH_TAP, selectFighterTouchHandler);
        }
        else {
            si.addEventListener(MouseEvent.MOUSE_OVER, selectFighterMouseHandler);
            si.addEventListener(MouseEvent.CLICK, selectFighterMouseHandler);
        }
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
                _cursor.moveToSelectFighterMore(_p1Slt, target);
                SoundCtrl.I.sndSelect();
                return;
            }

            if (checkSelected(_p1Slt, target)) {
                return;
            }
            _cursor.moveToSelectFighter(_p1Slt, target);
            SoundCtrl.I.sndSelect();
            return;
        }
        if (_p2Slt && _p2Slt.enabled) {

            if (_p2Slt.moreEnabled() && target.isMore) {
                _cursor.moveToSelectFighterMore(_p2Slt, target);
                SoundCtrl.I.sndSelect();
                return;
            }

            if (checkSelected(_p2Slt, target)) {
                return;
            }
            _cursor.moveToSelectFighter(_p2Slt, target);
            SoundCtrl.I.sndSelect();
            return;
        }
    }

    /**
     * 格子是否已被该选人器选过。
     */
    public static function checkSelected(slt:SelecterItemUI, sf:SelectFighterItem):Boolean {

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

    /** @private 供 CursorCtrl */
    public function get curListConfig():SelectCharListConfigVO {
        return _curListConfig;
    }

    /** @private */
    public function get moreFighterMap():Object {
        return _moreFighterMap;
    }

    /** @private */
    public function get moreFighterCache():Dictionary {
        return _moreFighterCache;
    }

    /** @private */
    public function set moreFighterCache(v:Dictionary):void {
        _moreFighterCache = v;
    }

    /** @private */
    public function get p1Slt():SelecterItemUI {
        return _p1Slt;
    }

    /** @private */
    public function get p2Slt():SelecterItemUI {
        return _p2Slt;
    }

    /** @private */
    public function get onSelectConfrimFn():Function {
        return _onSelectConfrim;
    }

    /** @private */
    public function get config():SelectStageConfigVO {
        return _config;
    }

    /** @private */
    public function get fighterListUI():Sprite {
        return _fighterListUI;
    }

    /**
     * 按格坐标取格子（供 CursorCtrl）。
     */
    public function getFighterItemAt(x:int, y:int):SelectFighterItem {
        return getFighterItem(x, y);
    }

    /**
     * 悬停（供 CursorCtrl / 鼠标）。
     */
    public function doHoverItem(target:SelectFighterItem):void {
        doHover(target);
    }

    /**
     * 点选（供 CursorCtrl / 鼠标）。
     */
    public function doSelectItem(target:SelectFighterItem):void {
        doSelect(target);
    }

    /**
     * 移动光标到格子。
     */
    public function moveSlt(slt:SelecterItemUI, x:int, y:int, fix:Boolean = true):Boolean {
        return _cursor.moveSlt(slt, x, y, fix);
    }

    /**
     * 相对移动光标。
     */
    public function moveSelecter(slt:SelecterItemUI, addX:int, addY:int):void {
        _cursor.moveSelecter(slt, addX, addY);
    }

}
}
