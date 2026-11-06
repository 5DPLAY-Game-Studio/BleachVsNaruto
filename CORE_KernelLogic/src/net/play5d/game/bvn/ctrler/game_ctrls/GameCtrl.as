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
import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.GameLoader;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.ctrler.GameRender;
import net.play5d.game.bvn.ctrler.musou_ctrls.MusouCtrl;
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.data.vos.GameRunDataVO;
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
import net.play5d.game.bvn.input.GameInputter;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.stage.GameStage;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.kyo.utils.KyoKeyboard;

/**
 * 对局门面：暂停、回合、精灵与帧循环。
 *
 * <p>格斗 / 无双的组装、建场、开局和结束后去向由 <code>IFightSession</code> 承担。</p>
 *
 * @see IFightSession
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
        _fightSession.bind(this);
        _fightSession.onGameInitialize();

        _renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / GameConfig.FPS_ANIMATE) - 1;

        _roundCtrl ||= new GameRoundCtrl();
        _roundCtrl.bind(this);

        KyoKeyboard.focus();
    }

    public function destroy():void {

        GameRender.remove(render);
        GameLogic.clear();
        GameInputter.clearInput();

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

        var continueLoser:FighterMain = gameRunData.continueLoser;
        gameRunData.p1FighterGroup.destroy(continueLoser);
        gameRunData.p2FighterGroup.destroy(continueLoser);

        gameRunData.clear();
        GameLoader.dispose();

        _gameRunning = false;
    }

    /**
     * 结束续关流程并清理对局。
     *
     * <p>由续关界面销毁时调用，清空续关保留角色并释放对局控制器。</p>
     *
     * @example
     * <listing version="3.0">
     * GameCtrl.I.finishContinue();
     * </listing>
     */
    public function finishContinue():void {
        gameRunData.continueLoser = null;
        destroy();
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

            if (sp is FighterMain) {
                (
                        sp as FighterMain
                ).targetTeams = _teamMap.getOtherTeams(teamId);
            }

        }
        else {
            LogLang(GameLogger.DEBUG, 'sys', 'game_ctrl.team_null', {name: 'team'});
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
     * 开始无双对局。
     *
     * <p>标志位之后交给当前无双会话开局。</p>
     *
     * @example
     * <listing version="3.0">
     * GameCtrl.I.startMusouGame();
     * </listing>
     */
    public function startMusouGame():void {
        if (!autoStartAble) {
            return;
        }
        fightFinished = false;
        (_fightSession as MusouFightSession).start();
    }

    /**
     * 开始格斗模式。
     *
     * <p>不检查 <code>autoStartAble</code>，供本机开局与联机同步开局共用。</p>
     *
     * @example
     * <listing version="3.0">
     * GameCtrl.I.doStartGame();
     * </listing>
     */
    public function doStartGame():void {
        versusSession().start();
    }

    /**
     * 组装选人对局数据。
     *
     * <p>确保格斗会话存在，并按选人排序写入双方队伍与地图。</p>
     *
     * @param sort1 P1 选人顺序（三个角色 id）。
     * @param sort2 P2 选人顺序（三个角色 id）。
     * @example
     * <listing version="3.0">
     * GameCtrl.I.prepareFight(p1Order, p2Order);
     * </listing>
     */
    public function prepareFight(sort1:Array, sort2:Array):void {
        versusSession().prepare(sort1, sort2);
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
     * 战斗结束，按当前会话决定去向。
     *
     * @example
     * <listing version="3.0">
     * GameCtrl.I.fightFinish();
     * </listing>
     */
    public function fightFinish():void {
        fightFinished = true;
        if (_fightSession) {
            _fightSession.onFightFinished();
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
        KyoKeyboard.focus();
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

    /**
     * 安装无双会话。
     *
     * <p>替换已有会话。随后由 <code>setupMusouGame</code> 组装数据。</p>
     *
     * @example
     * <listing version="3.0">
     * GameCtrl.I.initMusouGame();
     * </listing>
     */
    public function initMusouGame():void {
        if (_fightSession) {
            _fightSession.destroy();
            _fightSession = null;
        }
        _fightSession = new MusouFightSession();
        _fightSession.bind(this);
    }

    /**
     * 组装无双对局数据。
     *
     * <p>初始化无双会话并按当前任务写入计时、玩家队伍与地图，供 <code>startMusouGame</code> 使用。</p>
     *
     * @example
     * <listing version="3.0">
     * GameCtrl.I.setupMusouGame();
     * </listing>
     */
    public function setupMusouGame():void {
        initMusouGame();
        _fightSession.prepare(null, null);
    }

    /**
     * 取得或安装格斗会话。
     *
     * @return 格斗会话。
     */
    private function versusSession():VersusFightSession {
        if (!(_fightSession is VersusFightSession)) {
            if (_fightSession) {
                _fightSession.destroy();
                _fightSession = null;
            }
            _fightSession = new VersusFightSession();
        }
        _fightSession.bind(this);

        return _fightSession as VersusFightSession;
    }

    /**
     * 清除暂停标记，供会话开局。
     */
    internal function clearPause():void {
        _isPauseGame = false;
    }

    /**
     * 注册主循环，供会话开局。
     */
    internal function beginMatchRender():void {
        GameRender.add(render);
    }

    /**
     * 挂上练习控制器。
     *
     * @param p1 左侧角色。
     * @param p2 右侧角色。
     */
    internal function attachTraining(p1:FighterMain, p2:FighterMain):void {
        _trainingCtrl = new TrainingCtrl();
        _trainingCtrl.initialize([p1, p2]);
    }

    private function renderPause():void {
        if (_startCtrl || _endCtrl) {
            if (GameInputter.back(1) || GameInputter.select(GameInputType.MENU, 1)) {
                if (_startCtrl) {
                    _startCtrl.skip();
                }
                if (_endCtrl) {
                    _endCtrl.skip();
                }
            }
            return;
        }

        if (GameInputter.back(1)) {

            if (GameUI.showingConfirm()) {
                GameUI.cancelConfirm();
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

    /**
     * 按当前模式重建队伍表。
     */
    internal function initTeam():void {
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
        gameState.render();
        if (!_isRenderGame) {
            return;
        }

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
