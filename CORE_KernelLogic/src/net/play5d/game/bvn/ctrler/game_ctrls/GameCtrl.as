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

package net.play5d.game.bvn.ctrler.game_ctrls {
import flash.geom.ColorTransform;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.GameLoader;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.ctrler.GameRender;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.ctrler.mosou_ctrls.MosouCtrl;
import net.play5d.game.bvn.data.FighterVO;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.data.GameRunDataVO;
import net.play5d.game.bvn.data.GameRunFighterGroup;
import net.play5d.game.bvn.data.MessionModel;
import net.play5d.game.bvn.data.TeamID;
import net.play5d.game.bvn.data.TeamMap;
import net.play5d.game.bvn.data.TeamVO;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.factory.GameRunFactory;
import net.play5d.game.bvn.fighter.FighterAttacker;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.ctrler.FighterAICtrl;
import net.play5d.game.bvn.fighter.ctrler.FighterKeyCtrl;
import net.play5d.game.bvn.fighter.events.FighterEvent;
import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
import net.play5d.game.bvn.input.GameInputType;
import net.play5d.game.bvn.input.GameInputer;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.map.MapMain;
import net.play5d.game.bvn.stage.GameStage;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.utils.KeyBoarder;

//import net.play5d.game.bvn.data.mosou.MosouMissionModel;
/**
 * 游戏控制类
 */
public class GameCtrl {
    include '../../../../../../../include/_INCLUDE_.as';

    public const gameRunData:GameRunDataVO = new GameRunDataVO();
    private static var _i:GameCtrl;

    public static function get I():GameCtrl {
        _i ||= new GameCtrl();
        return _i;
    }

    public function GameCtrl() {
    }
    public var gameState:GameStage; //游戏主场景
    public var actionEnable:Boolean = false; //是否可操作
    public var autoStartAble:Boolean    = true; //是否可以本机逻辑开始游戏
    public var autoEndRoundAble:Boolean = true; //是否可以本机逻辑结束游戏
    public var fightFinished:Boolean;
    public var slowRate:Number = 0;
    /**
     * 队伍
     */
    private var _teamMap:TeamMap = new TeamMap();
    private var _startCtrl:GameStartCtrl; //开场控制
    private var _fighterEventCtrl:FighterEventCtrl; //角色事件控制
    private var _trainingCtrl:TrainingCtrler; //练习模式控制
    private var _mainLogicCtrl:GameMainLogicCtrler; //游戏主逻辑控制
    private var _endCtrl:GameEndCtrl; //KO，结束游戏控制
    private var _mosouCtrl:MosouCtrl; // 无双游戏控制
    private var _isRenderGame:Boolean = true;
    private var _isPauseGame:Boolean; //暂停
    private var _gameRunning:Boolean;
    private var _renderTimeFrame:int;
    private var _renderAnimateGap:int   = 0; //刷新动画间隔
    private var _renderAnimateFrame:int = 0;
    private var _gameStartAndPause:Boolean; //游戏开始时暂停

    public function getAttacker(name:String, team:int):FighterAttacker {
        if (_mosouCtrl) {
            return _mosouCtrl.getFighterEventCtrl().getAttacker(name, team);
        }
        return _fighterEventCtrl.getAttacker(name, team);
    }

    public function setRenderHit(v:Boolean):void {
        if (_mainLogicCtrl) {
            _mainLogicCtrl.renderHit = v;
        }
    }

    public function getMosouCtrl():MosouCtrl {
        return _mosouCtrl;
    }

    public function getTeamMap():TeamMap {
        return _teamMap;
    }

    public function getFighterByData(data:FighterVO):FighterMain {
        return this.gameState.getFighterByData(data);
    }

    /**
     * 初始化
     */
    public function initlize(gameState:GameStage):void {
        this.gameState = gameState;

        _isPauseGame       = false;
        _isRenderGame      = true;
        _gameRunning       = true;
        _gameStartAndPause = false;

        if (!_mosouCtrl) {
            _fighterEventCtrl = new FighterEventCtrl();
            _fighterEventCtrl.initlize();
        }

        _renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / GameConfig.FPS_ANIMATE) - 1;

        KeyBoarder.focus();
    }

    public function destory():void {

        GameRender.remove(render);
        GameLogic.clear();
        GameInputer.clearInput();

        if (_fighterEventCtrl) {
            _fighterEventCtrl.destory();
            _fighterEventCtrl = null;
        }

        if (_mainLogicCtrl) {
            _mainLogicCtrl.destory();
            _mainLogicCtrl = null;
        }

        if (_trainingCtrl) {
            _trainingCtrl.destory();
            _trainingCtrl = null;
        }

        if (_startCtrl) {
            _startCtrl.destory();
            _startCtrl = null;
        }

        if (_endCtrl) {
            _endCtrl.destory();
            _endCtrl = null;
        }

        if (gameState) {
            gameState = null;
        }

        if (_mosouCtrl) {
            _mosouCtrl.destory();
            _mosouCtrl = null;
        }

        gameRunData.p1FighterGroup.destory();
        gameRunData.p2FighterGroup.destory();

        gameRunData.clear();
        GameLoader.dispose();

        _gameRunning = false;
    }

    /**
     * 获得敌方队伍
     * @param sp 游戏元件
     * @return 敌方队伍
     */
    public function getEnemyTeam(sp:IGameSprite):TeamVO {
        if (sp.team) {
            switch (sp.team.id) {
            case TeamID.TEAM_1:
                return _teamMap.getTeam(TeamID.TEAM_2);
            case TeamID.TEAM_2:
                return _teamMap.getTeam(TeamID.TEAM_1);
            }
        }

        return null;
    }

    /**
     * 增加游戏元件
     */
    public function addGameSprite(teamId:int, sp:IGameSprite, index:int = -1):void {

        if (index != -1) {
            gameState.addGameSpriteAt(sp, index);
        }
        else {
            gameState.addGameSprite(sp);
        }

        var team:TeamVO = _teamMap.getTeam(teamId);
        if (team) {
            sp.team = team;
            team.addChild(sp);
//				Debugger.log('addGameSprite' , teamId , sp);

            if (sp is FighterMain) {
                (
                        sp as FighterMain
                ).targetTeams = _teamMap.getOtherTeams(teamId);
            }

        }
        else {
            Debugger.log(GetLang('debug.log.data.game_ctrl.team_null', 'team'));
        }
    }

    /**
     * 删除
     */
    public function removeGameSprite(sp:IGameSprite, dispose:Boolean = false):void {
        gameState.removeGameSprite(sp);
        var team:TeamVO = sp.team;
        if (team) {
            team.removeChild(sp);
        }
        else {
//				Debugger.log("GameCtrl.removeGameSprite :: team is null!");
        }
        sp.destory(dispose);
    }

    /**
     * 开始游戏
     */
    public function startGame():void {
        if (!autoStartAble) {
            return;
        }
        fightFinished = false;
        doStartGame();
    }

    /**
     * 开始游戏
     */
    public function startMosouGame():void {
        if (!autoStartAble) {
            return;
        }
        fightFinished = false;

        _isPauseGame        = false;
        GameInputer.enabled = true;

        initTeam();

        _mosouCtrl.buildGame();

        GameRender.add(render);

    }

    /**
     * 开始格斗模式
     */
    public function doStartGame():void {
        _isPauseGame = false;

        GameInputer.enabled = true;

        gameRunData.reset();

        initTeam();
        buildGame();

        GameEvent.dispatchEvent(GameEvent.GAME_START);

        GameRender.add(render);
    }

    public function addFighter(fighter:FighterMain, team:int):void {
        if (!fighter) {
            return;
        }

        var ctrl:IFighterActionCtrl;

        switch (team) {
        case 1:
            if (GameMode.isWatch()) {
                ctrl      = new FighterAICtrl();
                (
                        ctrl as FighterAICtrl
                ).AILevel = GameData.I.config.AI_level;
                (
                        ctrl as FighterAICtrl
                ).fighter = fighter;
            }
            else {
                ctrl          = new FighterKeyCtrl();
                (
                        ctrl as FighterKeyCtrl
                ).inputType   = GameInputType.P1;
                (
                        ctrl as FighterKeyCtrl
                ).classicMode = GameData.I.config.keyInputMode == 1;
            }
            break;
        case 2:
            if (GameMode.isVsCPU(false) || GameMode.isAcrade()) {
                //AI CTRL
                ctrl      = new FighterAICtrl();
                (
                        ctrl as FighterAICtrl
                ).AILevel = GameData.I.config.AI_level;
                (
                        ctrl as FighterAICtrl
                ).fighter = fighter;
            }
            else {
                ctrl          = new FighterKeyCtrl();
                (
                        ctrl as FighterKeyCtrl
                ).inputType   = GameInputType.P2;
                (
                        ctrl as FighterKeyCtrl
                ).classicMode = GameData.I.config.keyInputMode == 1;
            }
            break;
        }

        fighter.initlize();
        fighter.setActionCtrl(ctrl);

        addGameSprite(team, fighter);

        FighterEventDispatcher.dispatchEvent(fighter, FighterEvent.BIRTH);
    }

    public function removeFighter(fighter:FighterMain, isDispose:Boolean = false):void {
        if (!fighter) {
            return;
        }
        removeGameSprite(fighter, isDispose);
    }

    public function startNextRound():void {
        doBuildNextRound(GameMode.isTeamMode());
    }

    /**
     * 战斗结束，进行下一关
     */
    public function fightFinish():void {
        fightFinished = true;

        if (GameMode.isAcrade()) {
            if (TeamID.isTeam1(gameRunData.lastWinnerTeam)) {
                if (MessionModel.I.missionAllComplete()) {
                    TraceLang('debug.trace.data.game_ctrl.cleared');

                    MainGame.I.goCongratulations();
                }
                else {
                    TraceLang('debug.trace.data.game_ctrl.next');

                    GameData.I.winnerId = gameRunData.p1FighterGroup.currentFighter.data.id;
                    MainGame.I.goWinner();
                }


            }
            else {
                // 跳转是否继续
                TraceLang('debug.trace.data.game_ctrl.continue');

                gameRunData.continueLoser = gameRunData.p1FighterGroup.currentFighter;
                MainGame.I.goContinue();
            }
        }

        if (GameMode.isVsCPU() || GameMode.isVsPeople()) {
            // 返回选人
            TraceLang('debug.trace.data.game_ctrl.back_select');

            GameEvent.dispatchEvent(GameEvent.GAME_END);
            MainGame.I.goSelect();
        }
    }

    public function initStart():GameStartCtrl {
        _startCtrl   = new GameStartCtrl(GameCtrl.I.gameState);
        actionEnable = false;
        return _startCtrl;
    }

    public function initMainLogic():void {
        _mainLogicCtrl = new GameMainLogicCtrler();
        _mainLogicCtrl.initlize(gameState, _teamMap);
    }

    public function pause(pauseUI:Boolean = false):void {
        if (!_gameRunning) {
            return;
        }
        if (pauseUI && !_isPauseGame) {

            if (_startCtrl || _endCtrl || (
                    _mosouCtrl && _mosouCtrl.getGameFinished()
            )) {
                _gameStartAndPause = true;
                return;
            }

            GameEvent.dispatchEvent(GameEvent.PAUSE_GAME);
            _isPauseGame = true;
            GameUI.I.getUI().pause();

        }
        _isRenderGame = false;
    }

    public function resume(resumeUI:Boolean = false):void {
        if (!_gameRunning) {
            return;
        }

        _gameStartAndPause = false;

        if (resumeUI && _isPauseGame) {
            if (GameUI.I.getUI().resume()) {
                GameEvent.dispatchEvent(GameEvent.RESUME_GAME);
                _isPauseGame = false;
            }
        }
        KeyBoarder.focus();
        _isRenderGame = true;
    }

    /**
     * 游戏结束，KO
     */
    public function gameEnd(winner:FighterMain, loser:FighterMain):void {
        if (!autoEndRoundAble) {
            return;
        }
        if (_endCtrl) {
            return;
        }
        doGameEnd(winner, loser);
    }

    public function doGameEnd(winner:FighterMain, loser:FighterMain):void {
        gameRunData.lastWinnerTeam = winner.team;
        gameRunData.lastWinner     = winner;

        gameRunData.lastLoserData = loser.data;
        gameRunData.lastLoserQi   = loser.qi;

        switch (winner.team.id) {
        case TeamID.TEAM_1:
            gameRunData.p1Wins++;
            if (loser.hp <= 0 && GameMode.isAcrade()) {
                GameLogic.addScoreByKO();
            }

            break;
        case TeamID.TEAM_2:
            gameRunData.p2Wins++;

            break;
        }

        _endCtrl = new GameEndCtrl();
        _endCtrl.initlize(winner, loser);
        actionEnable = false;

        GameEvent.dispatchEvent(GameEvent.ROUND_END);
    }

    public function drawGame():void {
        if (_endCtrl) {
            return;
        }

        gameRunData.lastWinnerTeam = null;
        gameRunData.lastWinner     = null;
        gameRunData.isDrawGame     = true;

        _endCtrl = new GameEndCtrl();
        _endCtrl.drawGame();
        actionEnable = false;

        GameEvent.dispatchEvent(GameEvent.ROUND_END);
    }

    public function slow(rate:Number):void {
        slowRate              = rate;
        var animateFps:Number = GameConfig.FPS_ANIMATE / rate;
        setAnimateFPS(animateFps);
        _mainLogicCtrl.setSpeedPlus(GameConfig.SPEED_PLUS_DEFAULT / rate);
        gameState.camera.tweenSpd = GameConfig.CAMERA_TWEEN_SPD * rate;
    }

    public function slowResume():void {
        slowRate = 0;
        setAnimateFPS(GameConfig.FPS_ANIMATE);
        _mainLogicCtrl.setSpeedPlus(GameConfig.SPEED_PLUS_DEFAULT);
        gameState.camera.tweenSpd = GameConfig.CAMERA_TWEEN_SPD;
    }

    public function onFighterDie(loser:FighterMain):void {
        var winner:FighterMain;

        var team:TeamVO = GameCtrl.I.getEnemyTeam(loser);
        if (team) {
            for each(var i:IGameSprite in team.children) {
                if (i is FighterMain) {
                    winner = i as FighterMain;
                    break;
                }
            }
        }

        GameCtrl.I.gameEnd(winner, loser);
    }

    /************************************************************************************************************************************************************/
    public function initMosouGame():void {
        _mosouCtrl = new MosouCtrl();
        _mosouCtrl.initalize();
    }

    private function renderPause():void {
        if (_startCtrl || _endCtrl) {
            if (GameInputer.back(1) || GameInputer.select(GameInputType.MENU, 1)) {
                if (_startCtrl) {
                    _startCtrl.skip();
                }
                if (_endCtrl) {
                    _endCtrl.skip();
                }
            }
            return;
        }

        if (GameInputer.back(1)) {

            if (GameUI.showingConfrim()) {
                GameUI.cancelConfrim();
                return;
            }

            if (GameUI.showingAlert()) {
                GameUI.closeAlert();
                return;
            }

            if (_isPauseGame) {
                resume(true);
            }
            else {
                pause(true);
            }
        }
    }

    private function buildGame():void {

        gameRunData.p1FighterGroup.currentFighter  = GameRunFactory.createFighterByData(
                gameRunData.p1FighterGroup.fighter1, '1');
        gameRunData.p1FighterGroup.currentAssister = GameRunFactory.createAssisterByData(
                gameRunData.p1FighterGroup.assister, '1');

        gameRunData.p2FighterGroup.currentFighter  = GameRunFactory.createFighterByData(
                gameRunData.p2FighterGroup.fighter1, '2');
        gameRunData.p2FighterGroup.currentAssister = GameRunFactory.createAssisterByData(
                gameRunData.p2FighterGroup.assister, '2');

        var p1:FighterMain = gameRunData.p1FighterGroup.currentFighter;
        var p2:FighterMain = gameRunData.p2FighterGroup.currentFighter;

        if (GameMode.currentMode == GameMode.TRAINING) {
            _trainingCtrl = new TrainingCtrler();
            _trainingCtrl.initlize([p1, p2]);
            gameRunData.gameTimeMax = -1;
        }

        var map:MapMain = GameRunFactory.createMapByData(gameRunData.map);

        if (!p1 || !p2 || !map) {
            throw new Error(GetLang('debug.error.data.game_ctrl.build_game_fail'));
        }

        if (p1.data.id == p2.data.id) {
            var ct:ColorTransform = new ColorTransform();
            ct.greenOffset        = -85;
            p2.colorTransform     = ct;
        }
        else {
            p2.colorTransform = null;
        }

        addFighter(p1, 1);
        addFighter(p2, 2);

        //temp
//			p1.id = 'p1';

        map.initlize();

        gameState.initFight(gameRunData.p1FighterGroup, gameRunData.p2FighterGroup, map);

        GameLogic.initGameLogic(map, gameState.camera);

        initMainLogic();

        if (GameMode.currentMode == GameMode.TRAINING) {
            actionEnable = true;
            GameUI.I.fadIn();

            SoundCtrl.I.smartPlayGameBGM('map');

        }
        else {
            initStart();
            _startCtrl.start1v1(p1, p2);
        }

        GameInterface.instance.afterBuildGame();

    }

    /**
     * 运行下一个回合
     */
    private function buildNextRound(isTeamMode:Boolean):void {
//			if(!autoStartAble) return;
        doBuildNextRound(isTeamMode);
    }

    /**
     * 执行构建下一回合
     * @param isTeamMode 是否为小队模式
     */
    private function doBuildNextRound(isTeamMode:Boolean):void {
        gameState.resetFight(gameRunData.p1FighterGroup, gameRunData.p2FighterGroup);

        _startCtrl = new GameStartCtrl(gameState);

        if (isTeamMode) {
            if (gameRunData.lastWinner) {
                gameRunData.lastWinner.hp = gameRunData.lastWinnerHp;
            }

            var loseTeam:int = TeamID.UNKNOWN;
            if (gameRunData.lastWinnerTeam) {
                loseTeam = TeamID.isTeam1(gameRunData.lastWinnerTeam) ?
                           TeamID.TEAM_2 :
                           TeamID.TEAM_1;
            }

            _startCtrl.start1v1(
                    gameRunData.p1FighterGroup.currentFighter,
                    gameRunData.p2FighterGroup.currentFighter,
                    loseTeam
            );
        }
        else {
            _startCtrl.startNextRound();
        }

        gameRunData.isDrawGame = false;

        GameEvent.dispatchEvent(GameEvent.ROUND_START);
    }

    private function initTeam():void {
        _teamMap.clear();

        var teams:Array = GameMode.getTeams();

        for each(var o:Object in teams) {
            _teamMap.add(new TeamVO(o.id, o.name));
        }

    }

    /**
     * 主ENTER_FRAME
     */
    private function render():void {
        renderPause();

        if (_isPauseGame) {
            return;
        }

        EffectCtrl.I.render();
//			KeyBoardCtrl.I.render();
        gameState.render();
        if (!_isRenderGame) {
            return;
        }

//			return; //debug

        checkRenderAnimate();

        if (_mainLogicCtrl) {
            _mainLogicCtrl.render();
        }

        if (_startCtrl) {
            actionEnable    = false;
            var fin:Boolean = _startCtrl.render();
            if (fin) {
                _startCtrl.destory();
                _startCtrl   = null;
                actionEnable = true;
                gameRunData.setAllowLoseHP(true);

                if (_gameStartAndPause) {
                    pause(true);
                    _gameStartAndPause = false;
                }

            }
        }

        if (_endCtrl) {
            var fin2:Boolean = _endCtrl.render();
            if (fin2) {
                _endCtrl.destory();
                _endCtrl = null;
                runNext();
            }
        }

//			if(actionEnable && !_startCtrl && !_endCtrl){
//				renderGameTime();
//			}

        if (_trainingCtrl) {
            _trainingCtrl.render();
        }

        if (_mosouCtrl) {
            _mosouCtrl.render();
        }
    }

    private function checkRenderAnimate():void {
        if (_renderAnimateGap > 0) {
            if (_renderAnimateFrame++ >= _renderAnimateGap) {
                _renderAnimateFrame = 0;
                renderAnimate();
            }
        }
        else {
            renderAnimate();
        }
    }

    private function renderAnimate():void {
        if (_mainLogicCtrl) {
            _mainLogicCtrl.renderAnimate();
        }

        if (_mosouCtrl) {
            _mosouCtrl.renderAnimate();
        }

        if (actionEnable && !_startCtrl && !_endCtrl && !_mosouCtrl) {
            renderGameTime();
        }
    }

    private function renderGameTime():void {
        if (gameRunData.gameTimeMax != -1) {
            if (++_renderTimeFrame > GameConfig.FPS_ANIMATE) {
                _renderTimeFrame = 0;
                gameRunData.gameTime--;
                if (gameRunData.gameTime <= 0) {
                    fightTimeover();
                }
            }
        }
    }

    private function fightTimeover():void {
        TraceLang('debug.trace.data.game_ctrl.time_over');

        actionEnable = false;

        var fighter1:FighterMain = gameRunData.p1FighterGroup.currentFighter;
        var fighter2:FighterMain = gameRunData.p2FighterGroup.currentFighter;

        gameRunData.isTimerOver = true;

        if (fighter1.hp == fighter2.hp) {
            drawGame();
            return;
        }

        if (fighter1.hp > fighter2.hp) {
            gameEnd(fighter1, fighter2);
        }
        else {
            gameEnd(fighter2, fighter1);
        }

    }

    /**
     * 下一场战斗
     */
    private function runNext():void {
        TraceLang('debug.trace.data.game_ctrl.current_mode', GameMode.currentMode);

        gameRunData.nextRound();

        if (GameMode.isTeamMode()) {
            if (startNextTeamFight()) {
                buildNextRound(true);
                gameRunData.lastWinner = null;
                return;
            }
        }

        if (GameMode.isSingleMode()) {
            if (gameRunData.p1Wins < 2 && gameRunData.p2Wins < 2) {
                buildNextRound(false);
                gameRunData.lastWinner = null;
                return;
            }
        }

        fightFinish();

    }

    private function startNextTeamFight():Boolean {

        if (gameRunData.isDrawGame) {

            var p1NextFighter:FighterVO = gameRunData.p1FighterGroup.getNextFighter();
            var p2NextFighter:FighterVO = gameRunData.p2FighterGroup.getNextFighter();

//				trace(p1NextFighter , p2NextFighter);

            if (!p1NextFighter && !p2NextFighter) {
                return true;
            }

            if (p1NextFighter && !p2NextFighter) {
                gameRunData.lastWinnerTeam = gameRunData.p1FighterGroup.currentFighter.team;
                return false;
            }

            if (!p1NextFighter && p2NextFighter) {
                gameRunData.lastWinnerTeam = gameRunData.p2FighterGroup.currentFighter.team;
                return false;
            }

            nextFighter(gameRunData.p1FighterGroup);
            nextFighter(gameRunData.p2FighterGroup);

            return true;
        }

        switch (gameRunData.lastWinnerTeam.id) {
        case TeamID.TEAM_1:
            return nextFighter(gameRunData.p2FighterGroup);
        case TeamID.TEAM_2:
            return nextFighter(gameRunData.p1FighterGroup);
        }

        gameRunData.lastWinnerTeam = null;

        return true;
    }

    private function nextFighter(fg:GameRunFighterGroup):Boolean {
        if (!fg) {
            return false;
        }

        var team:TeamVO = fg.currentFighter.team;

        var nextFighterData:FighterVO = fg.getNextFighter();
        if (!nextFighterData) {
            return false;
        }

        var nextFighter:FighterMain = GameRunFactory.createFighterByData(nextFighterData, team.id.toString());
        if (!nextFighter) {
            return false;
        }

        if (gameRunData.lastLoserData) {
            if (gameRunData.lastLoserData.comicType == nextFighter.data.comicType) {
                nextFighter.qi = gameRunData.lastLoserQi + 100;
                if (nextFighter.qi > nextFighter.qiMax) {
                    nextFighter.qi = nextFighter.qiMax;
                }
            }
        }

        removeFighter(fg.currentFighter, true);

        fg.currentFighter = nextFighter;

        addFighter(fg.currentFighter, team.id);

        return true;
    }

    private function setAnimateFPS(v:Number):void {
        _renderAnimateGap   = Math.ceil(GameConfig.FPS_GAME / v) - 1;
        _renderAnimateFrame = 0;
    }

}
}
