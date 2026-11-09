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
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.musou.MusouFighterSellVO;
import net.play5d.game.bvn.data.musou.MusouMissionVO;
import net.play5d.game.bvn.data.musou.MusouModel;
import net.play5d.game.bvn.data.musou.MusouWorldMapAreaVO;
import net.play5d.game.bvn.data.musou.MusouWorldMapVO;
import net.play5d.game.bvn.data.musou.player.MusouMissionPlayerVO;
import net.play5d.game.bvn.data.musou.player.MusouPlayerData;
import net.play5d.game.bvn.data.musou.player.MusouWorldMapAreaPlayerVO;
import net.play5d.game.bvn.data.musou.player.MusouWorldMapPlayerVO;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.ui.GameUI;

/**
 * 无双地图进度、买人和场上连击。
 *
 * <p>下一关在区域还没开时返回 <code>null</code>。已经打到最后一关时，返回的仍是最后一关，不会变成 <code>null</code>。
 * 区域进度是已通过数除以关卡总数；关卡列表为空时结果是 <code>Infinity</code> 或 <code>NaN</code>。
 * 买人钱不够时只弹提示，不调用成功回调。连击数每次都加，同一个目标不会重复放进列表；列表空了才把次数清零并藏界面。</p>
 *
 * @see MusouCtrl
 */
public class MusouLogic {

    /** @private */
    private static var _i:MusouLogic;

    /**
     * 唯一实例。第一次读取时创建。
     *
     * @return 无双逻辑。
     * @example
     * <listing version="3.0">
     * var open:Boolean = MusouLogic.I.checkAreaIsOpen(areaId);
     * </listing>
     */
    public static function get I():MusouLogic {
        _i ||= new MusouLogic;
        return _i;
    }


    /** @private */
    private var _hitNum:int;
    /** @private */
    private var _hitTargets:Vector.<FighterMain> = new Vector.<FighterMain>();

    /**
     * 这个区域是不是当前所在区域。
     *
     * <p>还没有当前区域时返回 <code>false</code>。</p>
     *
     * @param areaId 区域 id。
     * @return 是当前区域时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var here:Boolean = MusouLogic.I.checkCurrentArea(areaId);
     * </listing>
     */
    public function checkCurrentArea(areaId:String):Boolean {
        var md:MusouPlayerData = GameData.I.musouData;
        if (!md.getCurrentArea()) {
            return false;
        }

        return md.getCurrentArea().id == areaId;
    }

    /**
     * 当前地图上这个区域是否已经打开。
     *
     * <p>当前地图为空时抛错。</p>
     *
     * @param areaId 区域 id。
     * @return 已打开时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var open:Boolean = MusouLogic.I.checkAreaIsOpen(areaId);
     * </listing>
     */
    public function checkAreaIsOpen(areaId:String):Boolean {
        var md:MusouPlayerData        = GameData.I.musouData;
        var map:MusouWorldMapPlayerVO = GameData.I.musouData.getCurrentMap();
        return map.getOpenArea(areaId) != null;
    }

    /**
     * 取这个区域下一场要打的关卡。
     *
     * <p>区域还没打开时返回 <code>null</code>。一场都没过时返回第一关。没有更后面的关卡时返回最后一关。</p>
     *
     * @param area2 区域配置。
     * @return 关卡；区域未打开时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var mission:MusouMissionVO = MusouLogic.I.getNextMission(area);
     * </listing>
     */
    public function getNextMission(area2:MusouWorldMapAreaVO):MusouMissionVO {
        var md:MusouPlayerData             = GameData.I.musouData;
        var map:MusouWorldMapPlayerVO      = GameData.I.musouData.getCurrentMap();
        var area:MusouWorldMapAreaPlayerVO = map.getOpenArea(area2.id);

        if (!area) {
            return null;
        }
//
        var m1:MusouMissionPlayerVO = area.getLastPassedMission();

        if (!m1) {
            return area2.missions[0];
        }

        var m2:MusouMissionVO = area2.getNextMission(m1.id);
        if (m2) {
            return m2;
        }
        return area2.missions[area2.missions.length - 1];
    }

    /**
     * 已通过关卡数除以该区域关卡总数。
     *
     * <p>区域没打开、或配置里没有关卡列表时返回 0。列表长度为 0 时结果是 <code>Infinity</code> 或 <code>NaN</code>。</p>
     *
     * @param areaId 区域 id。
     * @return 进度，通常在 0 到 1。
     * @example
     * <listing version="3.0">
     * var per:Number = MusouLogic.I.getAreaPercent(areaId);
     * </listing>
     */
    public function getAreaPercent(areaId:String):Number {
        var md:MusouPlayerData             = GameData.I.musouData;
        var map:MusouWorldMapPlayerVO      = GameData.I.musouData.getCurrentMap();
        var area:MusouWorldMapAreaPlayerVO = map.getOpenArea(areaId);
        if (!area) {
            return 0;
        }

        var area2:MusouWorldMapAreaVO = MusouModel.I.getMapArea(map.id, area.id);
        if (!area2 || !area2.missions) {
            return 0;
        }

        var per:Number = area.getPassedMissionAmount() / area2.missions.length;
        return per;
    }

    /**
     * 在指定地图上打开一个区域。
     *
     * <p>地图 id 不存在时抛错。</p>
     *
     * @param mapId 地图 id。
     * @param areaId 区域 id。
     * @example
     * <listing version="3.0">
     * MusouLogic.I.openMapArea(mapId, areaId);
     * </listing>
     */
    public function openMapArea(mapId:String, areaId:String):void {
        TraceLang('musou_logic.open_map_area', {areaId: areaId});

        var md:MusouPlayerData        = GameData.I.musouData;
        var map:MusouWorldMapPlayerVO = GameData.I.musouData.getMapById(mapId);
        map.openArea(areaId);
    }

    /**
     * 记下本关通过，加钱并保存。
     *
     * <p>这次是新通过时加 2000，重复通过加 500。当前区域为空时抛错。随后按前置区域进度打开后面的区域。</p>
     *
     * @param mission 刚通过的关卡。
     * @example
     * <listing version="3.0">
     * MusouLogic.I.passMission(mission);
     * </listing>
     */
    public function passMission(mission:MusouMissionVO):void {

        var area:MusouWorldMapAreaPlayerVO = GameData.I.musouData.getCurrentArea();

        if (area.passMission(mission.id)) {
            GameData.I.musouData.addMoney(2000);
        }
        else {
            GameData.I.musouData.addMoney(500);
        }


        updateMapAreas();
        GameData.I.saveData();
    }

    /**
     * 前置区域进度都超过 0.6 的区域会被打开。
     *
     * <p>当前地图为空时抛错。</p>
     *
     * @example
     * <listing version="3.0">
     * MusouLogic.I.updateMapAreas();
     * </listing>
     */
    public function updateMapAreas():void {
        var pmap:MusouWorldMapPlayerVO = GameData.I.musouData.getCurrentMap();

        var map:MusouWorldMapVO = MusouModel.I.getMap(pmap.id);
        for each(var i:MusouWorldMapAreaVO in map.areas) {
            if (i.preOpens && i.preOpens.length > 0) {

                var isOpenArea:Boolean = true;

                for each(var p:MusouWorldMapAreaVO in i.preOpens) {
                    if (!canPassNextArea(p.id)) {
                        isOpenArea = false;
                        break;
                    }
                }

                if (isOpenArea) {
                    openMapArea(pmap.id, i.id);
                }

            }
        }
    }

    /**
     * 花钱解锁角色。
     *
     * <p>钱不够时只弹提示并返回，不调用 <code>succback</code>。钱够时弹出确认，确认后扣钱、加入角色、保存，再调用成功回调。取消什么都不做。</p>
     *
     * @param data 出售数据。
     * @param succback 确认购买后的回调。可省略。
     * @example
     * <listing version="3.0">
     * MusouLogic.I.buyFighter(sell, function ():void {});
     * </listing>
     */
    public function buyFighter(data:MusouFighterSellVO, succback:Function = null):void {
        var musouData:MusouPlayerData = GameData.I.musouData;
        if (musouData.getMoney() < data.getPrice()) {
            GameUI.alert(
                    GetLang('musou.need_more_money.title'),
                    GetLang('musou.need_more_money', {amount: data.getPrice()})
            );
            return;
        }

        GameUI.confirm(
                GetLang('musou.unlock_fighter.title'),
                GetLang('musou.unlock_fighter', {amount: data.getPrice()}),
                function ():void {
                    musouData.loseMoney(data.getPrice());
                    musouData.addFighter(data.id);
                    GameData.I.saveData();
                    if (succback != null) {
                        succback();
                    }
                },
                null,
                true
        );

    }

    /**
     * 按当前关卡的敌人等级写体力和攻击加成。
     *
     * <p>没有敌人数据时直接返回。当前关卡为空时抛错。
     * 头目没配体力上限时用 <code>1000 + 等级 * 400</code>，能量上限是 <code>80 + 等级 * 10</code>。
     * 小兵没配上限时，等级大于 1 才按 <code>1 + (等级 - 1) * 0.08</code> 乘当前体力。</p>
     *
     * @param f 敌人。
     * @example
     * <listing version="3.0">
     * MusouLogic.I.initEnemyProps(enemy);
     * </listing>
     */
    public function initEnemyProps(f:FighterMain):void {
        if (!f.musouEnemyData) {
            return;
        }


        var mv:MusouMissionVO = MusouModel.I.currentMission;
        var lv:int            = mv.enemyLevel;

        f.musouEnemyData.level = lv;

        var hpRate:Number, hpAdd:Number, atk:Number, skl:Number, bs:Number;

        if (f.musouEnemyData.isBoss) {
            if (f.musouEnemyData.maxHp > 0) {
                f.hp = f.hpMax = f.musouEnemyData.maxHp;
            }
            else {
                f.hp = f.hpMax = 1000 + (
                        lv * 400
                );
            }

            f.energy = f.energyMax = 80 + (
                    lv * 10
            );

            atk = lv * 13;
            skl = lv * 14;
            bs  = lv * 15;

            f.initAttackAddDmg(atk, skl, bs);

        }
        else {
            if (f.musouEnemyData.maxHp > 0) {
                f.hp = f.hpMax = f.musouEnemyData.maxHp;
            }
            else {
                hpRate = 1 + (
                        lv - 1
                ) * 0.08;
                if (hpRate > 1) {
                    f.hp = f.hpMax = f.hp * hpRate;
                }
            }

            atk = lv * 5;
            skl = lv * 10;
            bs  = lv * 20;

            f.initAttackAddDmg(atk, skl, bs);
        }

    }

    /**
     * 连击加 1。同一个目标只放进列表一次。
     *
     * <p>次数大于 1 且界面已建好时才显示。</p>
     *
     * @param target 被打中的角色。
     * @return 当前连击数。
     * @example
     * <listing version="3.0">
     * var hits:int = MusouLogic.I.addHits(target);
     * </listing>
     */
    public function addHits(target:FighterMain):int {
        if (_hitTargets.indexOf(target) == -1) {
            _hitTargets.push(target);
        }
        _hitNum++;

        if (_hitNum > 1 && GameUI.I.getUI()) {
            GameUI.I.getUI().showHits(_hitNum, 1);
        }

        return _hitNum;
    }

    /**
     * 从连击列表拿掉一个目标。
     *
     * <p>不在列表里时直接返回。列表空了才把次数清成 0，并在界面存在时藏起连击。</p>
     *
     * @param target 目标。
     * @example
     * <listing version="3.0">
     * MusouLogic.I.removeHitTarget(target);
     * </listing>
     */
    public function removeHitTarget(target:FighterMain):void {
        var index:int = _hitTargets.indexOf(target);
        if (index == -1) {
            return;
        }

        _hitTargets.splice(index, 1);

        if (_hitTargets.length < 1) {
            _hitNum = 0;
            if (GameUI.I && GameUI.I.getUI()) {
                GameUI.I.getUI().hideHits(1);
            }
        }

    }

    /**
     * 把连击数和目标列表清掉。
     *
     * <p>不隐藏界面上已经显示的连击。</p>
     *
     * @example
     * <listing version="3.0">
     * MusouLogic.I.clearHits();
     * </listing>
     */
    public function clearHits():void {
        _hitNum     = 0;
        _hitTargets = new Vector.<FighterMain>();
    }

    private function canPassNextArea(areaId:String):Boolean {
        return getAreaPercent(areaId) > 0.6;
    }


}
}
