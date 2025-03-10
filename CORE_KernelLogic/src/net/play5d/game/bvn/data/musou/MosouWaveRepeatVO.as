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

public class MosouWaveRepeatVO implements IInstanceVO {
    include '../../../../../../../include/_INCLUDE_.as';
    include '../../../../../../../include/Clone.as';

    public function MosouWaveRepeatVO() {
    }
    /**
     * 类型：
     * 0=按时间重复
     * 1=当该节点中的敌人DEAD后，在等待时间之后进行重复
     */
    public var type:int;
    public var hold:int;
    public var wave:MosouWaveVO;
    /**
     * 敌人数组 （{id: fighterID, amount: 数量, hp: 血量}）
     */
    public var enemies:Vector.<MusouEnemyVO>;
    public var _holdFrame:int;

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
