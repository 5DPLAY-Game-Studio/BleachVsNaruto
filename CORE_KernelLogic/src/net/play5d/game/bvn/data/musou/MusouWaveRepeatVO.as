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
 * 一波敌人的重复刷出。
 *
 * <p>类型 0 按时间重复。类型 1 等这一组敌人死掉，再等 <code>hold</code> 秒。
 * <code>_holdFrame</code> 是运行时倒数的帧数，名字保持现有写法。</p>
 *
 * @see MusouWaveVO
 */
public class MusouWaveRepeatVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 重复类型。0 按时间，1 等敌人死亡后再等。
     *
     * @default 0
     */
    public var type:int;
    /**
     * 等待秒数。
     *
     * @default 0
     */
    public var hold:int;
    /**
     * 所属波次。加入敌人时会写到每个敌人上。
     *
     * @default null
     */
    public var wave:MusouWaveVO;
    /**
     * 要重复刷出的敌人。
     *
     * @default null
     */
    public var enemies:Vector.<MusouEnemyVO>;
    /**
     * 运行时剩余等待帧。
     *
     * @default 0
     */
    public var _holdFrame:int;

    /**
     * 追加敌人，并写上本波和本重复。
     *
     * <p><code>enemyAdds</code> 为空时抛错。</p>
     *
     * @param enemyAdds 敌人。
     * @example
     * <listing version="3.0">
     * repeat.addEnemy(enemies);
     * </listing>
     */
    public function addEnemy(enemyAdds:Vector.<MusouEnemyVO>):void {
        enemies ||= new Vector.<MusouEnemyVO>();

        for each(var e:MusouEnemyVO in enemyAdds) {
            e.wave   = wave;
            e.repeat = this;
            enemies.push(e);
        }

    }

}
}
