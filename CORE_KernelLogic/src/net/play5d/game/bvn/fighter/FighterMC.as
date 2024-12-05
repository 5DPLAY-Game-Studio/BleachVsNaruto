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
import flash.geom.Rectangle;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.fighter.ctrler.FighterMcCtrler;
import net.play5d.game.bvn.fighter.data.FighterActionState;
import net.play5d.game.bvn.fighter.data.FighterHitRange;
import net.play5d.game.bvn.fighter.data.FighterSpecialFrame;
import net.play5d.game.bvn.fighter.events.FighterEvent;
import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
import net.play5d.game.bvn.fighter.models.FighterHitModel;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.fighter.utils.McAreaCacher;
import net.play5d.game.bvn.utils.MCUtils;

public class FighterMC {
    include '../../../../../../include/_INCLUDE_.as';

    public function FighterMC() {
        super();
    }
    private var _mcCtrler:FighterMcCtrler;
    private var _fighter:FighterMain;
//		private var _action:FighterAction = new FighterAction();
    private var _fighterDisplay:DisplayObject;
    private var _renderMainAnimate:Boolean  = false; //是否执行主时间轴播放
    private var _renderMainAnimateFrame:int = 0; //主时间轴在N帧后停止播放
    private var _curFrameName:String; //当前帧名称
    private var _curMainFrameCount:int; //当前主动画已执行的帧数
    private var _curFrameCount:int; //当前动画已执行的帧数
    private var _mc:MovieClip; //movieclip元件
    private var _undefinedFrames:Array = []; //不存在的帧名称缓冲池
    private var _hurtFlyFrame:int = 0; //击飞中空中的帧数
    private var _hurtDownFrame:int; //倒地的时间
    /**
     * 击飞状态
     * 0=没有被击飞
     * 1=击飞
     * 2=落地
     * 3=弹起
     * 4=倒地
     */
    private var _hurtFlyState:int;
    private var _hurtYMin:Number = 0;
    private var _isHeavyDownAttack:Boolean;
    private var _bodyAreaCache:McAreaCacher     = new McAreaCacher('body');
    private var _hitAreaCache:McAreaCacher      = new McAreaCacher('hit');
    private var _hitCheckAreaCache:McAreaCacher = new McAreaCacher('hit_check');
    private var _hitRangeInited:Boolean;
    private var _hitRangeObj:Object;
    private var _goFrameDelay:Object = null;
    private var _hitx:Number = 0;
    private var _hity:Number = 0;

    /**
     * 当前帧名称
     */
    public function get currentFrameName():String {
        return _curFrameName;
    }

    public function get x():Number {
        return _mc.x;
    }

    public function set x(v:Number):void {
        _mc.x = x;
    }

    public function get y():Number {
        return _mc.y;
    }

    public function set y(v:Number):void {
        _mc.y = v;
    }

    public function getCurrentFrame():int {
        return _mc.currentFrame;
    }

    /**
     * 当前动画已执行的帧数
     */
    public function getCurrentFrameCount():int {
        return _curFrameCount;
    }

    public function initlize(mc:MovieClip, fighter:FighterMain, mcCtrler:FighterMcCtrler):void {
        _mc             = mc;
        _fighter        = fighter;
        _fighterDisplay = fighter.getDisplay();

        _mcCtrler = mcCtrler;
//			mcCtrler.setMc(this);
    }

    public function destory():void {
        if (_bodyAreaCache) {
            _bodyAreaCache.destory();
            _bodyAreaCache = null;
        }
        if (_hitAreaCache) {
            _hitAreaCache.destory();
            _hitAreaCache = null;
        }
        if (_hitCheckAreaCache) {
            _hitCheckAreaCache.destory();
            _hitCheckAreaCache = null;
        }
        _mc              = null;
        _fighter         = null;
        _fighterDisplay  = null;
        _undefinedFrames = null;
    }

    public function getChildByName(name:String):DisplayObject {
        return _mc.getChildByName(name);
    }

    /**
     * 播放动画
     */
    public function renderAnimate():void {
        if (_renderMainAnimate) {
            if (_renderMainAnimateFrame > 0) {
                if (--_renderMainAnimateFrame <= 0) {
                    _renderMainAnimate = false;
                }
                _curMainFrameCount++;
            }
            try {
                _mc.nextFrame();
            }
            catch (e:Error) {
                trace('FighterMC.renderAnimate', e);
            }
        }
        renderChildren();
        findBodyArea();
        findHitArea();

        if (_hurtFlyState != 0) {
            renderHurtFly();
        }

        _curFrameCount++;

        if (_goFrameDelay) {
            if (_goFrameDelay.delay-- <= 0) {
                if (_goFrameDelay.call != undefined) {
                    _goFrameDelay.call();
                }
                else {
                    goFrame(_goFrameDelay.name, _goFrameDelay.isPlay, _goFrameDelay.playFrame, null);
                }
                _goFrameDelay = null;
            }
        }

    }

    /**
     * 跳转到帧
     * @param name 帧名称
     * @param isPlay 是否播放
     * @param playFrame 播放到第几帧时，STOP
     * @param goFrameDelay 延迟播放下一个动作（无重叠，同一时间线上只有一个延时调用） {name:String|call:Function,delay:int,isPlay:Boolean=true,playFrame:int=0}
     */
    public function goFrame(name:String, isPlay:Boolean = true, playFrame:int = 0, goFrameDelay:Object = null):void {
        _curFrameName      = name;
        _curMainFrameCount = 0;
        _curFrameCount     = 0;
        _renderMainAnimate = isPlay;
        if (_renderMainAnimate) {
            _renderMainAnimateFrame = playFrame;
        }
        else {
            _renderMainAnimateFrame = 0;
        }

        if (goFrameDelay && (
                goFrameDelay.name || goFrameDelay.call
        ) && int(goFrameDelay.delay) > 0) {
            goFrameDelay.isPlay    = goFrameDelay.isPlay != undefined ? goFrameDelay.isPlay : true;
            goFrameDelay.playFrame = goFrameDelay.playFrame != undefined ? goFrameDelay.playFrame : 0;
            _goFrameDelay          = goFrameDelay;
        }
        else {
            _goFrameDelay = null;
        }

        try {
            _mc.gotoAndStop(name);
        }
        catch (e:Error) {
            trace('FighterMC.goFrame', e);
        }
        renderChildren();

    }

    /**
     *  停止主时间轴播放
     */
    public function stopRenderMainAnimate():void {
        _renderMainAnimate = false;
    }

    /**
     *  恢复主时间轴播放
     */
    public function resumeRenderMainAnimate():void {
        _renderMainAnimate = true;
    }

    /**
     * 检测帧名称是否存在
     */
    public function checkFrame(name:String):Boolean {
        if (_undefinedFrames.indexOf(name) != -1) {
            return false;
        }

        if (MCUtils.hasFrameLabel(_mc, name)) {
            return true;
        }

//			var labels:Array = _mc.currentLabels;
//			for each(var i:FrameLabel in labels){
//				if(i.name == name) return true;
//			}
        _undefinedFrames.push(name);
        trace('未找到帧：' + name);
        return false;
    }

    /**
     * 获取当前的攻击范围元件
     */
    public function getCurrentHitSprite():Array {
        var rt:Array = [];
        for (var i:int; i < _mc.numChildren; i++) {
            var d:DisplayObject = _mc.getChildAt(i);
            if (d && d.name.indexOf('atm') != -1) {
                rt.push(d);
            }
        }
        return rt;
    }

    public function getCurrentBodyArea():Rectangle {
        var obj:Object = _bodyAreaCache.getAreaByFrame(_mc.currentFrame);
        if (obj) {
            return obj.area;
        }
        return null;
    }

    public function getCurrentHitArea():Array {
        return _hitAreaCache.getAreaByFrame(_mc.currentFrame) as Array;
    }

    public function getCheckHitRect(name:String):Rectangle {
        var d:DisplayObject = _mc.getChildByName(name);
        if (!d) {
            return null;
        }

        var cacheObj:Object = _hitCheckAreaCache.getAreaByDisplay(d);

        if (cacheObj) {
            return cacheObj.area;
        }

        var rect:Rectangle = d.getBounds(_fighterDisplay);

        _hitCheckAreaCache.cacheAreaByDisplay(d, rect);

        return rect;
    }

    /**
     * 播放击飞动画
     */
    public function playHurtFly(hitx:Number, hity:Number, showBeHit:Boolean = true):void {
//			trace('playHurtFly' , hitx , hity);

        if (hitx != 0) {
            _fighter.direct = hitx > 0 ? -1 : 1;
        }

        if (showBeHit) {
            goFrame(FighterSpecialFrame.HURT, false, 0, {name: FighterSpecialFrame.HURT_FLY, delay: 1, isPlay: false});
        }
        else {
            goFrame(FighterSpecialFrame.HURT_FLY, false);
        }

        if (hity > GameConfig.HIT_DOWN_BY_HITY) {
            _hurtFlyFrame      = 0;
            _isHeavyDownAttack = true;
        }
        else {
            _isHeavyDownAttack = false;
            _hurtFlyFrame      = _fighter.isInAir ? 0 : GameConfig.HURT_JUMP_FRAME;
        }

        _fighter.setVelocity(hitx, hity);
        _fighter.setDamping(GameConfig.HURT_FLY_DAMPING_X, GameConfig.HURT_FLY_DAMPING_Y);

        _hurtFlyState = 1;

        _hurtYMin = _fighter.y;
        _hitx     = hitx;
        _hity     = hity;
    }

    /**
     * 击倒动画
     *
     */
    public function playHurtDown():void {

        goFrame(FighterSpecialFrame.HURT_TAN, false, 0, {call: playHurtDown2, delay: 2});

        _mcCtrler.effectCtrler.hitFloor(1, 2);

        _fighter.setDamping(GameConfig.HIT_FLOOR_DAMPING_X);
    }

    /**
     *  停止击飞动画
     */
    public function stopHurtFly():void {
        _hurtFlyState = 0;
    }

    public function getHitRange(id:String):Rectangle {
        if (!_hitRangeInited) {
            initHitRange();
            _hitRangeInited = true;
        }
        return _hitRangeObj[id];
    }

    /**
     * 播放子MC
     */
    private function renderChildren():void {
        var i:int;
        var length:int = _mc.numChildren;
        for (i = 0; i < length; i++) {

            try {
                var mc:MovieClip = _mc.getChildAt(i) as MovieClip;
                if (mc) {
                    var mcName:String = mc.name;
                    if (mcName == 'AImain' || mcName == 'bdmn' || mcName.indexOf('atm') != -1) {
                        continue;
                    }

                    var totalFrames:int = mc.totalFrames;
                    if (totalFrames < 2) {
                        continue;
                    }

                    switch (mc.currentFrameLabel) {
                    case 'stop':
                        break;
                    default:
                        if (mc.currentFrame == totalFrames) {
                            mc.gotoAndStop(1);
                        }
                        else {
                            mc.nextFrame();
                        }
                    }

                }
            }
            catch (e:Error) {
                trace('FighterMC.renderChildren', e);
            }

        }
    }

    private function findBodyArea():void {
        if (!_bodyAreaCache) {
            return;
        }
        //判断是否已定义过
        if (_bodyAreaCache.areaFrameDefined(_mc.currentFrame)) {
            return;
        }

        //取帧缓存
        var area:Object = _bodyAreaCache.getAreaByFrame(_mc.currentFrame);
        if (area != null) {
            return;
        } //已有，跳出

        var areamc:DisplayObject = _mc.getChildByName('bdmn');

        if (areamc) {
            //取缓存
            area = _bodyAreaCache.getAreaByDisplay(areamc);
            if (area == null) {
                //无缓存，创建并写入缓存
                var areaRect:Rectangle = areamc.getBounds(_fighterDisplay);
                area                   = _bodyAreaCache.cacheAreaByDisplay(areamc, areaRect);
            }
        }

        //写入帧缓存
        _bodyAreaCache.cacheAreaByFrame(_mc.currentFrame, area);
    }

    private function findHitArea():void {
        if (!_hitAreaCache) {
            return;
        }
        //判断是否已定义过
        if (_hitAreaCache.areaFrameDefined(_mc.currentFrame)) {
            return;
        }

        //取帧缓存
        var area:Object = _hitAreaCache.getAreaByFrame(_mc.currentFrame);
        if (area != null) {
            return;
        } //已有，跳出

        var hitModel:FighterHitModel = _fighter.getCtrler().hitModel;

        var areaRects:Array = [];

        for (var i:int; i < _mc.numChildren; i++) {
            var d:DisplayObject = _mc.getChildAt(i);
            var hitvo:HitVO     = hitModel.getHitVOByDisplayName(d.name);

            if (d == null || hitvo == null) {
                continue;
            }

            //取缓存
            var areaCached:Object = _hitAreaCache.getAreaByDisplay(d);
            if (areaCached == null) {
                //无缓存，创建并写入缓存
                var areaRect:Rectangle  = d.getBounds(_fighterDisplay);
                var areaCacheObj:Object = _hitAreaCache.cacheAreaByDisplay(d, areaRect, {hitVO: hitvo});
                areaRects.push(areaCacheObj);
            }
            else {
                areaRects.push(areaCached);
            }
        }

        if (areaRects.length < 1) {
            areaRects = null;
        }

        //写入帧缓存
        _hitAreaCache.cacheAreaByFrame(_mc.currentFrame, areaRects);
//			trace('hitrect cache:',_mc.currentFrame , areaRects);
    }

    private function playHurtDown2():void {
        goFrame('击飞_倒', false);

        _hurtDownFrame = GameConfig.HIT_DOWN_FRAME;
        _hurtFlyState  = 4;

        _mcCtrler.touchFloor();

        _fighter.actionState = FighterActionState.HURT_DOWN;
        FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.HURT_DOWN);
    }

    private function renderHurtFly():void {
        switch (_hurtFlyState) {
        case 1: //击飞
            if (--_hurtFlyFrame <= 0 && !_fighter.isInAir) {
                goFrame(FighterSpecialFrame.HURT_FALL);
                _hurtFlyState = 2;
            }
            if (_hurtYMin > _fighter.y) {
                _hurtYMin = _fighter.y;
            }
            break;
        case 2: //落地
            if (_curFrameCount < 2) {
                return;
            }
            if (_isHeavyDownAttack) {
                //被打击到地面
                _hurtDownFrame = GameConfig.HIT_DOWN_FRAME_HEAVY;
                goFrame('击飞_倒', false);
                _fighter.actionState = FighterActionState.HURT_DOWN;
                FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.HURT_DOWN);
//						_fighter.setVelocity(0,0);
                _fighter.setDamping(GameConfig.HIT_FLOOR_DAMPING_X_HEAVY);
                _hurtFlyState = 4;

                var yDiff:Number = _fighter.y - _hurtYMin;
                var vecy:Number  = yDiff / 25 * (
                        1 + _hity * 0.1
                );

                if (vecy < 2) {
                    vecy = 2;
                }
                if (vecy > 5) {
                    vecy = 5;
                }

                _mcCtrler.effectCtrler.hitFloor(2, vecy);

            }
            else {
                goFrame(FighterSpecialFrame.HURT_TAN, false);
                yDiff = _fighter.y - _hurtYMin;
                vecy  = yDiff / 25;

                if (vecy < GameConfig.HIT_FLOOR_TAN_Y_MIN) {
                    vecy = GameConfig.HIT_FLOOR_TAN_Y_MIN;
                }
                if (vecy > GameConfig.HIT_FLOOR_TAN_Y_MAX) {
                    vecy = GameConfig.HIT_FLOOR_TAN_Y_MAX;
                }

//						trace('vecy',vecy);

                _fighter.setVecY(-vecy);
                _hurtFlyState = 3;

                _fighter.actionState = FighterActionState.HURT_DOWN_TAN;

                if (vecy < 0.5) {
                    vecy = 0.5;
                }
                if (vecy > 3) {
                    vecy = 3;
                }

                _mcCtrler.effectCtrler.hitFloor(0, vecy);
            }
            break;
        case 3: //弹起
            if (_curFrameCount < 2) {
                return;
            }
            if (_fighter.isInAir) {
                return;
            }

            goFrame('击飞_倒', false);
            _fighter.setDamping(GameConfig.HIT_FLOOR_DAMPING_X);
            _hurtDownFrame = GameConfig.HIT_DOWN_FRAME;
            _hurtFlyState  = 4;

            _mcCtrler.effectCtrler.hitFloor(1, 1);

            _fighter.actionState = FighterActionState.HURT_DOWN;
            FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.HURT_DOWN);
            break;
        case 4: //倒地

            if (!_fighter.isAlive) {
                _hurtFlyState        = 0;
                _fighter.actionState = FighterActionState.DEAD;
                FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.DEAD);
                return;
            }

            if (--_hurtDownFrame <= 0) {
                goFrame("击飞_起", true);
                _hurtFlyState = 0;
            }
            break;
        }
    }

    private function initHitRange():void {
        var hrmc:MovieClip = _mc.getChildByName('AImain') as MovieClip;
        hrmc.gotoAndStop(2);
        _hitRangeObj = {};

        for each(var i:String in FighterHitRange.getALL()) {
            var d:DisplayObject = hrmc.getChildByName(i);
            if (d) {
                _hitRangeObj[i] = d.getBounds(_fighterDisplay);
            }
        }
        hrmc.gotoAndStop(1);
        hrmc.visible = false;
    }

}
}
