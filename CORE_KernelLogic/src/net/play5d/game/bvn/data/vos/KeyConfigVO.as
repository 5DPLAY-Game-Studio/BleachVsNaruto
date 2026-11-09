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
import net.play5d.kyo.utils.KyoUtils;

/**
 * 一套键位。
 *
 * <p><code>setKeys</code> 只在 <code>selects</code> 还是 <code>null</code> 时，把它设成只含攻击键。已经有数组时不会改。
 * 存档对象里不含 <code>id</code>。</p>
 *
 * @see ConfigVO
 */
public class KeyConfigVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 记下这套键的 id。
     *
     * @param id 0 菜单，1 是 P1，2 是 P2。
     * @example
     * <listing version="3.0">
     * var keys:KeyConfigVO = new KeyConfigVO(1);
     * </listing>
     */
    public function KeyConfigVO(id:int) {
        this.id = id;
    }

    /**
     * 这套键的 id。
     *
     * @default 0
     */
    public var id:int;
    /** 上。 @default 0 */
    public var up:uint;
    /** 下。 @default 0 */
    public var down:uint;
    /** 左。 @default 0 */
    public var left:uint;
    /** 右。 @default 0 */
    public var right:uint;
    /** 攻击。 @default 0 */
    public var attack:uint;
    /** 跳。 @default 0 */
    public var jump:uint;
    /** 冲。 @default 0 */
    public var dash:uint;
    /** 技能。 @default 0 */
    public var skill:uint;
    /** 必杀。 @default 0 */
    public var superKill:uint;
    /** 召唤。 @default 0 */
    public var beckons:uint;
    /**
     * 确认键。还没设置时为 <code>null</code>。
     *
     * @default null
     */
    public var selects:Array;

    /**
     * 一次写上全部键位。
     *
     * <p><code>selects</code> 为 <code>null</code> 时改成只含攻击键。</p>
     *
     * @param up 上。
     * @param down 下。
     * @param left 左。
     * @param right 右。
     * @param attack 攻击。
     * @param jump 跳。
     * @param dash 冲。
     * @param skill 技能。
     * @param superKill 必杀。
     * @param beckons 召唤。
     * @example
     * <listing version="3.0">
     * keys.setKeys(87, 83, 65, 68, 74, 75, 76, 85, 73, 79);
     * </listing>
     */
    public function setKeys(
            up:uint, down:uint, left:uint, right:uint, attack:uint, jump:uint, dash:uint, skill:uint, superKill:uint,
            beckons:uint
    ):void {
        this.up        = up;
        this.down      = down;
        this.left      = left;
        this.right     = right;
        this.attack    = attack;
        this.jump      = jump;
        this.dash      = dash;
        this.skill     = skill;
        this.dash      = dash;
        this.superKill = superKill;
        this.beckons   = beckons;

        selects ||= [attack];
    }

    /**
     * 做成存档对象，不含 <code>id</code>。
     *
     * @return 存档对象。
     * @example
     * <listing version="3.0">
     * var o:Object = keys.toSaveObj();
     * </listing>
     */
    public function toSaveObj():Object {
        var o:Object = KyoUtils.itemToObject(this);
        delete o['id'];
        return o;
    }

    /**
     * 把存档字段写回本对象。
     *
     * <p><code>o</code> 为空时抛错。对象里若带 <code>id</code>，会覆盖当前 id。</p>
     *
     * @param o 存档对象。
     * @example
     * <listing version="3.0">
     * keys.readSaveObj(o);
     * </listing>
     */
    public function readSaveObj(o:Object):void {
        KyoUtils.setValueByObject(this, o);
    }

}
}
