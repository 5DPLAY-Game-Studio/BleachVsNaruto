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

package net.play5d.game.bvn.ctrler.effect {
import net.play5d.game.bvn.data.vos.EffectVO;
import net.play5d.game.bvn.interfaces.IInstanceVO;

/**
 * 同一份受击数据上，普通目标与无双小兵各自的特效。
 *
 * <p>两字段不会同时被 <code>EffectManager</code> 写上。后查到的那一种会换掉整份对象。</p>
 *
 * @see EffectManager
 */
public class EffectCacheVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 普通目标的特效。
     *
     * @default null
     */
    public var normal:EffectVO;
    /**
     * 无双小兵的特效。
     *
     * @default null
     */
    public var musouEnemy:EffectVO;
}
}
