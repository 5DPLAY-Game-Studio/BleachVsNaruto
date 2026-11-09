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
import net.play5d.game.bvn.interfaces.IInstanceVO;

/**
 * 无双里的一个刷出敌人。
 *
 * <p>体力和攻击不大于 0 时保持 0，不会改成默认参数。经验和钱不大于 0 时，头目用 100，小兵用 10。
 * 实际经验和钱还会加上等级：头目每级 10 点经验和 5 点钱，小兵每级 2 点经验和 1 点钱。</p>
 *
 * @see MusouWaveVO
 */
public class MusouEnemyVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 建一个敌人。体力和攻击只在大于 0 时写入。
     *
     * @param fighterID 角色 id。
     * @param maxHp 体力上限。默认 200。不大于 0 时保持 0。
     * @param atk 攻击。默认 0。
     * @param isBoss 是否头目。默认 <code>false</code>。
     * @param exp 基础经验。默认 10。不大于 0 时按是否头目改成 100 或 10。
     * @param money 基础钱。默认 10。规则和经验相同。
     * @return 新的敌人。
     * @example
     * <listing version="3.0">
     * var enemy:MusouEnemyVO = MusouEnemyVO.create(id, 500, 0, true);
     * </listing>
     */
    public static function create(
            fighterID:String, maxHp:int = 200, atk:int = 0, isBoss:Boolean = false, exp:int = 10,
            money:int                                                                       = 10
    ):MusouEnemyVO {
        var musouEnemyVO:MusouEnemyVO = new MusouEnemyVO();

        musouEnemyVO.fighterID = fighterID;
        musouEnemyVO.isBoss    = isBoss;

        if (maxHp > 0) {
            musouEnemyVO.maxHp = maxHp;
        }

        if (atk > 0) {
            musouEnemyVO.atk = atk;
        }

        if (exp > 0) {
            musouEnemyVO.exp = exp;
        }
        else {
            musouEnemyVO.exp = isBoss ? 100 : 10;
        }

        if (money > 0) {
            musouEnemyVO.money = money;
        }
        else {
            musouEnemyVO.money = isBoss ? 100 : 10;
        }

        return musouEnemyVO;
    }

    /**
     * 按数量把一条 JSON 拆成多个敌人。
     *
     * <p>缺 <code>amount</code> 时数量是 0，返回空数组。缺经验和钱时按 0 处理，再走 <code>create</code> 的默认。</p>
     *
     * @param json 含 <code>id</code>、<code>amount</code>，以及可选的 hp、atk、isBoss、exp、money。
     * @return 新的敌人。
     * @example
     * <listing version="3.0">
     * var list:Vector.&lt;MusouEnemyVO&gt; = MusouEnemyVO.createByJSON(json);
     * </listing>
     */
    public static function createByJSON(json:Object):Vector.<MusouEnemyVO> {
        var id:String      = json.id;
        var hp:int         = json.hp;
        var atk:int        = json.atk;
        var amount:int     = json.amount;
        var isBoss:Boolean = json.isBoss;
        var exp:int        = json.exp;
        var money:int      = json.money;

        var result:Vector.<MusouEnemyVO> = new Vector.<MusouEnemyVO>();
        for (var i:int; i < amount; i++) {
            var mv:MusouEnemyVO = create(id, hp, atk, isBoss, exp, money);
            result.push(mv);
        }
        return result;
    }

    /**
     * 角色 id。
     *
     * @default null
     */
    public var fighterID:String;
    /**
     * 体力上限。0 表示交给关卡等级去算。
     *
     * @default 0
     */
    public var maxHp:int  = 0;
    /**
     * 攻击。0 表示不用这条覆盖。
     *
     * @default 0
     */
    public var atk:int    = 0;
    /**
     * 是否头目。
     *
     * @default false
     */
    public var isBoss:Boolean;
    /**
     * 所属波次。
     *
     * @default null
     */
    public var wave:MusouWaveVO;
    /**
     * 所属重复组。直接刷出的敌人为 <code>null</code>。
     *
     * @default null
     */
    public var repeat:MusouWaveRepeatVO;
    /**
     * 等级。开打前由关卡写成敌人等级。
     *
     * @default 1
     */
    public var level:int  = 1;
    /** @private */
    private var exp:int   = 10;
    /** @private */
    private var money:int = 10;

    /**
     * 基础经验加上等级加成。
     *
     * @return 经验。
     * @example
     * <listing version="3.0">
     * var exp:int = enemy.getExp();
     * </listing>
     */
    public function getExp():int {
        var levelAdd:int = isBoss ? (
                level * 10
        ) : (
                                   level * 2
                           );
        return exp + levelAdd;
    }

    /**
     * 基础钱加上等级加成。
     *
     * @return 钱。
     * @example
     * <listing version="3.0">
     * var money:int = enemy.getMoney();
     * </listing>
     */
    public function getMoney():int {
        var levelAdd:int = isBoss ? (
                level * 5
        ) : (
                                   level * 1
                           );
        return money + levelAdd;
    }
}
}
