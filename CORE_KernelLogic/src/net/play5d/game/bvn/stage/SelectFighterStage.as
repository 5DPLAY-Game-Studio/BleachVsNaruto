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

package net.play5d.game.bvn.stage {
import com.greensock.TweenLite;
import com.greensock.easing.Back;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.utils.setTimeout;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.ctrler.GameRender;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.ctrler.StateCtrl;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.data.MessionModel;
import net.play5d.game.bvn.data.vos.SelectStageConfigVO;
import net.play5d.game.bvn.data.vos.SelectVO;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.input.GameInputType;
import net.play5d.game.bvn.input.GameInputer;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.ui.select.SelectMapUI;
import net.play5d.game.bvn.ui.select.SelectUIFactory;
import net.play5d.game.bvn.ui.select.SelectedFighterGroup;
import net.play5d.game.bvn.ui.select.SelecterItemUI;
import net.play5d.game.bvn.ui.select.SelectFighterListCtrl;
import net.play5d.game.bvn.ui.select.flow.ISelectModeFlow;
import net.play5d.game.bvn.ui.select.flow.SelectFlowAction;
import net.play5d.game.bvn.ui.select.flow.SelectModeFlowFactory;
import net.play5d.kyo.utils.KeyBoarder;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.stage.IStage;

public class SelectFighterStage implements IStage {

    public static var AUTO_FINISH:Boolean = true;

    private var _ui:$select$MC_stgSelect;
    private var _fighterListUI:Sprite;
    private var _config:SelectStageConfigVO;
    private var _listCtrl:SelectFighterListCtrl;
    private var _p1Slt:SelecterItemUI;
    private var _p2Slt:SelecterItemUI;
    private var _p1SelectedGroup:SelectedFighterGroup;
    private var _p2SelectedGroup:SelectedFighterGroup;
    private var _mapSelectUI:SelectMapUI;
    private var _curStep:int = 0;
    private var _tweenTime:int = 500;
    private var _twoPlayerSelectFin:Boolean;  //解决两玩家同时选人
    private var _modeFlow:ISelectModeFlow;
    [Embed(source='/../assets/cancel.png')]
    private var _backMenuPicClass:Class;
    private var _backMenuBtn:Sprite;

    /**
     * 显示对象
     */
    public function get display():DisplayObject {
        return _ui;
    }

    public function get p1SelectFinish():Boolean {
        return _p1Slt && _p1Slt.selectFinish();
    }

//		private function initPageBtn():void{
//			// 雨兮定制
//			var upBtn:SimpleButton = _ui.getChildByName("bu2") as SimpleButton;
//			var upBtn2:SimpleButton = _ui.getChildByName("bu4") as SimpleButton;
//			var downBtn:SimpleButton = _ui.getChildByName("bu1") as SimpleButton;
//			var downBtn2:SimpleButton = _ui.getChildByName("bu3") as SimpleButton;
//
//			if(GameConfig.TOUCH_MODE){
//				if(upBtn){
//					upBtn.addEventListener(TouchEvent.TOUCH_TAP, pageUpHandler);
//					upBtn.visible = true;
//				}
//				if(upBtn2){
//					upBtn2.addEventListener(TouchEvent.TOUCH_TAP, pageUpHandler);
//					upBtn2.visible = true;
//				}
//				if(downBtn){
//					downBtn.addEventListener(TouchEvent.TOUCH_TAP, pageDownHandler);
//					downBtn.visible = true;
//				}
//				if(downBtn2){
//					downBtn2.addEventListener(TouchEvent.TOUCH_TAP, pageDownHandler);
//					downBtn2.visible = true;
//				}
//			}else{
//				if(upBtn){
//					upBtn.addEventListener(MouseEvent.CLICK, pageUpHandler);
//					upBtn.visible = true;
//				}
//				if(upBtn2){
//					upBtn2.addEventListener(MouseEvent.CLICK, pageUpHandler);
//					upBtn2.visible = true;
//				}
//				if(downBtn){
//					downBtn.addEventListener(MouseEvent.CLICK, pageDownHandler);
//					downBtn.visible = true;
//				}
//				if(downBtn2){
//					downBtn2.addEventListener(MouseEvent.CLICK, pageDownHandler);
//					downBtn2.visible = true;
//				}
//			}
//		}
//		private function removePageBtn():void{
//			var upBtn:SimpleButton = _ui.getChildByName("bu2") as SimpleButton;
//			var upBtn2:SimpleButton = _ui.getChildByName("bu4") as SimpleButton;
//			var downBtn:SimpleButton = _ui.getChildByName("bu1") as SimpleButton;
//			var downBtn2:SimpleButton = _ui.getChildByName("bu3") as SimpleButton;
//
//			if(upBtn){
//				upBtn.removeEventListener(TouchEvent.TOUCH_TAP, pageUpHandler);
//				upBtn.removeEventListener(MouseEvent.CLICK, pageUpHandler);
//				upBtn.visible = false;
//			}
//			if(upBtn2){
//				upBtn2.removeEventListener(TouchEvent.TOUCH_TAP, pageUpHandler);
//				upBtn2.removeEventListener(MouseEvent.CLICK, pageUpHandler);
//				upBtn2.visible = false;
//			}
//			if(downBtn){
//				downBtn.removeEventListener(TouchEvent.TOUCH_TAP, pageDownHandler);
//				downBtn.removeEventListener(MouseEvent.CLICK, pageDownHandler);
//				downBtn.visible = false;
//			}
//			if(downBtn2){
//				downBtn2.removeEventListener(TouchEvent.TOUCH_TAP, pageDownHandler);
//				downBtn2.removeEventListener(MouseEvent.CLICK, pageDownHandler);
//				downBtn2.visible = false;
//			}
//		}

    public function get p2SelectFinish():Boolean {
        return _p2Slt && _p2Slt.selectFinish();
    }

    /**
     * 构建
     */
    public function build():void {
        _ui            = ResUtils.I.createDisplayObject(ResUtils.swfLib.select, ResUtils.SELECT);
        _fighterListUI = new Sprite();

        _ui.addChild(_fighterListUI);

        _config   = GameData.I.config.select_config;
        _modeFlow = SelectModeFlowFactory.create();
        _listCtrl = new SelectFighterListCtrl(_fighterListUI, _config);
        _listCtrl.tweenTime      = _tweenTime;
        _listCtrl.onSelectConfrim = playerSeltBack;

        GameRender.add(render);
        GameInputer.focus();
        GameInputer.enabled = false;

        nextStep();

        SoundCtrl.I.BGM(AssetManager.I.getSound('select'));

        StateCtrl.I.clearTrans();

        KeyBoarder.focus();

        GameEvent.dispatchEvent(GameEvent.SELECT_FIGHTER);


    }

    public function setSelect(player:int, selects:Array):void {
        var selt:SelecterItemUI = player == 1 ? _p1Slt : _p2Slt;
        selt.setCurrentSelect(selects);
        selt.removeSelecter();
        SoundCtrl.I.sndConfrim();
    }

    public function nextStep():void {
        var a:SelectFlowAction = _modeFlow.resolveNextStep(_curStep);
        if (a.nextStep >= 0) {
            _curStep = a.nextStep;
        }

        switch (a.action) {
        case SelectFlowAction.INIT_FIGHTER:
            initFighter();
            break;
        case SelectFlowAction.ENABLE_P2_WITH_P1_INPUT:
            enableP2WithP1Input();
            break;
        case SelectFlowAction.FADOUT_ASSIST:
            _listCtrl.fadOutList(initAssist);
            break;
        case SelectFlowAction.FADOUT_MAP:
            _listCtrl.fadOutList(initMap);
            break;
        case SelectFlowAction.START_ARCADE:
            startAcradeGame();
            break;
        case SelectFlowAction.START_MUSOU:
            startMusouGame();
            break;
        case SelectFlowAction.SELECT_FINISH:
            selectFinish();
            break;
        }
    }

    public function goLoadGame():void {
        TraceLang('debug.trace.data.select_fighter_stage.start_game');
        StateCtrl.I.transIn(MainGame.I.loadGame);
    }

    /**
     * 稍后构建
     */
    public function afterBuild():void {
    }

    /**
     * 销毁
     * @param back 回调函数
     */
    public function destroy(back:Function = null):void {
        clear();
        GameRender.remove(render);
        GameInputer.enabled = false;
        SoundCtrl.I.BGM(null);
        GameUI.closeConfrim();
        _modeFlow = null;
        if (_listCtrl) {
            _listCtrl.destroy();
            _listCtrl = null;
        }

        if (_backMenuBtn) {
            _backMenuBtn.removeEventListener(TouchEvent.TOUCH_TAP, backMenuHandler);
            _backMenuBtn.removeEventListener(MouseEvent.CLICK, backMenuHandler);
            _backMenuBtn.visible = false;
        }
    }

    private function initBackBtn():void {
        if (!_backMenuBtn) {
            _backMenuBtn         = new Sprite();
            var btnBitmap:Bitmap = new _backMenuPicClass();
            btnBitmap.width      = 100;
            btnBitmap.smoothing  = true;
            btnBitmap.scaleY     = btnBitmap.scaleX;
            _backMenuBtn.addChild(btnBitmap);

            if (GameConfig.TOUCH_MODE) {
                _backMenuBtn.addEventListener(TouchEvent.TOUCH_TAP, backMenuHandler);
            }
            else {
                _backMenuBtn.addEventListener(MouseEvent.CLICK, backMenuHandler);
            }
        }
        _ui.addChild(_backMenuBtn);
    }

    private function initFighter():void {
        TraceLang('debug.trace.data.select_fighter_stage.init_fighter');
        clear();
        _listCtrl.selectState = SelectFighterListCtrl.SELECT_STATE_FIGHTER;
        _listCtrl.buildList(_config.charList);

        GameData.I.p1Select = new SelectVO();
        if (_modeFlow.createP2SelectVO()) {
            GameData.I.p2Select = new SelectVO();
        }

        GameInputer.enabled = false;
        setTimeout(initSelecter, _tweenTime);
        // 雨兮定制删除
//			initPageBtn();
        if (GameConfig.TOUCH_MODE) {
            initBackBtn();
        }
//			initSelecter();
    }

    //初始化辅助
    private function initAssist():void {
        TraceLang('debug.trace.data.select_fighter_stage.init_assist');
        clear();
        _listCtrl.selectState = SelectFighterListCtrl.SELECT_STATE_ASSIST;
        _listCtrl.buildList(_config.assistList);
        GameInputer.enabled = false;
        // 雨兮定制删除
//			initPageBtn();
        if (GameConfig.TOUCH_MODE) {
            initBackBtn();
        }
        setTimeout(initSelecter, _tweenTime);
    }

    private function clear():void {
        if (_listCtrl) {
            _listCtrl.clearItems();
        }

        if (_p1Slt) {
            _p1Slt.destroy();
            _p1Slt = null;
        }

        if (_p2Slt) {
            _p2Slt.destroy();
            _p2Slt = null;
        }

        if (_mapSelectUI) {
            _mapSelectUI.destroy();
            _mapSelectUI = null;
        }

        if (_p1SelectedGroup) {
            _p1SelectedGroup.destroy();
            _p1SelectedGroup = null;
        }

        if (_p2SelectedGroup) {
            _p2SelectedGroup.destroy();
            _p2SelectedGroup = null;
        }

        if (_listCtrl) {
            _listCtrl.setSelecters(null, null);
        }

//			removePageBtn();

    }

    private function initSelecter():void {

        GameInputer.enabled = true;

        if (_modeFlow.initBothSelecters()) {
            initSelecterP1();
            initSelecterP2();
            _twoPlayerSelectFin = false;
        }
        else {
            initSelecterP1();
        }
    }

    /**
     * CPU / 观战：P1 选完后用 P1 键位为 P2 选人。
     */
    private function enableP2WithP1Input():void {
        _p1Slt.removeSelecter();
        _p1Slt.enabled = false;
        initSelecterP2();
        _p2Slt.inputType = GameInputType.P1;
    }

    private function initSelecterP1():void {
        _p1Slt                  = SelectUIFactory.createSelecter(1);
        _p1Slt.isSelectAssist   = _listCtrl.selectState == SelectFighterListCtrl.SELECT_STATE_ASSIST;
        _p1Slt.selectTimesCount = (
                                          GameMode.isTeamMode() && !_p1Slt.isSelectAssist
                                  ) ? 3 : 1;

        _fighterListUI.addChild(_p1Slt.ui);

//			_ui.addChild(_p1Slt.ui);
        _ui.addChild(_p1Slt.group);
        _listCtrl.setSelecters(_p1Slt, _p2Slt);
        _listCtrl.moveSlt(_p1Slt, 0, 0);
    }

    private function initSelecterP2():void {
        _p2Slt                  = SelectUIFactory.createSelecter(2);
        _p2Slt.isSelectAssist   = _listCtrl.selectState == SelectFighterListCtrl.SELECT_STATE_ASSIST;
        _p2Slt.selectTimesCount = (
                                          GameMode.isTeamMode() && !_p2Slt.isSelectAssist
                                  ) ? 3 : 1;

        _fighterListUI.addChild(_p2Slt.ui);

//			_ui.addChild(_p2Slt.ui);
        _ui.addChild(_p2Slt.group);
        _listCtrl.setSelecters(_p1Slt, _p2Slt);
        _listCtrl.moveSlt(_p2Slt, 9, 0);
    }

    private function render():void {
        if (GameInputer.back(1)) {
            if (GameUI.showingDialog()) {
                GameUI.cancelConfrim();
            }
            else {
                GameUI.confrim(
                    GetLang('confirm.common.back_menu_title'),
                    GetLang('confirm.common.back_menu'),
                    MainGame.I.goMenu,
                    null,
                    IsMobile()
                );
                GameEvent.dispatchEvent(GameEvent.CONFRIM_BACK_MENU);
            }
        }

        if (GameUI.showingDialog()) {
            return;
        }

        var type:String;

        if (_p1Slt && _p1Slt.enabled) {

            SelectFighterListCtrl.renderRandom(_p1Slt);

            type = _p1Slt.inputType;

            if (GameInputer.up(type, 1)) {
                _listCtrl.moveSelecter(_p1Slt, 0, -1);
                SoundCtrl.I.sndSelect();
            }

            if (GameInputer.down(type, 1)) {
                _listCtrl.moveSelecter(_p1Slt, 0, 1);
                SoundCtrl.I.sndSelect();
            }

            if (GameInputer.left(type, 1)) {
                _listCtrl.moveSelecter(_p1Slt, -1, 0);
                SoundCtrl.I.sndSelect();
            }

            if (GameInputer.right(type, 1)) {
                _listCtrl.moveSelecter(_p1Slt, 1, 0);
                SoundCtrl.I.sndSelect();
            }

            if (GameInputer.select(type, 1)) {
                _p1Slt.select(playerSeltBack);
                SoundCtrl.I.sndConfrim();
            }

        }

        if (_p2Slt && _p2Slt.enabled) {

            type = _p2Slt.inputType;

            SelectFighterListCtrl.renderRandom(_p2Slt);

            if (GameInputer.up(type, 1)) {
                _listCtrl.moveSelecter(_p2Slt, 0, -1);
                SoundCtrl.I.sndSelect();
            }

            if (GameInputer.down(type, 1)) {
                _listCtrl.moveSelecter(_p2Slt, 0, 1);
                SoundCtrl.I.sndSelect();
            }

            if (GameInputer.left(type, 1)) {
                _listCtrl.moveSelecter(_p2Slt, -1, 0);
                SoundCtrl.I.sndSelect();
            }

            if (GameInputer.right(type, 1)) {
                _listCtrl.moveSelecter(_p2Slt, 1, 0);
                SoundCtrl.I.sndSelect();
            }

            if (GameInputer.select(type, 1)) {
                _p2Slt.select(playerSeltBack);
                SoundCtrl.I.sndConfrim();
            }

        }

        if (_mapSelectUI && _mapSelectUI.enabled) {
            type = _mapSelectUI.inputType;

            if (GameInputer.left(type, 1)) {
                _mapSelectUI.prev();
                SoundCtrl.I.sndSelect();
            }

            if (GameInputer.right(type, 1)) {
                _mapSelectUI.next();
                SoundCtrl.I.sndSelect();
            }

            if (GameInputer.select(type, 1)) {
                _mapSelectUI.select(onMapSelect);
                SoundCtrl.I.sndConfrim();
            }

        }

    }

    private function playerSeltBack(selt:SelecterItemUI):void {
        if (selt.selectFinish()) {
            if (_modeFlow.shouldWaitBothPlayers()) {
                GameEvent.dispatchEvent(GameEvent.SELECT_FIGHTER_STEP, selt.getCurrentSelectes());

                var otherSlt:SelecterItemUI = selt == _p1Slt ? _p2Slt : _p1Slt;
                if (otherSlt && otherSlt.selectFinish() && !_twoPlayerSelectFin) {
                    _twoPlayerSelectFin = true;
                    if (!AUTO_FINISH) {
                        return;
                    }
                    nextStep();
                }
            }
            else {
                nextStep();
            }
            selt.destroy();
//				if(selt == _p1Slt) _p1Slt = null;
//				if(selt == _p2Slt) _p2Slt = null;
        }
        else {
            if (!selt.randoms) {
                var move:int = selt == _p1Slt == 1 ? 1 : -1;
                _listCtrl.moveSlt(selt, selt.x + move, selt.y, true);
            }
        }
    }

    private function initMap():void {
        TraceLang('debug.trace.data.select_fighter_stage.select_map');

        GameEvent.dispatchEvent(GameEvent.SELECT_MAP);

        clear();

        GameInputer.enabled = false;

        _mapSelectUI = new SelectMapUI();
        _ui.addChild(_mapSelectUI);


        var oldX:Number = _mapSelectUI.x;
        var oldY:Number = _mapSelectUI.y;

        _mapSelectUI.scaleX = 0;
        _mapSelectUI.scaleY = 0;
        _mapSelectUI.x      = GameConfig.GAME_SIZE.x / 2;
        _mapSelectUI.y      = GameConfig.GAME_SIZE.y / 2;
        TweenLite.to(_mapSelectUI, 0.3, {
            x: oldX, y: oldY, scaleX: 1, scaleY: 1, ease: Back.easeOut, onComplete: function ():void {
                if (_mapSelectUI) {
                    _mapSelectUI.addMouseEvents(mapPrevHandler, mapNextHandler, mapConfrimHandler);
                    _mapSelectUI.inputType = GameInputType.P1;
                    _mapSelectUI.enabled   = true;
                }
                GameInputer.enabled = true;
            }
        });

        if (GameConfig.TOUCH_MODE) {
            initBackBtn();
        }
    }

    private function mapPrevHandler():void {
        _mapSelectUI.prev();
    }

    private function mapNextHandler():void {
        _mapSelectUI.next();
    }

    private function mapConfrimHandler():void {
        _mapSelectUI.select(onMapSelect);
    }

    private function onMapSelect():void {
        nextStep();
    }

    private function startAcradeGame():void {
        MessionModel.I.initMession();
        selectFinish();
    }

    private function startMusouGame():void {
//			MusouMissionModel.I.initMissions();
        selectFinish();
    }

    private function selectFinish():void {
        GameEvent.dispatchEvent(GameEvent.SELECT_FIGHTER_FINISH);
        if (!AUTO_FINISH) {
            return;
        }
        goLoadGame();
    }

    private function backMenuHandler(e:Event):void {
        GameUI.confrim(
            GetLang('confirm.common.back_menu_title'),
            GetLang('confirm.common.back_menu'),
            MainGame.I.goMenu,
            null,
            IsMobile()
        );
        GameEvent.dispatchEvent(GameEvent.CONFRIM_BACK_MENU);
    }

}
}
