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
import net.play5d.game.bvn.data.musou.player.MusouFighterVO;
import net.play5d.game.bvn.fighter.FighterMain;

/**
 * 按无双角色等级判断哪些招式能放，并把攻击加成写到角色上。
 *
 * <p>下面的等级常量全是 0。等级不小于 0 时，除冲刺以外的判断都为真。冲刺不看等级。
 * <code>ALL_ACTION_LEVELS</code> 里也全是 0，只有等级 0 能在里面找到。</p>
 *
 * @see MusouFighterVO
 */
public class MusouFighterLogic {

    /**
     * 空中冲刺解锁等级。
     *
     * @default 0
     */
    public static const LV_DASH_AIR:int         = 0;
    /**
     * 残影步解锁等级。
     *
     * @default 0
     */
    public static const LV_GHOST_STEP:int       = 0;
    /**
     * 技能 1 解锁等级。
     *
     * @default 0
     */
    public static const LV_SKILL1:int           = 0;
    /**
     * 技能 2 解锁等级。
     *
     * @default 0
     */
    public static const LV_SKILL2:int           = 0;
    /**
     * 空中技能解锁等级。
     *
     * @default 0
     */
    public static const LV_SKILL_AIR:int        = 0;
    /**
     * 招式 1 解锁等级。
     *
     * @default 0
     */
    public static const LV_ZHAO1:int            = 0;
    /**
     * 招式 2 解锁等级。
     *
     * @default 0
     */
    public static const LV_ZHAO2:int            = 0;
    /**
     * 招式 3 解锁等级。
     *
     * @default 0
     */
    public static const LV_ZHAO3:int            = 0;
    /**
     * 投技 1 解锁等级。
     *
     * @default 0
     */
    public static const LV_CATCH1:int           = 0;
    /**
     * 投技 2 解锁等级。
     *
     * @default 0
     */
    public static const LV_CATCH2:int           = 0;
    /**
     * 必杀解锁等级。
     *
     * @default 0
     */
    public static const LV_BISHA:int            = 0;
    /**
     * 空中必杀解锁等级。
     *
     * @default 0
     */
    public static const LV_BISHA_AIR:int        = 0;
    /**
     * 上必杀解锁等级。
     *
     * @default 0
     */
    public static const LV_BISHA_UP:int         = 0;
    /**
     * 超必杀解锁等级。
     *
     * @default 0
     */
    public static const LV_BISHA_SUPER:int      = 0;
    /**
     * 卍解解锁等级。
     *
     * @default 0
     */
    public static const LV_BANKAI:int           = 0;
    /**
     * 会换升级音效的等级。当前每一项都是 0。
     */
    public static const ALL_ACTION_LEVELS:Array = [
        LV_DASH_AIR, LV_GHOST_STEP,
        LV_SKILL1, LV_SKILL2, LV_SKILL_AIR,
        LV_ZHAO1, LV_ZHAO2, LV_ZHAO3,
        LV_CATCH1, LV_CATCH2,
        LV_BISHA, LV_BISHA_AIR, LV_BISHA_UP, LV_BISHA_SUPER,
        LV_BANKAI
    ];

    /**
     * 记下角色数据。数据为空时，后面的取值会抛错。
     *
     * @param v 角色数据。
     * @example
     * <listing version="3.0">
     * var logic:MusouFighterLogic = new MusouFighterLogic(vo);
     * </listing>
     */
    public function MusouFighterLogic(v:MusouFighterVO) {
        _fightData = v;
    }
    /** @private */
    private var _fightData:MusouFighterVO;

    /**
     * 体力。
     *
     * @return 体力。
     * @example
     * <listing version="3.0">
     * var hp:int = logic.getHP();
     * </listing>
     */
    public function getHP():int {
        return _fightData.getHP();
    }

    /**
     * 气。
     *
     * @return 气。
     * @example
     * <listing version="3.0">
     * var qi:int = logic.getQI();
     * </listing>
     */
    public function getQI():int {
        return _fightData.getQI();
    }

    /**
     * 能量。
     *
     * @return 能量。
     * @example
     * <listing version="3.0">
     * var energy:int = logic.getEnergy();
     * </listing>
     */
    public function getEnergy():int {
        return _fightData.getEnergy();
    }

    /**
     * 把普攻、技能、必杀加成写到角色上。
     *
     * @param f 角色。为空时抛错。
     * @example
     * <listing version="3.0">
     * logic.initFighterProps(fighter);
     * </listing>
     */
    public function initFighterProps(f:FighterMain):void {
        f.initAttackAddDmg(_fightData.getAttackDmg(), _fightData.getSkillDmg(), _fightData.getBishaDmg());
    }

    /**
     * 是否能冲刺。固定返回 <code>true</code>。
     *
     * @return <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = logic.canDash();
     * </listing>
     */
    public function canDash():Boolean {
        return true;
    }

    /**
     * 等级是否达到空中冲刺。
     *
     * @return 达到时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = logic.canDashAir();
     * </listing>
     */
    public function canDashAir():Boolean {
        return _fightData.getLevel() >= LV_DASH_AIR;
    }

    /**
     * 等级是否达到残影步。
     *
     * @return 达到时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = logic.canGhostStep();
     * </listing>
     */
    public function canGhostStep():Boolean {
        return _fightData.getLevel() >= LV_GHOST_STEP;
    }

    /**
     * 等级是否达到空中技能。
     *
     * @return 达到时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = logic.canSkillAir();
     * </listing>
     */
    public function canSkillAir():Boolean {
        return _fightData.getLevel() >= LV_SKILL_AIR;
    }

    /**
     * 等级是否达到技能 1。
     *
     * @return 达到时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = logic.canSkill1();
     * </listing>
     */
    public function canSkill1():Boolean {
        return _fightData.getLevel() >= LV_SKILL1;
    }

    /**
     * 等级是否达到技能 2。
     *
     * @return 达到时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = logic.canSkill2();
     * </listing>
     */
    public function canSkill2():Boolean {
        return _fightData.getLevel() >= LV_SKILL2;
    }

    /**
     * 等级是否达到招式 1。
     *
     * @return 达到时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = logic.canZhao1();
     * </listing>
     */
    public function canZhao1():Boolean {
        return _fightData.getLevel() >= LV_ZHAO1;
    }

    /**
     * 等级是否达到招式 2。
     *
     * @return 达到时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = logic.canZhao2();
     * </listing>
     */
    public function canZhao2():Boolean {
        return _fightData.getLevel() >= LV_ZHAO2;
    }

    /**
     * 等级是否达到招式 3。
     *
     * @return 达到时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = logic.canZhao3();
     * </listing>
     */
    public function canZhao3():Boolean {
        return _fightData.getLevel() >= LV_ZHAO3;
    }

    /**
     * 等级是否达到投技 1。
     *
     * @return 达到时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = logic.canCatch1();
     * </listing>
     */
    public function canCatch1():Boolean {
        return _fightData.getLevel() >= LV_CATCH1;
    }

    /**
     * 等级是否达到投技 2。
     *
     * @return 达到时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = logic.canCatch2();
     * </listing>
     */
    public function canCatch2():Boolean {
        return _fightData.getLevel() >= LV_CATCH2;
    }

    /**
     * 等级是否达到必杀。
     *
     * @return 达到时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = logic.canBisha();
     * </listing>
     */
    public function canBisha():Boolean {
        return _fightData.getLevel() >= LV_BISHA;
    }

    /**
     * 等级是否达到上必杀。
     *
     * @return 达到时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = logic.canBishaUP();
     * </listing>
     */
    public function canBishaUP():Boolean {
        return _fightData.getLevel() >= LV_BISHA_UP;
    }

    /**
     * 等级是否达到空中必杀。
     *
     * @return 达到时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = logic.canBishaAir();
     * </listing>
     */
    public function canBishaAir():Boolean {
        return _fightData.getLevel() >= LV_BISHA_AIR;
    }

    /**
     * 等级是否达到超必杀。
     *
     * @return 达到时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = logic.canBishaSuper();
     * </listing>
     */
    public function canBishaSuper():Boolean {
        return _fightData.getLevel() >= LV_BISHA_SUPER;
    }

    /**
     * 等级是否达到卍解。
     *
     * @return 达到时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = logic.canBankai();
     * </listing>
     */
    public function canBankai():Boolean {
        return _fightData.getLevel() >= LV_BANKAI;
    }

}
}
