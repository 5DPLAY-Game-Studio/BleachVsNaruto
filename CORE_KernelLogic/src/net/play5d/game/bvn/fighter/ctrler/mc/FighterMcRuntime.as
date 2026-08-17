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

package net.play5d.game.bvn.fighter.ctrler.mc {
import net.play5d.game.bvn.fighter.ctrler.FighterActionLogic;
import net.play5d.game.bvn.fighter.FighterAction;
import net.play5d.game.bvn.fighter.FighterMC;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;

/**
 * Mc 门面与 Hurt/Action 协作者共享的运行时状态。
 *
 * <p>不对外暴露；由 <code>FighterMcCtrler</code> 持有并注入协作者。</p>
 *
 * @see FighterMcCtrler
 */
public class FighterMcRuntime {

    /**
     * 角色主类。
     */
    public var fighter:FighterMain;

    /**
     * 角色 MC 封装。
     */
    public var mc:FighterMC;

    /**
     * 动作定义。
     */
    public var action:FighterAction;

    /**
     * 动作输入判定。
     */
    public var actionLogic:FighterActionLogic;

    /**
     * 操作控制（键/AI）。
     */
    public var actionCtrler:IFighterActionCtrl;

    /**
     * 是否已贴地。
     * @default true
     */
    public var isTouchFloor:Boolean = true;

    /**
     * 是否正在下落。
     */
    public var isFalling:Boolean;

    /**
     * 当前动作帧标签。
     */
    public var doingAction:String;

    /**
     * 当前空中动作帧标签。
     */
    public var doingAirAction:String;

    /**
     * 当前 doAction 已持续帧数（供卍解等判定）。
     */
    public var doActionFrame:int;

}
}
