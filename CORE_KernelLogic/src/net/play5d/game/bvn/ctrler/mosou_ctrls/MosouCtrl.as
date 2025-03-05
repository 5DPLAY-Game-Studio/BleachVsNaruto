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

package net.play5d.game.bvn.ctrler.mosou_ctrls {
import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.ctrler.StateCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameRunFighterGroup;
import net.play5d.game.bvn.data.mosou.MosouEnemyVO;
import net.play5d.game.bvn.data.mosou.MosouFighterLogic;
import net.play5d.game.bvn.data.mosou.MosouMissionVO;
import net.play5d.game.bvn.data.mosou.MosouModel;
import net.play5d.game.bvn.data.mosou.MosouWaveRepeatVO;
import net.play5d.game.bvn.data.mosou.MosouWaveVO;
import net.play5d.game.bvn.data.mosou.MousouGameRunDataVO;
import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.factory.GameRunFactory;
import net.play5d.game.bvn.fighter.data.FighterActionState;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.ctrler.EnemyBossAICtrl;
import net.play5d.game.bvn.fighter.ctrler.EnemyFighterAICtrl;
import net.play5d.game.bvn.fighter.events.FighterEvent;
import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.map.MapMain;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.ui.mosou.MosouUI;

public class MosouCtrl {
    include '../../../../../../../include/_INCLUDE_.as';

    public const gameRunData:MousouGameRunDataVO = new MousouGameRunDataVO();

    public function MosouCtrl() {
    }
    public var waveCount:int;
    public var currentWave:int;
    private var _mission:MosouMissionVO;
    private var _runningWaves:Vector.<MosouWaveVO>;
    private var _runningWave:MosouWaveVO;
    private var _stageEnemies:Vector.<FighterMain>;
    private var _bossCount:int;
    private var _renderTimer:int;
    private var _renderTimerMax:int;
    private var _fighterEventCtrl:MosouFighterEventCtrl;
    private var _enemyBarCtrl:MosouEnemyBarCtrl;
    private var _changeFighterGap:int;
    private var _resumeGap:int;
    private var _enemyCreators:Vector.<EnemyCreator> = new Vector.<EnemyCreator>();
    private var _missionComplete:Boolean;
    private var _gameFinish:Boolean = false;
    private var _addEnemyGap:int = 0;
    private var _introBoss:FighterMain;
    private var _bossInAnimate:Boolean;

    public function getFighterEventCtrl():MosouFighterEventCtrl {
        return _fighterEventCtrl;
    }

    public function getGameFinished():Boolean {
        return _gameFinish;
    }

    public function initalize():void {
        _mission         = MosouModel.I.currentMission;
        _missionComplete = false;

        _bossCount = _mission.bossCount();

        _enemyBarCtrl = new MosouEnemyBarCtrl();

        _stageEnemies = new Vector.<FighterMain>();

        _fighterEventCtrl = new MosouFighterEventCtrl();
        _fighterEventCtrl.initlize();

        waveCount   = _mission.waves.length;
        currentWave = 0;

        _gameFinish = false;

//			MosouFighterModel.I.init();


//			gameRunData.reset();
    }

    public function destory():void {
        GameEvent.removeEventListener(GameEvent.LEVEL_UP, onLevelUp);

        if (_enemyBarCtrl) {
            _enemyBarCtrl.destory();
            _enemyBarCtrl = null;
        }

        if (_enemyCreators) {
            _enemyCreators = null;
        }

        if (_fighterEventCtrl) {
            _fighterEventCtrl.destory();
            _fighterEventCtrl = null;
        }

    }

    public function buildGame():void {
        _runningWaves = _mission.waves.concat();

        var p1Group:GameRunFighterGroup = GameCtrl.I.gameRunData.p1FighterGroup;

        var datas:Vector.<MosouFighterVO> = GameData.I.mosouData.getFighterTeam();

        p1Group.putFighter(GameRunFactory.createFighterByMosouData(p1Group.fighter1, datas[0], '1'));
        p1Group.putFighter(GameRunFactory.createFighterByMosouData(p1Group.fighter2, datas[1], '1'));
        p1Group.putFighter(GameRunFactory.createFighterByMosouData(p1Group.fighter3, datas[2], '1'));

        p1Group.currentFighter = p1Group.getFighter(p1Group.fighter1);

        var p1:FighterMain = p1Group.currentFighter;
        var map:MapMain    = GameRunFactory.createMapByData(GameCtrl.I.gameRunData.map);

        if (!p1 || !map) {
            throw new Error(GetLang('debug.error.data.musou_ctrl.build_game_fail'));
            return;
        }


        GameCtrl.I.addFighter(p1, 1);

        map.initlize();

        GameCtrl.I.gameState.initMosouFight(GameCtrl.I.gameRunData.p1FighterGroup, map);

        GameLogic.initGameLogic(map, GameCtrl.I.gameState.camera);

        GameCtrl.I.initMainLogic();

        GameCtrl.I.initStart().startMosou();

        GameInterface.instance.afterBuildGame();

        GameEvent.addEventListener(GameEvent.LEVEL_UP, onLevelUp);

        if (Math.random() < 0.7) {
            SoundCtrl.I.playFighterBGM(p1.data.id);
        }
        else {
            SoundCtrl.I.smartPlayGameBGM('map');
        }

        GameEvent.dispatchEvent(GameEvent.MOSOU_MISSION_START);

    }

    public function render():void {
        _enemyBarCtrl.render();
    }

    public function renderAnimate():void {
        _enemyBarCtrl.renderAnimate();
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

    public function addEnemyFighter(fighter:FighterMain):void {
        if (!fighter) {
            return;
        }

        if (!fighter.initlized()) {

            var ctrl:IFighterActionCtrl;
            if (fighter.mosouEnemyData && fighter.mosouEnemyData.isBoss) {
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

            fighter.initlize();
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

    public function removeEnemy(enemy:FighterMain):void {
        var index:int = _stageEnemies.indexOf(enemy);
        if (index != -1) {
            _stageEnemies.splice(index, 1);
        }

        GameCtrl.I.removeFighter(enemy);

        checkNextOrWin();
    }

    public function onSelfDie(f:FighterMain):void {
        TraceLang('debug.trace.data.musou_ctrl.self_die');
        GameCtrl.I.actionEnable = false;

        EffectCtrl.I.doEffectById('hit_end', f.x, f.y);
        EffectCtrl.I.shine(0xff0000, 0.8);

        GameCtrl.I.gameState.cameraFocusOne(f.getDisplay());
        EffectCtrl.I.slowDown(2, 5000);
    }

    public function onSelfDead(f:FighterMain):void {
        _gameFinish = true;

        GameEvent.dispatchEvent(GameEvent.MOSOU_MISSION_FINISH);

        (
                GameUI.I.getUI() as MosouUI
        ).showLose(function ():void {
            TraceLang('debug.trace.data.musou_ctrl.self_die_complete');
            backToWorldMap();
        });
    }

    public function anyWaypassMission():void {
        missionComplete();
    }

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

        if (to.initlized()) {
            GameCtrl.I.addGameSprite(to.team.id, to);
        }
        else {
            GameCtrl.I.addFighter(to, 1);
        }

        group.currentFighter = to;

        _changeFighterGap = GameConfig.FPS_ANIMATE;
        (
                GameUI.I.getUI() as MosouUI
        ).updateFighter();

        EffectCtrl.I.doEffectById('team_change', to.x, to.y);

        to.updatePosition();

        updateCamera();


        TraceLang('debug.trace.data.musou_ctrl.show_fzqi',to.fzqi);
        TraceLang('debug.trace.data.musou_ctrl.show_fzqi_max',to.fzqiMax);
    }

    public function updateEnemy(v:FighterMain):void {
        if (_enemyBarCtrl) {
            _enemyBarCtrl.updateEnemyBar(v);
        }
    }

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

    public function onBossBirth(f:FighterMain):void {
        GameCtrl.I.actionEnable = false;

        _introBoss = f;

        f.getCtrler().setDirectToTarget();

        GameCtrl.I.gameState.cameraFocusOne(f.getDisplay());

        _bossInAnimate = false;

        var ui:MosouUI = GameUI.I.getUI() as MosouUI;
        if (ui) {
            ui.setBossHp(f);
            _bossInAnimate = true;
            SoundCtrl.I.BGM(null);

            ui.showBossIn(function ():void {
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

    public function onBossDie(f:FighterMain):void {
        TraceLang('debug.trace.data.musou_ctrl.boss_die');
        (
                GameUI.I.getUI() as MosouUI
        ).showBossKO(f, function ():void {

        });
    }

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

//			if(_addEnemyGap++ < 15) return;

        var ev:MosouEnemyVO = _enemyCreators[0].getNextEnemy();
        if (ev) {
            addEmeny(ev);
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
        var repeats:Vector.<MosouWaveRepeatVO> = _runningWave.repeats;
        if (!repeats || repeats.length < 1) {
            return;
        }

        for (var i:int = 0; i < repeats.length; i++) {
            renderRepeat(repeats[i]);
        }

    }

    private function renderRepeat(data:MosouWaveRepeatVO):void {
        if (!data.enemies || data.enemies.length < 1) {
            return;
        }

        var result:Vector.<MosouEnemyVO> = null;

        if (data._holdFrame > 0) {
            data._holdFrame--;
            return;
        }

        data._holdFrame = GameConfig.FPS_ANIMATE * data.hold;

        if (data.type == 1) {
            result = new Vector.<MosouEnemyVO>();

            for each(var i:MosouEnemyVO in data.enemies) {
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
//				trace('==== renderRepeat '+result.length+'   ===============================');
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
            TraceLang('debug.trace.data.musou_ctrl.wave_end');
            return;
        }

        TraceLang('debug.trace.data.musou_ctrl.wave_next');

        var wave:MosouWaveVO = _runningWaves.shift();
        _runningWave         = wave;

        currentWave++;

        _renderTimerMax = wave.hold * GameConfig.FPS_ANIMATE;
        _renderTimer    = _renderTimerMax;

        if (wave.enemies) {
            _enemyCreators.push(new EnemyCreator(wave.enemies));
        }

    }

    private function addEmeny(data:MosouEnemyVO):void {
        var enemy:FighterMain = GameRunFactory.createEnemyByData(data);
        _stageEnemies.push(enemy);
        addEnemyFighter(enemy);
    }

    private function getBossEnemies(checkIsAlive:Boolean = false):Vector.<FighterMain> {
        return _stageEnemies.filter(function (f:FighterMain, i:int, a:Vector.<FighterMain>):Boolean {
            if (checkIsAlive) {
                return f.isAlive && f.mosouEnemyData.isBoss;
            }
            return f.mosouEnemyData.isBoss;
        });
    }

    private function getEnemyByData(mosouData:MosouEnemyVO):FighterMain {
        var filtered:Vector.<FighterMain> = _stageEnemies.filter(
                function (f:FighterMain, i:int, a:Vector.<FighterMain>):Boolean {
                    return f.mosouEnemyData == mosouData;
                });

        if (!filtered || filtered.length < 1) {
            return null;
        }

        return filtered[0];
    }

    private function onTimeOver():void {
        TraceLang('debug.trace.data.musou_ctrl.time_over');
        GameCtrl.I.actionEnable = false;

        GameEvent.dispatchEvent(GameEvent.MOSOU_MISSION_FINISH);

        (
                GameUI.I.getUI() as MosouUI
        ).showLose(function ():void {
            TraceLang('debug.trace.data.musou_ctrl.time_over_complete');
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

        TraceLang('debug.trace.data.musou_ctrl.mission_complete');

        SoundCtrl.I.BGM(AssetManager.I.getSound('win'), false);

        GameEvent.dispatchEvent(GameEvent.MOSOU_MISSION_FINISH);

        GameCtrl.I.actionEnable = false;
        (
                GameUI.I.getUI() as MosouUI
        ).showWin(function ():void {
            TraceLang('debug.trace.data.musou_ctrl.mission_complete_complete');

            MosouLogic.I.passMission(_mission);
            backToWorldMap();
        });
    }

    private function backToWorldMap():void {
        StateCtrl.I.transIn(transFinish, false);
    }

    private function transFinish():void {
        MainGame.I.goWorldMap();
        GameEvent.dispatchEvent(GameEvent.MOSOU_BACK_MAP);
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

//					KyoTimeout.setTimeout(missionComplete, 2 * GameConfig.FPS_GAME);
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
            if (f.mosouEnemyData && f.mosouEnemyData.repeat) {
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

        var data:MosouFighterVO = e.param;

        var p1:FighterMain = p1Group.currentFighter;
        if (p1 && p1.mosouPlayerData == data) {
            p1.updateProperties();

            var index:int = MosouFighterLogic.ALL_ACTION_LEVELS.indexOf(data.getLevel());
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

import net.play5d.game.bvn.data.mosou.MosouEnemyVO;

internal class EnemyCreator {
    public function EnemyCreator(enemies:Vector.<MosouEnemyVO>) {
        _addEnemies = enemies.concat();
    }
    private var _addEnemies:Vector.<MosouEnemyVO>;

    public function getNextEnemy():MosouEnemyVO {
        if (_addEnemies.length < 1) {
            return null;
        }
        return _addEnemies.shift();
    }
}
