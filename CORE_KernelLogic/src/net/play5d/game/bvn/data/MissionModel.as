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

package net.play5d.game.bvn.data {
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.data.vos.MissionStageVO;
import net.play5d.game.bvn.data.vos.MissionVO;
import net.play5d.game.bvn.data.vos.SelectVO;

/**
 * 闯关进度。
 *
 * <p>已经停在最后一关时，<code>missionComplete</code> 只打日志，不会再往下走。
 * <code>missionAllComplete</code> 在当前下标已经是最后一关时就为 <code>true</code>。
 * 开一关时会清掉 P2 的第二、第三人，再按本关角色写回去。</p>
 *
 * @see MissionVO
 */
public class MissionModel {

    /** @private */
    private static var _i:MissionModel;

    /**
     * 唯一实例。第一次读取时创建。
     *
     * @return 关卡表。
     * @example
     * <listing version="3.0">
     * var stage:MissionStageVO = MissionModel.I.getCurrentMissionStage();
     * </listing>
     */
    public static function get I():MissionModel {
        _i ||= new MissionModel();
        return _i;
    }

    /**
     * 本关 AI 等级。开一关时改成配置里的等级。
     *
     * @default 3
     */
    public var AI_LEVEL:int = 3;
    /** @private */
    private var _curMission:MissionVO;
    /** @private */
    private var _curStageId:int;
    /** @private */
    private var _curStage:MissionStageVO;
    /** @private */
    [ArrayElementType('net.play5d.game.bvn.data.vos.MissionVO')]
    private var _missions:Array;

    /**
     * 取全部关卡。返回的是内部数组。
     *
     * @return 关卡数组。还没加载时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var all:Array = MissionModel.I.getAllMissions();
     * </listing>
     */
    public function getAllMissions():Array {
        return _missions;
    }

    /**
     * 用关卡 JSON 重建列表。
     *
     * <p>缺少 <code>level</code> 时抛错。</p>
     *
     * @param obj 含 <code>level</code> 数组的对象。
     * @example
     * <listing version="3.0">
     * MissionModel.I.initByObject(data);
     * </listing>
     */
    public function initByObject(obj:Object):void {
        _missions = [];

        var levelArr:Array = obj['level'];
        for each(var level:Object in levelArr) {
            var missionVO:MissionVO = new MissionVO();
            missionVO.initByObject(level);

            _missions.push(missionVO);
        }
    }

    /**
     * 按漫画类型和模式取第一份匹配的关卡。
     *
     * @param comicType 0 为死神，1 为火影。
     * @param gameMode 0 为组队，1 为单人。
     * @return 关卡。没有时为 <code>null</code>。列表还没建时抛错。
     * @example
     * <listing version="3.0">
     * var mission:MissionVO = MissionModel.I.getMission(0, 1);
     * </listing>
     */
    public function getMission(comicType:int, gameMode:int):MissionVO {
        for each(var i:MissionVO in _missions) {
            if (i.comicType == comicType && i.gameMode == gameMode) {
                return i;
            }
        }
        return null;
    }

    /**
     * 取当前小关。
     *
     * @return 小关。还没开时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var stage:MissionStageVO = MissionModel.I.getCurrentMissionStage();
     * </listing>
     */
    public function getCurrentMissionStage():MissionStageVO {
        return _curStage;
    }

    /**
     * 按 P1 第一人的漫画类型和当前模式进入本关，并写好 P2 与地图。
     *
     * <p>P1 选人或角色不存在、或没有对应关卡时抛错。组队模式用 0，其它用 1。</p>
     *
     * @example
     * <listing version="3.0">
     * MissionModel.I.initMission();
     * </listing>
     */
    public function initMission():void {
        var fighter:FighterVO = FighterModel.I.getFighter(GameData.I.p1Select.fighter1);
        var gameMode:int      = GameMode.isTeamMode() ? 0 : 1;
        var mv:MissionVO      = getMission(fighter.comicType, gameMode);
        _curMission           = mv;
        _curStage             = mv.stageList[_curStageId];

        GameData.I.p2Select ||= new SelectVO();

        // 清除之前的队伍配置，避免模式切换时残留
        GameData.I.p2Select.fighter2 = null;
        GameData.I.p2Select.fighter3 = null;

        var fighters:Array  = _curStage.getFighters();
        var fightersLen:int = fighters.length;
        for (var i:int = 0; i < fightersLen; i++) {
            GameData.I.p2Select['fighter' + (i + 1)] = fighters[i];
        }
        GameData.I.p2Select.fuzhu = _curStage.assister;
        GameData.I.selectMap      = _curStage.map;


        AI_LEVEL = GameData.I.config.AI_level;

    }

    /**
     * 回到第一关之前，并清掉闯关分数。
     *
     * <p>P2 选人不会清。</p>
     *
     * @example
     * <listing version="3.0">
     * MissionModel.I.reset();
     * </listing>
     */
    public function reset():void {
        _curStageId      = 0;
        _curStage        = null;
        _curMission      = null;
        GameData.I.score = 0;
    }

    /**
     * 进入下一小关。
     *
     * <p>已经在最后一关时只打日志并返回。</p>
     *
     * @example
     * <listing version="3.0">
     * MissionModel.I.missionComplete();
     * </listing>
     */
    public function missionComplete():void {
        if (missionAllComplete()) {
            TraceLang('mission_model.mission_all_over');
            return;
        }

        _curStageId++;

        initMission();
    }

    /**
     * 当前下标是否已经是最后一关。
     *
     * <p>还没开局时会抛错。</p>
     *
     * @return 已在最后一关时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var done:Boolean = MissionModel.I.missionAllComplete();
     * </listing>
     */
    public function missionAllComplete():Boolean {
        return _curStageId >= _curMission.stageList.length - 1;
    }


}
}
