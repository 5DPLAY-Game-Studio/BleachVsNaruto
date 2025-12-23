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

import flash.display.DisplayObject;
import flash.utils.setTimeout;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.ctrler.GameRender;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.ctrler.StateCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.ctrler.game_stage_loader.GameStageLoadCtrl;
import net.play5d.game.bvn.data.AssisterModel;
import net.play5d.game.bvn.data.FighterModel;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameRunFighterGroup;
import net.play5d.game.bvn.data.MapModel;
import net.play5d.game.bvn.data.vos.SelectVO;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.input.GameInputer;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.ui.select.SelectIndexUI;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.stage.IStage;

//import net.play5d.game.bvn.data.musou.MosouMissionModel;
public class LoadingStage implements IStage {
    include '../../../../../../include/_INCLUDE_.as';

    public static var AUTO_START_GAME:Boolean = true;

    public function LoadingStage() {
    }
    private var _ui:loading_fight_mc;
    private var _sltUI:$loading$MC_loadingFight;
    private var _destoryed:Boolean;
    private var _loadFin:Boolean;
    private var _selectIndexUI:SelectIndexUI;
    private var _gameFinished:Boolean;

    /**
     * 显示对象
     */
    public function get display():DisplayObject {
        return _ui;
    }

    public function p1SelectFinish():Boolean {
        return _selectIndexUI.p1Finish();
    }

    public function p2SelectFinish():Boolean {
        return _selectIndexUI.p2Finish();
    }

    public function selectFinish():Boolean {
        return _selectIndexUI.isFinish();
    }

    public function getSort():Array {
        return [_selectIndexUI.getP1Order(), _selectIndexUI.getP2Order()];
    }

    public function setOrder(player:int, v:Array):void {
        if (player == 1) {
            _selectIndexUI.setP1Order(v);
        }
        if (player == 2) {
            _selectIndexUI.setP2Order(v);
        }
    }

    /**
     * 构建
     */
    public function build():void {
        GameEvent.dispatchEvent(GameEvent.FIGHT_LOADING_START);

        GameRender.add(render);
        GameInputer.focus();
        GameInputer.enabled = true;

        SoundCtrl.I.BGM(AssetManager.I.getSound('loading'));

        _ui    = ResUtils.I.createDisplayObject(ResUtils.swfLib.fight, '$loading$MC_loadingFight');
        _sltUI = _ui.sltui;

        _selectIndexUI          = new SelectIndexUI();
        _selectIndexUI.onFinish = finish;
        _sltUI.addChild(_selectIndexUI);

    }

    public function gotoGame(sort1:Array, sort2:Array):void {
        var p1group:GameRunFighterGroup = GameCtrl.I.gameRunData.p1FighterGroup;
        var p2group:GameRunFighterGroup = GameCtrl.I.gameRunData.p2FighterGroup;

        p1group.fighter1 = FighterModel.I.getFighter(sort1[0], true);
        p1group.fighter2 = FighterModel.I.getFighter(sort1[1], true);
        p1group.fighter3 = FighterModel.I.getFighter(sort1[2], true);
        p1group.assister = AssisterModel.I.getAssister(GameData.I.p1Select.fuzhu, true);

        p2group.fighter1 = FighterModel.I.getFighter(sort2[0], true);
        p2group.fighter2 = FighterModel.I.getFighter(sort2[1], true);
        p2group.fighter3 = FighterModel.I.getFighter(sort2[2], true);
        p2group.assister = AssisterModel.I.getAssister(GameData.I.p2Select.fuzhu, true);

        GameCtrl.I.gameRunData.map = MapModel.I.getMap(GameData.I.selectMap);

        GameEvent.dispatchEvent(GameEvent.FIGHT_LOADING_FINISH);

        StateCtrl.I.transIn(MainGame.I.goGame, false);

    }

    /**
     * 稍后构建
     */
    public function afterBuild():void {
        StateCtrl.I.transOut(startLoad);
    }

    /**
     * 销毁
     * @param back 回调函数
     */
    public function destroy(back:Function = null):void {
        _destoryed = true;

        if (_selectIndexUI) {
            _selectIndexUI.destory();
            _selectIndexUI = null;
        }

        SoundCtrl.I.BGM(null);

        GameInputer.clearInput();
        GameRender.remove(render);

        GameUI.closeConfrim();
    }

    private function render():void {
        if (GameInputer.back(1)) {
            if (GameUI.showingDialog()) {
                GameUI.cancelConfrim();
            }
            else {
                GameUI.confrim('BACK TITLE?', '返回到主菜单？', MainGame.I.goMenu, null, IsMobile());
                GameEvent.dispatchEvent(GameEvent.CONFRIM_BACK_MENU);
            }
        }
    }

    private function onLoadProcess(msg:String, process:Number):void {
        _sltUI.bar.txt.text   = msg;
        _sltUI.bar.bar.scaleX = process;
    }

    private function onLoadError(msg:String):void {
        Debugger.errorMsg(msg);
    }

    private function onLoadFinish():void {
//			trace('loadFin');

        TweenLite.to(_sltUI, 1, {
            y: 80, onComplete: function ():void {
                setTimeout(delayCall, 2000);
            }
        });

        function delayCall():void {
            _loadFin = true;
            finish();
        }

    }

    private function finish():void {
        if (_destoryed) {
            return;
        }
        if (!_selectIndexUI.isFinish() || !_loadFin) {
            return;
        }
        if (!AUTO_START_GAME) {
            return;
        }

        if (_gameFinished) {
            return;
        }

        _gameFinished = true;

        var sort1:Array = _selectIndexUI.getP1Order();
        var sort2:Array = _selectIndexUI.getP2Order();

        gotoGame(sort1, sort2);
    }

    private function startLoad():void {
        var maps:Array      = [];
        var fighters:Array  = [];
        var assisters:Array = [];
        var bgms:Array      = [];

        maps.push(GameData.I.selectMap);

        var p1selt:SelectVO = GameData.I.p1Select;
        fighters.push(p1selt.fighter1, p1selt.fighter2, p1selt.fighter3);

        var p2selt:SelectVO = GameData.I.p2Select;
        fighters.push(p2selt.fighter1, p2selt.fighter2, p2selt.fighter3);

        assisters.push(p1selt.fuzhu, p2selt.fuzhu);

        bgms = fighters.concat([GameData.I.selectMap]);

        GameStageLoadCtrl.I.init(onLoadProcess, onLoadError);
        GameStageLoadCtrl.I.loadGame(maps, fighters, assisters, bgms, onLoadFinish);

        GameEvent.dispatchEvent(GameEvent.FIGHT_LOADING);
    }
}
}
