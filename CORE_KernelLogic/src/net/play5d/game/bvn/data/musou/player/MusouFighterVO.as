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

package net.play5d.game.bvn.data.musou.player {
import net.play5d.game.bvn.interfaces.ISaveData;
import net.play5d.game.bvn.data.musou.LevelModel;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.interfaces.IInstanceVO;
import net.play5d.kyo.utils.WrapInteger;

/**
 * 一个无双角色的等级、经验和战斗数值。
 *
 * <p>等级上限默认 80，存在 <code>LEVEL_MAX</code> 里。构造时等级是 1，并按等级重算攻击、体力、气和能量。
 * 加经验一次最多升 1 级，多出来的经验留到下次。已经到上限时不再升级，也不派升级事件，经验写成当前等级的升级线。
 * 读档时经验和等级为 0 会跳过，所以 0 不会把现有值清掉。等级写入后才会重算数值。</p>
 *
 * @see LevelModel
 */
public class MusouFighterVO implements ISaveData, IInstanceVO {

    include '../../../../../../../../include/Clone.as';

    /**
     * 等级上限。改这个值会影响之后的升级。
     *
     * @default 80
     */
    public static var LEVEL_MAX:WrapInteger = new WrapInteger(80);

    /**
     * 从 1 级开始，并按 1 级重算数值。
     *
     * @example
     * <listing version="3.0">
     * var vo:MusouFighterVO = new MusouFighterVO();
     * </listing>
     */
    public function MusouFighterVO() {
        _level.setValue(1);
        updateLevel(_level.getValue());
    }
    /**
     * 角色 id。
     *
     * @default null
     */
    public var id:String;
    /** @private */
    private var _level:WrapInteger    = new WrapInteger(0);
    /** @private */
    private var _exp:WrapInteger      = new WrapInteger(0);
    /** @private */
    private var _atk:WrapInteger      = new WrapInteger(0);
    /** @private */
    private var _skillAtk:WrapInteger = new WrapInteger(0);
    /** @private */
    private var _bishaAtk:WrapInteger = new WrapInteger(0);
    /** @private */
    private var _hp:WrapInteger       = new WrapInteger(0);
    /** @private */
    private var _qi:WrapInteger       = new WrapInteger(0);

    /** @private */
    private var _energy:WrapInteger = new WrapInteger(0);

    /**
     * 普攻加成。等级乘 10。
     *
     * @return 普攻加成。
     * @example
     * <listing version="3.0">
     * var atk:int = vo.getAttackDmg();
     * </listing>
     */
    public function getAttackDmg():int {
        return _atk.getValue();
    }

    /**
     * 技能加成。等级乘 15。
     *
     * @return 技能加成。
     * @example
     * <listing version="3.0">
     * var skl:int = vo.getSkillDmg();
     * </listing>
     */
    public function getSkillDmg():int {
        return _skillAtk.getValue();
    }

    /**
     * 必杀加成。等级乘 17。
     *
     * @return 必杀加成。
     * @example
     * <listing version="3.0">
     * var bs:int = vo.getBishaDmg();
     * </listing>
     */
    public function getBishaDmg():int {
        return _bishaAtk.getValue();
    }

    /**
     * 体力。1000 加等级乘 150。
     *
     * @return 体力。
     * @example
     * <listing version="3.0">
     * var hp:int = vo.getHP();
     * </listing>
     */
    public function getHP():int {
        return _hp.getValue();
    }

    /**
     * 气。100 加等级乘 20，最高 300。
     *
     * @return 气。
     * @example
     * <listing version="3.0">
     * var qi:int = vo.getQI();
     * </listing>
     */
    public function getQI():int {
        return _qi.getValue();
    }

    /**
     * 能量。50 加等级乘 10。
     *
     * @return 能量。
     * @example
     * <listing version="3.0">
     * var energy:int = vo.getEnergy();
     * </listing>
     */
    public function getEnergy():int {
        return _energy.getValue();
    }

    /**
     * 当前等级。
     *
     * @return 等级。
     * @example
     * <listing version="3.0">
     * var lv:int = vo.getLevel();
     * </listing>
     */
    public function getLevel():int {
        return _level.getValue();
    }

    /**
     * 当前经验。
     *
     * @return 经验。
     * @example
     * <listing version="3.0">
     * var exp:int = vo.getExp();
     * </listing>
     */
    public function getExp():int {
        return _exp.getValue();
    }

    /**
     * 加上经验。够升级线时只升 1 级。
     *
     * @param v 增加的经验。负数会把经验减下去。
     * @example
     * <listing version="3.0">
     * vo.addExp(100);
     * </listing>
     */
    public function addExp(v:int):void {
        var lv:int      = _level.getValue();
        var val:int     = _exp.getValue() + v;
        var nextExp:int = LevelModel.getLevelUpExp(lv);

        if (val >= nextExp) {
            var isLimit:Boolean = updateLevel(lv + 1);
            if (!isLimit) {
                TraceLang('musou_fighter_vo.level_up');
                GameEvent.dispatchEvent(GameEvent.LEVEL_UP, this);
                _exp.setValue(val - nextExp);
            }
            else {
                _exp.setValue(nextExp);
            }
            return;
        }

        _exp.setValue(val);

    }

    /**
     * 存 id、等级和经验。
     *
     * @return 存档对象。
     * @example
     * <listing version="3.0">
     * var o:Object = vo.toSaveObj();
     * </listing>
     */
    public function toSaveObj():Object {
        var o:Object = {};
        o.id         = id;
        o.level      = _level.getValue();
        o.exp        = _exp.getValue();
        return o;
    }

    /**
     * 读 id、经验和等级。
     *
     * <p>对象为空时抛错。id、经验或等级为 0 或空时跳过对应字段。</p>
     *
     * @param o 存档对象。
     * @example
     * <listing version="3.0">
     * vo.readSaveObj(o);
     * </listing>
     */
    public function readSaveObj(o:Object):void {
        if (o.id) {
            id = o.id;
        }
        if (o.exp) {
            _exp.setValue(o.exp);
        }
        if (o.level) {
            updateLevel(o.level);
        }
    }

    /** @private */
    private function updateLevel(lv:int):Boolean {
        var lvMax:int       = LEVEL_MAX.getValue();
        var isLimit:Boolean = false;

        if (lv < 1) {
            lv = 1;
        }

        if (lv > lvMax) {
            lv      = lvMax;
            isLimit = true;
        }

        _level.setValue(lv);

        _atk.setValue(lv * 10);
        _skillAtk.setValue(lv * 15);
        _bishaAtk.setValue(lv * 17);

        _hp.setValue(1000 + lv * 150);
        _energy.setValue(50 + lv * 10);

        var qi:int = 100 + lv * 20;
        _qi.setValue(Math.min(qi, 300));

        return isLimit;
    }

}
}
