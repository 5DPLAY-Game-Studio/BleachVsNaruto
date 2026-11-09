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

package net.play5d.game.bvn.data {
import flash.utils.Dictionary;

import net.play5d.game.bvn.data.vos.FighterVO;

import net.play5d.game.bvn.fighter.Assister;
import net.play5d.game.bvn.fighter.FighterMain;

/**
 * 一队三人、当前场上角色和援助。
 *
 * <p><code>destroy</code> 不会清掉已放入的角色表，之后 <code>getFighter</code> 仍能取到已经销毁的实例。
 * 下一个存活角色在当前角色不在存活列表里时，返回列表里的第一个。
 * 按数据找下一槽只认 <code>fighter1</code>、<code>fighter2</code>、<code>fighter3</code> 这三个对象本身。</p>
 *
 * @see FighterVO
 */
public class GameRunFighterGroup {

    /**
     * 第一人的数据。
     *
     * @default null
     */
    public var fighter1:FighterVO;
    /**
     * 第二人的数据。
     *
     * @default null
     */
    public var fighter2:FighterVO;
    /**
     * 第三人的数据。
     *
     * @default null
     */
    public var fighter3:FighterVO;
    /**
     * 援助数据。
     *
     * @default null
     */
    public var assister:FighterVO;
    /**
     * 当前场上角色。
     *
     * @default null
     */
    public var currentFighter:FighterMain;
    /**
     * 当前援助。
     *
     * @default null
     */
    public var currentAssister:Assister;

    /**
     * 当前正在场上的角色 id。
     *
     * <p>没有当前角色或数据时为 <code>null</code>。</p>
     *
     * @return 角色 id。
     */
    public function get currentFighterId():String {
        if (currentFighter && currentFighter.data) {
            return currentFighter.data.id;
        }

        return null;
    }

    /**
     * 当前正在场上的援助 id。
     *
     * <p>没有当前援助或数据时为 <code>null</code>。</p>
     *
     * @return 援助 id。
     */
    public function get currentAssisterId():String {
        if (currentAssister && currentAssister.data) {
            return currentAssister.data.id;
        }

        return null;
    }

    /** @private */
    private var _fighterMap:Dictionary;

    /**
     * 清空队伍数据并销毁场上角色。
     *
     * <p>续关保留的角色不释放显示对象。角色表不会清掉。</p>
     *
     * @param continueLoser 续关要留下的角色；没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * group.destroy(runData.continueLoser);
     * </listing>
     */
    public function destroy(continueLoser:FighterMain = null):void {
        fighter1 = null;
        fighter2 = null;
        fighter3 = null;
        assister = null;

        if (currentFighter) {
            currentFighter.destroy(continueLoser && currentFighter != continueLoser);
            currentFighter = null;
        }
        if (currentAssister) {
            currentAssister.destroy(true);
            currentAssister = null;
        }
    }

    /**
     * 取三人数据。
     *
     * <p>空槽也会放进结果。去掉当前角色时按数据对象比较，对不上三个槽时三个都会留下。</p>
     *
     * @param exceptCurrentFighter 是否去掉当前场上角色对应的那一槽。默认 <code>false</code>。
     * @return 新的数组。
     * @example
     * <listing version="3.0">
     * var list:Vector.&lt;FighterVO&gt; = group.getFighters(true);
     * </listing>
     */
    public function getFighters(exceptCurrentFighter:Boolean = false):Vector.<FighterVO> {
        var vec:Vector.<FighterVO> = new Vector.<FighterVO>();
        var curData:FighterVO      = currentFighter ? currentFighter.data : null;
        if (exceptCurrentFighter) {
            if (fighter1 != curData) {
                vec.push(fighter1);
            }
            if (fighter2 != curData) {
                vec.push(fighter2);
            }
            if (fighter3 != curData) {
                vec.push(fighter3);
            }
        }
        else {
            vec.push(fighter1);
            vec.push(fighter2);
            vec.push(fighter3);
        }
        return vec;
    }

    /**
     * 取三个槽里还活着、并且已经放进表的角色。
     *
     * @return 新的数组。没放进表的槽会被跳过。
     * @example
     * <listing version="3.0">
     * var alive:Vector.&lt;FighterMain&gt; = group.getAliveFighters();
     * </listing>
     */
    public function getAliveFighters():Vector.<FighterMain> {
        var vec:Vector.<FighterMain> = new Vector.<FighterMain>();

        var f1:FighterMain = getFighter(fighter1);
        var f2:FighterMain = getFighter(fighter2);
        var f3:FighterMain = getFighter(fighter3);

        if (f1 && f1.isAlive) {
            vec.push(f1);
        }
        if (f2 && f2.isAlive) {
            vec.push(f2);
        }
        if (f3 && f3.isAlive) {
            vec.push(f3);
        }
        return vec;
    }

    /**
     * 取下一个还活着的场上角色。
     *
     * <p>没有当前角色，或存活不足 2 人时返回 <code>null</code>。当前角色不在存活列表里时返回第一个。</p>
     *
     * @return 下一个存活角色。
     * @example
     * <listing version="3.0">
     * var next:FighterMain = group.getNextAliveFighter();
     * </listing>
     */
    public function getNextAliveFighter():FighterMain {
        if (!currentFighter) {
            return null;
        }

        var aliveFighters:Vector.<FighterMain> = getAliveFighters();
        if (aliveFighters.length < 2) {
            return null;
        }

        var index:int = aliveFighters.indexOf(currentFighter);
        if (index == aliveFighters.length - 1) {
            return aliveFighters[0];
        }

        return aliveFighters[index + 1];
    }

    /**
     * 按槽位取下一个人的数据。
     *
     * <p>当前是第三人时，只有 <code>loop</code> 为 <code>true</code> 才回到第一人。数据对不上三个槽时返回 <code>null</code>。</p>
     *
     * @param loop 是否从第三人绕回第一人。默认 <code>false</code>。
     * @return 下一槽的数据。
     * @example
     * <listing version="3.0">
     * var data:FighterVO = group.getNextFighter(true);
     * </listing>
     */
    public function getNextFighter(loop:Boolean = false):FighterVO {
        if (!currentFighter) {
            return null;
        }
        switch (currentFighter.data) {
        case fighter1:
            return fighter2;
        case fighter2:
            return fighter3;
        case fighter3:
            return loop ? fighter1 : null;
        }
        return null;
    }

    /**
     * 按角色数据对象放进表。同一次数据对象会覆盖。
     *
     * <p><code>f</code> 为空时抛错。</p>
     *
     * @param f 场上角色。
     * @example
     * <listing version="3.0">
     * group.putFighter(fighter);
     * </listing>
     */
    public function putFighter(f:FighterMain):void {
        _fighterMap ||= new Dictionary();
        _fighterMap[f.data] = f;
    }

    /**
     * 按数据对象取已放入的角色。
     *
     * @param data 角色数据，按对象本身查找。
     * @return 场上角色。表还没建时为 <code>null</code>，没有这个键时为 <code>undefined</code>。
     * @example
     * <listing version="3.0">
     * var f:FighterMain = group.getFighter(data);
     * </listing>
     */
    public function getFighter(data:FighterVO):FighterMain {
        if (!_fighterMap) {
            return null;
        }
        return _fighterMap[data];
    }

    /**
     * 取除当前角色以外还活着的人。
     *
     * <p>没有当前角色时返回 <code>null</code>，不是空数组。</p>
     *
     * @return 存活角色。没有当前角色时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var hold:Vector.&lt;FighterMain&gt; = group.getHoldFighters();
     * </listing>
     */
    public function getHoldFighters():Vector.<FighterMain> {
        if (!currentFighter) {
            return null;
        }

        var aliveFighters:Vector.<FighterMain> = getAliveFighters();
        var index:int                          = aliveFighters.indexOf(currentFighter);
        if (index != -1) {
            aliveFighters.splice(index, 1);
        }

        return aliveFighters;
    }

}
}
