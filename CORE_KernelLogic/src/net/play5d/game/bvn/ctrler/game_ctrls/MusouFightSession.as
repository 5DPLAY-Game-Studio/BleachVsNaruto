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
import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.musou_ctrls.MusouCtrl;
import net.play5d.game.bvn.ctrler.musou_ctrls.MusouLogic;
import net.play5d.game.bvn.data.FighterModel;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameRunFighterGroup;
import net.play5d.game.bvn.data.MapModel;
import net.play5d.game.bvn.data.musou.MusouMissionVO;
import net.play5d.game.bvn.data.musou.MusouModel;
import net.play5d.game.bvn.data.musou.player.MusouFighterVO;
import net.play5d.game.bvn.fighter.FighterAttacker;
import net.play5d.game.bvn.input.GameInputer;

/**
 * 无双对局会话。
 *
 * <p>包装 <code>MusouCtrl</code>，并负责按当前任务组装对局数据与开局。</p>
 *
 * @see IFightSession
 * @see MusouCtrl
 */
public class MusouFightSession implements IFightSession {

    /** @private */
    private var _host:GameCtrl;
    /** @private */
    private var _musouCtrl:MusouCtrl;

    /**
     * 创建并初始化无双控制器（对应原 <code>GameCtrl.initMusouGame</code>）。
     */
    public function MusouFightSession() {
        _musouCtrl = new MusouCtrl();
        _musouCtrl.initialize();
    }

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
    }

    /**
     * @inheritDoc
     */
    public function prepare(sort1:Array, sort2:Array):void {
        // 无双按当前任务组装，不使用选人顺序。
        var mission:MusouMissionVO = MusouModel.I.currentMission;

        _musouCtrl.gameRunData.koNum = 0;
        MusouLogic.I.clearHits();
        _musouCtrl.gameRunData.gameTimeMax = mission.time * GameConfig.FPS_ANIMATE;
        _musouCtrl.gameRunData.gameTime    = mission.time * GameConfig.FPS_ANIMATE;

        var fighterTeam:Vector.<MusouFighterVO> = GameData.I.musouData.getFighterTeam();
        var group:GameRunFighterGroup           = _host.gameRunData.p1FighterGroup;
        group.fighter1 = FighterModel.I.getFighter(fighterTeam[0].id);
        group.fighter2 = FighterModel.I.getFighter(fighterTeam[1].id);
        group.fighter3 = FighterModel.I.getFighter(fighterTeam[2].id);
        _host.gameRunData.map = MapModel.I.getMap(mission.map);
    }

    /**
     * @inheritDoc
     */
    public function start():void {
        _host.clearPause();
        GameInputer.enabled = true;
        _host.initTeam();
        buildGame();
        _host.beginMatchRender();
    }

    /**
     * @inheritDoc
     */
    public function destroy():void {
        if (_musouCtrl) {
            _musouCtrl.destroy();
            _musouCtrl = null;
        }
        _host = null;
    }

    /**
     * @inheritDoc
     */
    public function getAttacker(name:String, team:int):FighterAttacker {
        return _musouCtrl.getFighterEventCtrl().getAttacker(name, team);
    }

    /**
     * @inheritDoc
     */
    public function buildGame():void {
        _musouCtrl.buildGame();
    }

    /**
     * @inheritDoc
     */
    public function onFightFinished():void {
    }

    /**
     * @inheritDoc
     */
    public function render():void {
        _musouCtrl.render();
    }

    /**
     * @inheritDoc
     */
    public function renderAnimate():void {
        _musouCtrl.renderAnimate();
    }

    /**
     * @inheritDoc
     */
    public function allowsRoundTimer():Boolean {
        return false;
    }

    /**
     * @inheritDoc
     */
    public function isFinished():Boolean {
        return _musouCtrl.getGameFinished();
    }

    /**
     * @inheritDoc
     */
    public function getMusouCtrl():MusouCtrl {
        return _musouCtrl;
    }
}
}
