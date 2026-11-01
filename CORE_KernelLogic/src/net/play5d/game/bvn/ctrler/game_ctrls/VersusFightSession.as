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

package net.play5d.game.bvn.ctrler.game_ctrls {
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.ctrler.musou_ctrls.MusouCtrl;
import net.play5d.game.bvn.data.AssisterModel;
import net.play5d.game.bvn.data.FighterModel;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.data.GameRunFighterGroup;
import net.play5d.game.bvn.data.MapModel;
import net.play5d.game.bvn.data.MissionModel;
import net.play5d.game.bvn.data.TeamID;
import net.play5d.game.bvn.data.vos.GameRunDataVO;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.fighter.FighterAttacker;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.input.GameInputter;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.map.MapMain;
import net.play5d.game.bvn.ui.GameUI;

/**
 * 格斗（1v1 / 小队 / 练习等）对局会话。
 *
 * <p>负责选人数据、建场、开局，以及闯关 / 对战结束后的场景去向。回合推进仍由 <code>GameRoundCtrl</code> 经门面调度。</p>
 *
 * @see IFightSession
 * @see FighterEventCtrl
 */
public class VersusFightSession implements IFightSession {

    /** @private */
    private var _host:GameCtrl;
    /** @private */
    private var _fighterEventCtrl:FighterEventCtrl;

    /**
     * @inheritDoc
     */
    public function bind(host:GameCtrl):void {
        _host = host;
    }

    /**
     * @inheritDoc
     */
    public function onGameInitialize():void {
        _fighterEventCtrl = new FighterEventCtrl();
        _fighterEventCtrl.initialize();
    }

    /**
     * @inheritDoc
     */
    public function prepare(sort1:Array, sort2:Array):void {
        var runData:GameRunDataVO       = _host.gameRunData;
        var p1group:GameRunFighterGroup = runData.p1FighterGroup;
        var p2group:GameRunFighterGroup = runData.p2FighterGroup;

        p1group.fighter1 = FighterModel.I.getFighter(sort1[0], true);
        p1group.fighter2 = FighterModel.I.getFighter(sort1[1], true);
        p1group.fighter3 = FighterModel.I.getFighter(sort1[2], true);
        p1group.assister = AssisterModel.I.getAssister(GameData.I.p1Select.fuzhu, true);

        p2group.fighter1 = FighterModel.I.getFighter(sort2[0], true);
        p2group.fighter2 = FighterModel.I.getFighter(sort2[1], true);
        p2group.fighter3 = FighterModel.I.getFighter(sort2[2], true);
        p2group.assister = AssisterModel.I.getAssister(GameData.I.p2Select.fuzhu, true);

        runData.map = MapModel.I.getMap(GameData.I.selectMap);
    }

    /**
     * @inheritDoc
     */
    public function start():void {
        _host.clearPause();
        GameInputter.enabled = true;
        _host.gameRunData.reset();
        _host.initTeam();
        buildGame();
        GameEvent.dispatchEvent(GameEvent.GAME_START);
        _host.beginMatchRender();
    }

    /**
     * @inheritDoc
     */
    public function destroy():void {
        if (_fighterEventCtrl) {
            _fighterEventCtrl.destroy();
            _fighterEventCtrl = null;
        }
        _host = null;
    }

    /**
     * @inheritDoc
     */
    public function getAttacker(name:String, team:int):FighterAttacker {
        return _fighterEventCtrl.getAttacker(name, team);
    }

    /**
     * @inheritDoc
     */
    public function buildGame():void {
        var runData:GameRunDataVO       = _host.gameRunData;
        var p1Group:GameRunFighterGroup = runData.p1FighterGroup;
        var p2Group:GameRunFighterGroup = runData.p2FighterGroup;
        p1Group.currentFighter          = GameRunFactory.createFighterByData(p1Group.fighter1, '1');
        p2Group.currentFighter          = GameRunFactory.createFighterByData(p2Group.fighter1, '2');

        var p1:FighterMain = p1Group.currentFighter;
        var p2:FighterMain = p2Group.currentFighter;

        if (GameMode.currentMode == GameMode.TRAINING) {
            _host.attachTraining(p1, p2);
            runData.gameTimeMax = -1;
        }

        var map:MapMain = GameRunFactory.createMapByData(runData.map);
        if (!p1 || !p2 || !map) {
            ThrowError(Error, GetLang('debug.error.data.game_ctrl.build_game_fail'));
            return;
        }

        map.initialize();

        // initFight 方法中包含镜头初始化的实现
        _host.gameState.initFight(runData.p1FighterGroup, runData.p2FighterGroup, map, initBack);

        function initBack():void {
            p1Group.currentAssister = GameRunFactory.createAssisterByData(p1Group.assister, '1');
            p2Group.currentAssister = GameRunFactory.createAssisterByData(p2Group.assister, '2');
        }

        _host.addFighter(p1, 1);
        _host.addFighter(p2, 2);

        GameLogic.initGameLogic(map, _host.gameState.camera);
        _host.initMainLogic();

        if (GameMode.currentMode == GameMode.TRAINING) {
            _host.actionEnable = true;
            GameUI.I.fadIn();
            SoundCtrl.I.smartPlayGameBGM('map');
        }
        else {
            _host.initStart().start1v1(p1, p2);
        }

        GameInterface.instance.afterBuildGame();
    }

    /**
     * @inheritDoc
     */
    public function onFightFinished():void {
        var runData:GameRunDataVO = _host.gameRunData;

        if (GameMode.isArcade()) {
            if (TeamID.TEAM_1 == runData.lastWinnerTeam.id) {
                if (MissionModel.I.missionAllComplete()) {
                    TraceLang('debug.trace.data.game_ctrl.cleared');
                    MainGame.I.goCongratulations();
                }
                else {
                    TraceLang('debug.trace.data.game_ctrl.next');
                    GameData.I.winnerId = runData.p1FighterGroup.currentFighter.data.id;
                    MainGame.I.goWinner();
                }
            }
            else {
                TraceLang('debug.trace.data.game_ctrl.continue');
                runData.continueLoser = runData.p1FighterGroup.currentFighter;
                MainGame.I.goContinue();
            }
        }

        if (GameMode.isVsCPU() || GameMode.isVsPeople()) {
            TraceLang('debug.trace.data.game_ctrl.back_select');
            GameEvent.dispatchEvent(GameEvent.GAME_END);
            MainGame.I.goSelect();
        }
    }

    /**
     * @inheritDoc
     */
    public function render():void {
    }

    /**
     * @inheritDoc
     */
    public function renderAnimate():void {
    }

    /**
     * @inheritDoc
     */
    public function allowsRoundTimer():Boolean {
        return true;
    }

    /**
     * @inheritDoc
     */
    public function isFinished():Boolean {
        return false;
    }

    /**
     * @inheritDoc
     */
    public function getMusouCtrl():MusouCtrl {
        return null;
    }
}
}
