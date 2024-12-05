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

package net.play5d.game.bvn.fighter.cntlr {
import flash.display.MovieClip;
import flash.geom.Rectangle;

import net.play5d.game.bvn.cntlr.EffectCtrl;
import net.play5d.game.bvn.fighter.Assister;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.events.FighterEvent;
import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
import net.play5d.game.bvn.fighter.models.FighterHitModel;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.interfaces.IGameSpriteCntlr;

public class AssisiterCtrler implements IGameSpriteCntlr {
    include '../../../../../../../include/_INCLUDE_.as';

    public function AssisiterCtrler() {
    }
    public var hitModel:FighterHitModel;
    private var _effectCtrl:FighterEffectCtrl;
    private var _assister:Assister;
    private var _touchFloor:Boolean;
    private var _touchFloorFrame:String;
    private var hitTargetAction:String;
    private var hitTargetChecker:String;

    public function get effect():FighterEffectCtrl {
        return _effectCtrl;
    }

    public function get owner_mc_ctrler():FighterMcCtrler {
        var fighter:FighterMain = _assister.getOwner() as FighterMain;
        if (fighter) {
            return fighter.getCtrler().getMcCtrl();
        }
        return null;
    }

    public function get owner_fighter_ctrler():FighterCtrler {
        var fighter:FighterMain = _assister.getOwner() as FighterMain;
        if (fighter) {
            return fighter.getCtrler();
        }
        return null;
    }

    public function destory():void {
        if (_effectCtrl) {
            _effectCtrl.destory();
            _effectCtrl = null;
        }
        if (hitModel) {
            hitModel.destory();
            hitModel = null;
        }
        _assister = null;
    }

    /**
     * 获取目标
     * @return 目标游戏精灵
     */
    public function getTarget():IGameSprite {
        var owner:FighterMain = _assister.getOwner() as FighterMain;
        if (owner) {
            return owner.getCurrentTarget();
        }

        return null;
    }

    /**
     * 获取所有目标的 IGameSprite
     * @param isOnlyAlive 是否仅获取存活的目标
     * @return 目标全部游戏精灵
     */
    public function getTargetAll(isOnlyAlive:Boolean = true):Vector.<IGameSprite> {
        return null;
    }

    /**
     * 获取主人
     * @return 游戏精灵的上层
     */
    public function getOwner():IGameSprite {
        return _assister.getOwner();
    }

    /**
     * 获取最上层主人
     * @return 游戏精灵的最上层
     */
    public function getOwnerTop():IGameSprite {
        return null;
    }

    /**
     * 获取自身
     * @return 游戏精灵自身
     */
    public function getSelf():IGameSprite {
        return _assister;
    }

    public function setApplyG(v:Boolean):void {
        _assister.isApplyG = v;
    }

    public function finish(showEffect:Boolean = true):void {
        if (showEffect) {
            EffectCtrl.I.assisterEffect(_assister);
        }
        _assister.isAttacking = false;
        removeSelf();
        _assister.gotoAndStop(1);
    }

    /**
     * 定义攻击数据，由FLASH IDE 调用
     * @param id 攻击KEY
     * @param obj 攻击数据
     * sample : defineAction("atm1" , {power:30 , hitType:1 , hitx:2 , hity:6 , hurtTime:300 , hurtType:0 ,
     *         isBreakDef:false});
     */
    public function defineAction(id:String, obj:Object):void {
        hitModel.addHitVO(id, obj);
    }

    public function initAssister(assister:Assister):void {
        hitModel    = new FighterHitModel(assister);
        _assister   = assister;
        _effectCtrl = new FighterEffectCtrl(assister);
    }

    public function endAct():void {
        _assister.isAttacking = false;
    }

    public function render():void {
        renderCheckTargetHit();

        if (_assister.isInAir) {
            _touchFloor = false;
            return;
        }

        if (!_touchFloor) {
            _touchFloor = true;
            if (_touchFloorFrame) {
                _assister.gotoAndPlay(_touchFloorFrame);
                _touchFloorFrame = null;
            }
        }
    }

//		public function moveToTarget(offsetX:Number = NaN , offsetY:Number = NaN):void{
//			_assister.moveToTarget(offsetX,offsetY);
//		}

    /**
     * 移动到攻击对象
     * @param offsetX X位置偏移
     * @param offsetY Y位置偏移
     * @param setDirect 面对到攻击对象
     * parent.$fighter_ctrler.moveToTarget(0,0,true);
     */
    public function moveToTarget(x:Object = null, y:Object = null, setDirect:Boolean = true):void {
        var fighter:FighterMain = _assister.getOwner() as FighterMain;
        if (!fighter) {
            return;
        }

        var target:IGameSprite = fighter.getCurrentTarget();
        if (!target) {
            return;
        }

        //			var display:DisplayObject = _fighter.getDisplay();
        //			var targetDisplay:DisplayObject = target.getDisplay();

        if (x != null) {
            _assister.x = target.x + Number(x) * _assister.direct;
        }

        if (y != null) {
            _assister.y = target.y + Number(y);
        }

        if (setDirect) {
            _assister.direct = (
                                       _assister.x < target.x
                               ) ? 1 : -1;
        }
    }

    public function setDirectToTarget():void {
        var target:IGameSprite = getTarget();
        if (!target) {
            return;
        }
        _assister.direct = (
                                   _assister.x < target.x
                           ) ? 1 : -1;
    }

    public function move(x:Number = 0, y:Number = 0):void {
        _assister.setVelocity(x * _assister.direct, y);
    }

    public function damping(x:Number = 0, y:Number = 0):void {
        _assister.setDamping(x, y);
    }

    public function stop():void {
        _assister.stop();
    }

    public function gotoAndPlay(frame:String):void {
        _assister.gotoAndPlay(frame);
    }

    public function gotoAndStop(frame:String):void {
        _assister.gotoAndStop(frame);
    }

    public function setTouchFloor(frame:String):void {
        _touchFloorFrame = frame;
    }

//		public function justHit(hitId:String):Boolean{
//			return _assister.justHit(hitId);
//		}

    /**
     * 刚刚攻击到
     * @param hitId 攻击ID
     * @param includeDefense 包括防御
     * @return
     */
    public function justHit(hitId:String, playFrame:String = null, includeDefense:Boolean = false):Boolean {
        if (isJustHit(hitId, includeDefense)) {
            if (playFrame != null) {
                gotoAndPlay(playFrame);
            }
            return true;
        }
        return false;
    }

    //设定检测碰撞后攻击,checker:检测对象名称，action碰撞后执行的动作
    public function setHitTarget(checker:String, action:String):void {
        hitTargetAction  = action;
        hitTargetChecker = checker;
    }

    public function removeSelf():void {
        _assister.removeSelf();
    }

    //放波，子弹
    public function fire(mcName:String, params:Object = null):void {

        var mc:MovieClip = _assister.mc.getChildByName(mcName) as MovieClip;
        if (mc) {
            params ||= {};
            params.mc    = mc;
            params.hitVO = hitModel.getHitVO(mcName);

            FighterEventDispatcher.dispatchEvent(_assister, FighterEvent.FIRE_BULLET, params);
        }
        else {
            _assister.setAnimateFrameOut(function ():void {
                fire(mcName, params);
            }, 1);
        }

    }

    public function addAttacker(mcName:String, params:Object = null):void {
        var mc:MovieClip = _assister.mc.getChildByName(mcName) as MovieClip;
        if (mc) {
            params ||= {};
            params.mc    = mc;
            params.hitVO = hitModel.getHitVOByDisplayName(mcName);

            FighterEventDispatcher.dispatchEvent(_assister, FighterEvent.ADD_ATTACKER, params);
        }
        else {
            _assister.setAnimateFrameOut(function ():void {
                addAttacker(mcName, params);
            }, 1);
        }
    }

    /**
     * 检测碰撞主角
     */
    public function checkHitOwner(mcName:String):Boolean {
        var rect:Rectangle = _assister.getHitCheckRect(mcName);
        if (!rect) {
            return false;
        }
        var ownerRect:Rectangle = _assister.getOwner().getArea();
        if (!ownerRect) {
            return false;
        }
        return rect.intersects(ownerRect);
    }

    private function isJustHit(hitId:String, includeDefense:Boolean = false):Boolean {
        var owner:FighterMain  = _assister.getOwner() as FighterMain;
        var target:IGameSprite = owner.getCurrentTarget();
        if (target && target is FighterMain) {
            var hv:HitVO = (
                    target as FighterMain
            ).hurtHit;
            if (hv) {
                return hv.id == hitId;
            }
            if (includeDefense) {
                var hv2:HitVO = (
                        target as FighterMain
                ).defenseHit;
                if (hv2) {
                    return hv2.id == hitId;
                }
            }
        }
        return false;
    }

    private function renderCheckTargetHit():void {
        if (!hitTargetChecker) {
            return;
        }

        var rect:Rectangle = _assister.getHitCheckRect(hitTargetChecker);
        if (!rect) {
            return;
        }

        var targets:Vector.<IGameSprite> = _assister.getTargets();
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
