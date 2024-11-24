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
import net.play5d.game.bvn.interfaces.IInstanceVO;
import net.play5d.pcl.utils.ClassUtils;

/**
 * BGM 值对象
 */
public class BgmVO implements IInstanceVO {
    include '../../../../../../include/_INCLUDE_.as';

    // 音乐 ID
    public var id:String;
    // 播放概率
    public var rate:Number;
    // 资源路径
    public var url:String;

    /**
     * 克隆自身
     * @return 返回自身实例的克隆对象
     */
    public function clone():IInstanceVO {
        var bVO:BgmVO  = new BgmVO();
        var keys:Array = ClassUtils.getClassProperty(BgmVO);

        for each (var prop:String in keys) {
            bVO[prop] = this[prop];
        }

        return bVO;
    }
}
}
