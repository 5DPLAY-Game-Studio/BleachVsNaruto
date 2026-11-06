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

public class MissionModel {

    private static var _i:MissionModel;

    public static function get I():MissionModel {
        _i ||= new MissionModel();
        return _i;
    }

    public var AI_LEVEL:int = 3;  //1-6
    private var _curMission:MissionVO;  //当前关卡
    private var _curStageId:int;  //当前关卡ID
    private var _curStage:MissionStageVO;  //当前关卡
    [ArrayElementType('net.play5d.game.bvn.data.vos.MissionVO')]
    private var _missions:Array;

    public function getAllMissions():Array {
        return _missions;
    }

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
     * 获取关卡数据
     * @param comicType 0=死神，1=火影
     * @param gameMode 0=team，1=single
     */
    public function getMission(comicType:int, gameMode:int):MissionVO {
        for each(var i:MissionVO in _missions) {
            if (i.comicType == comicType && i.gameMode == gameMode) {
                return i;
            }
        }
        return null;
    }

    public function getCurrentMissionStage():MissionStageVO {
        return _curStage;
    }

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

        var fighters:Array = _curStage.getFighters();
        var fightersLen:int = fighters.length;
        for (var i:int = 0; i < fightersLen; i++) {
            GameData.I.p2Select['fighter' + (i + 1)] = fighters[i];
        }
        GameData.I.p2Select.fuzhu = _curStage.assister;
        GameData.I.selectMap      = _curStage.map;


        AI_LEVEL = GameData.I.config.AI_level;

    }

    public function reset():void {
        _curStageId      = 0;
        _curStage        = null;
        _curMission      = null;
        GameData.I.score = 0;
    }

    public function missionComplete():void {
        if (missionAllComplete()) {
            TraceLang('mission_model.mission_all_over');
            return;
        }

        _curStageId++;

        initMission();
    }

    public function missionAllComplete():Boolean {
        return _curStageId >= _curMission.stageList.length - 1;
    }


}
}
