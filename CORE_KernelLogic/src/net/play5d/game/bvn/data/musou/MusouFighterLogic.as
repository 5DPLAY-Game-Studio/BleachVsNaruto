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

public class MusouFighterLogic {

    public static const LV_DASH_AIR:int   = 0;
    public static const LV_GHOST_STEP:int = 0;
    public static const LV_SKILL1:int    = 0;
    public static const LV_SKILL2:int    = 0;
    public static const LV_SKILL_AIR:int = 0;
    public static const LV_ZHAO1:int = 0;
    public static const LV_ZHAO2:int = 0;
    public static const LV_ZHAO3:int = 0;
    public static const LV_CATCH1:int = 0;
    public static const LV_CATCH2:int = 0;
    public static const LV_BISHA:int       = 0;
    public static const LV_BISHA_AIR:int   = 0;
    public static const LV_BISHA_UP:int    = 0;
    public static const LV_BISHA_SUPER:int = 0;
    public static const LV_BANKAI:int = 0;
    public static const ALL_ACTION_LEVELS:Array = [
        LV_DASH_AIR, LV_GHOST_STEP,
        LV_SKILL1, LV_SKILL2, LV_SKILL_AIR,
        LV_ZHAO1, LV_ZHAO2, LV_ZHAO3,
        LV_CATCH1, LV_CATCH2,
        LV_BISHA, LV_BISHA_AIR, LV_BISHA_UP, LV_BISHA_SUPER,
        LV_BANKAI
    ];

    public function MusouFighterLogic(v:MusouFighterVO) {
        _fightData = v;
    }
    private var _fightData:MusouFighterVO;

    public function getHP():int {
        return _fightData.getHP();
    }

    public function getQI():int {
        return _fightData.getQI();
    }

    public function getEnergy():int {
        return _fightData.getEnergy();
    }

    public function initFighterProps(f:FighterMain):void {
        f.initAttackAddDmg(_fightData.getAttackDmg(), _fightData.getSkillDmg(), _fightData.getBishaDmg());
    }

    public function canDash():Boolean {
        return true;
    }

    public function canDashAir():Boolean {
        return _fightData.getLevel() >= LV_DASH_AIR;
    }

    public function canGhostStep():Boolean {
        return _fightData.getLevel() >= LV_GHOST_STEP;
    }

    public function canSkillAir():Boolean {
        return _fightData.getLevel() >= LV_SKILL_AIR;
    }

    public function canSkill1():Boolean {
        return _fightData.getLevel() >= LV_SKILL1;
    }

    public function canSkill2():Boolean {
        return _fightData.getLevel() >= LV_SKILL2;
    }

    public function canZhao1():Boolean {
        return _fightData.getLevel() >= LV_ZHAO1;
    }

    public function canZhao2():Boolean {
        return _fightData.getLevel() >= LV_ZHAO2;
    }

    public function canZhao3():Boolean {
        return _fightData.getLevel() >= LV_ZHAO3;
    }

    public function canCatch1():Boolean {
        return _fightData.getLevel() >= LV_CATCH1;
    }

    public function canCatch2():Boolean {
        return _fightData.getLevel() >= LV_CATCH2;
    }

    public function canBisha():Boolean {
        return _fightData.getLevel() >= LV_BISHA;
    }

    public function canBishaUP():Boolean {
        return _fightData.getLevel() >= LV_BISHA_UP;
    }

    public function canBishaAir():Boolean {
        return _fightData.getLevel() >= LV_BISHA_AIR;
    }

    public function canBishaSuper():Boolean {
        return _fightData.getLevel() >= LV_BISHA_SUPER;
    }

    public function canBankai():Boolean {
        return _fightData.getLevel() >= LV_BANKAI;
    }

}
}
