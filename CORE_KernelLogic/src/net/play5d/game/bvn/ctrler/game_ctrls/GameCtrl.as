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
import net.play5d.game.bvn.ctrler.musou_ctrls.MusouCtrl;
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.data.vos.GameRunDataVO;
import net.play5d.game.bvn.data.GameRunFighterGroup;
import net.play5d.game.bvn.data.MessionModel;
import net.play5d.game.bvn.data.TeamID;
import net.play5d.game.bvn.data.TeamMap;
import net.play5d.game.bvn.data.vos.TeamVO;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.events.GameEvent;
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
import net.play5d.kyo.utils.KeyBoarder;

/**
 * 游戏控制类
 */
public class GameCtrl {

    public const gameRunData:GameRunDataVO = new GameRunDataVO();
    private static var _i:GameCtrl;

    public static function get I():GameCtrl {
        _i ||= new GameCtrl();
        return _i;
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
    private var _fightSession:IFightSession; //格斗 / 无双会话
    private var _trainingCtrl:TrainingCtrl; //练习模式控制
    private var _mainLogicCtrl:GameMainLogicCtrl; //游戏主逻辑控制
    private var _endCtrl:GameEndCtrl; //KO，结束游戏控制
    private var _roundCtrl:GameRoundCtrl; //回合推进
    private var _isRenderGame:Boolean = true;
    private var _isPauseGame:Boolean; //暂停
    private var _gameRunning:Boolean;
    private var _renderTimeFrame:int;
    private var _renderAnimateGap:int   = 0; //刷新动画间隔
    private var _renderAnimateFrame:int = 0;
    private var _gameStartAndPause:Boolean; //游戏开始时暂停

    public function getAttacker(name:String, team:int):FighterAttacker {
        return _fightSession.getAttacker(name, team);
    }

    public function setRenderHit(v:Boolean):void {
        if (_mainLogicCtrl) {
            _mainLogicCtrl.renderHit = v;
        }
    }

    public function getMusouCtrl():MusouCtrl {
        return _fightSession ? _fightSession.getMusouCtrl() : null;
    }

    public function getTeamMap():TeamMap {
        return _teamMap;
    }

    /** @private 供 GameRoundCtrl */
    public function get roundStartCtrl():GameStartCtrl {
        return _startCtrl;
    }

    /** @private */
    public function set roundStartCtrl(v:GameStartCtrl):void {
        _startCtrl = v;
    }

    /** @private 供 GameRoundCtrl */
    public function get roundTimeFrame():int {
        return _renderTimeFrame;
    }

    /** @private */
    public function set roundTimeFrame(v:int):void {
        _renderTimeFrame = v;
    }


    public function getFighterByData(data:FighterVO):FighterMain {
        return this.gameState.getFighterByData(data);
    }

    /**
     * 初始化
     */
    public function initialize(gameState:GameStage):void {
        this.gameState = gameState;

        _isPauseGame       = false;
        _isRenderGame      = true;
        _gameRunning       = true;
        _gameStartAndPause = false;

        if (!_fightSession) {
            _fightSession = new VersusFightSession();
        }
        _fightSession.onGameInitialize();

        _renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / GameConfig.FPS_ANIMATE) - 1;

        _roundCtrl ||= new GameRoundCtrl();
        _roundCtrl.bind(this);

        KeyBoarder.focus();
    }

    public function destroy():void {

        GameRender.remove(render);
        GameLogic.clear();
        GameInputer.clearInput();

        // 格斗：FighterEventCtrl 原先在此阶段销毁
        if (_fightSession && !_fightSession.getMusouCtrl()) {
            _fightSession.destroy();
            _fightSession = null;
        }

        if (_mainLogicCtrl) {
            _mainLogicCtrl.destroy();
            _mainLogicCtrl = null;
        }

        if (_trainingCtrl) {
            _trainingCtrl.destroy();
            _trainingCtrl = null;
        }

        if (_startCtrl) {
            _startCtrl.destroy();
            _startCtrl = null;
        }

        if (_endCtrl) {
            _endCtrl.destroy();
            _endCtrl = null;
        }

        if (_roundCtrl) {
            _roundCtrl.destroy();
            _roundCtrl = null;
        }

        if (gameState) {
            gameState = null;
        }

        // 无双：MusouCtrl 原先在此阶段销毁
        if (_fightSession) {
            _fightSession.destroy();
            _fightSession = null;
        }

        gameRunData.p1FighterGroup.destroy();
        gameRunData.p2FighterGroup.destroy();

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
            Debugger.log(GetLang('debug.log.data.game_ctrl.team_null', {name: 'team'}));
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
        sp.destroy(dispose);
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
    public function startMusouGame():void {
        if (!autoStartAble) {
            return;
        }
        fightFinished = false;

        _isPauseGame        = false;
        GameInputer.enabled = true;

        initTeam();

        _fightSession.buildGame();

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
                ctrl = new FighterAICtrl();
                (ctrl as FighterAICtrl).AILevel = GameData.I.config.AI_level;
                (ctrl as FighterAICtrl).fighter = fighter;
            }
            else {
                ctrl = new FighterKeyCtrl();
                (ctrl as FighterKeyCtrl).inputType   = GameInputType.P1;
                (ctrl as FighterKeyCtrl).classicMode = GameData.I.config.keyInputMode == 1;
            }
            break;
        case 2:
            if (GameMode.isVsCPU(false) || GameMode.isArcade()) {
                //AI CTRL
                ctrl = new FighterAICtrl();
                (ctrl as FighterAICtrl).AILevel = GameData.I.config.AI_level;
                (ctrl as FighterAICtrl).fighter = fighter;
            }
            else {
                ctrl = new FighterKeyCtrl();
                (ctrl as FighterKeyCtrl).inputType   = GameInputType.P2;
                (ctrl as FighterKeyCtrl).classicMode = GameData.I.config.keyInputMode == 1;
            }
            break;
        }

        fighter.initialize();
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
        if (_roundCtrl) {
            _roundCtrl.startNextRound();
        }
    }

    /**
     * 战斗结束，进行下一关
     */
    public function fightFinish():void {
        fightFinished = true;

        if (GameMode.isArcade()) {
            if (TeamID.TEAM_1 == gameRunData.lastWinnerTeam.id) {
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
        _mainLogicCtrl = new GameMainLogicCtrl();
        _mainLogicCtrl.initialize(gameState, _teamMap);
    }

    public function pause(pauseUI:Boolean = false):void {
        if (!_gameRunning) {
            return;
        }
        if (pauseUI && !_isPauseGame) {

            if (_startCtrl || _endCtrl || (
                    _fightSession && _fightSession.isFinished()
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
            if (loser.hp <= 0 && GameMode.isArcade()) {
                GameLogic.addScoreByKO();
            }

            break;
        case TeamID.TEAM_2:
            gameRunData.p2Wins++;

            break;
        }

        _endCtrl = new GameEndCtrl();
        _endCtrl.initialize(winner, loser);
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
    public function initMusouGame():void {
        _fightSession = new MusouFightSession();
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
        var p1Group:GameRunFighterGroup = gameRunData.p1FighterGroup;
        var p2Group:GameRunFighterGroup = gameRunData.p2FighterGroup;
        p1Group.currentFighter  = GameRunFactory.createFighterByData(
                p1Group.fighter1,
                '1'
        );
        p2Group.currentFighter  = GameRunFactory.createFighterByData(
                p2Group.fighter1,
                '2'
        );

        var p1:FighterMain = p1Group.currentFighter;
        var p2:FighterMain = p2Group.currentFighter;

        if (GameMode.currentMode == GameMode.TRAINING) {
            _trainingCtrl = new TrainingCtrl();
            _trainingCtrl.initialize([p1, p2]);
            gameRunData.gameTimeMax = -1;
        }

        var map:MapMain = GameRunFactory.createMapByData(gameRunData.map);

        if (!p1 || !p2 || !map) {
            throw new Error(GetLang('debug.error.data.game_ctrl.build_game_fail'));
        }

//        if (p1.data.id == p2.data.id) {
//            var ct:ColorTransform = new ColorTransform();
//            ct.greenOffset        = -85;
//            p2.colorTransform     = ct;
//        }
//        else {
//            p2.colorTransform = null;
//        }


        //temp
//			p1.id = 'p1';

        map.initialize();

        // initFight 方法中包含镜头初始化的实现
        gameState.initFight(
                gameRunData.p1FighterGroup,
                gameRunData.p2FighterGroup,
                map,
                initBack
        );
        function initBack():void {
            p1Group.currentAssister = GameRunFactory.createAssisterByData(
                    p1Group.assister,
                    '1'
            );
            p2Group.currentAssister = GameRunFactory.createAssisterByData(
                    p2Group.assister,
                    '2'
            );
        }

        addFighter(p1, 1);
        addFighter(p2, 2);

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

    private function initTeam():void {
        _teamMap.clear();

        var teams:Array = GameMode.getAllTeams();

        for each(var o:Object in teams) {
            _teamMap.add(new TeamVO(o.id, o.name));
        }

    }

    /**
     * 主 ENTER_FRAME
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
                _startCtrl.destroy();
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
                _endCtrl.destroy();
                _endCtrl = null;
                _roundCtrl.onEndFinished();
            }
        }

//			if(actionEnable && !_startCtrl && !_endCtrl){
//				renderGameTime();
//			}

        if (_trainingCtrl) {
            _trainingCtrl.render();
        }

        if (_fightSession) {
            _fightSession.render();
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

        if (_fightSession) {
            _fightSession.renderAnimate();
        }

        if (actionEnable && !_startCtrl && !_endCtrl && _fightSession &&
            _fightSession.allowsRoundTimer()) {
            _roundCtrl.renderGameTime();
        }
    }

    private function setAnimateFPS(v:Number):void {
        _renderAnimateGap   = Math.ceil(GameConfig.FPS_GAME / v) - 1;
        _renderAnimateFrame = 0;
    }

}
}
