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
 * 一首背景音乐的 id、权重和地址。
 *
 * @see MapModel
 */
public class BgmVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 曲目 id。地图曲会写成 <code>map</code>。
     *
     * @default null
     */
    public var id:String;
    /**
     * 播放权重。
     *
     * @default NaN
     */
    public var rate:Number;
    /**
     * 资源路径。
     *
     * @default null
     */
    public var url:String;

}
}
