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
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrl.EffectCtrl;
import net.play5d.game.bvn.ctrl.GameLogic;
import net.play5d.game.bvn.data.TeamVO;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.utils.MCUtils;
import net.play5d.kyo.utils.KyoUtils;

public class Bullet implements IGameSprite {
    include '../../../../../../include/_INCLUDE_.as';

    /**
     * 子弹，波
     * @param mc 显示对象
     * @param params 参数 {
     * 						x:Number(速度X)|{start:Number(开始速度),add:Number(加速度),max:Number(最大速度)} ,
     * 						y:Number(速度Y)|{start:Number(开始速度),add:Number(加速度),max:Number(最大速度)} ,
     * 						hold:int(持续帧数) ,
     * 						hits:int(攻击次数)
     * 					 }
     */
    public function Bullet(mc:MovieClip, params:Object = null) {
        this.mc    = mc;
        _orgScale  = new Point(mc.scaleX, mc.scaleY);
        _orgRotate = mc.rotation;

        if (params) {
            if (params.x) {
                if (params.x is Number) {
                    speed.x = params.x;
                }
                else {
                    if (params.x.start != undefined) {
                        speed.x = params.x.start;
                    }
                    if (params.x.add != undefined) {
                        addSpeed.x = params.x.add * 2;
                    }
                    if (params.x.max != undefined) {
                        maxSpeed.x = params.x.max;
                    }
                    if (params.x.min != undefined) {
                        minSpeed.x = params.x.min;
                    }
                    if (params.x.hit != undefined) {
                        hitSpeed.x = params.x.hit;
                    }
                }
            }

            if (params.y) {
                if (params.y is Number) {
                    speed.y = params.y;
                }
                else {
                    if (params.y.start != undefined) {
                        speed.y = params.y.start;
                    }
                    if (params.y.add != undefined) {
                        addSpeed.y = params.y.add * 2;
                    }
                    if (params.y.max != undefined) {
                        maxSpeed.y = params.y.max;
                    }
                    if (params.y.min != undefined) {
                        minSpeed.y = params.y.min;
                    }
                    if (params.y.hit != undefined) {
                        hitSpeed.y = params.y.hit;
                    }
                }
            }

            if (params.hold) {
                if (params.hold == -1) {
                    holdFrame = -1;
                }
                else {
                    holdFrame = params.hold * GameConfig.FPS_GAME;
                }
            }
            if (params.hits) {
                hitTimes = params.hits;
            }

            if (params.hp) {
                hp = hpMax = params.hp;
            }

        }

    }
    public var speed:Point = new Point(5, 0);
    public var hp:int    = 100;
    public var hpMax:int = 100;
    public var addSpeed:Point = new Point();
    public var maxSpeed:Point = new Point(999, 999);
    public var minSpeed:Point = new Point(-999, -999);
    public var hitSpeed:Point = new Point(NaN, NaN);
    public var holdFrame:int = -1;
    public var onRemove:Function;
    public var mc:MovieClip;
    public var hitTimes:int = -1;
    public var owner:IGameSprite;
    private var _area:Rectangle;
    private var _orgScale:Point;
    private var _orgRotate:int;
    private var _isHit:Boolean;
    private var _isTimeout:Boolean;
    private var _bulletArea:Rectangle;
    private var _hitVO:HitVO;
    private var _loopFrame:Object;
    private var _hitAble:Boolean  = true;
    private var _speedPlus:Number = GameConfig.SPEED_PLUS; //速度比率
    private var _isActive:Boolean;

    private var _destoryed:Boolean;
    private var _currentRect:Rectangle = new Rectangle();

    private var _team:TeamVO;

    public function get team():TeamVO {
        return _team;
    }

    public function set team(value:TeamVO):void {
        _team = value;
    }

    public function get x():Number {
        return mc.x;
    }

    public function set x(v:Number):void {
        mc.x = v;
    }

    public function get y():Number {
        return mc.y;
    }

    public function set y(v:Number):void {
        mc.y = v;
    }

    private var _direct:int;

    public function get direct():int {
        return _direct;
    }

    public function set direct(value:int):void {
        _direct     = value;
        mc.scaleX   = _orgScale.x * _direct;
        mc.rotation = _orgRotate * _direct;
        mc.x *= _direct;
        speed.x *= value;
        addSpeed.x *= value;
        if (!isNaN(hitSpeed.x)) {
            hitSpeed.x *= value;
        }
    }

    public function getActive():Boolean {
        return _isActive;
    }

    public function setActive(v:Boolean):void {
        _isActive = v;
    }

    public function isAttacking():Boolean {
        return _hitAble;
    }

    public function setSpeedRate(v:Number):void {
        _speedPlus = v;
    }

    public function setVolume(v:Number):void {
        KyoUtils.setMcVolume(mc, v);
    }

    public function setHitVO(v:HitVO):void {
        owner = v.owner;

        _hitVO       = v.clone();
        _hitVO.owner = this;

        var mainDisplay:DisplayObject  = mc.getChildByName('main');
        var ownerDisplay:DisplayObject = owner.getDisplay();
        if (mainDisplay) {
            _bulletArea = mainDisplay.getBounds(ownerDisplay);
            _bulletArea.x -= mc.x;
            _bulletArea.y -= mc.y;
        }
        else {
            _bulletArea = mc.getBounds(ownerDisplay);
            _bulletArea.x -= mc.x;
            _bulletArea.y -= mc.y;
        }

//			if(mainDisplay){
//				_bulletArea = mainDisplay.getBounds(mc);
//			}else{
//				_bulletArea = mc.getBounds(mc);
//			}

        direct = owner.direct;

        mc.x += owner.x;
        mc.y += owner.y;

        if (owner is FighterMain) {
            var fmc:FighterMC = (
                    owner as FighterMain
            ).getMC();
            mc.x += fmc.x;
            mc.y += fmc.y;

            _bulletArea.x -= fmc.x;
            _bulletArea.y -= fmc.y;
        }


    }

    public function destory(dispose:Boolean = true):void {

        _destoryed = true;

        if (mc) {
            try {
                mc.stopAllMovieClips();
            }
            catch (e:Error) {
                trace(e);
            }
            mc = null;
        }

        speed    = null;
        addSpeed = null;
        maxSpeed = null;
        minSpeed = null;
        hitSpeed = null;

        owner       = null;
        _area       = null;
        _orgScale   = null;
        _team       = null;
        _bulletArea = null;
        _hitVO      = null;
    }

    public function isDestoryed():Boolean {
        return _destoryed;
    }

    public function renderAnimate():void {
        mc.nextFrame();
        var label:String = mc.currentLabel;
        switch (label) {
        case 'loop':
            if (_loopFrame == null) {
                if (MCUtils.hasFrameLabel(mc, 'loop_start')) {
                    _loopFrame = 'loop_start';
                }
                else {
                    _loopFrame = 1;
                }
            }
            mc.gotoAndStop(_loopFrame);
            break;
        case 'remove':
            removeSelf();
            break;
        case 'hit_over':
            _hitAble = false;
            break;
        default:
            if (mc.currentFrame == mc.totalFrames - 1) {
                removeSelf();
            }
//					if(_isHit) if(mc.currentFrame == mc.totalFrames-1) removeSelf();
        }
    }

    public function render():void {
        if (_isHit) {
            return;
        }

        mc.x += speed.x * _speedPlus;
        mc.y += speed.y * _speedPlus;

        speed.x += addSpeed.x * _speedPlus;
        speed.y += addSpeed.y * _speedPlus;

        if (_direct > 0) {
            if (speed.x > maxSpeed.x) {
                speed.x = maxSpeed.x;
            }
            if (speed.x < minSpeed.x) {
                speed.x = minSpeed.x;
            }
        }
        else {
            if (speed.x < -maxSpeed.x) {
                speed.x = -maxSpeed.x;
            }
            if (speed.x > -minSpeed.x) {
                speed.x = -minSpeed.x;
            }
        }

        if (speed.y > maxSpeed.y) {
            speed.y = maxSpeed.y;
        }
        if (speed.y < minSpeed.y) {
            speed.y = minSpeed.y;
        }

        if (holdFrame != -1 && !_isTimeout) {
            holdFrame--;
            if (holdFrame <= 0) {
                if (MCUtils.hasFrameLabel(mc, 'timeout')) {
                    _isTimeout = true;
                    mc.gotoAndStop('timeout');
                }
                else {
                    removeSelf();
                    return;
                }
            }
        }

        if (GameLogic.isTouchBottomFloor(this)) {
            hit(_hitVO, null);
            EffectCtrl.I.shake(0, 1, 200);
            return;
        }

        if (GameLogic.isOutRange(this)) {
            removeSelf();
        }
    }

    public function getDisplay():DisplayObject {
        return mc;
    }

    /**
     * 攻击到其他人
     * @param target 被攻击对象
     */
    public function hit(hitvo:HitVO, target:IGameSprite):void {

        if (target is Bullet) {
            if (!isNaN(hitSpeed.x)) {
                speed.x = hitSpeed.x;
            }
            if (!isNaN(hitSpeed.y)) {
                speed.y = hitSpeed.y;
            }
            return;
        }

        if (hitTimes != -1) {
            if (--hitTimes <= 0) {
                doHit();
            }
        }

        if (target && owner && owner is FighterMain) {
            (
                    owner as FighterMain
            ).addQi(hitvo.power * GameConfig.QI_ADD_HIT_BULLET_RATE);
            GameLogic.hitTarget(hitvo, owner, target);
        }

        if (target) {

            if (hitSpeed.x == 0 && hitSpeed.y == 0) {
                return;
            }

            if (target is BaseGameSprite && (
                    target as BaseGameSprite
            ).getIsTouchSide()) {
                if (isNaN(hitSpeed.x)) {
                    hitSpeed.x = speed.x;
                }
                if (isNaN(hitSpeed.y)) {
                    hitSpeed.y = speed.y;
                }

                hitSpeed.x = Math.abs(hitSpeed.x) < 1 ? 0 : hitSpeed.x * 0.5;
                hitSpeed.y = Math.abs(hitSpeed.y) < 1 ? 0 : hitSpeed.y * 0.5;
            }

            if (!isNaN(hitSpeed.x)) {
                speed.x = hitSpeed.x;
            }
            if (!isNaN(hitSpeed.y)) {
                speed.y = hitSpeed.y;
            }

        }
    }

    /**
     * 被攻击
     * @param hitvo 攻击数据
     * @param hitRect 攻击相交区域
     */
    public function beHit(hitvo:HitVO, hitRect:Rectangle = null):void {
        if (hitvo.owner && hitvo.owner is Bullet) {
            hp -= (
                    hitvo.owner as Bullet
            ).hpMax;
        }
        else {
            hp -= hitvo.power;
        }
        if (hp <= 0) {
            doHit();
        }
    }

    /**
     * 当前攻击的攻击数据 return [FighterHitVO];
     */
    public function getCurrentHits():Array {
        if (!_hitVO || !_bulletArea || !_hitAble) {
            return null;
        }

        _hitVO.currentArea = getCurrentRect(_bulletArea);
        return [_hitVO];
    }

    public function getArea():Rectangle {
        if (!_bulletArea) {
            return null;
        }
        return getCurrentRect(_bulletArea);
    }

    /**
     * 当前可被攻击的面
     */
    public function getBodyArea():Rectangle {
        if (!_bulletArea) {
            return null;
        }
        return getCurrentRect(_bulletArea);
    }

    public function allowCrossMapXY():Boolean {
        return true;
    }

    public function allowCrossMapBottom():Boolean {
        return false;
    }

    public function getIsTouchSide():Boolean {
        return false;
    }

    public function setIsTouchSide(v:Boolean):void {
    }

    private function removeSelf():void {
        if (onRemove != null) {
            onRemove(this);
        }
    }

    private function doHit():void {
        if (!_isHit) {
            try {
                mc.gotoAndStop('hit');
            }
            catch (e:Error) {
                ThrowError(e, GetLang('debug.error.data.bullet.do_hit', 'hit'));
            }
        }
        _isHit   = true;
        _hitAble = false;
    }

    private function getCurrentRect(rect:Rectangle):Rectangle {
//			var newRect:Rectangle = new Rectangle();
        var newRect:Rectangle = _currentRect;

        newRect.x = rect.x * _direct + mc.x;
        if (_direct < 0) {
            newRect.x -= rect.width;
        }

        newRect.y      = rect.y + mc.y;
        newRect.width  = rect.width;
        newRect.height = rect.height;
        return newRect;
    }

}
}
