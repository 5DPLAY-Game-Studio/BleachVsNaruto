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

package net.play5d.game.bvn.ui.mosou {
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.geom.Point;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.GameRunFighterGroup;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.data.FighterActionState;
import net.play5d.game.bvn.ui.ContinueBtn;
import net.play5d.game.bvn.ui.IGameUI;
import net.play5d.game.bvn.ui.MosouPauseDialog;
import net.play5d.game.bvn.ui.fight.HitsUI;
import net.play5d.game.bvn.ui.mosou.enemy.BossHpUI;
import net.play5d.game.bvn.ui.mosou.enemy.EnemyHpUIGroup;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.utils.KyoTimeout;

public class MosouUI implements IGameUI {
    include '../../../../../../../include/_INCLUDE_.as';

    public function MosouUI() {
        _ui    = ResUtils.I.createDisplayObject(ResUtils.swfLib.mosou, 'ui_mosou');
        _hpbar = new MosouFightBarUI(_ui.hpbarmc);

        _bossHpBar = new BossHpUI(_ui.bosshp_mc);
        _bossHpBar.enabled(false);

        _timeUI = new MosouTimeUI(_ui.time_mc);
        _waveUI = new MosouWaveUI(_ui.wave_mc);

        _KOUI = new MousouKOsUI(_ui.kos_mc);

        _hitsUI = new HitsUI(_ui.hitsmc);

        _startAndKoMc  = _ui.getChildByName('startKOmc') as MovieClip;
        _startAndKoPos = new Point(_startAndKoMc.x, _startAndKoMc.y);

        _enemyHpBarGroup = new EnemyHpUIGroup(_ui.ct_enemybar);
    }
    private var _ui:ui_mosou;
    private var _hpbar:MosouFightBarUI;
    private var _bossHpBar:BossHpUI;
    private var _enemyHpBarGroup:EnemyHpUIGroup;
    private var _timeUI:MosouTimeUI;
    private var _waveUI:MosouWaveUI;
    private var _KOUI:MousouKOsUI;
    private var _startAndKoMc:MovieClip;
    private var _startAndKoPos:Point;
    private var _hitsUI:HitsUI;
    private var _bosses:Vector.<FighterMain> = new Vector.<FighterMain>();
    private var _pauseDialog:MosouPauseDialog;

    public function initlize(p1:GameRunFighterGroup):void {
        _hpbar.setFighter(p1);
    }

    public function updateFighter():void {
        _hpbar.updateFighters();
    }

//		public function updateEnemyHp(f:FighterMain):void{
//			if(f.mosouData.isBoss){
//				_bossHpBar.setFighter(f);
//				return;
//			}else{
////				_enemyHpBarGroup.updateFighter(f);
//			}
//		}

    public function setBossHp(f:FighterMain):void {
        if (f != null) {
            if (_bosses.indexOf(f) == -1) {
                _bosses.push(f);
            }

            _enemyHpBarGroup.removeByFighter(f);

            for each(var b:FighterMain in _bosses) {
                if (b == f) {
                    continue;
                }
                _enemyHpBarGroup.updateFighter(b);
            }
        }

        _bossHpBar.setFighter(f);
    }

    public function updateBossHp():void {
        for each(var f:FighterMain in _bosses) {
            if (!f.isAlive || !f.getActive()) {
                var index:int = _bosses.indexOf(f);
                if (index != -1) {
                    _bosses.splice(index, 1);
                }
            }
        }

        if (_bosses.length < 1) {
            setBossHp(null);
        }
        else {
            setBossHp(_bosses[0]);
        }

    }

//		public function setBossesHp(bosses:Vector.<FighterMain>):void{
//			if(!bosses || bosses.length < 1){
//				setBossHp(null);
//				return;
//			}
//
//			setBossHp(bosses[0]);
//
//			var others:Vector.<FighterMain> = bosses.slice(1);
//			for each(var b:FighterMain in others){
//				_enemyHpBarGroup.updateFighter(b);
//			}
//		}

    public function setVolume(v:Number):void {
    }

    public function destory():void {
        if (_pauseDialog) {
            _pauseDialog.destory();
            _pauseDialog = null;
        }
    }

    public function fadIn(animate:Boolean = true):void {
    }

    public function fadOut(animate:Boolean = true):void {
    }

    public function getUI():DisplayObject {
        return _ui;
    }

    public function render():void {
        _hpbar.render();
        _bossHpBar.render();
        _enemyHpBarGroup.render();
    }

    public function renderAnimate():void {
        _hpbar.renderAnimate();
        _timeUI.renderAnimate();
        _waveUI.renderAnimate();
        renderStartAndKO();
    }

    public function showHits(hits:int, id:int):void {
        _hitsUI.show(hits);
    }

    public function hideHits(id:int):void {
        _hitsUI.hide();
    }

    public function updateKONum():void {
        _KOUI.update();
    }

    public function showStart(finishBack:Function = null, params:Object = null):void {
        trace('Mosou Start!!');

        playStartKO('mission_start', false);

        _startAndKoMc.addEventListener(Event.COMPLETE, completeHandler);

        function completeHandler(e:Event):void {
            _startAndKoMc.removeEventListener(Event.COMPLETE, completeHandler);
            if (finishBack != null) {
                finishBack();
            }
        }

    }

    public function showEnd(finishBack:Function = null, params:Object = null):void {
        trace('Mosou End!!');
    }

    public function showBossIn(finishBack:Function = null):void {
        playStartKO('boss_in', false);

        _startAndKoMc.addEventListener(Event.COMPLETE, completeHandler);

        function completeHandler(e:Event):void {
            _startAndKoMc.removeEventListener(Event.COMPLETE, completeHandler);
            if (finishBack != null) {
                finishBack();
            }
        }
    }

    public function showBossKO(boss:FighterMain, finishBack:Function = null):void {
        EffectCtrl.I.doEffectById('hit_end', boss.x, boss.y);
        EffectCtrl.I.shine(0xffffff, 0.5);
        GameCtrl.I.gameState.cameraFocusOne(boss.getDisplay());

        EffectCtrl.I.freezeEnabled = false;
        GameCtrl.I.pause();

        var bsKO:Boolean = false;

        var p1:FighterMain = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
        if (p1.actionState == FighterActionState.BISHA_ING || p1.actionState == FighterActionState.BISHA_SUPER_ING) {
            bsKO = true;
            EffectCtrl.I.BGEffect('kobg', 2);
        }

        EffectCtrl.I.slowDown(2, 5000);

//			if(!bsKO){
//				EffectCtrl.I.bgBlur(10, 0);
//			}

//			EffectCtrl.I.bgBlurEnabled = false;

        EffectCtrl.I.shake(5, 0, 1.5);
        SoundCtrl.I.playSwcSound(snd_over_hit);

        KyoTimeout.setTimeout(playKO2, 1000);

        function playKO2():void {
            _startAndKoMc.addEventListener(Event.COMPLETE, koBack);
            playStartKO('boss_ko', false);
            SoundCtrl.I.playSwcSound(bsKO ? snd_ko_bs : snd_ko);
        }

        function koBack(e:Event):void {
            EffectCtrl.I.freezeEnabled = true;
            GameCtrl.I.resume();

            if (finishBack != null) {
                finishBack();
            }
        }
    }

    public function showWin(finishBack:Function = null):void {
        var offset:Point = GameConfig.SHOW_UI_STATUS == 1 ? new Point(0, -50) : null;
        var scale:Number = GameConfig.SHOW_UI_STATUS == 1 ? 0.8 : 1;

        playStartKO('mission_complete', false, offset);

        _startAndKoMc.addEventListener(Event.COMPLETE, completeHandler);

        var p1:FighterMain = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;

        GameCtrl.I.gameState.cameraFocusOne(p1.getDisplay());
//			EffectCtrl.I.slowDown(2, 1000);
//			p1.win();

        KyoTimeout.setTimeout(p1.win, 1000);

        function completeHandler(e:Event):void {
            _startAndKoMc.removeEventListener(Event.COMPLETE, completeHandler);

            if (GameConfig.SHOW_UI_STATUS == 1) {
                showContinue(finishBack);
            }
            else {
                if (finishBack != null) {
                    KyoTimeout.setTimeout(finishBack, 4000);
                }
            }

        }
    }

    public function showLose(finishBack:Function = null):void {
        var offset:Point = GameConfig.SHOW_UI_STATUS == 1 ? new Point(-160, 60) : null;
        var scale:Number = GameConfig.SHOW_UI_STATUS == 1 ? 0.7 : 1;

        playStartKO('mission_fail', false, offset, scale);

        _startAndKoMc.addEventListener(Event.COMPLETE, completeHandler);

//			var p1:FighterMain = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
//
//			GameCtrl.I.gameState.cameraFocusOne(p1.getDisplay());
//			EffectCtrl.I.slowDown(2, 2000);

        function completeHandler(e:Event):void {
            _startAndKoMc.removeEventListener(Event.COMPLETE, completeHandler);

            if (GameConfig.SHOW_UI_STATUS == 1) {
                showContinue(finishBack);
            }
            else {
                if (finishBack != null) {
                    KyoTimeout.setTimeout(finishBack, 3000);
                }
            }

        }
    }

    public function clearStartAndEnd():void {
    }

    public function pause():void {
        if (!_pauseDialog) {
            _pauseDialog = new MosouPauseDialog();
            _ui.addChild(_pauseDialog);
        }
        _pauseDialog.show();
    }

    public function resume():Boolean {
        if (!_pauseDialog) {
            return true;
        }
        return _pauseDialog.hide();
    }

    private function renderStartAndKO():void {
        if (!_startAndKoMc) {
            return;
        }
        var curLabel:String = _startAndKoMc.currentFrameLabel;
        if (curLabel) {
            if (curLabel == 'stop') {
                return;
            }
            if (curLabel.indexOf('go:') != -1) {
                playStartKO(curLabel.split('go:')[1], false);
                return;
            }
        }
        _startAndKoMc.nextFrame();
    }

    private function playStartKO(frame:Object, play:Boolean, offset:Point = null, scale:Number = 1):void {
        if (offset) {
            _startAndKoMc.x = _startAndKoPos.x + offset.x;
            _startAndKoMc.y = _startAndKoPos.y + offset.y;
        }
        else {
            _startAndKoMc.x = _startAndKoPos.x;
            _startAndKoMc.y = _startAndKoPos.y;
        }
        _startAndKoMc.scaleX = _startAndKoMc.scaleY = scale;

        if (play) {
            _startAndKoMc.gotoAndPlay(frame);
        }
        else {
            _startAndKoMc.gotoAndStop(frame);
        }
    }

    private function showContinue(onClick:Function):void {
        if (!_ui) {
            return;
        }

        function onBtnClick(b:ContinueBtn):void {
            onClick();

            b.destory();
            try {
                _ui.removeChild(b);
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

        _ui.addChild(btn);
    }
}
}
