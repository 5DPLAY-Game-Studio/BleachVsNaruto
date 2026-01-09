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

package net.play5d.game.bvn.ui.fight {
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.geom.Point;
import flash.media.SoundTransform;
import flash.utils.getTimer;
import flash.utils.setTimeout;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.data.GameRunFighterGroup;
import net.play5d.game.bvn.data.TeamID;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.data.fighter.FighterActionState;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.ui.ContinueBtn;
import net.play5d.game.bvn.ui.IGameUI;
import net.play5d.game.bvn.ui.PauseDialog;
import net.play5d.game.bvn.utils.ResUtils;

public class FightUI implements IGameUI {
    include '../../../../../../../include/_INCLUDE_.as';

    public static var QI_BAR_MODE:int;

    public function FightUI() {
        ui        = ResUtils.I.createDisplayObject(ResUtils.swfLib.fight, '$fight$MC_fightUI');
        _fightbar = new FightBar(ui.hpbarmc);
        _qibar1   = new QiBar(ui.fzqi1);
        _qibar2   = new QiBar(ui.fzqi2);
        _hits1    = new HitsUI(ui.hits1);
        _hits2    = new HitsUI(ui.hits2);
        _qibar2.setDirect(-1);

        _p1PosUI = ResUtils.I.createDisplayObject(ResUtils.swfLib.fight, '$fight$SP_playerPos1');
        _p2PosUI = ResUtils.I.createDisplayObject(ResUtils.swfLib.fight, '$fight$SP_playerPos2');

        _p1PosUI.visible = false;
        _p2PosUI.visible = false;

        ui.addChild(_p1PosUI);
        ui.addChild(_p2PosUI);

        if (GameMode.isAcrade()) {
            trace('fightUI.initlize');
            _fightbar.initScore();
            GameEvent.addEventListener(GameEvent.SCORE_UPDATE, updateScore);
        }
    }
    public var ui:$fight$MC_fightUI;
    private var _fightbar:FightBar;
    private var _qibar1:QiBar;
    private var _qibar2:QiBar;
    private var _hits1:HitsUI;
    private var _hits2:HitsUI;
    private var _endParam:Object;
    private var _renderEnd:Boolean;
    private var _playOver:Boolean;
    private var _showWinnerDelay:int;
    private var _drawGame:Boolean;
    private var _isSlowDown:Boolean;
    private var _pauseDialog:PauseDialog;
    private var _flyTimer:Number = 0;
    private var _p1PosUI:$fight$SP_playerPos1;
    private var _p2PosUI:$fight$SP_playerPos2;

    public function initlize(p1:GameRunFighterGroup, p2:GameRunFighterGroup):void {
        _fightbar.setFighter(p1, p2);
        _qibar1.setFighter(p1.currentFighter, p1.currentAssister);
        _qibar2.setFighter(p2.currentFighter, p2.currentAssister);
        updateScore(null);
    }

    public function setVolume(v:Number):void {
        var st:SoundTransform = ui.soundTransform;
        st.volume             = v;
        ui.soundTransform     = st;
    }

    public function showWins(fighter:FighterMain, wins:int):void {
        _fightbar.showWin(fighter, wins);
    }

    public function destory():void {
        GameEvent.removeEventListener(GameEvent.SCORE_UPDATE, updateScore);
        if (_pauseDialog) {
            _pauseDialog.destory();
            _pauseDialog = null;
        }
        if (_fightbar) {
            _fightbar.destory();
            _fightbar = null;
        }
        if (_qibar1) {
            _qibar1.destory();
            _qibar1 = null;
        }
        if (_qibar2) {
            _qibar2.destory();
            _qibar2 = null;
        }
        if (_hits1) {
            _hits1.destory();
            _hits1 = null;
        }
        if (_hits2) {
            _hits2.destory();
            _hits2 = null;
        }
        if (ui) {
            try {
                ui.removeChildren();
                ui.stopAllMovieClips();
            }
            catch (e:Error) {
                trace(e);
            }

            ui = null;
        }
    }

    public function getUI():DisplayObject {
        return ui;
    }

    public function render():void {
        _fightbar.render();
        _qibar1.render();
        _qibar2.render();

        var zoom:Number = GameCtrl.I.gameState.camera.getZoom();

        renderPlayerPosUI(zoom);

        if (_renderEnd) {
            renderEnd();
        }
    }

    public function renderAnimate():void {
        _fightbar.renderAnimate();
        _qibar1.renderAnimate();
        _qibar2.renderAnimate();
        renderStartAndKO();
    }

    public function fadIn(animate:Boolean = true):void {
        _fightbar.fadIn(animate);

        if (QI_BAR_MODE == FightQiBarMode.TOP) {
            _qibar1.fadIn(false);
            _qibar2.fadIn(false);
            _qibar1.setPosAndScale(120, 60, 0.8);
            _qibar2.setPosAndScale(675, 60, 0.8);
        }
        else {
            _qibar1.fadIn(animate);
            _qibar2.fadIn(animate);
        }
    }

    public function fadOut(animate:Boolean = true):void {
        _fightbar.fadOut(animate);
        _qibar1.fadOut(animate);
        _qibar2.fadOut(animate);
    }

    public function showHits(hits:int, id:int):void {
        var hitsui:HitsUI = id == 1 ? _hits1 : _hits2;
        hitsui.show(hits);
    }

    public function hideHits(id:int):void {
        var hitsui:HitsUI = id == 1 ? _hits1 : _hits2;
        hitsui.hide();
    }

    public function showStart(finishBack:Function = null, params:Object = null):void {

        fadIn();

        var round:int = GameCtrl.I.gameRunData.round;

        ui.startKOmc.y      = -50;
        ui.startKOmc.$round = round;
        ui.startKOmc.gotoAndStop(round < 5 ? 'start' : 'start_final');
//			ui.startKOmc.gotoAndStop("start_final");

        //fight_in | fight
        ui.startKOmc.addEventListener('fight', onFight);

        if (finishBack != null) {
            ui.startKOmc.addEventListener(Event.COMPLETE, startComplete);
        }

        function onFight(e:Event):void {
            ui.startKOmc.removeEventListener('fight', onFight);
        }

        function startComplete(e:Event):void {
            ui.startKOmc.removeEventListener(Event.COMPLETE, startComplete);
            if (finishBack != null) {
                finishBack();
            }
        }
    }

    public function showEnd(finishBack:Function = null, params:Object = null):void {

        _endParam            = params;
        _endParam ||= {};
        _endParam.finishBack = finishBack;

        _drawGame = params ? params.drawGame : false;

        _renderEnd = true;
        _playOver  = false;

        if (GameCtrl.I.gameRunData.isTimerOver) {
            playTimeOver();
        }
        else {
            var loser:FighterMain = params ? params.loser : null;
            playKO(loser);
        }

    }

    public function showContinue(onClick:Function):void {
        if (!ui) {
            return;
        }

        function onBtnClick(b:ContinueBtn):void {
            onClick();

            b.destory();
            try {
                ui.removeChild(b);
            }
            catch (e:Error) {
            }
        }

//			var btn:SetBtn = new SetBtn("CONTINUE", "继续游戏");
//			btn.hover();
//			btn.x = 300;
//			btn.y = 500;
//			btn.addEventListener(MouseEvent.CLICK, onBtnClick);

        var btn:ContinueBtn = new ContinueBtn();
        btn.x               = 300;
        btn.y               = 500;
        btn.onClick(onBtnClick);

        ui.addChild(btn);
    }

    public function clearStartAndEnd():void {
        ui.startKOmc.gotoAndStop(1);
    }

    public function pause():void {
        if (!_pauseDialog) {
            _pauseDialog = new PauseDialog();
            ui.addChild(_pauseDialog);
        }
        _pauseDialog.show();
    }

    public function resume():Boolean {
        if (!_pauseDialog) {
            return true;
        }
        return _pauseDialog.hide();
    }

    private function renderQibarPos(zoom:Number):void {

        if (QI_BAR_MODE != FightQiBarMode.AUTO) {
            return;
        }

        if (zoom < 1.5) {
            _qibar1.moveTo(120, 60, 0.8);
            _qibar2.moveTo(675, 60, 0.8);
        }
        else {
            _qibar1.moveResume();
            _qibar2.moveResume();
        }
    }

    private function renderStartAndKO():void {
        var stkomc:MovieClip = ui.startKOmc;
        if (!stkomc) {
            return;
        }
        var curLabel:String = stkomc.currentFrameLabel;
        if (curLabel) {
            if (curLabel == 'stop') {
                return;
            }
            if (curLabel.indexOf('go:') != -1) {
                stkomc.gotoAndStop(curLabel.split('go:')[1]);
                return;
            }
        }
        stkomc.nextFrame();
    }

    private function playKO(loser:FighterMain = null):void {

        _showWinnerDelay           = 0;
        EffectCtrl.I.freezeEnabled = false;

        _isSlowDown = false;

        if (loser) {
            EffectCtrl.I.doEffectById('hit_end', loser.x, loser.y);
            EffectCtrl.I.shine(0xffffff, 0.5);
            GameCtrl.I.gameState.cameraFocusOne(loser.getDisplay());
        }

        GameCtrl.I.pause();

        var bsKO:Boolean = false;

        var p1:FighterMain = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
        var p2:FighterMain = GameCtrl.I.gameRunData.p2FighterGroup.currentFighter;

        if (p1 && p2) {
            if (p1.actionState == FighterActionState.BISHA_ING || p1.actionState ==
                FighterActionState.BISHA_SUPER_ING ||
                p2.actionState == FighterActionState.BISHA_ING || p2.actionState == FighterActionState.BISHA_SUPER_ING
            ) {
                bsKO = true;
                EffectCtrl.I.BGEffect('kobg', 2);
            }
        }

        if (!bsKO) {
            EffectCtrl.I.bgBlur(10, 0, 2000);
        }

        EffectCtrl.I.bgBlurEnabled = false;

        EffectCtrl.I.shake(5, 0, 1.5);
        SoundCtrl.I.playSwcSound(snd_over_hit);

        setTimeout(playKO2, 500);

        function playKO2():void {
            ui.startKOmc.y = 0;
            ui.startKOmc.gotoAndStop('ko');
            ui.startKOmc.addEventListener(Event.COMPLETE, koBack);

            SoundCtrl.I.playSwcSound(bsKO ? snd_ko_bs : snd_ko);
            //				fadOut();
            _qibar1.fadOut();
            _qibar2.fadOut();
        }
    }

    private function playTimeOver():void {
        ui.startKOmc.y = 0;
        ui.startKOmc.gotoAndStop('timeover');
        ui.startKOmc.addEventListener(Event.COMPLETE, timeoverBack);
        _qibar1.fadOut();
        _qibar2.fadOut();
    }

    private function playDrawGame():void {
        ui.startKOmc.gotoAndStop('drawgame');
        ui.startKOmc.addEventListener(Event.COMPLETE, drawGameBack);
    }

    private function renderEnd():void {
        if (!_playOver) {
            return;
        }
        if (!_endParam) {
            return;
        }

        if (_showWinnerDelay > 0) {
            _showWinnerDelay--;
            if (_showWinnerDelay <= 0) {
                var winner:FighterMain = _endParam.winner;
                if (winner) {
                    GameCtrl.I.gameState.cameraFocusOne(winner.getDisplay());
//						showWinner(winner , _endParam.finishBack);
                    showWinner(winner);

                    if (GameMode.isSingleMode()) {
                        showWins(winner, GameCtrl.I.gameRunData.getWins(winner));
                    }

                    if (_endParam) {
                        _endParam.finishBack();
                    }
                }
                _renderEnd = false;
                _endParam  = null;
            }
            return;
        }

        var loser:FighterMain = _endParam.loser;

        if (loser) {
            if (loser.actionState == FighterActionState.HURT_FLYING) {
                if (!_isSlowDown) {
                    _isSlowDown = true;
//						EffectCtrl.I.slowDown(2,0);
                    _flyTimer   = getTimer();
                }
            }
            if (loser.actionState == FighterActionState.DEAD) {
                if (_isSlowDown) {

                    if (getTimer() - _flyTimer < 2000) {
                        _showWinnerDelay = 2 * GameConfig.FPS_GAME;
                    }
                    else {
                        _showWinnerDelay = 1 * GameConfig.FPS_GAME;
                    }
                    EffectCtrl.I.slowDownResume();
                }
                else {
                    _showWinnerDelay = 2 * GameConfig.FPS_GAME;
                    EffectCtrl.I.slowDownResume();
                }
            }
        }


    }

    private function showWinner(winner:FighterMain, back:Function = null):void {
        ui.startKOmc.y = 30;
        var teamid:int = winner && winner.team ? winner.team.id : 1;

        if (GameConfig.SHOW_UI_STATUS == 1) {
            ui.startKOmc.$winnerScale = 0.8;
            switch (teamid) {
            case TeamID.TEAM_1:
                ui.startKOmc.$winnerX = 30;
                break;
            case TeamID.TEAM_2:
                ui.startKOmc.$winnerX = 586;
                break;
            }
        }
        else {
            switch (teamid) {
            case 1:
                ui.startKOmc.$winnerX = 30;
                break;
            case 2:
                ui.startKOmc.$winnerX = 546;
                break;
            }
        }


        ui.startKOmc.$perfect = winner.hp >= winner.hpMax;
        ui.startKOmc.gotoAndStop('winner');

        if (back != null) {
            ui.startKOmc.addEventListener(Event.COMPLETE, winnerBack);
        }

        function winnerBack(e:Event):void {
            ui.startKOmc.removeEventListener(Event.COMPLETE, winnerBack);
            if (back != null) {
                back();
            }
        }

    }

    private function renderPlayerPosUI(zoom:Number):void {
        if (zoom > 1.8) {
            _p1PosUI.visible = _p2PosUI.visible = false;
            return;
        }

        var p1:FighterMain = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
        var p2:FighterMain = GameCtrl.I.gameRunData.p2FighterGroup.currentFighter;

        var pos:Point;

        if (p1) {
            pos              = getPlayerPos(p1);
            _p1PosUI.x       = pos.x;
            _p1PosUI.y       = pos.y;
            _p1PosUI.visible = true;
        }

        if (p2) {
            pos              = getPlayerPos(p2);
            _p2PosUI.x       = pos.x;
            _p2PosUI.y       = pos.y;
            _p2PosUI.visible = true;
        }

    }

    private function getPlayerPos(sp:IGameSprite):Point {
        var pos:Point = GameCtrl.I.gameState.getGameSpriteGlobalPosition(sp, 0, -50);
        if (pos.x < 20) {
            pos.x = 20;
        }
        if (pos.x > GameConfig.GAME_SIZE.x - 20) {
            pos.x = GameConfig.GAME_SIZE.x - 20;
        }
        if (pos.y < 60) {
            pos.y = 60;
        }
        if (pos.y > GameConfig.GAME_SIZE.y - 5) {
            pos.x = GameConfig.GAME_SIZE.x - 5;
        }
        return pos;
    }

    private function updateScore(e:GameEvent):void {
        _fightbar.setScore(GameData.I.score);
    }

    private function koBack(e:Event):void {
        EffectCtrl.I.freezeEnabled = true;
        EffectCtrl.I.bgBlurEnabled = true;
        ui.startKOmc.removeEventListener(Event.COMPLETE, koBack);
        _playOver = true;
        GameCtrl.I.resume();
        GameCtrl.I.slowRate = 2;
        EffectCtrl.I.slowDown(2, 0);
    }

    private function timeoverBack(e:Event):void {
        EffectCtrl.I.freezeEnabled = true;
        ui.startKOmc.removeEventListener(Event.COMPLETE, timeoverBack);

        if (_drawGame) {
            playDrawGame();
            _showWinnerDelay = 0;
        }
        else {
            _playOver        = true;
            _showWinnerDelay = 1 * GameConfig.FPS_GAME;
        }

    }

    private function drawGameBack(e:Event):void {
        ui.startKOmc.removeEventListener(Event.COMPLETE, drawGameBack);
        if (_endParam.finishBack != null) {
            _endParam.finishBack();
        }
    }


}
}
