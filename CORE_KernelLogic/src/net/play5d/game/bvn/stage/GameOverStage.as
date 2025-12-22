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
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.ctrler.GameRender;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.ctrler.StateCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.input.GameInputType;
import net.play5d.game.bvn.input.GameInputer;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.display.bitmap.BitmapFontText;
import net.play5d.kyo.stage.IStage;
import net.play5d.kyo.utils.KyoTimeout;

public class GameOverStage implements IStage {
    include '../../../../../../include/_INCLUDE_.as';

    public function GameOverStage() {
        StateCtrl.I.clearTrans();
        _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.game_over, ResUtils.GAME_OVER);
        _ui.gotoAndStop(1);
    }
    private var _ui:$game_over$MC_stgGameOver;
    private var _arrow:$common$MC_sltArrow;
    private var _arrowSelected:String;
    private var _keyInited:Boolean;
    private var _keyEnabled:Boolean = true;
    private var _char:FighterMain;
    private var _btns:Array         = [];

    /**
     * 显示对象
     */
    public function get display():DisplayObject {
        return _ui;
    }

    public function showContinue():void {
        _ui.addEventListener(Event.COMPLETE, showContinueComplete, false, 0, true);
        _ui.gotoAndPlay('continue');
        addChar();

        SoundCtrl.I.BGM(AssetManager.I.getSound('continue'));
    }

    public function showGameOver():void {
        _ui.addEventListener(Event.COMPLETE, gameOverComplete, false, 0, true);
        _ui.gotoAndPlay('gameover');
        SoundCtrl.I.playSwcSound(snd_gameover);
        SoundCtrl.I.BGM(null);

        addScore();
    }

    /**
     * 构建
     */
    public function build():void {
    }

    /**
     * 稍后构建
     */
    public function afterBuild():void {
        GameEvent.dispatchEvent(GameEvent.GAME_OVER_CONTINUE);
    }

    /**
     * 销毁
     * @param back 回调函数
     */
    public function destroy(back:Function = null):void {
        GameRender.remove(render);

        if (_btns) {
            for each(var b:DisplayObject in _btns) {
                b.removeEventListener(MouseEvent.MOUSE_OVER, btnMouseHandler);
                b.removeEventListener(MouseEvent.CLICK, btnMouseHandler);
            }
            _btns = null;
        }

        if (_char) {
            try {
                _char.mc.parent.removeChild(_char.mc);
            }
            catch (e:Error) {
            }
            _char = null;
        }

        GameCtrl.I.gameRunData.continueLoser = null;
        GameCtrl.I.destory();

    }

    private function initBtn(name:String):void {
        var btn:Sprite = _ui.getChildByName(name) as Sprite;
        if (!btn) {
            return;
        }
        btn.buttonMode = true;
        btn.addEventListener(MouseEvent.MOUSE_OVER, btnMouseHandler);
        btn.addEventListener(MouseEvent.CLICK, btnMouseHandler);
        _btns.push(btn);
    }

    private function render():void {
        if (!_keyEnabled) {
            return;
        }

        if (GameInputer.left(GameInputType.MENU, 1)) {
            setArrow('btn_yes');
        }
        if (GameInputer.right(GameInputType.MENU, 1)) {
            setArrow('btn_no');
        }
        if (GameInputer.select(GameInputType.MENU, 1)) {
            selectHandler();
        }

    }

    private function selectHandler():void {
        switch (_arrowSelected) {
        case 'btn_yes':
            showContYes();
            break;
        case 'btn_no':
            showContNo();
            break;
        case 'btn_back':
            MainGame.I.goLogo();
            break;
        }
        SoundCtrl.I.sndConfrim();
    }

    private function initArrow(defaultId:String = null):void {
        if (!_arrow) {
            _arrow = ResUtils.I.createDisplayObject(ResUtils.swfLib.common, '$common$MC_sltArrow');
            _ui.addChild(_arrow);
        }

        if (defaultId) {
            setArrow(defaultId);
        }

//			if(!_keyInited){
//				KeyBoardCtrl.I.addEventListener(KeyEvent.KEY_DOWN,onKeyDown);
//				KeyBoardCtrl.I.setFocus();
//			}

        GameRender.add(render);
        GameInputer.focus();

        _keyEnabled = true;

    }

    private function removeArrow():void {
        if (_arrow) {
            try {
                _ui.removeChild(_arrow);
            }
            catch (e:Error) {
            }
            _arrow = null;
        }
        _keyEnabled = false;
    }

    private function setArrow(name:String):void {
        _arrowSelected        = name;
        var btn:DisplayObject = _ui.getChildByName(name);
        if (btn) {
            _arrow.x = btn.x;
            _arrow.y = btn.y;
            SoundCtrl.I.sndSelect();
        }
    }

    private function addChar():void {
        var ct:Sprite = _ui.getChildByName('ct_char') as Sprite;
        if (ct) {
            try {
                var fighter:FighterMain = GameCtrl.I.gameRunData.continueLoser;
                if (fighter) {
                    fighter.scale = 3;
                    fighter.x     = 0;
                    fighter.y     = 0;
                    fighter.setVelocity(0, 0);
                    fighter.setVec2(0, 0);
                    fighter.renderSelf();
                    fighter.lose();
                    ct.addChild(fighter.mc);
                    _char = fighter;
                }
            }
            catch (e:Error) {
                trace(e);
            }

        }
        else {
            KyoTimeout.setFrameout(addChar, 2);
        }
    }

    private function showContYes():void {
        _ui.addEventListener(Event.COMPLETE, showContYesComplete, false, 0, true);
        _ui.gotoAndPlay('continue_yes');
        _keyEnabled = false;
        try {
            _char.idle();
        }
        catch (e:Error) {
            trace(e);
        }
        removeArrow();
    }

    private function showContNo():void {
        _ui.addEventListener(Event.COMPLETE, showContNoComplete, false, 0, true);
        _ui.gotoAndPlay('continue_no');
        removeArrow();
    }

    private function addScore():void {
        var ct:Sprite = _ui.getChildByName('ct_score') as Sprite;
        if (ct) {
            var scoreTxt:BitmapFontText = new BitmapFontText(AssetManager.I.getFont('font1'));
            scoreTxt.text               = 'SCORE ' + GameData.I.score;
            scoreTxt.x                  = -scoreTxt.width / 2;
            ct.addChild(scoreTxt);
        }
        else {
            KyoTimeout.setFrameout(addScore, 1);
        }
    }

    private function showContinueComplete(e:Event):void {
        _ui.removeEventListener(Event.COMPLETE, showContinueComplete);
//			var yesbtn:DisplayObject = _ui.getChildByName('btn_yes');
//			var nobtn:DisplayObject = _ui.getChildByName('btn_no');

        initBtn('btn_yes');
        initBtn('btn_no');

        initArrow('btn_yes');
    }

    private function btnMouseHandler(e:MouseEvent):void {
        var target:DisplayObject = e.currentTarget as DisplayObject;
        switch (e.type) {
        case MouseEvent.MOUSE_OVER:
            setArrow(target.name);
            break;
        case MouseEvent.CLICK:
            _arrowSelected = target.name;
            selectHandler();
            break;
        }
    }

    private function showContYesComplete(e:Event):void {
        _ui.removeEventListener(Event.COMPLETE, showContYesComplete);
        GameLogic.loseScoreByContinue();
        MainGame.I.goSelect();
    }

    private function showContNoComplete(e:Event):void {
        _ui.removeEventListener(Event.COMPLETE, showContNoComplete);
        showGameOver();
    }

    private function gameOverComplete(e:Event):void {
        _ui.removeEventListener(Event.COMPLETE, gameOverComplete);

        GameEvent.dispatchEvent(GameEvent.GAME_OVER);

        initBtn('btn_back');
        initArrow('btn_back');
    }
}
}
