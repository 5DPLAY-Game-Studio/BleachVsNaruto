/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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

package net.play5d.game.bvn.data.vos {
import net.play5d.game.bvn.interfaces.IInstanceVO;

/**
 * 选人列表的格子和行列数。
 *
 * <p><code>HCount</code> 和 <code>VCount</code> 由选人配置初始化时写入。这里默认都是 0。</p>
 */
public class SelectCharListConfigVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';


    /**
     * 格子。构造时是空数组。
     */
    public var list:Array = [];
    /**
     * 列数。
     *
     * @default 0
     */
    public var HCount:int;
    /**
     * 行数。
     *
     * @default 0
     */
    public var VCount:int;
}
}
