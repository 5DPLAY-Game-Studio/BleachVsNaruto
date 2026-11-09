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
import net.play5d.game.bvn.data.MissionModel;
import net.play5d.game.bvn.data.vos.MissionStageVO;
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
import net.play5d.game.bvn.utils.ResUtils;

/**
 * 对局里的落地、出界、连击和分数。
 *
 * <p><code>clear</code> 只丢掉地图和镜头，连击表和落脚的楼层还在。地图还没设上时，落地和出界判断记一条日志并返回 <code>false</code>。
 * 加分在按键模式不是 0 时乘 0.8。续关扣分不会发出分数更新事件。</p>
 *
 * @see GameCtrl
 */
public class GameLogic {

    /** @private */
    private static var _map:MapMain;
    /** @private */
    private static var _camera:GameCamera;
    /** @private */
    private static var _floorContact:Dictionary = new Dictionary();
    /** @private */
    private static var _hitsObj:Object          = {};

    /**
     * 记下本局地图和镜头。
     *
     * @param map 地图。
     * @param camera 镜头。
     * @example
     * <listing version="3.0">
     * GameLogic.initGameLogic(map, camera);
     * </listing>
     */
    public static function initGameLogic(map:MapMain, camera:GameCamera):void {
        _map    = map;
        _camera = camera;
    }

    /**
     * 丢掉地图和镜头。
     *
     * <p>连击表和楼层接触还留着。之后再修正位置会抛错。</p>
     *
     * @example
     * <listing version="3.0">
     * GameLogic.clear();
     * </listing>
     */
    public static function clear():void {
        _map    = null;
        _camera = null;
    }

    /**
     * 判断是否在空中，并在落地时改写 <code>y</code>。
     *
     * <p>向上时一定在空中。落到主地面会把 <code>y</code> 收到 <code>playerBottom</code>。
     * 下落够快时才会踩楼层；这一帧离开已记住的楼层后，不会再查其它楼层。</p>
     *
     * @param target 精灵。
     * @return 在空中时为 <code>true</code>。没有地图时为 <code>false</code>。
     * @example
     * <listing version="3.0">
     * var air:Boolean = GameLogic.isInAir(sprite);
     * </listing>
     */
    public static function isInAir(target:BaseGameSprite):Boolean {
        if (!_map) {
            TraceLang('game_logic.map_null');
            return false;
        }

        if (target.getVecY() < 0) {
            target.isTouchBottom = false;
            return true;
        }

        if (target.y > _map.playerBottom - GameConfig.G) {
            target.y             = _map.playerBottom;
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

    /**
     * 判断脚是否低于主地面。
     *
     * <p>相等不算碰到。没有地图时返回 <code>false</code>。</p>
     *
     * @param target 精灵。
     * @return 低于主地面时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var touch:Boolean = GameLogic.isTouchBottomFloor(sprite);
     * </listing>
     */
    public static function isTouchBottomFloor(target:IGameSprite):Boolean {
        if (!_map) {
            TraceLang('game_logic.map_null');
            return false;
        }

        return target.y > _map.playerBottom;
    }

    /**
     * 判断是否超出地图左、右或下边界 20 像素。
     *
     * <p>不看上边界。没有地图时返回 <code>false</code>。</p>
     *
     * @param target 精灵。
     * @return 出界时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var out:Boolean = GameLogic.isOutRange(sprite);
     * </listing>
     */
    public static function isOutRange(target:IGameSprite):Boolean {
        if (!_map) {
            TraceLang('game_logic.map_null');
            return false;
        }

        var offset:int = 20;

        return target.x > _map.right + offset || target.x < _map.left - offset || target.y > _map.bottom + offset;
    }

    /**
     * 给一份连击加 1，并改写当前目标。
     *
     * <p>第一次写入 <code>uiID</code>，之后再加不会改它。返回的是加过之后的次数。</p>
     *
     * @param id 攻击方键。
     * @param targetID 当前被连击的目标。
     * @param uiID 界面用的 id，只在新建时写入。
     * @return 当前连击数。
     * @example
     * <listing version="3.0">
     * var hits:int = GameLogic.addHits(attackerId, targetId, 1);
     * </listing>
     */
    public static function addHits(id:Object, targetID:Object, uiID:int):int {
        if (_hitsObj[id] == undefined) {
            _hitsObj[id] = {hits: 0, targetID: targetID, uiID: uiID};
        }
        _hitsObj[id].targetID = targetID;
        _hitsObj[id].hits++;
        return _hitsObj[id].hits;
    }

    /**
     * 把一份连击清成 0。
     *
     * <p>这个键还没有连击时会抛错。</p>
     *
     * @param id 攻击方键。
     * @example
     * <listing version="3.0">
     * GameLogic.clearHits(attackerId);
     * </listing>
     */
    public static function clearHits(id:Object):void {
        _hitsObj[id].hits     = 0;
        _hitsObj[id].targetID = null;
        _hitsObj[id].uiID     = null;
    }

    /**
     * 取一份连击记录。
     *
     * <p>返回的是表里的原对象。没有这个键时为 <code>undefined</code>。</p>
     *
     * @param id 攻击方键。
     * @return 含 <code>hits</code>、<code>targetID</code>、<code>uiID</code> 的对象。
     * @example
     * <listing version="3.0">
     * var hits:Object = GameLogic.getHitsObj(attackerId);
     * </listing>
     */
    public static function getHitsObj(id:Object):Object {
        return _hitsObj[id];
    }

    /**
     * 按被连击的目标查找第一份记录。
     *
     * @param id 目标 id。
     * @return 记录；没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var hits:Object = GameLogic.getHitsObjByTargetId(targetId);
     * </listing>
     */
    public static function getHitsObjByTargetId(id:Object):Object {
        for each(var o:Object in _hitsObj) {
            if (o.targetID == id) {
                return o;
            }
        }
        return null;
    }

    /**
     * 删掉所有正在打这个目标的连击。
     *
     * @param id 目标 id。
     * @example
     * <listing version="3.0">
     * GameLogic.clearHitsByTargetId(targetId);
     * </listing>
     */
    public static function clearHitsByTargetId(id:Object):void {
        for (var i:String in _hitsObj) {
            if (_hitsObj[i].targetID == id) {
                delete _hitsObj[i];
            }
        }
    }

    /**
     * 判断角色是否应判死。
     *
     * <p>练习模式一律返回 <code>false</code>。</p>
     *
     * @param v 角色。
     * @return 体力小于等于 0 时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var dead:Boolean = GameLogic.checkFighterDie(fighter);
     * </listing>
     */
    public static function checkFighterDie(v:FighterMain):Boolean {
        if (GameMode.currentMode == GameMode.TRAINING) {
            return false;
        }
        return v.hp <= 0;
    }

    /**
     * 双方都是角色、且目标正处于受击或击飞时，给攻击方派发命中事件。
     *
     * <p>任一方不是 <code>FighterMain</code>，或目标不在这两种动作里，直接返回。</p>
     *
     * @param hitvo 命中数据。
     * @param attacker 攻击方。
     * @param target 受击方。
     * @example
     * <listing version="3.0">
     * GameLogic.hitTarget(hitvo, attacker, target);
     * </listing>
     */
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

    /**
     * 按这一击给闯关加分，并派发分数更新。
     *
     * <p>连击数读的是键 <code>1</code>。必杀把威力翻倍；<code>sh1</code> / <code>sh2</code>、破防、受击类型 1 各再加一笔。</p>
     *
     * @param hitvo 命中数据。
     * @example
     * <listing version="3.0">
     * GameLogic.addScoreByHitTarget(hitvo);
     * </listing>
     */
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
     * 结算 KO 加分，并派发分数更新。
     *
     * <p>P1 上一击是必杀时再加 2000。满体力加 20000，否则加 3000。两笔可以叠在一起。</p>
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
     * 结算通过一小关的加分，并派发分数更新。
     *
     * <p>组队闯关且 P1 当前数据就是队伍里的第一人时加 15000，否则加 5000。比较的是对象本身。</p>
     */
    public static function addScoreByPassMission():void {
        if (GameMode.currentMode == GameMode.TEAM_ARCADE &&
            P1.data == GameCtrl.I.gameRunData.p1FighterGroup.fighter1
        ) {
            addScore(15000);
        }
        else {
            addScore(5000);
        }
    }

    /**
     * 续关扣 10000 分，最低到 0。
     *
     * <p>不派发分数更新。</p>
     *
     * @example
     * <listing version="3.0">
     * GameLogic.loseScoreByContinue();
     * </listing>
     */
    public static function loseScoreByContinue():void {
        GameData.I.score -= 10000;
        if (GameData.I.score < 0) {
            GameData.I.score = 0;
        }
    }

    /**
     * 把不允许出界的精灵收回地图边缘。
     *
     * <p>角色正在横向移动、且镜头已经缩到自动最小时，左右边界再收到当前画面里。
     * 地图或镜头还没设上时会抛错。</p>
     *
     * @param sp 精灵。
     */
    public static function fixGameSpritePosition(sp:IGameSprite):void {
        if (!sp.allowCrossMapXY()) {
            var left:Number    = _map.left + GameConfig.X_SIDE_OFFSET;
            var right:Number   = _map.right - GameConfig.X_SIDE_OFFSET;
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

    /**
     * 按配置和当前关卡倍率写回体力和体力上限，并标成存活。
     *
     * <p>有自定义上限时用它，否则用全局上限。闯关且当前有关卡时再乘 <code>hpRate</code>。</p>
     *
     * @param v 角色。
     * @example
     * <listing version="3.0">
     * GameLogic.resetFighterHP(fighter);
     * </listing>
     */
    public static function resetFighterHP(v:FighterMain):void {
        var missionRate:Number = 1;
        if (GameMode.isArcade() && MissionModel.I.getCurrentMissionStage()) {
            missionRate = MissionModel.I.getCurrentMissionStage().hpRate;
        }

        if (v.customHpMax > 0) {
            v.hp = v.hpMax = v.customHpMax * GameData.I.config.fighterHP * missionRate;
        }
        else {
            v.hp = v.hpMax = GameConfig.FIGHTER_HP_MAX * GameData.I.config.fighterHP * missionRate;
        }

        v.isAlive = true;
    }

    /**
     * 把当前关卡的攻击倍率写到角色上。
     *
     * <p>没有当前关卡时不改原来的倍率。</p>
     *
     * @param v 角色。
     * @example
     * <listing version="3.0">
     * GameLogic.setMissionEnemyAttack(fighter);
     * </listing>
     */
    public static function setMissionEnemyAttack(v:FighterMain):void {
        var mv:MissionStageVO = MissionModel.I.getCurrentMissionStage();
        if (mv) {
            v.attackRate = mv.attackRate;
        }
    }

    /**
     * 角色 id 是否出现在选人列表里。
     *
     * @param id 角色 id。
     * @return 列表里有这个 id 时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = GameLogic.canSelectFighter(id);
     * </listing>
     */
    public static function canSelectFighter(id:String):Boolean {
        var charList:SelectCharListConfigVO = GameData.I.config.select_config.charList;
        for each(var c:SelectCharListItemVO in charList.list) {
            if (c.fighterID == id) {
                return true;
            }
        }
        return false;
    }

    /**
     * 援助 id 是否出现在援助列表里。
     *
     * @param id 援助 id。
     * @return 列表里有这个 id 时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = GameLogic.canSelectAssist(id);
     * </listing>
     */
    public static function canSelectAssist(id:String):Boolean {
        var assistList:SelectCharListConfigVO = GameData.I.config.select_config.assistList;
        for each(var c:SelectCharListItemVO in assistList.list) {
            if (c.fighterID == id) {
                return true;
            }
        }
        return false;
    }

    /**
     * 按模式号改界面、地图标志和续关开关。
     *
     * <p>1 和 2 都打开状态界面、自己的地图标志和续关。其它值会重新读 <code>config/select.json</code>，并关掉续关。</p>
     *
     * @param v 模式号。
     * @example
     * <listing version="3.0">
     * GameLogic.setGameMode(1);
     * </listing>
     */
    public static function setGameMode(v:int):void {
        TraceLang('game_logic.set_game_mode', {mode: v});
        switch (v) {
        case 1:
            GameConfig.SHOW_UI_STATUS = 1;
            GameEndCtrl.SHOW_CONTINUE = true;
            GameConfig.MAP_LOGO_STATE = MapLogoState.SHOW_MINE;
            break;
        case 2:
            GameConfig.SHOW_UI_STATUS = 1;
            GameConfig.MAP_LOGO_STATE = MapLogoState.SHOW_MINE;
            GameEndCtrl.SHOW_CONTINUE = true;
            break;
        default:
            GameData.I.loadSelect('config/select.json');
            ResUtils.WINNER           = '$loading$MC_stageWinner';
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

}

}
