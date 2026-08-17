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
import flash.display.DisplayObject;
import flash.geom.Rectangle;

import net.play5d.game.bvn.data.fighter.FighterSpecialFrame;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.ctrler.FighterMcCtrler;
import net.play5d.game.bvn.fighter.vos.MoveTargetParamVO;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IGameSprite;

/**
 * 动作渲染门面：落地 / 空中 / 幽步 / 移动目标。
 *
 * <p><code>FighterMcCtrler</code> 仍为时间轴门面；本类编排动作 Handler。</p>
 *
 * @see FighterMcCtrler
 * @see FighterMcFloorHandler
 * @see FighterMcAirHandler
 * @see FighterMcGhostHandler
 */
public class FighterMcActionCtrl {

    /** @private */
    private var _owner:FighterMcCtrler;
    /** @private */
    private var _rt:FighterMcRuntime;
    /** @private */
    private var _hurt:FighterMcHurtCtrl;
    /** @private */
    private var _floor:FighterMcFloorHandler;
    /** @private */
    private var _air:FighterMcAirHandler;
    /** @private */
    private var _ghost:FighterMcGhostHandler;
    /** @private */
    private var _moveTargetParam:MoveTargetParamVO;
    /** @private */
    private var _autoDirectFrame:int;

    /**
     * 绑定门面与受击域，并组装子 Handler。
     *
     * @param owner 时间轴门面。
     * @param rt 运行时状态。
     * @param hurt 受击域。
     */
    public function bind(owner:FighterMcCtrler, rt:FighterMcRuntime, hurt:FighterMcHurtCtrl):void {
        _owner = owner;
        _rt    = rt;
        _hurt  = hurt;

        _ghost = new FighterMcGhostHandler();
        _air   = new FighterMcAirHandler();
        _floor = new FighterMcFloorHandler();

        _ghost.bind(owner, rt, hurt);
        _air.bind(owner, rt, hurt);
        _air.bindGhost(_ghost);
        _floor.bind(owner, rt, hurt);
        _floor.bindPeers(_air, _ghost);
        _air.bindFloor(_floor);
    }

    /**
     * 释放引用。
     */
    public function destroy():void {
        if (_floor) {
            _floor.destroy();
            _floor = null;
        }
        if (_air) {
            _air.destroy();
            _air = null;
        }
        if (_ghost) {
            _ghost.destroy();
            _ghost = null;
        }
        _moveTargetParam = null;
        _owner           = null;
        _rt              = null;
        _hurt            = null;
    }

    /**
     * 是否处于幽步中。
     */
    public function get ghostStepIng():Boolean {
        return _ghost != null && _ghost.ghostStepIng;
    }

    /**
     * 是否正在跟随目标位移。
     */
    public function get hasMoveTarget():Boolean {
        return _moveTargetParam != null;
    }

    /**
     * 设定或清除攻击目标位移。
     *
     * @param params 位移参数；为 <code>null</code> 时清除。
     */
    public function setMoveTarget(params:Object = null):void {
        if (!params) {
            if (_moveTargetParam) {
                _moveTargetParam.clear();
            }
            _moveTargetParam = null;
            return;
        }
        _moveTargetParam = new MoveTargetParamVO(params);
        _moveTargetParam.setTarget(_rt.fighter.getCurrentTarget());
    }

    /**
     * 清除移动目标。
     */
    public function clearMoveTarget():void {
        _moveTargetParam = null;
    }

    /**
     * idle 时重置自动朝向计数。
     */
    public function resetAutoDirect():void {
        _autoDirectFrame = 0;
    }

    /**
     * doAction 开始时重置动作帧计数。
     */
    public function resetDoActionFrame():void {
        _rt.doActionFrame = 0;
    }

    /**
     * 供卍解判定读取当前动作帧计数。
     */
    public function get doActionFrame():int {
        return _rt.doActionFrame;
    }

    /**
     * 动画帧：推进当前动作帧计数。
     */
    public function tickDoActionFrame():void {
        if (_rt.doingAction) {
            _rt.doActionFrame++;
        }
    }

    /**
     * 动画帧：idle 自动朝向。
     */
    public function tickAutoDirect():void {
        if (_rt.mc && _rt.mc.currentFrameName == FighterSpecialFrame.IDLE) {
            if (++_autoDirectFrame > 5) {
                _rt.fighter.getCtrler().setDirectToTarget();
                _autoDirectFrame = 0;
            }
        }
    }

    /**
     * 落地。
     */
    public function touchFloor():void {
        _air.touchFloor();
    }

    /**
     * 跳跃动画帧。
     */
    public function renderJumpAnimate():void {
        _air.renderJumpAnimate();
    }

    /**
     * 地面动作。
     */
    public function renderFloorAction():void {
        _floor.renderFloorAction();
    }

    /**
     * 卍解输入。
     *
     * @return 是否已消耗本帧输入。
     */
    public function renderWanKaiCtrl():Boolean {
        return _floor.renderWanKaiCtrl();
    }

    /**
     * 空中动作。
     */
    public function renderAirAction():void {
        _air.renderAirAction();
    }

    /**
     * 进入下落。
     */
    public function fall():void {
        _air.fall();
    }

    /**
     * 幽步动画帧。
     */
    public function renderGhostStep():void {
        _ghost.renderGhostStep();
    }

    /**
     * 跟随位移目标。
     */
    public function renderMoveTarget():void {
//			var target:IGameSprite = _rt.fighter.getCurrentTarget();
        var target:IGameSprite = _moveTargetParam.target;
        if (!target) {
            return;
        }
//			var targetDisplay:DisplayObject = target.getDisplay();
//			if(!targetDisplay) return;

//			var selfDisplay:DisplayObject = _rt.fighter.getDisplay();
//			if(!selfDisplay) return;

        var aimX:Number;
        var aimY:Number;

        if (_moveTargetParam.followMcName) {
            var mc:DisplayObject = _rt.mc.getChildByName(_moveTargetParam.followMcName);
            if (!mc) {
                return;
            }

            aimX = _rt.fighter.x + mc.x * _rt.fighter.direct;
            aimY = _rt.fighter.y + mc.y;

        }
        else {

            if (!isNaN(_moveTargetParam.x)) {
                aimX = _moveTargetParam.x;
            }
            if (!isNaN(_moveTargetParam.y)) {
                aimY = _moveTargetParam.y;
            }

        }

        if (_moveTargetParam.speed) {
            if (_moveTargetParam.speed.x > 0 && !isNaN(aimX)) {
                if (target.x > aimX + _moveTargetParam.speed.x) {
                    target.x -= _moveTargetParam.speed.x;
                }
                if (target.x < aimX - _moveTargetParam.speed.x) {
                    target.x += _moveTargetParam.speed.x;
                }
                if (target.y > aimY + _moveTargetParam.speed.y) {
                    if (target is BaseGameSprite) {
//							(target as BaseGameSprite).isApplyG = false;
                        (
                                target as BaseGameSprite
                        ).setVecY(-_moveTargetParam.speed.y);
                        (
                                target as BaseGameSprite
                        ).setDampingY(1);
                    }
                    else {
                        target.y -= _moveTargetParam.speed.y;
                    }
                }
                if (target.y < aimY - _moveTargetParam.speed.y) {
                    if (target is BaseGameSprite) {
                        (
                                target as BaseGameSprite
                        ).setVecY(_moveTargetParam.speed.y);
                        (
                                target as BaseGameSprite
                        ).setDampingY(1);
                    }
                    else {
                        target.y += _moveTargetParam.speed.y;
                    }
                }
            }
        }
        else {
            if (!isNaN(aimX)) {
                target.x = aimX;
            }
            if (!isNaN(aimY)) {
                target.y = aimY;
            }
        }

    }

    /**
     * 命中指定目标后跳转。
     */
    public function renderCheckTargetHit():void {
        var checkerName:String = _rt.action.hitTargetChecker;
        if (!checkerName) {
            return;
        }

        var rect:Rectangle = _rt.fighter.getCtrler().getHitCheckRect(checkerName);
        if (!rect) {
            return;
        }

        var targets:Vector.<IGameSprite> = _rt.fighter.getTargets();
        if (!targets) {
            return;
        }

        for (var i:int; i < targets.length; i++) {
            if (targets[i] is FighterMain) {
                var body:Rectangle = targets[i].getBodyArea();
                if (body && rect.intersects(body)) {
                    _owner.doAction(_rt.action.hitTarget);
                }
            }
        }

    }

}
}
