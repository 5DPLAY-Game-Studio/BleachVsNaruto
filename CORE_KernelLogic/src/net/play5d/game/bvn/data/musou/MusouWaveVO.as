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
 * 无双的一波敌人。
 *
 * <p>JSON 里的 <code>repeat</code> 只建成一份，不是数组。没有 <code>enemies</code> 时创建会抛错。
 * 没有重复时，<code>getAllEnemies</code> 返回本波自己的数组，不是拷贝。<code>bossCount</code> 不数重复组里的头目。</p>
 *
 * @see MusouEnemyVO
 */
public class MusouWaveVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 用一条波次 JSON 建波次。
     *
     * @param json 含 <code>hold</code>、<code>enemies</code>，可选 <code>repeat</code>。
     * @return 新的波次。
     * @example
     * <listing version="3.0">
     * var wave:MusouWaveVO = MusouWaveVO.createByJSON(json);
     * </listing>
     */
    public static function createByJSON(json:Object):MusouWaveVO {
        var wave:MusouWaveVO = new MusouWaveVO();
        wave.hold            = int(json.hold);

        var enemies:Array = json.enemies;
        for (var j:int = 0; j < enemies.length; j++) {
            wave.addEnemy(MusouEnemyVO.createByJSON(enemies[j]));
        }

        if (json.repeat) {
            wave.repeats = new Vector.<MusouWaveRepeatVO>();

            var waveRepeat:MusouWaveRepeatVO = new MusouWaveRepeatVO();
            waveRepeat.type                  = json.repeat.type;
            waveRepeat.hold                  = json.repeat.hold;

            var repeatEnemies:Array = json.repeat.enemies;
            for (var k:int = 0; k < repeatEnemies.length; k++) {
                waveRepeat.addEnemy(MusouEnemyVO.createByJSON(repeatEnemies[k]));
            }

            wave.repeats.push(waveRepeat);
        }

        return wave;
    }

    /**
     * 波次 id。创建 JSON 时不会写它。
     *
     * @default 0
     */
    public var id:int;
    /**
     * 本波直接刷出的敌人。
     *
     * @default null
     */
    public var enemies:Vector.<MusouEnemyVO>;
    /**
     * 重复组。
     *
     * @default null
     */
    public var repeats:Vector.<MusouWaveRepeatVO>;
    /**
     * 这一波持续的秒数。
     *
     * @default 0
     */
    public var hold:int;

    /**
     * 本波敌人和重复组里的敌人。
     *
     * <p>没有重复组时返回 <code>enemies</code> 本身，可能是 <code>null</code>。</p>
     *
     * @return 敌人。
     * @example
     * <listing version="3.0">
     * var all:Vector.&lt;MusouEnemyVO&gt; = wave.getAllEnemies();
     * </listing>
     */
    public function getAllEnemies():Vector.<MusouEnemyVO> {
        if (!repeats) {
            return enemies;
        }

        var result:Vector.<MusouEnemyVO> = enemies.concat();
        for each(var i:MusouWaveRepeatVO in repeats) {
            if (i.enemies) {
                result = result.concat(i.enemies);
            }
        }

        return result;
    }

    /**
     * 本波和重复组里出现过的角色 id，去重。
     *
     * <p>敌人列表为空时抛错。</p>
     *
     * @return 角色 id。
     * @example
     * <listing version="3.0">
     * var ids:Array = wave.getAllEnemyIds();
     * </listing>
     */
    public function getAllEnemyIds():Array {
        var result:Array                     = [];
        var allEnemies:Vector.<MusouEnemyVO> = getAllEnemies();

        for each(var e:MusouEnemyVO in allEnemies) {
            if (result.indexOf(e.fighterID) == -1) {
                result.push(e.fighterID);
            }
        }

        return result;
    }

    /**
     * 本波和重复组里的头目。同一个对象只出现一次。
     *
     * @return 头目。
     * @example
     * <listing version="3.0">
     * var bosses:Vector.&lt;MusouEnemyVO&gt; = wave.getBosses();
     * </listing>
     */
    public function getBosses():Vector.<MusouEnemyVO> {
        var result:Vector.<MusouEnemyVO>     = new Vector.<MusouEnemyVO>();
        var allEnemies:Vector.<MusouEnemyVO> = getAllEnemies();

        for each(var e:MusouEnemyVO in allEnemies) {
            if (!e.isBoss) {
                continue;
            }

            if (result.indexOf(e) == -1) {
                result.push(e);
            }
        }

        return result;
    }

    /**
     * 追加敌人，并写上所属波次。
     *
     * @param enemyAdd 敌人。为空时抛错。
     * @example
     * <listing version="3.0">
     * wave.addEnemy(enemies);
     * </listing>
     */
    public function addEnemy(enemyAdd:Vector.<MusouEnemyVO>):void {
        enemies ||= new Vector.<MusouEnemyVO>();

        for each(var e:MusouEnemyVO in enemyAdd) {
            e.wave = this;
            enemies.push(e);
        }
    }

    /**
     * 追加一组重复，并写上所属波次。
     *
     * @param repeat 重复组。为空时抛错。
     * @example
     * <listing version="3.0">
     * wave.addRepeat(repeat);
     * </listing>
     */
    public function addRepeat(repeat:MusouWaveRepeatVO):void {
        repeats ||= new Vector.<MusouWaveRepeatVO>();

        repeat.wave = this;
        repeats.push(repeat);
    }

    /**
     * 数本波直接敌人里的头目。重复组不算。
     *
     * <p><code>enemies</code> 为空时抛错。</p>
     *
     * @return 头目数量。
     * @example
     * <listing version="3.0">
     * var n:int = wave.bossCount();
     * </listing>
     */
    public function bossCount():int {
        var count:int;
        for each(var i:MusouEnemyVO in enemies) {
            if (i.isBoss) {
                count++;
            }
        }
        return count;
    }

}
}
