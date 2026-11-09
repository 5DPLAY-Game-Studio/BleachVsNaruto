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
import net.play5d.game.bvn.data.vos.TeamVO;

/**
 * 按 id 存放的队伍表。
 *
 * <p><code>clear</code> 只清查找表，<code>teams</code> 里的旧队伍还在，要等下一次 <code>add</code> 或 <code>remove</code> 才重建。</p>
 *
 * @see TeamVO
 */
public class TeamMap {

    /**
     * 当前队伍。查找表重建之后才会换成新数组。
     */
    public var teams:Vector.<TeamVO> = new Vector.<TeamVO>();
    /** @private */
    private var _teamObj:Object      = {};

    /**
     * 清掉按 id 查找的表。
     *
     * <p><code>teams</code> 不会跟着变。</p>
     *
     * @example
     * <listing version="3.0">
     * map.clear();
     * </listing>
     */
    public function clear():void {
        _teamObj = {};
    }

    /**
     * 按 id 取队伍。
     *
     * @param id 队伍 id。
     * @return 队伍。没有这个 id 时为 <code>undefined</code>。
     * @example
     * <listing version="3.0">
     * var team:TeamVO = map.getTeam(1);
     * </listing>
     */
    public function getTeam(id:int):TeamVO {
        return _teamObj[id];
    }

    /**
     * 取除这个 id 以外的队伍。
     *
     * @param id 要排除的队伍 id。
     * @return 新的数组。
     * @example
     * <listing version="3.0">
     * var others:Vector.&lt;TeamVO&gt; = map.getOtherTeams(1);
     * </listing>
     */
    public function getOtherTeams(id:int):Vector.<TeamVO> {
        var teams:Vector.<TeamVO> = new Vector.<TeamVO>();
        for each(var i:TeamVO in _teamObj) {
            if (i.id != id) {
                teams.push(i);
            }
        }
        return teams;
    }

    /**
     * 放入或覆盖一个队伍，并重建 <code>teams</code>。
     *
     * <p>同一个 id 会覆盖。<code>v</code> 为空时抛错。</p>
     *
     * @param v 队伍。
     * @example
     * <listing version="3.0">
     * map.add(team);
     * </listing>
     */
    public function add(v:TeamVO):void {
        _teamObj[v.id] = v;
        refreshTeams();
    }

    /**
     * 按 id 删掉队伍，并重建 <code>teams</code>。
     *
     * @param v 队伍。为空时抛错。
     * @example
     * <listing version="3.0">
     * map.remove(team);
     * </listing>
     */
    public function remove(v:TeamVO):void {
        delete _teamObj[v.id];
        refreshTeams();
    }

    /** @private */
    private function refreshTeams():void {
        teams = new Vector.<TeamVO>();
        for each(var i:TeamVO in _teamObj) {
            if (i) {
                teams.push(i);
            }
        }
    }

}
}
