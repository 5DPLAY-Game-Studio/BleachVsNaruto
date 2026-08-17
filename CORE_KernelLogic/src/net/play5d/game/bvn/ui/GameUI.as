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

package net.play5d.game.bvn.ui {
import flash.display.DisplayObject;
import flash.display.Sprite;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.data.GameRunFighterGroup;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.ui.dialog.AlertUI;
import net.play5d.game.bvn.ui.dialog.BaseDialog;
import net.play5d.game.bvn.ui.dialog.ConfrimUI;
import net.play5d.game.bvn.ui.dialog.DialogManager;
import net.play5d.game.bvn.ui.dialog.MusouConfrimUI;
import net.play5d.game.bvn.ui.fight.FightUI;
import net.play5d.game.bvn.ui.musou.MusouUI;

public class GameUI {

    public static var I:GameUI;

    /**
     * 将UI转换成BITMAP
     */
    public static var BITMAP_UI:Boolean    = true;
    public static var SHOW_CN_TEXT:Boolean = true;

    public static var SHOW_HP_TEXT:Boolean = false;
    private static var _confrimUI:BaseDialog;
    private static var _confrimUICls:Class;
    private static var _alertUI:AlertUI;
    private static var _transUI:TransUI;
    private static var _quickTransUI:QuickTransUI;
    private static var _transContainer:Sprite;

    public static function showingDialog():Boolean {
        return _confrimUI != null || _alertUI != null;
    }

    public static function showingConfrim():Boolean {
        return _confrimUI != null;
    }

    public static function showingAlert():Boolean {
        return _alertUI != null;
    }

    /**
     * 弹出【确认】对话框
     *
     * @param enMsg 英文标题
     * @param cnMsg 中文信息
     * @param yes 点击【确定】执行的回调
     * @param no 点击【取消】执行的回调
     * @param isMusouStyle 是否为无双样式
     */
    public static function confrim(
            enMsg:String = null, cnMsg:String = null,
            yes:Function = null, no:Function = null,
            isMusouStyle:Boolean = false
    ):void {
        closeConfrim();

        _confrimUICls = isMusouStyle ? MusouConfrimUI : ConfrimUI;

        _confrimUI = new _confrimUICls();
        _confrimUI.setMsg(enMsg, cnMsg);
        _confrimUI.yesBack = yesClose;
        _confrimUI.noBack  = noClose;

        GameEvent.dispatchEvent(GameEvent.UI_CONFRIM);

        DialogManager.showDialog(_confrimUI, false);

        function yesClose():void {
            if (yes != null) {
                yes();
            }
            closeConfrim();
//				GameEvent.dispatchEvent(GameEvent.UI_CONFRIM_CLOSE);
        }

        function noClose():void {
            if (no != null) {
                no();
            }
            closeConfrim();
            GameEvent.dispatchEvent(GameEvent.UI_CONFRIM_CLOSE);
        }

    }

    public static function alert(enMsg:String = null, cnMsg:String = null, close:Function = null):void {
        closeAlert();
        _alertUI = new AlertUI();
        _alertUI.setMsg(enMsg, cnMsg);
        _alertUI.yesBack = closeBack;

        DialogManager.showDialog(_alertUI, false);

        GameEvent.dispatchEvent(GameEvent.UI_ALERT, {enMsg: enMsg, cnMsg: cnMsg});

        function closeBack():void {
            if (close != null) {
                close();
            }
            closeAlert();
            GameEvent.dispatchEvent(GameEvent.UI_ALERT_CLOSE);
        }
    }

    public static function closeAlert():void {
        if (_alertUI) {
            DialogManager.closeDialog(_alertUI);
            _alertUI = null;
        }
    }

    public static function closeConfrim():void {
        if (_confrimUI) {
            DialogManager.closeDialog(_confrimUI);
            _confrimUI = null;
        }
    }

    public static function cancelConfrim():void {
        if (_confrimUI) {
            if (_confrimUI.noBack != null) {
                _confrimUI.noBack();
            }
            else {
                closeConfrim();
            }
        }
    }

    public function GameUI() {
        I = this;

//        SHOW_HP_TEXT = GameMode.currentMode == GameMode.TRAINING && GameConfig.ALLOW_SHOW_HP_TEXT;
        SHOW_HP_TEXT = GameData.I.config.isShowHp;

        _renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / GameConfig.FPS_ANIMATE) - 1;
    }
    private var _ui:IGameUI;
    private var _renderAnimateGap:int;
    private var _renderAnimateFrame:int = 0;

    public function getUI():IGameUI {
        return _ui;
    }

    public function getUIDisplay():DisplayObject {
        return _ui.getUI();
    }

    public function initFight(p1:GameRunFighterGroup, p2:GameRunFighterGroup):void {
        var volume:Number = GameData.I.config.soundVolume;

        if (_ui) {
            if (!(_ui is FightUI)) {
                _ui.destroy();
                _ui = new FightUI();
                _ui.setVolume(volume);
            }
        }
        else {
            _ui = new FightUI();
            _ui.setVolume(volume);
        }

        (_ui as FightUI).initialize(p1, p2);
    }

    public function initMission(p1:GameRunFighterGroup):void {
        var volume:Number = GameData.I.config.soundVolume;

        if (_ui) {
            if (_ui is FightUI == false) {
                _ui.destroy();
                _ui = new FightUI();
                _ui.setVolume(volume);
            }
        }
        else {
            _ui = new MusouUI();
            _ui.setVolume(volume);
        }

        (
                _ui as MusouUI
        ).initialize(p1);
    }

    public function render():void {
        if (!_ui) {
            return;
        }
        _ui.render();
        if (isRenderAnimate()) {
            renderAnimate();
        }
    }

    public function fadIn():void {
        if (_ui) {
            var volume:Number = GameData.I.config.soundVolume;
            _ui.fadIn();
            _ui.setVolume(volume);
        }
    }

    public function fadOut():void {
        if (_ui) {
            _ui.fadIn();
        }
    }

    public function destroy():void {
        if (_ui) {
            _ui.destroy();
        }
    }

    /**
     * 显示 Continue（对战 UI）。
     *
     * @param onClick 点击回调。
     */
    public function showContinue(onClick:Function):void {
        if (_ui) {
            _ui.showContinue(onClick);
        }
    }

    /**
     * 无双：刷新角色血条组。
     */
    public function updateMusouFighter():void {
        var ui:MusouUI = _ui as MusouUI;
        if (ui) {
            ui.updateFighter();
        }
    }

    /**
     * 无双：失败结算。
     *
     * @param finishBack 结束回调。
     */
    public function showMusouLose(finishBack:Function = null):void {
        var ui:MusouUI = _ui as MusouUI;
        if (ui) {
            ui.showLose(finishBack);
        }
    }

    /**
     * 无双：胜利结算。
     *
     * @param finishBack 结束回调。
     */
    public function showMusouWin(finishBack:Function = null):void {
        var ui:MusouUI = _ui as MusouUI;
        if (ui) {
            ui.showWin(finishBack);
        }
    }

    /**
     * 无双：设置 Boss 血条。
     *
     * @param f Boss。
     */
    public function setMusouBossHp(f:FighterMain):void {
        var ui:MusouUI = _ui as MusouUI;
        if (ui) {
            ui.setBossHp(f);
        }
    }

    /**
     * 无双：Boss 入场演出。
     *
     * @param finishBack 结束回调。
     */
    public function showMusouBossIn(finishBack:Function = null):void {
        var ui:MusouUI = _ui as MusouUI;
        if (ui) {
            ui.showBossIn(finishBack);
        }
    }

    /**
     * 无双：Boss KO 演出。
     *
     * @param boss Boss。
     * @param finishBack 结束回调。
     */
    public function showMusouBossKO(boss:FighterMain, finishBack:Function = null):void {
        var ui:MusouUI = _ui as MusouUI;
        if (ui) {
            ui.showBossKO(boss, finishBack);
        }
    }

    /**
     * 无双：刷新 KO 数。
     */
    public function updateMusouKONum():void {
        var ui:MusouUI = _ui as MusouUI;
        if (ui) {
            ui.updateKONum();
        }
    }

    /**
     * 无双：刷新 Boss 血条列表。
     */
    public function updateMusouBossHp():void {
        var ui:MusouUI = _ui as MusouUI;
        if (ui) {
            ui.updateBossHp();
        }
    }

    /**
     * 无双：跟随敌人血条。
     *
     * @param f 敌人。
     */
    public function updateMusouEnemyBar(f:FighterMain):void {
        var ui:MusouUI = _ui as MusouUI;
        if (ui) {
            ui.updateEnemyBar(f);
        }
    }

    /**
     * 场景转场淡入。
     *
     * @param back 完成回调。
     * @param removeAfterComplete 完成后是否移除转场层。
     */
    public static function transIn(back:Function = null, removeAfterComplete:Boolean = false):void {
        addTransUI();
        if (removeAfterComplete) {
            _transUI.fadIn(removeSelf);
        }
        else {
            _transUI.fadIn(back);
        }

        function removeSelf():void {
            if (back != null) {
                back();
            }
            removeTransUI();
        }
    }

    /**
     * 场景转场淡出。
     *
     * @param back 完成回调。
     * @param removeAfterComplete 完成后是否移除转场层。
     */
    public static function transOut(back:Function = null, removeAfterComplete:Boolean = true):void {
        addTransUI();
        if (removeAfterComplete) {
            _transUI.fadOut(removeSelf);
        }
        else {
            _transUI.fadOut(back);
        }

        function removeSelf():void {
            if (back != null) {
                back();
            }
            removeTransUI();
        }
    }

    /**
     * 快速转场。
     *
     * @param back 完成回调。
     */
    public static function quickTrans(back:Function = null):void {
        ensureTransContainer();
        if (!_transContainer) {
            if (back != null) {
                back();
            }

            return;
        }
        _quickTransUI ||= new QuickTransUI();
        _transContainer.addChild(_quickTransUI);
        _quickTransUI.fadInAndOut(transCom);

        function transCom():void {
            try {
                _transContainer.removeChild(_quickTransUI);
            }
            catch (e:Error) {
            }
            if (back != null) {
                back();
            }
        }
    }

    /**
     * 清除转场层。
     */
    public static function clearTrans():void {
        removeTransUI();
    }

    private static function ensureTransContainer():void {
        if (!_transContainer && MainGame.I) {
            _transContainer = MainGame.I.root;
        }
    }

    private static function addTransUI():void {
        ensureTransContainer();
        if (!_transUI) {
            _transUI = new TransUI();
        }
        _transContainer.addChild(_transUI.ui);
    }

    private static function removeTransUI():void {
        if (!_transUI || !_transContainer) {
            return;
        }
        try {
            _transContainer.removeChild(_transUI.ui);
        }
        catch (e:Error) {
        }
    }

    private function renderAnimate():void {
        if (_ui) {
            _ui.renderAnimate();
        }
    }

    private function isRenderAnimate():Boolean {
        if (_renderAnimateGap > 0) {
            if (_renderAnimateFrame++ >= _renderAnimateGap) {
                _renderAnimateFrame = 0;
                return true;
            }
            else {
                return false;
            }
        }
        return true;
    }

}
}
