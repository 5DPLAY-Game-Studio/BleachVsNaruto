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

package net.play5d.game.bvn.fighter.ctrler {
/**
 * 头目 AI。这些招式固定返回 <code>false</code>，不走父类。
 *
 * @see FighterAICtrl
 */
public class EnemyBossAICtrl extends FighterAICtrl {

    /**
     * 不放卍解。
     *
     * @return <code>false</code>。
     */
    public override function banKai():Boolean {
        return false;
    }

    /**
     * 不放前卍解。
     *
     * @return <code>false</code>。
     */
    public override function banKaiW():Boolean {
        return false;
    }

    /**
     * 不放后卍解。
     *
     * @return <code>false</code>。
     */
    public override function banKaiS():Boolean {
        return false;
    }

    /**
     * 不放残影步。
     *
     * @return <code>false</code>。
     */
    public override function ghostStep():Boolean {
        return false;
    }

    /**
     * 不放残影跳。
     *
     * @return <code>false</code>。
     */
    public override function ghostJump():Boolean {
        return false;
    }

    /**
     * 不放残影下跳。
     *
     * @return <code>false</code>。
     */
    public override function ghostJumpDown():Boolean {
        return false;
    }

    /**
     * 不叫援助。
     *
     * @return <code>false</code>。
     */
    public override function assist():Boolean {
        return false;
    }

    /**
     * 不放特殊技能。
     *
     * @return <code>false</code>。
     */
    public override function specialSkill():Boolean {
        return false;
    }

    /**
     * 不放超必杀。
     *
     * @return <code>false</code>。
     */
    public override function bishaSUPER():Boolean {
        return false;
    }

    /**
     * 不放投技 1。
     *
     * @return <code>false</code>。
     */
    public override function catch1():Boolean {
        return false;
    }

    /**
     * 不放投技 2。
     *
     * @return <code>false</code>。
     */
    public override function catch2():Boolean {
        return false;
    }

}
}
