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

package net.play5d.game.bvn.data.musou {
import net.play5d.game.bvn.interfaces.IInstanceVO;

/**
 * 一关无双的地图、时间和波次。
 *
 * <p>没有地图，或时间小于 1，初始化会抛错。敌人等级小于 1 时改成 1。缺省等级和时间都会先变成 0。
 * 波次 id 从 1 往下排。<code>bossCount</code> 只加各波自己的头目，不算重复组。</p>
 *
 * @see MusouWaveVO
 */
public class MusouMissionVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 关卡 id。
     *
     * @default null
     */
    public var id:String;
    /**
     * 名字。初始化不读它。
     *
     * @default null
     */
    public var name:String;
    /**
     * 地图 id。
     *
     * @default null
     */
    public var map:String;
    /**
     * 关卡秒数。小于 1 时初始化抛错。
     *
     * @default 0
     */
    public var time:int;
    /**
     * 敌人等级。小于 1 时改成 1。
     *
     * @default 0
     */
    public var enemyLevel:int;
    /**
     * 波次。
     *
     * @default null
     */
    public var waves:Vector.<MusouWaveVO>;
    /**
     * 所属区域。初始化不写它。
     *
     * @default null
     */
    public var area:MusouWorldMapAreaVO;

    /**
     * 用关卡 JSON 填写字段并建波次。
     *
     * @param o 关卡对象。没有 <code>waves</code> 时抛错。
     * @example
     * <listing version="3.0">
     * mission.initByJsonObject(json);
     * </listing>
     */
    public function initByJsonObject(o:Object):void {
        id         = o.id;
        map        = o.map;
        time       = int(o.time);
        enemyLevel = int(o.enemyLevel);

        if (enemyLevel < 1) {
            enemyLevel = 1;
        }

        if (!map || time < 1) {
            throw new Error(GetLang('log.error.musou.musou_mission_vo.init_musou_stage_fail'));
        }

        var wvs:Array = o.waves;

        waves = new Vector.<MusouWaveVO>();

        for (var i:int; i < wvs.length; i++) {
            var wave:MusouWaveVO = MusouWaveVO.createByJSON(wvs[i]);
            addWave(wave);
        }
    }

    /**
     * 各波敌人，含重复组。某一波没有敌人时跳过。
     *
     * <p><code>waves</code> 为空时抛错。</p>
     *
     * @return 敌人。
     * @example
     * <listing version="3.0">
     * var all:Vector.&lt;MusouEnemyVO&gt; = mission.getAllEnemies();
     * </listing>
     */
    public function getAllEnemies():Vector.<MusouEnemyVO> {
        var result:Vector.<MusouEnemyVO> = new Vector.<MusouEnemyVO>();
        for (var i:int; i < waves.length; i++) {
            var w:MusouWaveVO                 = waves[i];
            var enemies:Vector.<MusouEnemyVO> = w.getAllEnemies();
            if (enemies) {
                result = result.concat(enemies);
            }
        }
        return result;
    }

    /**
     * 各波角色 id，去重。
     *
     * @return 角色 id。
     * @example
     * <listing version="3.0">
     * var ids:Array = mission.getAllEnemyIds();
     * </listing>
     */
    public function getAllEnemyIds():Array {
        var result:Array = [];
        for (var i:int; i < waves.length; i++) {
            var w:MusouWaveVO  = waves[i];
            var enemyIds:Array = w.getAllEnemyIds();
            if (enemyIds) {
                for each(var e:String in enemyIds) {
                    if (result.indexOf(e) == -1) {
                        result.push(e);
                    }
                }
            }
        }
        return result;
    }

    /**
     * 各波头目的角色 id，去重。
     *
     * @return 角色 id。
     * @example
     * <listing version="3.0">
     * var ids:Array = mission.getBossIds();
     * </listing>
     */
    public function getBossIds():Array {
        var bosses:Vector.<MusouEnemyVO> = getBosses();
        var result:Array                 = [];
        for each(var i:MusouEnemyVO in bosses) {
            if (result.indexOf(i.fighterID) == -1) {
                result.push(i.fighterID);
            }
        }
        return result;
    }

    /**
     * 各波头目，同一个对象只留一次。
     *
     * @return 头目。
     * @example
     * <listing version="3.0">
     * var bosses:Vector.&lt;MusouEnemyVO&gt; = mission.getBosses();
     * </listing>
     */
    public function getBosses():Vector.<MusouEnemyVO> {
        var result:Vector.<MusouEnemyVO> = new Vector.<MusouEnemyVO>();
        for (var i:int; i < waves.length; i++) {
            var w:MusouWaveVO                = waves[i];
            var bosses:Vector.<MusouEnemyVO> = w.getBosses();
            if (bosses) {
                for each(var e:MusouEnemyVO in bosses) {
                    if (result.indexOf(e) == -1) {
                        result.push(e);
                    }
                }
            }
        }
        return result;
    }

    /**
     * 追加一波，并把 id 写成当前波数加 1。
     *
     * @param wave 波次。为空时抛错。
     * @example
     * <listing version="3.0">
     * mission.addWave(wave);
     * </listing>
     */
    public function addWave(wave:MusouWaveVO):void {
        waves ||= new Vector.<MusouWaveVO>();
        wave.id = waves.length + 1;
        waves.push(wave);
    }

    /**
     * 各波直接头目的数量之和。重复组不算。
     *
     * @return 头目数量。
     * @example
     * <listing version="3.0">
     * var n:int = mission.bossCount();
     * </listing>
     */
    public function bossCount():int {
        var count:int;
        for (var i:int; i < waves.length; i++) {
            var w:MusouWaveVO = waves[i];
            count += w.bossCount();
        }
        return count;
    }

}
}
