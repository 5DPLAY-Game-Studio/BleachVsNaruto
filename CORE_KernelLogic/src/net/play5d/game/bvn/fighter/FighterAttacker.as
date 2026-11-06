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

package net.play5d.game.bvn.fighter {
import flash.display.MovieClip;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.fighter.ctrler.FighterAttackerCtrler;
import net.play5d.game.bvn.fighter.models.FighterHitModel;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.fighter.utils.HitAreaUtil;
import net.play5d.game.bvn.fighter.utils.McAreaCacher;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IGameSprite;

public class FighterAttacker extends BaseGameSprite {

    public function FighterAttacker(mainmc:MovieClip, params:Object = null) {
        super(mainmc);

        _mcOrgPoint = new Point(mainmc.x, mainmc.y);

        _startX = _mcOrgPoint.x;
        _startY = _mcOrgPoint.y;

        _x = _startX;
        _y = _startY;

        _ctrler = new FighterAttackerCtrler(this);

        if (mainmc.setAttackerCtrler) {
            mainmc.setAttackerCtrler(_ctrler);
        }

        if (params) {

            if (params.x != undefined) {
                if (params.x is Number) {
                    _startX = params.x + _mcOrgPoint.x;
                }
                else {
                    moveToTargetX = params.x.moveToTarget == true;
                    followTargetX = params.x.followTarget == true;
                    if (params.x.offset != undefined) {
                        _startX = params.x.offset;
                    }
                    if (params.x.range != undefined && params.x.range is Array) {
                        rangeX = new Point(params.x.range[0], params.x.range[1]);
                    }
                }
            }

            if (params.y != undefined) {
                if (params.y is Number) {
                    _startY = params.y + _mcOrgPoint.y;
                }
                else {
                    moveToTargetY = params.y.moveToTarget == true;
                    followTargetY = params.y.followTarget == true;
                    if (params.y.offset != undefined) {
                        _startY = params.y.offset;
                    }
                    if (params.y.range != undefined && params.y.range is Array) {
                        rangeY = new Point(params.y.range[0], params.y.range[1]);
                    }
                }
            }

            if (params.applyG != undefined) {
                isApplyG = params.applyG == true;
            }

        }

    }
    public var onRemove:Function;
    public var isAttacking:Boolean;
    public var moveToTargetX:Boolean;
    public var moveToTargetY:Boolean;
    public var followTargetX:Boolean;
    public var followTargetY:Boolean;
    public var rangeX:Point;
    public var rangeY:Point;
    private var _ctrler:FighterAttackerCtrler;
    private var _owner:IGameSprite;
    private var _startX:Number = 0;

    private var _startY:Number                  = 0;
    private var _hitAreaCache:McAreaCacher      = new McAreaCacher('hit');
    /** @private getCurrentHits 复用缓冲 */
    private var _hitsBuf:Array                  = [];
    private var _hitCheckAreaCache:McAreaCacher = new McAreaCacher('hit_check');
    private var _rectCache:Object               = {};

    private var _mcOrgPoint:Point;
    private var _isRenderMainAnimate:Boolean = true;

    public function get name():String {
        return _mainMc.name;
    }

    public override function destroy(dispose:Boolean = true):void {
        if (_hitAreaCache) {
            _hitAreaCache.destroy();
            _hitAreaCache = null;
        }
        if (_hitCheckAreaCache) {
            _hitCheckAreaCache.destroy();
            _hitCheckAreaCache = null;
        }
        if (_ctrler) {
            _ctrler.destroy();
            _ctrler = null;
        }
        _rectCache  = null;
        _owner      = null;
        _mcOrgPoint = null;

        super.destroy(true);
    }

    public override function renderAnimate():void {
        if (!_isRenderMainAnimate) {
            return;
        }
        super.renderAnimate();
        mc.nextFrame();
        findHitArea();
        if (mc.currentFrame == mc.totalFrames - 1) {
            removeSelf();
        }
    }

    public override function render():void {
        super.render();
        _ctrler.render();
        renderFollowTarget();
    }

    /**
     * 当前攻击的攻击数据 return [FighterHitVO];
     */
    public override function getCurrentHits():Array {
        if (!_hitAreaCache) {
            return null;
        }

        return HitAreaUtil.collectCurrentHits(
                _hitAreaCache.getAreaByFrame(_mainMc.currentFrame) as Array,
                _hitsBuf,
                getCurrentRect
        );
    }

    public override function hit(hitvo:HitVO, target:IGameSprite):void {
        var owner:FighterMain = getOwnerFighter();
        if (target && owner) {
            var rate:Number = _owner is Assister ? GameConfig.QI_ADD_HIT_ASSISTER_RATE :
                              GameConfig.QI_ADD_HIT_ATTACKER_RATE;
            owner.addQi(hitvo.power * rate);
            GameLogic.hitTarget(hitvo, owner, target);
        }
    }

    public function getOwner():IGameSprite {
        return _owner;
    }

    public function getCtrler():FighterAttackerCtrler {
        return _ctrler;
    }

    public function setOwner(v:IGameSprite):void {
        _owner = v;

        direct = v.direct;

        if (_owner is FighterMain) {
            _ctrler.effect = (
                    _owner as FighterMain
            ).getCtrler().getEffectCtrl();
        }
        if (_owner is Assister) {
            _ctrler.effect = (
                    _owner as Assister
            ).getCtrler().effect;
        }
    }

    public function init():void {

        if (!_owner) {
            return;
        }

        if (direct > 0) {
            _x = _owner.x + _startX;
        }
        else {
            _x = _owner.x - _startX;
        }
        _y += _owner.y;

        if (_owner is FighterMain) {
            var fmc:FighterMC = (
                    _owner as FighterMain
            ).getMC();
            _x += fmc.x;
            _y += fmc.y;
        }

        if (!moveToTargetX && !moveToTargetY) {
            return;
        }

        var target:IGameSprite = getTarget();
        if (target) {
            if (moveToTargetX) {
                var tx:Number = target.x + (
                        _startX * direct
                );
                if (rangeX) {
                    var xDis:Number;
                    if (direct > 0) {
                        xDis = tx - _owner.x;
                        if (xDis < rangeX.x) {
                            tx = _owner.x + rangeX.x;
                        }
                        if (xDis > rangeX.y) {
                            tx = _owner.x + rangeX.y;
                        }
                    }
                    else {
                        xDis = _owner.x - tx;
                        if (xDis < rangeX.x) {
                            tx = _owner.x - rangeX.x;
                        }
                        if (xDis > rangeX.y) {
                            tx = _owner.x - rangeX.y;
                        }
                    }
                }
                _x = tx;
            }
            if (moveToTargetY) {
                var ty:Number = target.y + _startY;
                if (rangeY) {
                    var yDis:Number = ty - _owner.y;
                    if (yDis < rangeY.x) {
                        ty = target.y + rangeY.x;
                    }
                    if (yDis > rangeY.y) {
                        ty = target.y + rangeY.y;
                    }
                }
                _y = ty;
            }
        }

        isAttacking = true;

    }

    public function stopFollowTarget():void {
        followTargetX = false;
        followTargetY = false;
    }

    public function moveToTarget(offsetX:Number = NaN, offsetY:Number = NaN):void {
        var target:IGameSprite = getTarget();
        if (!target) {
            return;
        }

        if (!isNaN(offsetX)) {
            _x = target.x + (
                    offsetX * direct
            );
        }
        if (!isNaN(offsetY)) {
            _y = target.y + offsetY;
        }
    }

    public function stop():void {
        _isRenderMainAnimate = false;
    }

    public function gotoAndPlay(frame:String):void {
        _mainMc.gotoAndStop(frame);
        _isRenderMainAnimate = true;
    }

    public function gotoAndStop(frame:String):void {
        _mainMc.gotoAndStop(frame);
        _isRenderMainAnimate = false;
    }

    public function getTargets():Vector.<IGameSprite> {
        if (_owner is FighterMain) {
            return (
                    _owner as FighterMain
            ).getTargets();
        }
        if (_owner is Assister) {
            return (
                    _owner as Assister
            ).getTargets();
        }
        return null;
    }

    public function removeSelf():void {
        if (onRemove != null) {
            onRemove(this);
        }
    }

    public function getHitCheckRect(name:String):Rectangle {
        var area:Rectangle = getCheckHitRect(name);
        if (area == null) {
            return null;
        }
        return getCurrentRect(area, 'hit_check');
    }

    public function getCheckHitRect(name:String):Rectangle {
        return HitAreaUtil.getCheckHitRect(_mainMc, name, _hitCheckAreaCache, _mainMc);
    }

    private function renderFollowTarget():void {
        if (!followTargetX && !followTargetY) {
            return;
        }
        var target:IGameSprite = getTarget();
        if (!target) {
            return;
        }

        if (followTargetX) {
            _x = target.x + (
                    _startX * direct
            );
        }
        if (followTargetY) {
            _y = target.y + _startY;
        }
    }

    private function getTarget():IGameSprite {
        if (_owner is FighterMain) {
            return (
                    _owner as FighterMain
            ).getCurrentTarget();
        }
        if (_owner is Assister) {
            return (
                    _owner as Assister
            ).getCurrentTarget();
        }
        return null;
    }

    private function getCurrentRect(rect:Rectangle, cacheId:String = null):Rectangle {
        return HitAreaUtil.toWorldRect(rect, direct, _x, _y, _rectCache, cacheId);
    }

    private function getHitModel():FighterHitModel {
        if (_owner is FighterMain) {
            return (
                    _owner as FighterMain
            ).getCtrler().hitModel;
        }
        if (_owner is Assister) {
            return (
                    _owner as Assister
            ).getCtrler().hitModel;
        }
        ThrowError(Error, GetLang('log.error.fight.fighter_attacker.unsupported_type'));
        return null;
    }

    private function findHitArea():void {
        if (!_hitAreaCache) {
            return;
        }
        var hitModel:FighterHitModel = getHitModel();
        if (!hitModel) {
            return;
        }

        HitAreaUtil.findHitArea(_mainMc, _mainMc.currentFrame, _hitAreaCache, _mainMc, hitModel, true);
    }

    private function getOwnerFighter():FighterMain {
        if (_owner is FighterMain) {
            return _owner as FighterMain;
        }
        if (_owner is Assister) {
            return (
                   _owner as Assister
                   ).getOwner() as FighterMain;
        }
        return null;
    }

}
}
