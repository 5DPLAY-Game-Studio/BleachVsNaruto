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
 * 一侧选中的三个角色和援助。
 *
 * <p><code>isSelected</code> 不看援助。传入 <code>null</code> 时，空着的槽也算选中。</p>
 */
public class SelectVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';


    /**
     * 第一人 id。
     *
     * @default null
     */
    public var fighter1:String;
    /**
     * 第二人 id。
     *
     * @default null
     */
    public var fighter2:String;
    /**
     * 第三人 id。
     *
     * @default null
     */
    public var fighter3:String;
    /**
     * 援助 id。
     *
     * @default null
     */
    public var fuzhu:String;

    /**
     * 取已选角色 id。空槽不放入。不含援助。
     *
     * @return 新的数组。
     * @example
     * <listing version="3.0">
     * var ids:Array = select.getSelectFighters();
     * </listing>
     */
    public function getSelectFighters():Array {
        var a:Array = [];
        if (fighter1) {
            a.push(fighter1);
        }
        if (fighter2) {
            a.push(fighter2);
        }
        if (fighter3) {
            a.push(fighter3);
        }
        return a;
    }

    /**
     * 三个角色槽里是否有这个 id。
     *
     * @param id 角色 id。
     * @return 有时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var picked:Boolean = select.isSelected(id);
     * </listing>
     */
    public function isSelected(id:String):Boolean {
        return fighter1 == id || fighter2 == id || fighter3 == id;
    }

    /**
     * 拼成一行调试文字。
     *
     * @return 含三个角色和援助的字符串。
     */
    public function toString():String {
        return 'SelectVO{fighter1=' + String(fighter1) + ',fighter2=' + String(fighter2) + ',fighter3=' +
               String(fighter3) + ',fuzhu=' + String(fuzhu) + '}';
    }

}
}
