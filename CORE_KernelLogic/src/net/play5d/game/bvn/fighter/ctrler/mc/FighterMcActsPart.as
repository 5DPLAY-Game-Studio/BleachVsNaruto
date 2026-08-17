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
import net.play5d.game.bvn.fighter.FighterAction;
import net.play5d.game.bvn.fighter.FighterMC;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.ctrler.FighterActionLogic;
import net.play5d.game.bvn.fighter.ctrler.FighterMcCtrler;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;

/**
 * Mc 动作 Handler 共享基类：持有门面 / 运行时 / 受击域引用。
 *
 * @see FighterMcActionCtrl
 */
public class FighterMcActsPart {

    /** @private */
    protected var _owner:FighterMcCtrler;
    /** @private */
    protected var _rt:FighterMcRuntime;
    /** @private */
    protected var _hurt:FighterMcHurtCtrl;

    /**
     * 绑定共享引用。
     *
     * @param owner 时间轴门面。
     * @param rt 运行时状态。
     * @param hurt 受击域。
     */
    public function bind(owner:FighterMcCtrler, rt:FighterMcRuntime, hurt:FighterMcHurtCtrl):void {
        _owner = owner;
        _rt    = rt;
        _hurt  = hurt;
    }

    /**
     * 释放引用。
     */
    public function destroy():void {
        _owner = null;
        _rt    = null;
        _hurt  = null;
    }

    /** @private */
    protected function get _fighter():FighterMain {
        return _rt.fighter;
    }

    /** @private */
    protected function get _mc():FighterMC {
        return _rt.mc;
    }

    /** @private */
    protected function get _action():FighterAction {
        return _rt.action;
    }

    /** @private */
    protected function get _actionLogic():FighterActionLogic {
        return _rt.actionLogic;
    }

    /** @private */
    protected function get _actionCtrler():IFighterActionCtrl {
        return _rt.actionCtrler;
    }

    /** @private */
    protected function get _isTouchFloor():Boolean {
        return _rt.isTouchFloor;
    }

    /** @private */
    protected function set _isTouchFloor(v:Boolean):void {
        _rt.isTouchFloor = v;
    }

    /** @private */
    protected function get _isFalling():Boolean {
        return _rt.isFalling;
    }

    /** @private */
    protected function set _isFalling(v:Boolean):void {
        _rt.isFalling = v;
    }

    /** @private */
    protected function get _doingAction():String {
        return _rt.doingAction;
    }

    /** @private */
    protected function set _doingAction(v:String):void {
        _rt.doingAction = v;
    }

    /** @private */
    protected function get _doingAirAction():String {
        return _rt.doingAirAction;
    }

    /** @private */
    protected function set _doingAirAction(v:String):void {
        _rt.doingAirAction = v;
    }

}
}
