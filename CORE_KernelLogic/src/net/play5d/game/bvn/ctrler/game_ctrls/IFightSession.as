/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.ctrler.game_ctrls {
import net.play5d.game.bvn.ctrler.musou_ctrls.MusouCtrl;
import net.play5d.game.bvn.fighter.FighterAttacker;

/**
 * 对局会话：格斗 / 无双等模式差异的窄接口。
 *
 * <p><code>GameCtrl</code> 持有一份实现；公共入口（如 <code>getMusouCtrl</code>）保持不变。</p>
 *
 * @example
 * <listing version="3.0">
 * var s:IFightSession = new VersusFightSession();
 * s.onGameInitialize();
 * s.render();
 * </listing>
 * @see VersusFightSession
 * @see MusouFightSession
 */
public interface IFightSession {
    /**
     * 对局场景已就绪时调用（创建角色事件监听等）。
     *
     * @example
     * <listing version="3.0">
     * session.onGameInitialize();
     * </listing>
     */
    function onGameInitialize():void;

    /**
     * 释放会话资源。
     *
     * @example
     * <listing version="3.0">
     * session.destroy();
     * </listing>
     */
    function destroy():void;

    /**
     * 按名称与队伍取得攻击体。
     *
     * @param name 攻击体名。
     * @param team 队伍 id。
     * @return 攻击体实例。
     * @example
     * <listing version="3.0">
     * var a:FighterAttacker = session.getAttacker('atk', 1);
     * </listing>
     */
    function getAttacker(name:String, team:int):FighterAttacker;

    /**
     * 构建并启动本模式对局内容（无双建波等；格斗模式由 <code>GameCtrl</code> 自行 <code>buildGame</code>）。
     *
     * @example
     * <listing version="3.0">
     * session.buildGame();
     * </listing>
     */
    function buildGame():void;

    /**
     * 逻辑帧推进。
     *
     * @example
     * <listing version="3.0">
     * session.render();
     * </listing>
     */
    function render():void;

    /**
     * 动画帧推进。
     *
     * @example
     * <listing version="3.0">
     * session.renderAnimate();
     * </listing>
     */
    function renderAnimate():void;

    /**
     * 是否由 <code>GameCtrl</code> 驱动回合计时（无双为 <code>false</code>）。
     *
     * @return 允许计时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (session.allowsRoundTimer()) {
     *     // ...
     * }
     * </listing>
     */
    function allowsRoundTimer():Boolean;

    /**
     * 会话是否已结束（用于暂停 UI 门禁等）。
     *
     * @return 已结束为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (session.isFinished()) {
     *     return;
     * }
     * </listing>
     */
    function isFinished():Boolean;

    /**
     * 无双控制器；非无双会话返回 <code>null</code>。
     *
     * @return 无双控制器或 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var m:MusouCtrl = session.getMusouCtrl();
     * </listing>
     */
    function getMusouCtrl():MusouCtrl;
}
}
