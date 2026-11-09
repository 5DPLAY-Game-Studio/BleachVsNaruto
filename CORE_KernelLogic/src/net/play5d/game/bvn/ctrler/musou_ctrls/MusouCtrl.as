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

package net.play5d.game.bvn.ctrler.musou_ctrls {
import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.ctrler.StateCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.KoPresentCtrl;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameRunFighterGroup;
import net.play5d.game.bvn.data.musou.MusouEnemyVO;
import net.play5d.game.bvn.data.musou.MusouFighterLogic;
import net.play5d.game.bvn.data.musou.MusouMissionVO;
import net.play5d.game.bvn.data.musou.MusouModel;
import net.play5d.game.bvn.data.musou.MusouWaveRepeatVO;
import net.play5d.game.bvn.data.musou.MusouWaveVO;
import net.play5d.game.bvn.data.musou.MusouGameRunDataVO;
import net.play5d.game.bvn.data.musou.player.MusouFighterVO;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.ctrler.game_ctrls.GameRunFactory;
import net.play5d.game.bvn.data.fighter.FighterActionState;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.ctrler.EnemyBossAICtrl;
import net.play5d.game.bvn.fighter.ctrler.EnemyFighterAICtrl;
import net.play5d.game.bvn.fighter.events.FighterEvent;
import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.map.MapMain;
import net.play5d.game.bvn.ui.GameUI;

/**
 * 无双关卡：刷怪、换人、头目登场和胜负。
 *
 * <p><code>render</code> 是空的，刷怪和计时都在 <code>renderAnimate</code>，而且操作被关掉时不会跑。
 * 波次进度在当前波已经走完时为 1；计时走到负的那一帧会大于 1。
 * 头目登场有一半几率去播角色曲。那次调用找到曲子时还会再播头目曲，没找到时头目曲不会播。
 * 直接调用 <code>addEnemyFighter</code> 不会放进在场列表。</p>
 *
 * @see MusouLogic
 * @see GameCtrl
 */
public class MusouCtrl {

    /**
     * 本关无双运行数据。构造时创建，之后一直是这一份。
     */
    public const gameRunData:MusouGameRunDataVO = new MusouGameRunDataVO();

    /**
     * 本关波次总数。
     *
     * @default 0
     */
    public var waveCount:int;
    /**
     * 已经开始的波次数。
     *
     * @default 0
     */
    public var currentWave:int;
    /** @private */
    private var _mission:MusouMissionVO;
    /** @private */
    private var _runningWaves:Vector.<MusouWaveVO>;
    /** @private */
    private var _runningWave:MusouWaveVO;
    /** @private */
    private var _stageEnemies:Vector.<FighterMain>;
    /** @private */
    private var _bossCount:int;
    /** @private */
    private var _renderTimer:int;
    /** @private */
    private var _renderTimerMax:int;
    /** @private */
    private var _fighterEventCtrl:MusouFighterEventCtrl;
    /** @private */
    private var _changeFighterGap:int;
    /** @private */
    private var _resumeGap:int;
    /** @private */
    private var _enemyCreators:Vector.<EnemyCreator> = new Vector.<EnemyCreator>();
    /** @private */
    private var _missionComplete:Boolean;
    /** @private */
    private var _gameFinish:Boolean                  = false;
    /** @private */
    private var _addEnemyGap:int                     = 0;
    /** @private */
    private var _introBoss:FighterMain;
    /** @private */
    private var _bossInAnimate:Boolean;

    /**
     * 取本关的角色事件控制。还没初始化时为 <code>null</code>。
     *
     * @return 事件控制。
     * @example
     * <listing version="3.0">
     * var events:MusouFighterEventCtrl = ctrl.getFighterEventCtrl();
     * </listing>
     */
    public function getFighterEventCtrl():MusouFighterEventCtrl {
        return _fighterEventCtrl;
    }

    /**
     * 本关是否已经进入结束。
     *
     * <p>自己倒下或通关时为 <code>true</code>。时间到不会改这个值。</p>
     *
     * @return 已结束时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var done:Boolean = ctrl.getGameFinished();
     * </listing>
     */
    public function getGameFinished():Boolean {
        return _gameFinish;
    }

    /**
     * 读当前关卡，并接上无双角色事件。
     *
     * <p>当前关卡为空时抛错。再调用一次会换掉事件控制，上一份不会销毁。</p>
     *
     * @example
     * <listing version="3.0">
     * ctrl.initialize();
     * </listing>
     */
    public function initialize():void {
        _mission         = MusouModel.I.currentMission;
        _missionComplete = false;

        _bossCount = _mission.bossCount();

        _stageEnemies = new Vector.<FighterMain>();

        _fighterEventCtrl = new MusouFighterEventCtrl();
        _fighterEventCtrl.initialize();

        waveCount   = _mission.waves.length;
        currentWave = 0;

        _gameFinish = false;

    }

    /**
     * 去掉升级监听并销毁角色事件控制。
     *
     * <p>场上的敌人不会清掉。</p>
     *
     * @example
     * <listing version="3.0">
     * ctrl.destroy();
     * </listing>
     */
    public function destroy():void {
        GameEvent.removeEventListener(GameEvent.LEVEL_UP, onLevelUp);

        if (_enemyCreators) {
            _enemyCreators = null;
        }

        if (_fighterEventCtrl) {
            _fighterEventCtrl.destroy();
            _fighterEventCtrl = null;
        }

    }

    /**
     * 按当前任务把三人队伍和地图放进场景，并开始无双开场。
     *
     * <p>角色或地图没建出来时记错误并返回。调试器里这次错误会抛出。
     * 大约七成播当前角色的曲子，否则播地图曲。每次调用都会再挂一个升级监听。</p>
     *
     * @example
     * <listing version="3.0">
     * ctrl.buildGame();
     * </listing>
     */
    public function buildGame():void {
        _runningWaves = _mission.waves.concat();

        var p1Group:GameRunFighterGroup = GameCtrl.I.gameRunData.p1FighterGroup;

        var datas:Vector.<MusouFighterVO> = GameData.I.musouData.getFighterTeam();

        p1Group.putFighter(GameRunFactory.createFighterByMusouData(p1Group.fighter1, datas[0], '1'));
        p1Group.putFighter(GameRunFactory.createFighterByMusouData(p1Group.fighter2, datas[1], '1'));
        p1Group.putFighter(GameRunFactory.createFighterByMusouData(p1Group.fighter3, datas[2], '1'));

        p1Group.currentFighter = p1Group.getFighter(p1Group.fighter1);

        var p1:FighterMain = p1Group.currentFighter;
        var map:MapMain    = GameRunFactory.createMapByData(GameCtrl.I.gameRunData.map);

        if (!p1 || !map) {
            ThrowError(Error, GetLang('log.error.musou.musou_ctrl.build_game_fail'));
            return;
        }


        GameCtrl.I.addFighter(p1, 1);

        map.initialize();

        GameCtrl.I.gameState.initMusouFight(GameCtrl.I.gameRunData.p1FighterGroup, map);

        GameLogic.initGameLogic(map, GameCtrl.I.gameState.camera);

        GameCtrl.I.initMainLogic();

        GameCtrl.I.initStart().startMusou();

        GameInterface.instance.afterBuildGame();

        GameEvent.addEventListener(GameEvent.LEVEL_UP, onLevelUp);

        if (Math.random() < 0.7) {
            SoundCtrl.I.playFighterBGM(p1.data.id);
        }
        else {
            SoundCtrl.I.smartPlayGameBGM('map');
        }

        GameEvent.dispatchEvent(GameEvent.MUSOU_MISSION_START);

    }

    /**
     * 空方法。刷怪在 <code>renderAnimate</code>。
     */
    public function render():void {
    }

    /**
     * 推进头目登场。操作开着时再推进波次、刷怪、计时和换人冷却。
     *
     * <p>操作开着、但还没 <code>buildGame</code> 时，读波次列表会抛错。</p>
     */
    public function renderAnimate():void {
        renderBossIn();

        if (!GameCtrl.I.actionEnable) {
            return;
        }

        renderWave();
        renderWaveRepeat();
        renderAddEnemy();
        renderGameTime();
        renderResumeFighters();

        if (_changeFighterGap > 0) {
            _changeFighterGap--;
        }
    }

    /**
     * 当前波次进行了多少。
     *
     * <p>初始化之前两个计数字段都是 0，结果是 1。还没到最后一波、且这一波没有计时上限时为 0。
     * 计时走到负的那一帧会大于 1。</p>
     *
     * @return 进度。
     * @example
     * <listing version="3.0">
     * var per:Number = ctrl.getWavePercent();
     * </listing>
     */
    public function getWavePercent():Number {
        if (currentWave >= waveCount) {
            return 1;
        }
        if (_renderTimerMax < 1) {
            return 0;
        }
        return 1 - (
                _renderTimer / _renderTimerMax
        );
    }

    /**
     * 把敌人放到当前角色附近，播出场并加入 2 队。
     *
     * <p>为空时直接返回。还没初始化的头目用头目 AI，其它用小兵 AI；已经初始化过的改为复活。
     * 不会写入在场列表。当前角色为空时抛错。</p>
     *
     * @param fighter 敌人。
     * @example
     * <listing version="3.0">
     * ctrl.addEnemyFighter(enemy);
     * </listing>
     */
    public function addEnemyFighter(fighter:FighterMain):void {
        if (!fighter) {
            return;
        }

        if (!fighter.initialized()) {

            var ctrl:IFighterActionCtrl;
            if (fighter.musouEnemyData && fighter.musouEnemyData.isBoss) {
                ctrl      = new EnemyBossAICtrl();
                (
                        ctrl as EnemyBossAICtrl
                ).AILevel = 2;
                (
                        ctrl as EnemyBossAICtrl
                ).fighter = fighter;
            }
            else {
                ctrl      = new EnemyFighterAICtrl();
                (
                        ctrl as EnemyFighterAICtrl
                ).fighter = fighter;
            }

            fighter.initialize();
            fighter.setActionCtrl(ctrl);
        }
        else {
            fighter.relive();
        }


        fighter.team = GameCtrl.I.getTeamMap().getTeam(2);

        var p1:FighterMain = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;

        var disX:Number = 100 + (
                Math.random() * 100
        );
        var disY:Number = 50 + (
                Math.random() * 50
        );

        fighter.x = Math.random() > 0.5 ? (
                p1.x + disX
        ) : (
                            p1.x - disX
                    );
        fighter.y = Math.random() > 0.5 ? (
                p1.y + disY
        ) : (
                            p1.y - disY
                    );

        EffectCtrl.I.enemyBirthEffect(fighter);

        GameCtrl.I.addGameSprite(2, fighter);

        FighterEventDispatcher.dispatchEvent(fighter, FighterEvent.BIRTH);

    }

    /**
     * 从在场列表和场景拿掉敌人，并检查是否进入下一波或通关。
     *
     * <p>不在列表里也会从场景拿掉。</p>
     *
     * @param enemy 敌人。
     * @example
     * <listing version="3.0">
     * ctrl.removeEnemy(enemy);
     * </listing>
     */
    public function removeEnemy(enemy:FighterMain):void {
        var index:int = _stageEnemies.indexOf(enemy);
        if (index != -1) {
            _stageEnemies.splice(index, 1);
        }

        GameCtrl.I.removeFighter(enemy);

        checkNextOrWin();
    }

    /**
     * 自己进入死亡动作：关掉操作，播终结闪光，镜头跟过去并慢放 5 秒。
     *
     * @param f 倒下的角色。
     * @example
     * <listing version="3.0">
     * ctrl.onSelfDie(fighter);
     * </listing>
     */
    public function onSelfDie(f:FighterMain):void {
        TraceLang('musou_ctrl.self_die');
        GameCtrl.I.actionEnable = false;

        EffectCtrl.I.doEffectById('hit_end', f.x, f.y);
        EffectCtrl.I.shine(0xff0000, 0.8);

        GameCtrl.I.gameState.cameraFocusOne(f.getDisplay());
        EffectCtrl.I.slowDown(2, 5000);
    }

    /**
     * 自己已经倒下：标成结束，弹出失败，确认后回世界地图。
     *
     * @param f 倒下的角色。当前没有使用。
     * @example
     * <listing version="3.0">
     * ctrl.onSelfDead(fighter);
     * </listing>
     */
    public function onSelfDead(f:FighterMain):void {
        _gameFinish = true;

        GameEvent.dispatchEvent(GameEvent.MUSOU_MISSION_FINISH);

        GameUI.I.showMusouLose(function ():void {
            TraceLang('musou_ctrl.self_die_complete');
            backToWorldMap();
        });
    }

    /**
     * 直接按通关处理。已经通关过时什么都不做。
     *
     * @example
     * <listing version="3.0">
     * ctrl.anyWaypassMission();
     * </listing>
     */
    public function anyWaypassMission():void {
        missionComplete();
    }

    /**
     * 换成另一个自己人，并写满援助气。
     *
     * <p>换人冷却还没结束时直接返回。冷却是 1 秒的动作帧，而且操作关掉时不倒数。
     * 目标已经初始化过时按它自己的队伍放回去；还没初始化时固定放进 1 队。</p>
     *
     * @param from 当前角色。
     * @param to 换上去的角色。
     * @example
     * <listing version="3.0">
     * ctrl.changeFighter(current, next);
     * </listing>
     */
    public function changeFighter(from:FighterMain, to:FighterMain):void {
        if (_changeFighterGap > 0) {
            return;
        }

        var group:GameRunFighterGroup = GameCtrl.I.gameRunData.p1FighterGroup;
        GameCtrl.I.removeFighter(from);

        to.x      = from.x;
        to.y      = from.y;
        to.fzqi   = to.fzqiMax;
        to.direct = from.direct;

        TraceLang('musou_ctrl.show_fzqi', {fzqi: to.fzqi, fzqiMax: to.fzqiMax});

        if (to.initialized()) {
            GameCtrl.I.addGameSprite(to.team.id, to);
        }
        else {
            GameCtrl.I.addFighter(to, 1);
        }

        group.currentFighter = to;

        _changeFighterGap = GameConfig.FPS_ANIMATE;
        GameUI.I.updateMusouFighter();

        EffectCtrl.I.doEffectById('team_change', to.x, to.y);

        to.updatePosition();

        updateCamera();
    }

    /**
     * 刷新这个敌人的血条。
     *
     * @param v 敌人。
     * @example
     * <listing version="3.0">
     * ctrl.updateEnemy(enemy);
     * </listing>
     */
    public function updateEnemy(v:FighterMain):void {
        GameUI.I.updateMusouEnemyBar(v);
    }

    /**
     * 镜头看自己和第一个还活着的头目。
     *
     * <p>在场列表还没建时抛错。</p>
     *
     * @example
     * <listing version="3.0">
     * ctrl.updateCamera();
     * </listing>
     */
    public function updateCamera():void {
        var p1:FighterMain              = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
        var bosses:Vector.<FighterMain> = getBossEnemies(true);
        var p2:FighterMain              = bosses.length > 0 ? bosses[0] : null;

        var focuses:Array = [];
        if (p1) {
            focuses.push(p1.getDisplay());
        }
        if (p2) {
            focuses.push(p2.getDisplay());
        }

        GameCtrl.I.gameState.updateCameraFocus(focuses);

    }

    /**
     * 头目登场：关掉操作，镜头跟过去，并播登场界面。
     *
     * <p>界面存在时先停掉背景音乐。登场回调里有一半几率去播角色曲；找到时还会再播头目曲，没找到时头目曲不会播。
     * 没有界面时不停音乐，台词说完并且不在开场动作里之后会重新打开操作。</p>
     *
     * @param f 头目。
     * @example
     * <listing version="3.0">
     * ctrl.onBossBirth(boss);
     * </listing>
     */
    public function onBossBirth(f:FighterMain):void {
        GameCtrl.I.actionEnable = false;

        _introBoss = f;

        f.getCtrler().setDirectToTarget();

        GameCtrl.I.gameState.cameraFocusOne(f.getDisplay());

        _bossInAnimate = false;

        if (GameUI.I) {
            GameUI.I.setMusouBossHp(f);
            _bossInAnimate = true;
            SoundCtrl.I.BGM(null);

            GameUI.I.showMusouBossIn(function ():void {
                _bossInAnimate = false;

                var played:Boolean = false;
                if (Math.random() < 0.5) {
                    played = SoundCtrl.I.playFighterBGM(f.data.id);
                }

                if (!played) {
                    SoundCtrl.I.playBossBGM(f.data.comicType == 1);
                }

            });
        }

    }

    /**
     * 头目进入死亡动作：镜头、定格和 5 秒慢放，并弹出 KO。
     *
     * @param f 头目。
     * @example
     * <listing version="3.0">
     * ctrl.onBossDie(boss);
     * </listing>
     */
    public function onBossDie(f:FighterMain):void {
        TraceLang('musou_ctrl.boss_die');
        KoPresentCtrl.focus(f);
        KoPresentCtrl.hold();
        KoPresentCtrl.slow(2, 5000);
        GameUI.I.showMusouBossKO(f, function ():void {
            KoPresentCtrl.release();
        });
    }

    /**
     * 头目已经倒下。场上没有其它存活头目时，剩下的敌人进入死亡并通关。
     *
     * <p>还有存活头目时只更新镜头。</p>
     *
     * @param f 头目。当前没有使用。
     * @example
     * <listing version="3.0">
     * ctrl.onBossDead(boss);
     * </listing>
     */
    public function onBossDead(f:FighterMain):void {
        updateCamera();
        checkNextOrWin(true);
    }

    private function renderWave():void {
        if (_runningWaves.length > 0) {
            if (_renderTimer-- < 0) {
                nextWave();
            }
        }
    }

    private function renderResumeFighters():void {
        if (!GameCtrl.I.gameRunData || !GameCtrl.I.gameRunData.p1FighterGroup) {
            return;
        }

        if (_resumeGap-- > 0) {
            return;
        }

        var fighters:Vector.<FighterMain> = GameCtrl.I.gameRunData.p1FighterGroup.getHoldFighters();
        if (!fighters || fighters.length < 1) {
            return;
        }

        for each(var f:FighterMain in fighters) {
            if (f.hp < f.hpMax) {
                f.hp += f.hpMax * 0.01;
                if (f.hp > f.hpMax) {
                    f.hp = f.hpMax;
                }
            }
            if (f.qi < f.qiMax) {
                f.qi += f.qiMax * 0.02;
                if (f.qi > f.qiMax) {
                    f.qi = f.qiMax;
                }
            }
            if (f.energy < f.energyMax) {
                f.energy += f.energyMax * 0.08;
                if (f.energy > f.energyMax) {
                    f.energy = f.energyMax;
                }
            }
        }

        _resumeGap = GameConfig.FPS_ANIMATE;
    }

    private function renderAddEnemy():void {
        if (_enemyCreators.length < 1) {
            return;
        }

        var musouEnemyVO:MusouEnemyVO = _enemyCreators[0].getNextEnemy();
        if (musouEnemyVO) {
            addEnemy(musouEnemyVO);
        }
        else {
            _enemyCreators.shift();
        }

        _addEnemyGap = 0;
    }

    private function renderWaveRepeat():void {
        if (!_runningWave) {
            return;
        }
        var repeats:Vector.<MusouWaveRepeatVO> = _runningWave.repeats;
        if (!repeats || repeats.length < 1) {
            return;
        }

        for (var i:int = 0; i < repeats.length; i++) {
            renderRepeat(repeats[i]);
        }

    }

    private function renderRepeat(data:MusouWaveRepeatVO):void {
        if (!data.enemies || data.enemies.length < 1) {
            return;
        }

        var result:Vector.<MusouEnemyVO> = null;

        if (data._holdFrame > 0) {
            data._holdFrame--;
            return;
        }

        data._holdFrame = GameConfig.FPS_ANIMATE * data.hold;

        if (data.type == 1) {
            result = new Vector.<MusouEnemyVO>();

            for each(var i:MusouEnemyVO in data.enemies) {
                var f:FighterMain = getEnemyByData(i);
                if (!f || !f.isAlive || !f.getActive()) {
                    result.push(i);
                }
            }
        }
        else {
            result = data.enemies;
        }

        if (result && result.length > 0) {
            _enemyCreators.push(new EnemyCreator(result));
        }
    }

    private function renderGameTime():void {
        if (gameRunData.gameTime > 0) {
            gameRunData.gameTime--;
            if (gameRunData.gameTime <= 0) {
                gameRunData.gameTime = 0;
                onTimeOver();
            }
        }
    }

    private function nextWave():void {
        if (_runningWaves.length < 1) {
            TraceLang('musou_ctrl.wave_end');
            return;
        }

        TraceLang('musou_ctrl.wave_next');

        var wave:MusouWaveVO = _runningWaves.shift();
        _runningWave         = wave;

        currentWave++;

        _renderTimerMax = wave.hold * GameConfig.FPS_ANIMATE;
        _renderTimer    = _renderTimerMax;

        if (wave.enemies) {
            _enemyCreators.push(new EnemyCreator(wave.enemies));
        }

    }

    private function addEnemy(data:MusouEnemyVO):void {
        var enemy:FighterMain = GameRunFactory.createEnemyByData(data);
        _stageEnemies.push(enemy);
        addEnemyFighter(enemy);
    }

    private function getBossEnemies(checkIsAlive:Boolean = false):Vector.<FighterMain> {
        return _stageEnemies.filter(function (f:FighterMain, i:int, a:Vector.<FighterMain>):Boolean {
            if (checkIsAlive) {
                return f.isAlive && f.musouEnemyData.isBoss;
            }
            return f.musouEnemyData.isBoss;
        });
    }

    private function getEnemyByData(musouData:MusouEnemyVO):FighterMain {
        var filtered:Vector.<FighterMain> = _stageEnemies.filter(
                function (f:FighterMain, i:int, a:Vector.<FighterMain>):Boolean {
                    return f.musouEnemyData == musouData;
                });

        if (!filtered || filtered.length < 1) {
            return null;
        }

        return filtered[0];
    }

    private function onTimeOver():void {
        TraceLang('musou_ctrl.time_over');
        GameCtrl.I.actionEnable = false;

        GameEvent.dispatchEvent(GameEvent.MUSOU_MISSION_FINISH);

        GameUI.I.showMusouLose(function ():void {
            TraceLang('musou_ctrl.time_over_complete');
            backToWorldMap();
        });
    }

    private function missionComplete():void {
        if (_missionComplete) {
            return;
        }

        _gameFinish      = true;
        _missionComplete = true;
        _runningWave     = null;

        TraceLang('musou_ctrl.mission_complete');

        SoundCtrl.I.BGM(AssetManager.I.getSound('win'), false);

        GameEvent.dispatchEvent(GameEvent.MUSOU_MISSION_FINISH);

        GameCtrl.I.actionEnable = false;
        KoPresentCtrl.focus(GameCtrl.I.gameRunData.p1FighterGroup.currentFighter);
        GameUI.I.showMusouWin(function ():void {
            TraceLang('musou_ctrl.mission_complete_complete');

            MusouLogic.I.passMission(_mission);
            backToWorldMap();
        });
    }

    private function backToWorldMap():void {
        StateCtrl.I.transIn(transFinish, false);
    }

    private function transFinish():void {
        MainGame.I.goWorldMap();
        GameEvent.dispatchEvent(GameEvent.MUSOU_BACK_MAP);
    }

    private function checkNextOrWin(onBossDie:Boolean = false):void {

        var aliveEnemies:Vector.<FighterMain> = getAliveEnemies();

        // NEXT WAVE
        if (_runningWaves.length > 0) {
            if (aliveEnemies.length < 1) {
                if (_renderTimer > 2 * GameConfig.FPS_ANIMATE) {
                    _renderTimer = 2 * GameConfig.FPS_ANIMATE;
                }
            }
            return;
        }

        // BOSS DIE
        if (onBossDie) {
            var bosses:Vector.<FighterMain> = getBossEnemies(true);
            if (bosses.length < 1) {
                for each(var m:FighterMain in aliveEnemies) {
                    m.die();
                }

                missionComplete();
            }
            return;
        }

        // CHECK ENEMY
        if (aliveEnemies.length < 1) {
            missionComplete();
        }

    }

    private function getAliveEnemies():Vector.<FighterMain> {
        return _stageEnemies.filter(function (f:FighterMain, i:int, a:Vector.<FighterMain>):Boolean {
            if (f.musouEnemyData && f.musouEnemyData.repeat) {
                return false;
            }
            return f.isAlive;
        });
    }

    private function renderBossIn():void {
        if (!_introBoss) {
            return;
        }

        if (!_introBoss.introSaid) {
            if (!_introBoss.isInAir) {
                _introBoss.sayIntro();
            }
            return;
        }

        if (!_bossInAnimate && (
                _introBoss.actionState != FighterActionState.KAI_CHANG
        )) {
            _introBoss              = null;
            GameCtrl.I.actionEnable = true;
            updateCamera();
        }
    }

    private function onLevelUp(e:GameEvent):void {
        var p1Group:GameRunFighterGroup = GameCtrl.I.gameRunData.p1FighterGroup;
        if (!p1Group) {
            return;
        }

        var data:MusouFighterVO = e.param;

        var p1:FighterMain = p1Group.currentFighter;
        if (p1 && p1.musouPlayerData == data) {
            p1.updateProperties();

            var index:int = MusouFighterLogic.ALL_ACTION_LEVELS.indexOf(data.getLevel());
            if (index != -1) {
                EffectCtrl.I.doEffectById('level_up_new_act', p1.x, p1.y);
            }
            else {
                EffectCtrl.I.doEffectById('level_up', p1.x, p1.y);
            }

        }
    }


}
}

import net.play5d.game.bvn.data.musou.MusouEnemyVO;

/**
 * 按顺序吐出一份敌人列表。
 *
 * @private
 */
internal class EnemyCreator {
    /**
     * 复制一份敌人列表。传入的数组之后再改，不会影响这里。
     *
     * @param enemies 敌人数据。
     */
    public function EnemyCreator(enemies:Vector.<MusouEnemyVO>) {
        _addEnemies = enemies.concat();
    }
    /** @private */
    private var _addEnemies:Vector.<MusouEnemyVO>;

    /**
     * 取出下一个敌人。
     *
     * @return 敌人数据；列表空了为 <code>null</code>。
     */
    public function getNextEnemy():MusouEnemyVO {
        if (_addEnemies.length < 1) {
            return null;
        }
        return _addEnemies.shift();
    }
}
