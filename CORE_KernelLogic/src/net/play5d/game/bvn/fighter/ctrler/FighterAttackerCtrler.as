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

package net.play5d.game.bvn.fighter.ctrler {
import flash.display.MovieClip;
import flash.geom.Rectangle;

import net.play5d.game.bvn.fighter.Assister;
import net.play5d.game.bvn.fighter.FighterAttacker;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.events.FighterEvent;
import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.interfaces.IGameSprite;

public class FighterAttackerCtrler {
    include '../../../../../../../include/_INCLUDE_.as';

    public function FighterAttackerCtrler(attacker:FighterAttacker) {
        _attacker = attacker;
    }
    public var effect:FighterEffectCtrl;
    public var ownerMc:FighterMcCtrler;
    private var _attacker:FighterAttacker;
    private var _touchFloor:Boolean;
    private var _touchFloorFrame:String;
    private var hitTargetAction:String;
    private var hitTargetChecker:String;

    public function get owner_mc_ctrler():FighterMcCtrler {
        var fighter:FighterMain = _attacker.getOwner() as FighterMain;
        if (fighter) {
            return fighter.getCtrler().getMcCtrl();
        }
        return null;
    }

    public function get owner_fighter_ctrler():FighterCtrler {
        var fighter:FighterMain = _attacker.getOwner() as FighterMain;
        if (fighter) {
            return fighter.getCtrler();
        }
        return null;
    }

    public function destory():void {
        _attacker = null;
        effect    = null;
        ownerMc   = null;
    }

    public function endAct():void {
        _attacker.isAttacking = false;
    }

    public function render():void {

        renderCheckTargetHit();

        if (_attacker.isInAir) {
            _touchFloor = false;
            return;
        }

        if (!_touchFloor) {
            _touchFloor = true;
            if (_touchFloorFrame) {
                _attacker.gotoAndPlay(_touchFloorFrame);
                _touchFloorFrame = null;
            }
        }

    }

    public function stopFollowTarget():void {
        _attacker.stopFollowTarget();
    }

    public function moveToTarget(offsetX:Number = NaN, offsetY:Number = NaN):void {
        _attacker.moveToTarget(offsetX, offsetY);
    }

    public function move(x:Number = 0, y:Number = 0):void {
        _attacker.setVelocity(x * _attacker.direct, y);
    }

    public function damping(x:Number = 0, y:Number = 0):void {
        _attacker.setDamping(x, y);
    }

    public function stop():void {
        _attacker.stop();
    }

    public function gotoAndPlay(frame:String):void {
        _attacker.gotoAndPlay(frame);
    }

    public function gotoAndStop(frame:String):void {
        _attacker.gotoAndStop(frame);
    }

    public function setTouchFloor(frame:String):void {
        _touchFloorFrame = frame;
    }

    public function justHit(hitId:String):Boolean {
        var owner:IGameSprite = _attacker.getOwner();
        if (owner is FighterMain) {
            return (
                    _attacker.getOwner() as FighterMain
            ).getCtrler().justHit(hitId);
            ;
        }
        if (owner is Assister) {
            return (
                    _attacker.getOwner() as Assister
            ).getCtrler().justHit(hitId);
            ;
        }
        return false;
    }

    //设定检测碰撞后攻击,checker:检测对象名称，action碰撞后执行的动作
    public function setHitTarget(checker:String, action:String):void {
        hitTargetAction  = action;
        hitTargetChecker = checker;
    }

    public function setCrossMap(v:Boolean):void {
        _attacker.isAllowCrossX = _attacker.isAllowCrossBottom = v;
    }

    public function removeSelf():void {
        _attacker.removeSelf();
    }

    //放波，子弹
    public function fire(mcName:String, params:Object = null):void {

        if (!owner_fighter_ctrler || !owner_fighter_ctrler.hitModel) {
            trace('hitModel error!');
            return;
        }

        var mc:MovieClip = _attacker.mc.getChildByName(mcName) as MovieClip;
        if (mc) {
            params ||= {};
            params.mc = mc;

            var hv:HitVO = owner_fighter_ctrler.hitModel.getHitVOByDisplayName(mcName);
            if (!hv) {
                trace('hitVO error!');
                return;
            }

            hv       = hv.clone() as HitVO;
            hv.owner = _attacker;

            params.hitVO = hv;

            FighterEventDispatcher.dispatchEvent(_attacker, FighterEvent.FIRE_BULLET, params);
        }
        else {
            _attacker.setAnimateFrameOut(function ():void {
                fire(mcName, params);
            }, 1);
        }

    }

    private function renderCheckTargetHit():void {
        if (!hitTargetChecker) {
            return;
        }

        var rect:Rectangle = _attacker.getHitCheckRect(hitTargetChecker);
        if (!rect) {
            return;
        }

        var targets:Vector.<IGameSprite> = _attacker.getTargets();
        if (!targets) {
            return;
        }

        for (var i:int; i < targets.length; i++) {
            var body:Rectangle = targets[i].getBodyArea();
            if (body && rect.intersects(body)) {
                gotoAndPlay(hitTargetAction);
            }
        }

    }

}
}
