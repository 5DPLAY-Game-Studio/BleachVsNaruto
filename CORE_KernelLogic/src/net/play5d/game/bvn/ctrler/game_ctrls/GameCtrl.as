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
import net.play5d.game.bvn.data.GameInputType;
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
import net.play5d.game.bvn.input.GameInputter;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.stage.GameStage;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.utils.GameLogger;
import net.play5d.kyo.utils.KyoKeyboard;

/**
 * 对局门面：暂停、回合、精灵与帧循环。
 *
 * <p>格斗 / 无双的组装、建场、开局和结束后去向由 <code>IFightSession</code> 承担。</p>
 *
 * @see IFightSession
 */
public class GameCtrl {

    /**
     * 本局运行数据。构造时创建，之后一直是这一份。
     */
    public const gameRunData:GameRunDataVO = new GameRunDataVO();
    /** @private */
    private static var _i:GameCtrl;

    /**
     * 唯一实例。第一次读取时创建。
     *
     * @return 对局控制。
     * @example
     * <listing version="3.0">
     * GameCtrl.I.pause(true);
     * </listing>
     */
    public static function get I():GameCtrl {
        _i ||= new GameCtrl();
        return _i;
    }

    /**
     * 对局场景。
     *
     * @default null
     */
    public var gameState:GameStage;
    /**
     * 是否允许操作。开场和结束演出期间会被写成 <code>false</code>。
     *
     * @default false
     */
    public var actionEnable:Boolean     = false;
    /**
     * 为 <code>false</code> 时，<code>startGame</code> 和 <code>startMusouGame</code> 直接返回。
     *
     * @default true
     */
    public var autoStartAble:Boolean    = true;
    /**
     * 为 <code>false</code> 时，<code>gameEnd</code> 直接返回。<code>doGameEnd</code> 不看这个开关。
     *
     * @default true
     */
    public var autoEndRoundAble:Boolean = true;
    /**
     * 本场是否已经走完结束流程。
     *
     * @default false
     */
    public var fightFinished:Boolean;
    /**
     * 当前慢放倍率。0 表示没有慢放。
     *
     * @default 0
     */
    public var slowRate:Number          = 0;
    /** @private */
    private var _teamMap:TeamMap        = new TeamMap();
    /** @private */
    private var _startCtrl:GameStartCtrl;
    /** @private */
    private var _fightSession:IFightSession;
    /** @private */
    private var _trainingCtrl:TrainingCtrl;
    /** @private */
    private var _mainLogicCtrl:GameMainLogicCtrl;
    /** @private */
    private var _endCtrl:GameEndCtrl;
    /** @private */
    private var _roundCtrl:GameRoundCtrl;
    /** @private */
    private var _isRenderGame:Boolean   = true;
    /** @private */
    private var _isPauseGame:Boolean;
    /** @private */
    private var _gameRunning:Boolean;
    /** @private */
    private var _renderTimeFrame:int;
    /** @private */
    private var _renderAnimateGap:int   = 0;
    /** @private */
    private var _renderAnimateFrame:int = 0;
    /** @private */
    private var _gameStartAndPause:Boolean;

    /**
     * 按名字和队伍找攻击体。
     *
     * <p>会话还没建时抛错。</p>
     *
     * @param name 攻击体名字。
     * @param team 队伍 id。
     * @return 攻击体；没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var a:FighterAttacker = GameCtrl.I.getAttacker(name, team);
     * </listing>
     */
    public function getAttacker(name:String, team:int):FighterAttacker {
        return _fightSession.getAttacker(name, team);
    }

    /**
     * 开关身体和攻击判定。主逻辑还没建时什么都不做。
     *
     * @param v 是否判定。
     * @example
     * <listing version="3.0">
     * GameCtrl.I.setRenderHit(false);
     * </listing>
     */
    public function setRenderHit(v:Boolean):void {
        if (_mainLogicCtrl) {
            _mainLogicCtrl.renderHit = v;
        }
    }

    /**
     * 取当前无双控制。
     *
     * <p>还没有会话时返回 <code>null</code>。</p>
     *
     * @return 无双控制；格斗会话上为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var musou:MusouCtrl = GameCtrl.I.getMusouCtrl();
     * </listing>
     */
    public function getMusouCtrl():MusouCtrl {
        return _fightSession ? _fightSession.getMusouCtrl() : null;
    }

    /**
     * 取队伍表。返回的是内部那一份。
     *
     * @return 队伍表。
     * @example
     * <listing version="3.0">
     * var teams:TeamMap = GameCtrl.I.getTeamMap();
     * </listing>
     */
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


    /**
     * 按角色数据从场景里找场上角色。
     *
     * <p>场景还没设上时抛错。</p>
     *
     * @param data 角色数据。
     * @return 场上角色。
     * @example
     * <listing version="3.0">
     * var f:FighterMain = GameCtrl.I.getFighterByData(data);
     * </listing>
     */
    public function getFighterByData(data:FighterVO):FighterMain {
        return this.gameState.getFighterByData(data);
    }

    /**
     * 绑上场景，并保证有一份格斗会话。
     *
     * <p>还没有会话时新建格斗会话。动作帧间隔是 <code>ceil(逻辑帧 / 动作帧) - 1</code>。</p>
     *
     * @param gameState 对局场景。
     * @example
     * <listing version="3.0">
     * GameCtrl.I.initialize(stage);
     * </listing>
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

    /**
     * 卸掉渲染、输入和各控制器，并清掉加载缓存。
     *
     * <p>格斗会话在清队伍之前销毁。无双会话留到清场景之后再销毁。不防重入。</p>
     *
     * @example
     * <listing version="3.0">
     * GameCtrl.I.destroy();
     * </listing>
     */
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
     * 取精灵对面的队伍。
     *
     * <p>没有队伍，或队伍不是 1、2 时返回 <code>null</code>。</p>
     *
     * @param sp 精灵。
     * @return 敌方队伍。
     * @example
     * <listing version="3.0">
     * var team:TeamVO = GameCtrl.I.getEnemyTeam(sprite);
     * </listing>
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
     * 把精灵放进场景和队伍。
     *
     * <p><code>index</code> 不是 -1 时插到该深度。队伍不存在时只记一条调试日志，精灵仍留在场景里，且没有队伍。
     * 场景还没设上时抛错。</p>
     *
     * @param teamId 队伍 id。
     * @param sp 精灵。
     * @param index 深度。默认 -1，加到显示列表末尾。
     * @example
     * <listing version="3.0">
     * GameCtrl.I.addGameSprite(teamId, sprite);
     * </listing>
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
     * 从场景和队伍拿掉精灵，并调用它的 <code>destroy</code>。
     *
     * <p>场景还没设上时抛错。</p>
     *
     * @param sp 精灵。
     * @param dispose 是否连显示对象一起释放。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * GameCtrl.I.removeGameSprite(sprite);
     * </listing>
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
     * 本机开始格斗。
     *
     * <p><code>autoStartAble</code> 为 <code>false</code> 时直接返回，结束标记也不会清。</p>
     *
     * @example
     * <listing version="3.0">
     * GameCtrl.I.startGame();
     * </listing>
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
     * <p><code>autoStartAble</code> 为 <code>false</code> 时直接返回。当前会话不是无双会话时，后面的调用会抛错。</p>
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

    /**
     * 初始化角色、装上操作或 AI，放进队伍并派发出生。
     *
     * <p><code>fighter</code> 为空时直接返回。1 队在观战模式用 AI，否则用 P1 键。2 队在对电脑或闯关时用 AI，否则用 P2 键。
     * 其它队伍 id 仍会初始化和入队，操作器是 <code>null</code>。经典键位在 <code>keyInputMode == 1</code> 时打开。</p>
     *
     * @param fighter 角色。
     * @param team 队伍 id。
     * @example
     * <listing version="3.0">
     * GameCtrl.I.addFighter(fighter, 1);
     * </listing>
     */
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

    /**
     * 从场上拿掉角色。
     *
     * <p><code>fighter</code> 为空时直接返回。</p>
     *
     * @param fighter 角色。
     * @param isDispose 是否连显示对象一起释放。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * GameCtrl.I.removeFighter(fighter);
     * </listing>
     */
    public function removeFighter(fighter:FighterMain, isDispose:Boolean = false):void {
        if (!fighter) {
            return;
        }
        removeGameSprite(fighter, isDispose);
    }

    /**
     * 开始下一回合。回合控制还没建时什么都不做。
     *
     * @example
     * <listing version="3.0">
     * GameCtrl.I.startNextRound();
     * </listing>
     */
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

    /**
     * 新建开场控制并关掉操作。
     *
     * <p>上一份开场控制不会销毁。场景还没设上时，开场控制里记的是空场景。</p>
     *
     * @return 新的开场控制。
     * @example
     * <listing version="3.0">
     * var start:GameStartCtrl = GameCtrl.I.initStart();
     * </listing>
     */
    public function initStart():GameStartCtrl {
        _startCtrl   = new GameStartCtrl(GameCtrl.I.gameState);
        actionEnable = false;
        return _startCtrl;
    }

    /**
     * 新建主逻辑。上一份不会销毁。
     *
     * <p>场景还没设上时抛错。</p>
     *
     * @example
     * <listing version="3.0">
     * GameCtrl.I.initMainLogic();
     * </listing>
     */
    public function initMainLogic():void {
        _mainLogicCtrl = new GameMainLogicCtrl();
        _mainLogicCtrl.initialize(gameState, _teamMap);
    }

    /**
     * 暂停逻辑帧。
     *
     * <p>对局没在跑时直接返回。开场、结束或会话已结束时，只记下“开场后再暂停”，逻辑帧继续。
     * <code>pauseUI</code> 为 <code>true</code> 且当前没暂停时，会派发暂停事件并让界面进入暂停。</p>
     *
     * @param pauseUI 是否同时暂停界面。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * GameCtrl.I.pause(true);
     * </listing>
     */
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

    /**
     * 恢复逻辑帧，并让键盘重新得到焦点。
     *
     * <p>对局没在跑时直接返回。界面恢复返回 <code>false</code> 时，暂停标记还在，但逻辑帧已经恢复。</p>
     *
     * @param resumeUI 是否同时恢复界面。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * GameCtrl.I.resume(true);
     * </listing>
     */
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
     * 本机结束本回合。
     *
     * <p><code>autoEndRoundAble</code> 为 <code>false</code>，或已经有一份结束控制时，直接返回。</p>
     *
     * @param winner 胜者。
     * @param loser 败者。
     * @example
     * <listing version="3.0">
     * GameCtrl.I.gameEnd(winner, loser);
     * </listing>
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

    /**
     * 记下胜负、胜场，并开始结束演出。
     *
     * <p>不看 <code>autoEndRoundAble</code>。胜者或败者为空时抛错。
     * 1 队获胜且败者体力不大于 0、又是闯关时，再加 KO 分。其它队伍 id 不加胜场。</p>
     *
     * @param winner 胜者。
     * @param loser 败者。
     * @example
     * <listing version="3.0">
     * GameCtrl.I.doGameEnd(winner, loser);
     * </listing>
     */
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

    /**
     * 开始平局演出。
     *
     * <p>已经有结束控制时直接返回。不看 <code>autoEndRoundAble</code>。</p>
     *
     * @example
     * <listing version="3.0">
     * GameCtrl.I.drawGame();
     * </listing>
     */
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

    /**
     * 按倍率放慢动作、移动和镜头。
     *
     * <p>倍率为 0 时会除以 0。主逻辑或场景还没建时抛错。</p>
     *
     * @param rate 倍率，大于 0。
     * @example
     * <listing version="3.0">
     * GameCtrl.I.slow(2);
     * </listing>
     */
    public function slow(rate:Number):void {
        slowRate              = rate;
        var animateFps:Number = GameConfig.FPS_ANIMATE / rate;
        setAnimateFPS(animateFps);
        _mainLogicCtrl.setSpeedPlus(GameConfig.SPEED_PLUS_DEFAULT / rate);
        gameState.camera.tweenSpd = GameConfig.CAMERA_TWEEN_SPD * rate;
    }

    /**
     * 恢复正常速度，并把 <code>slowRate</code> 写成 0。
     *
     * <p>主逻辑或场景还没建时抛错。</p>
     *
     * @example
     * <listing version="3.0">
     * GameCtrl.I.slowResume();
     * </listing>
     */
    public function slowResume():void {
        slowRate = 0;
        setAnimateFPS(GameConfig.FPS_ANIMATE);
        _mainLogicCtrl.setSpeedPlus(GameConfig.SPEED_PLUS_DEFAULT);
        gameState.camera.tweenSpd = GameConfig.CAMERA_TWEEN_SPD;
    }

    /**
     * 角色倒下时，用敌方队伍里第一个角色当胜者并结束回合。
     *
     * <p>找不到胜者时仍会进入结束流程，随后在读胜者队伍时抛错。</p>
     *
     * @param loser 倒下的角色。
     * @example
     * <listing version="3.0">
     * GameCtrl.I.onFighterDie(loser);
     * </listing>
     */
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
