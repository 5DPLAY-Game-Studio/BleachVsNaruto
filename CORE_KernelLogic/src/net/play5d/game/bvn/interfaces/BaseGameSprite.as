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

package net.play5d.game.bvn.interfaces {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.media.SoundTransform;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.cntlr.GameRender;
import net.play5d.game.bvn.data.TeamVO;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.kyo.utils.KyoUtils;
import net.play5d.kyo.utils.UUID;

public class BaseGameSprite extends EventDispatcher implements IGameSprite {
    include '../../../../../../include/_INCLUDE_.as';

    public function BaseGameSprite(mainmc:MovieClip) {
        _mainMc = mainmc;
        if (_mainMc) {
            _area = _mainMc.getBounds(_mainMc);
        }
    }
    public var isInAir:Boolean; //是否在空中
    public var isTouchBottom:Boolean; //是否在底层地面上
    public var isAllowBeHit:Boolean = true; //是否可以被打
    public var isCross:Boolean      = false; //是否穿过其他角色
    // 是否允许受到因版边攻击造成的反向推动
    public var isAllowReversePush:Boolean = true;
    public var isAlive:Boolean            = true;//是否活着
    public var isAllowLoseHP:Boolean      = true;//是否伤血
    public var isApplyG:Boolean = true;
    public var heavy:Number = 2; //重量，用于计算角色碰撞处理
    public var hp:Number    = 1000;
    public var hpMax:Number = 1000;
    public var defense:Number = 0; //防御力
    public var isAllowCrossX:Boolean      = false;
    public var isAllowCrossBottom:Boolean = false;
    public var id:String = UUID.create();
    protected var _g:Number            = 0; //重力
    protected var _mainMc:MovieClip;
    protected var _isTouchSide:Boolean = false;
    protected var _isActive:Boolean = false;
    protected var _area:Rectangle;
    protected var _destoryed:Boolean;
    private var _frameFuncs:Array        = []; //在N帧后调用，临时保存的FUNCTION数组
    private var _frameAnimateFuncs:Array = []; //在N帧后调用，临时保存的FUNCTION数组
    private var _speedPlus:Number   = GameConfig.SPEED_PLUS; //速度比率
    private var _dampingRate:Number = 1; //速度减缓比率
    private var _velocity:Point = new Point();
    private var _damping:Point  = new Point();

//		private var _lastPos:Point = new Point();
    private var _velocity2:Point = new Point();
    private var _damping2:Point  = new Point();

    private var _attackRate:Number  = 1; //攻击力比例

    public function get attackRate():Number {
        return _attackRate;
    }

    public function set attackRate(value:Number):void {
        _attackRate = value;
    }

    private var _defenseRate:Number = 1; //防御力比例

    public function get defenseRate():Number {
        return _defenseRate;
    }

    public function set defenseRate(value:Number):void {
        _defenseRate = value;
    }

    protected var _x:Number = 0;

    public function get x():Number {
        return _x;
    }

    public function set x(v:Number):void {
        _x = v;
    }

    protected var _y:Number = 0;

    public function get y():Number {
        return _y;
    }

    public function set y(v:Number):void {
        _y = v;
    }

    private var _direct:int = 1; //方向 左-1 & 右1

    public function get direct():int {
        return _direct;
    }

    public function set direct(value:int):void {
        _direct        = value;
        _mainMc.scaleX = _direct * _scale;
    }

    private var _scale:Number = 1;

    public function get scale():Number {
        return _scale;
    }

    public function set scale(v:Number):void {
        _scale         = v;
        _mainMc.scaleX = _mainMc.scaleY = v;
    }

    public function get mc():MovieClip {
        return _mainMc;
    }

    private var _team:TeamVO; //队伍

    public function get team():TeamVO {
        return _team;
    }

    public function set team(value:TeamVO):void {
        _team = value;
    }

    public function getActive():Boolean {
        return _isActive;
    }

    public function setActive(v:Boolean):void {
        _isActive = v;
    }

    public function updatePosition():void {
        _mainMc.x = _x;
        _mainMc.y = _y;
    }

    public function setVolume(v:Number):void {
        if (_mainMc) {
            var transform:SoundTransform = _mainMc.soundTransform;
            if (transform) {
                transform.volume       = v;
                _mainMc.soundTransform = transform;
            }
        }
    }

    public function isDestoryed():Boolean {
        return _destoryed;
    }

    public function destory(dispose:Boolean = true):void {
        _destoryed   = true;
        isAlive      = false;
        isAllowBeHit = false;
        stopRenderSelf();

        if (dispose) {
            if (_mainMc) {
                try {
                    _mainMc.stopAllMovieClips();
                }
                catch (e:Error) {
                    trace(e);
                }
                _mainMc = null;
            }
        }

    }

    public function renderAnimate():void {
        if (_destoryed) {
            return;
        }

        renderAnimateFrameOut();
    }

    public function render():void {
        if (_destoryed) {
            return;
        }

        renderVelocity();
        renderFrameOut();

//			trace(_x,_y);
        _mainMc.x = _x;
        _mainMc.y = _y;
//			_lastPos = new Point(x,y);
    }

    public function getDisplay():DisplayObject {
        return _mainMc;
    }

    /**
     *  角色移动
     */
    public function move(x:Number = 0, y:Number = 0):void {
        if (x != 0) {
            _x += x * _speedPlus;
        }
        if (y != 0) {
            _y += y * _speedPlus;
        }
    }

    public function setSpeedRate(v:Number):void {
        _speedPlus   = v;
        _dampingRate = v / GameConfig.SPEED_PLUS_DEFAULT;
    }

    /**
     * 获取力 (不含重力)
     */
    public function getVelocity():Point {
        return _velocity;
    }

//		public function getRealVelocity():Point{
//			return new Point(x - _lastPos.x , y - _lastPos.y);
//		}

    /**
     * 获取力X
     */
    public function getVecX():Number {
        return _velocity.x;
    }

    /**
     * 获取力Y(不含重力)
     */
    public function getVecY():Number {
        return _velocity.y;
    }

    public function setVecX(v:Number):void {
        _velocity.x = v;
    }

    public function setVecY(v:Number):void {
        _velocity.y = v;
    }

    /**
     * 设置力
     */
    public function setVelocity(x:Number = 0, y:Number = 0):void {
        _velocity.x = x;
        _velocity.y = y;
        setDamping(0, 0);
    }

    /**
     * 增加力
     */
    public function addVelocity(x:Number = 0, y:Number = 0):void {
        _velocity.x += x;
        _velocity.y += y;
    }

    /**
     * 第二作用力
     */
    public function setVec2(x:Number = 0, y:Number = 0, dampingX:Number = 0, dampingY:Number = 0):void {
        _velocity2.x = x;
        _velocity2.y = y;
        _damping2.x  = dampingX * GameConfig.SPEED_PLUS_DEFAULT * 6;
        _damping2.y  = dampingY * GameConfig.SPEED_PLUS_DEFAULT * 6;
    }

    public function getVec2():Point {
        return _velocity2;
    }

    /**
     * 获取阻尼 X
     */
    public function getDampingX():Number {
        return _damping.x;
    }

    /**
     * 获取阻尼 Y
     */
    public function getDampingY():Number {
        return _damping.y;
    }

    /**
     * 设置阻尼 X
     */
    public function setDampingX(v:Number):void {
        _damping.x = v;
    }

    /**
     * 设置阻尼 Y
     */
    public function setDampingY(v:Number):void {
        _damping.y = v;
    }

    /**
     * 设置阻尼
     */
    public function setDamping(x:Number = 0, y:Number = 0):void {
        _damping.x = x * GameConfig.SPEED_PLUS_DEFAULT * 2;
        _damping.y = y * GameConfig.SPEED_PLUS_DEFAULT * 2;
    }

    /**
     * 增加阻尼
     */
    public function addDamping(x:Number = 0, y:Number = 0):void {
        _damping.x += x;
        _damping.y += y;
    }

    public function applayG(g:Number):void {

        if (!isApplyG) {
            _g = 0;
            return;
        }

        if (_velocity.y < 0) {
            _g = 0;
            return;
        }

        if (_g < g) {
            var addG:Number = GameConfig.G_ADD * GameConfig.SPEED_PLUS;
            _g += addG;
            if (_g > g) {
                _g = g;
            }
        }
//			_mainMc.y += _g * _speedPlus;
//			_y += _g * _speedPlus;
        move(0, _g);
    }

//		public function getGForce():Number{
//			return _g;
//		}

    public function setInAir(v:Boolean):void {
        if (!v) {
            _g = GameConfig.G_ON_FLOOR;
        }
        isInAir = v;
    }

    /**
     * 攻击到其他人
     * @param target 被攻击对象
     */
    public function hit(hitvo:HitVO, target:IGameSprite):void {
        if (target && target.getDisplay()) {
            var d:DisplayObject  = getDisplay();
            var td:DisplayObject = target.getDisplay();
            if (d && td && d.parent && d.parent == td.parent) {
                var _parent:DisplayObjectContainer = d.parent;
                var index1:int                     = _parent.getChildIndex(d);
                var index2:int                     = _parent.getChildIndex(td);
                if (index1 != -1 && index2 != -1 && index1 < index2) {
                    _parent.setChildIndex(td, index1);
                    _parent.setChildIndex(d, index2);
                }

            }
        }
    }

    /**
     * 被攻击
     * @param hitvo 攻击数据
     * @param hitRect 攻击相交区域
     */
    public function beHit(hitvo:HitVO, hitRect:Rectangle = null):void {

    }

    /**
     * 当前攻击的攻击数据 return [FighterHitVO];
     */
    public function getCurrentHits():Array {
        return null;
    }

    public function getArea():Rectangle {
        if (!_area) {
            return null;
        }

        var newRect:Rectangle = _area.clone();

        newRect.x += _x;
        newRect.y += _y;

        return newRect;
    }

    /**
     * 当前可被攻击的面
     */
    public function getBodyArea():Rectangle {
        return null;
    }

    public function allowCrossMapXY():Boolean {
        return isAllowCrossX;
    }

    public function allowCrossMapBottom():Boolean {
        return isAllowCrossBottom;
    }

    public function getIsTouchSide():Boolean {
        return _isTouchSide;
    }

    public function setIsTouchSide(v:Boolean):void {
        _isTouchSide = v;
    }

    public function addHp(v:Number):void {
        hp += v;
        if (hp > hpMax) {
            hp = hpMax;
        }
    }

    public function loseHp(v:Number):void {
        if (!isAllowLoseHP) {
            return;
        }
        var dr:Number = 2 - defenseRate;
        if (dr < 0.1) {
            dr = 0.1;
        }
        if (dr > 1) {
            dr = 1;
        }

        var lose:Number = (
                                  v * dr
                          ) - defense;
        if (lose < 0) {
            return;
        }
        hp -= lose;
        if (hp < 0) {
            hp = 0;
        }
    }

    public function delayCall(func:Function, frame:int):void {
        _frameFuncs.push({func: func, frame: frame});
    }

    public function renderSelf():void {
        GameRender.add(renderSelfEnterFrame, this);
    }

    public function stopRenderSelf():void {
        GameRender.remove(renderSelfEnterFrame, this);
    }

    /**
     * 在N帧后调用，按动画帧速
     */
    public function setAnimateFrameOut(func:Function, frame:int):void {
        _frameAnimateFuncs.push({func: func, frame: frame});
        //			_frameFuncs[0] = {func:func,frame:frame};
    }

    private function renderVelocity():void {
        var resultX:Number = 0;
        var resultY:Number = 0;

        if (_velocity.x != 0) {
            resultX += _velocity.x;
            if (_damping.x > 0) {
                _velocity.x = KyoUtils.num_wake(_velocity.x, _damping.x * _dampingRate);
            }
        }
        if (_velocity.y != 0) {
            resultY += _velocity.y;
            if (_damping.y > 0) {
                _velocity.y = KyoUtils.num_wake(_velocity.y, _damping.y * _dampingRate);
            }
        }
        if (_velocity2.x != 0) {
            resultX += _velocity2.x;
            if (_damping2.x > 0) {
                _velocity2.x = KyoUtils.num_wake(_velocity2.x, _damping2.x * _dampingRate);
            }
        }
        if (_velocity2.y != 0) {
            resultY += _velocity2.y;
            if (_damping2.y > 0) {
                _velocity2.y = KyoUtils.num_wake(_velocity2.y, _damping2.y * _dampingRate);
            }
        }
        if (resultX != 0 || resultY != 0) {
            move(resultX, resultY);
        }
    }

    private function renderSelfEnterFrame():void {
        if (_destoryed) {
            return;
        }
        try {
            render();
            renderAnimate();
        }
        catch (e:Error) {
            Debugger.log('BaseGameSprite.renderSelfEnterFrame', e);
        }
    }

    /**
     * 为在N帧后调用，按动画帧速作服务
     */
    private function renderAnimateFrameOut():void {
        if (_frameAnimateFuncs.length < 1) {
            return;
        }
        for (var i:int; i < _frameAnimateFuncs.length; i++) {
            var o:Object = _frameAnimateFuncs[i];
            o.frame--;
            if (o.frame < 1) {
                o.func();
                _frameAnimateFuncs.splice(i, 1);
            }
        }
    }

    /**
     * 为在N帧后调用
     */
    private function renderFrameOut():void {
        if (_frameFuncs.length < 1) {
            return;
        }
        for (var i:int; i < _frameFuncs.length; i++) {
            var o:Object = _frameFuncs[i];
            o.frame--;
            if (o.frame < 1) {
                o.func();
                _frameFuncs.splice(i, 1);
            }
        }
    }

}
}
