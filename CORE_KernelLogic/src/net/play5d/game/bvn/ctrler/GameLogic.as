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

package net.play5d.game.bvn.ctrler {
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.GameEndCtrl;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.data.MapLogoState;
import net.play5d.game.bvn.data.MessionModel;
import net.play5d.game.bvn.data.vos.MessionStageVO;
import net.play5d.game.bvn.data.vos.SelectCharListConfigVO;
import net.play5d.game.bvn.data.vos.SelectCharListItemVO;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.data.fighter.FighterActionState;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.events.FighterEvent;
import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.map.FloorVO;
import net.play5d.game.bvn.map.MapMain;
import net.play5d.game.bvn.stage.GameCamera;
import net.play5d.game.bvn.ui.select.SelectIndexUI;
import net.play5d.game.bvn.utils.ResUtils;

public class GameLogic {
    include '../../../../../../include/_INCLUDE_.as';

    private static var _map:MapMain;
    private static var _camera:GameCamera;
    private static var _floorContact:Dictionary = new Dictionary();
    private static var _hitsObj:Object = {};

    public static function initGameLogic(map:MapMain, camera:GameCamera):void {
        _map    = map;
        _camera = camera;
    }

    public static function clear():void {
        _map    = null;
        _camera = null;
    }

    public static function isInAir(target:BaseGameSprite):Boolean {
        if (!_map) {
            TraceLang('debug.trace.data.game_logic.map_null');
            return false;
        }

        //			if(!target.isApplyG) return true;

        if (target.getVecY() < 0) {
            target.isTouchBottom = false;
            return true;
        }

        //			var targetDisplay:DisplayObject = target.getDisplay();

        if (target.y > _map.playerBottom - GameConfig.G) {
            target.y             = _map.playerBottom;
            //				if(target.getVecY() > 0) target.setVecY(0);
            target.isTouchBottom = true;
            return false;
        }

        target.isTouchBottom = false;

        var allowHitAirFloor:Boolean = target.getVecY() < GameConfig.NO_TOUCH_BAN_ON_VECY * GameConfig.SPEED_PLUS;

        if (!allowHitAirFloor) {
            return true;
        }

        var floorSpd:Number = 10 * GameConfig.SPEED_PLUS_DEFAULT;

        var fv:FloorVO = _floorContact[target];
        if (fv) {
            if (fv.hitTest(target.x, target.y, floorSpd)) {
                target.y = fv.y;
                return false;
            }
            else {
                delete _floorContact[target];
                return true;
            }
        }

        fv = _map.getFloorHitTest(target.x, target.y, floorSpd);
        if (fv) {
            target.y              = fv.y;
            _floorContact[target] = fv;
            return false;
        }

        return true;
    }

    public static function isTouchBottomFloor(target:IGameSprite):Boolean {
        if (!_map) {
            TraceLang('debug.trace.data.game_logic.map_null');
            return false;
        }

        return target.y > _map.playerBottom;
    }

    public static function isOutRange(target:IGameSprite):Boolean {
        if (!_map) {
            TraceLang('debug.trace.data.game_logic.map_null');
            return false;
        }

        var offset:int = 20;

        return target.x > _map.right + offset || target.x < _map.left - offset || target.y > _map.bottom + offset;
    }

    public static function addHits(id:Object, targetID:Object, uiID:int):int {

        //			//防止出现使用冲突
        //			for each(var o:Object in _hitsObj){
        //				if(o.id != id && o.uiID == uiID){
        //					uiID = o.uiID == 1 ? 2 : 1;
        //				}
        //			}

        if (_hitsObj[id] == undefined) {
            _hitsObj[id] = {hits: 0, targetID: targetID, uiID: uiID};
        }
        _hitsObj[id].targetID = targetID;
        _hitsObj[id].hits++;
        return _hitsObj[id].hits;
    }

    public static function clearHits(id:Object):void {
        _hitsObj[id].hits     = 0;
        _hitsObj[id].targetID = null;
        _hitsObj[id].uiID     = null;
    }

    public static function getHitsObj(id:Object):Object {
        return _hitsObj[id];
    }

    public static function getHitsObjByTargetId(id:Object):Object {
        for each(var o:Object in _hitsObj) {
            if (o.targetID == id) {
                return o;
            }
        }
        return null;
    }

    public static function clearHitsByTargetId(id:Object):void {
        for (var i:String in _hitsObj) {
            if (_hitsObj[i].targetID == id) {
                delete _hitsObj[i];
            }
        }
    }

    public static function checkFighterDie(v:FighterMain):Boolean {
        if (GameMode.currentMode == GameMode.TRAINING) {
            return false;
        }
        return v.hp <= 0;
    }

    public static function hitTarget(hitvo:HitVO, attacker:IGameSprite, target:IGameSprite):void {
        if (!attacker || !target) {
            return;
        }
        if (!(
                attacker is FighterMain
        )) {
            return;
        }
        if (!(
                target is FighterMain
        )) {
            return;
        }

        if ((
                    target as FighterMain
            ).actionState != FighterActionState.HURT_ING &&
            (
                    target as FighterMain
            ).actionState != FighterActionState.HURT_FLYING
        ) {
            return;
        }

        var param:Object = {};
        param.target     = target;
        param.hitvo      = hitvo;
        FighterEventDispatcher.dispatchEvent(attacker as FighterMain, FighterEvent.HIT_TARGET, param);

    }

    public static function addScoreByHitTarget(hitvo:HitVO):void {
        var baseScore:int = hitvo.power;
        var score:int     = baseScore;

        if (hitvo.isBisha()) {
            score = baseScore * 2;
        }

        if (hitvo.id == 'sh1' || hitvo.id == 'sh2') {
            score += 500;
        }

        if (hitvo.isBreakDef) {
            score += 200;
        }
        if (hitvo.hurtType == 1) {
            score += 200;
        }

        var hitsObj:Object = getHitsObj(1);
        var hits:int       = hitsObj ? hitsObj.hits : 0;

        if (hits < 4) {
            score += hits * 50;
        }
        else {
            score += hits * 100;
        }

        addScore(score);

        GameEvent.dispatchEvent(GameEvent.SCORE_UPDATE);
    }

    /**
     * 添加分数 - 结算 KO 事件
     */
    public static function addScoreByKO():void {
        if (P1.lastHitVO && P1.lastHitVO.isBisha()) {
            addScore(2000);
        }

        if (P1.hp == P1.hpMax) {
            addScore(20000);
        }
        else {
            addScore(3000);
        }

        GameEvent.dispatchEvent(GameEvent.SCORE_UPDATE);
    }

    /**
     * 添加分数 - 结算通过一小关事件
     */
    public static function addScoreByPassMission():void {
        if (GameMode.currentMode == GameMode.TEAM_ACRADE &&
            P1.data == GameCtrl.I.gameRunData.p1FighterGroup.fighter1
        ) {
            addScore(15000);
        }
        else {
            addScore(5000);
        }
    }

    public static function loseScoreByContinue():void {
        GameData.I.score -= 10000;
        if (GameData.I.score < 0) {
            GameData.I.score = 0;
        }
    }

    /**
     * 防止游戏元件超出地图、当前显示区域
     */
    public static function fixGameSpritePosition(sp:IGameSprite):void {
        if (!sp.allowCrossMapXY()) {
            var left:Number = _map.left + GameConfig.X_SIDE_OFFSET;
            var right:Number = _map.right - GameConfig.X_SIDE_OFFSET;
            var offsetX:Number = GameConfig.X_SIDE_OFFSET;

            var camzoom:Number    = _camera.getZoom();
            var camRect:Rectangle = _camera.getScreenRect();

            if (sp is FighterMain) {
                if ((
                            sp as FighterMain
                    ).getVecX() != 0) {
                    if (camzoom == _camera.autoZoomMin) {

                        var camLeft:Number  = camRect.x / camzoom + offsetX;
                        var camRight:Number = camLeft + camRect.width - offsetX;

                        if (left < camLeft) {
                            left = camLeft;
                        }
                        if (right > camRight) {
                            right = camRight;
                        }
                    }
                }
            }

            var isTouchSide:Boolean = false;

            if (sp.x <= left) {
                sp.x        = left;
                isTouchSide = true;
            }
            if (sp.x >= right) {
                sp.x        = right;
                isTouchSide = true;
            }

            sp.setIsTouchSide(isTouchSide);
        }

        if (!sp.allowCrossMapBottom()) {
            if (sp.y > _map.bottom) {
                sp.y = _map.bottom;
            }
        }
    }

    public static function resetFighterHP(v:FighterMain):void {
        var messionRate:Number = 1;
        if (GameMode.isAcrade() && MessionModel.I.getCurrentMessionStage()) {
            messionRate = MessionModel.I.getCurrentMessionStage().hpRate;
        }

        if (v.customHpMax > 0) {
            v.hp = v.hpMax = v.customHpMax * GameData.I.config.fighterHP * messionRate;
        }
        else {
            v.hp = v.hpMax = GameConfig.FIGHTER_HP_MAX * GameData.I.config.fighterHP * messionRate;
        }

        v.isAlive = true;
    }

    //		public static function isTouchBottom(sp:IGameSprite):Boolean{
    //			if(sp.allowCrossMapBottom()) return false;
    //			return sp.y >= _map.bottom;
    //		}

    public static function setMessionEnemyAttack(v:FighterMain):void {
        var mv:MessionStageVO = MessionModel.I.getCurrentMessionStage();
        if (mv) {
            v.attackRate = mv.attackRate;
        }
    }

    public static function canSelectFighter(id:String):Boolean {
        var charList:SelectCharListConfigVO = GameData.I.config.select_config.charList;
        for each(var c:SelectCharListItemVO in charList.list) {
            if (c.fighterID == id) {
                return true;
            }
        }
        return false;
    }

    public static function canSelectAssist(id:String):Boolean {
        var assistList:SelectCharListConfigVO = GameData.I.config.select_config.assistList;
        for each(var c:SelectCharListItemVO in assistList.list) {
            if (c.fighterID == id) {
                return true;
            }
        }
        return false;
    }

    public static function setGameMode(v:int):void {
        TraceLang('debug.trace.data.game_logic.set_game_mode', v);
        switch (v) {
        case 1:
            GameData.I.loadSelect('config/salect.xml');
//            ResUtils.WINNER = '$loading$MC_stageWinner';
            SelectIndexUI.SHOW_MODE   = 1;
            GameConfig.SHOW_UI_STATUS = 1;
            GameEndCtrl.SHOW_CONTINUE = true;
            GameConfig.MAP_LOGO_STATE = MapLogoState.SHOW_MINE;
            break;
        case 2:
            GameData.I.loadDebugSelect('salect.xml');
//            ResUtils.WINNER = '$loading$MC_stageWinner2';
            SelectIndexUI.SHOW_MODE   = 1;
            GameConfig.SHOW_UI_STATUS = 1;
            GameConfig.MAP_LOGO_STATE = MapLogoState.SHOW_MINE;
            GameEndCtrl.SHOW_CONTINUE = true;
            break;
        default:
            GameData.I.loadSelect('config/select.xml');
            ResUtils.WINNER           = '$loading$MC_stageWinner';
            SelectIndexUI.SHOW_MODE   = 0;
            GameConfig.SHOW_UI_STATUS = 0;
            GameConfig.MAP_LOGO_STATE = MapLogoState.SHOW_4399;
            GameEndCtrl.SHOW_CONTINUE = false;
        }
    }

    /**
     * 添加分数
     *
     * @param score 分数
     */
    private static function addScore(score:int):void {
        var rate:Number = GameData.I.config.keyInputMode == 0 ? 1 : 0.8;
        GameData.I.score += score * rate;
    }

    //		public static function startVsMode(p1:FighterMain , p2:FighterMain , map:MapMain):void{
    //			if(p1){
    //				p1.initlize();
    //				var ctrl:FighterKeyCtrl = new FighterKeyCtrl();
    //				ctrl.config = GameData.I.config.key_p1;
    //				p1.setCtrl(ctrl);
    //			}
    //
    //			if(p2){
    //				p2.initlize();
    //				var ctrl2:FighterKeyCtrl = new FighterKeyCtrl();
    //				ctrl2.config = GameData.I.config.key_p2;
    //				p2.setCtrl(ctrl2);
    //			}
    //
    //			if(map){
    //				map.initlize();
    //				setMap(map);
    //			}
    //
    //			var gs:GameState = new GameState();
    //			gs.initFight(p1,p2,map);
    //
    //			GameCtrl.I.startGame(0);
    //
    //			bleachvsnaruto.stageCtrl.goStage(gs);
    //		}

}

}
