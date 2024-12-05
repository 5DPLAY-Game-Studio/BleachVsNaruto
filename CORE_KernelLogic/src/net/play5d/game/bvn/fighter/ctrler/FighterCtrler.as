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
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Rectangle;

import net.play5d.game.bvn.cntlr.game_ctrls.GameCtrl;
import net.play5d.game.bvn.fighter.data.FighterActionState;
import net.play5d.game.bvn.fighter.FighterMC;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.data.FighterSpecialFrame;
import net.play5d.game.bvn.fighter.models.FighterHitModel;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.interfaces.IGameSpriteCntlr;

/**
 * 角色控制类，提供共同方法给FLASH IDE调用
 */
public class FighterCtrler implements IGameSpriteCntlr {
    include '../../../../../../../include/_INCLUDE_.as';

    public function FighterCtrler() {
    }
    public var hitModel:FighterHitModel;
    private var _effectCtrl:FighterEffectCtrl;
    private var _fighterMcCtrl:FighterMcCtrler;
    private var _voiceCtrl:FighterVoiceCtrler;
    private var _fighter:FighterMain;

//		private var _initAction:String = "开场";
    private var _rectCache:Object = {};
    private var _doingWankai:Boolean;

    /**
     * 获取目标
     * @return 目标游戏精灵
     */
    public function getTarget():IGameSprite {
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
        return null;
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
        return _fighter;
    }

    //由FLASH IDE调用，定义血量
    public function get hp():Number {
        return _fighter.hp;
    }

    public function set hp(v:Number):void {
        _fighter.hp = _fighter.hpMax = _fighter.customHpMax = v;
    }

    //由FLASH IDE调用，定义速度
    public function get energy():Number {
        return _fighter.energyMax;
    }

    public function set energy(v:Number):void {
        _fighter.energy = _fighter.energyMax = v;
    }

    //由FLASH IDE调用，定义速度
    public function get speed():Number {
        return _fighter.speed;
    }

    public function set speed(v:Number):void {
        _fighter.speed = v;
    }

    //由FLASH IDE调用，定义跳跃力
    public function get jumpPower():Number {
        return _fighter.jumpPower;
    }

    public function set jumpPower(v:Number):void {
        _fighter.jumpPower = v;
    }

    //由FLASH IDE调用，定义体格
    public function get heavy():Number {
        return _fighter.heavy;
    }

    public function set heavy(v:Number):void {
        _fighter.heavy = v;
    }

    //由FLASH IDE调用，定义防御类型
    public function get defenseType():int {
        return _fighter.defenseType;
    }

    public function set defenseType(v:int):void {
        _fighter.defenseType = v;
    }

    //自身MC
    public function get self():DisplayObject {
        return _fighter.getDisplay();
    }

    //当前的攻击对象，有可能是NULL
    public function get target():DisplayObject {
        var target:IGameSprite = _fighter.getCurrentTarget();
        if (!target) {
            return null;
        }
        return target.getDisplay();
    }

    public function destory():void {
        if (_effectCtrl) {
            _effectCtrl.destory();
            _effectCtrl = null;
        }
        if (_fighterMcCtrl) {
            _fighterMcCtrl.destory();
            _fighterMcCtrl = null;
        }
        if (_voiceCtrl) {
            _voiceCtrl.destory();
            _voiceCtrl = null;
        }
        if (_rectCache) {
            _rectCache = null;
        }
        if (hitModel) {
            hitModel.destory();
            hitModel = null;
        }
        _fighter = null;
    }

    public function getEffectCtrl():FighterEffectCtrl {
        return _effectCtrl;
    }

    public function getVoiceCtrl():FighterVoiceCtrler {
        return _voiceCtrl;
    }

    public function addHp(v:Number):void {
        _fighter.addHp(v);
    }

    public function addHpPercent(v:Number):void {
        _fighter.addHp(_fighter.hpMax * v);
    }

    public function loseHp(v:Number):void {
        _fighter.loseHp(v);
    }

    public function loseHpPercent(v:Number):void {
        _fighter.loseHp(v * _fighter.hpMax);
    }

    public function getEnergy():Number {
        return _fighter.energy;
    }

    public function getEnergyOverload():Boolean {
        return _fighter.energyOverLoad;
    }

    public function loseEnergy(v:Number):void {
        _fighter.useEnergy(v);
    }

    public function loseQi(v:Number):void {
        _fighter.useQi(v);
    }

    //当前的攻击对象，有可能是NULL
    public function getTargetSP():IGameSprite {
        var target:IGameSprite = _fighter.getCurrentTarget();
        if (!target) {
            return null;
        }
        return target;
    }

    //获取敌人的状态
    public function getTargetState():int {
        var target:FighterMain = _fighter.getCurrentTarget() as FighterMain;
        if (!target) {
            return FighterActionState.NORMAL;
        }
        return target.actionState;
    }

    public function setTargetVelocity(x:Number, y:Number):void {
        var target:IGameSprite = _fighter.getCurrentTarget();
        if (target && target is BaseGameSprite) {
            (
                    target as BaseGameSprite
            ).setVelocity(x, y);
        }
    }

    public function setTargetDamping(x:Number, y:Number):void {
        var target:IGameSprite = _fighter.getCurrentTarget();
        if (target && target is BaseGameSprite) {
            (
                    target as BaseGameSprite
            ).setDamping(x, y);
        }
    }

    //判断敌人是否在打击范围内，传后检测MC
    public function targetInRange(rx:Array = null, ry:Array = null):Boolean {
        var targetDisplay:DisplayObject = this.target;
        if (!target) {
            return false;
        }
        var selfDisplay:DisplayObject = this.self;

        var xDis:Number;
        if (_fighter.direct > 0) {
            xDis = targetDisplay.x - selfDisplay.x;
        }
        else {
            xDis = selfDisplay.x - targetDisplay.x;
        }

        var yDis:Number = targetDisplay.y - selfDisplay.y;

        var XinRange:Boolean = true;
        var YinRange:Boolean = true;

        if (rx) {
            XinRange = xDis >= rx[0] && xDis <= rx[1];
        }
        if (ry) {
            YinRange = yDis >= ry[0] && yDis <= ry[1];
        }

        return XinRange && YinRange;
    }

    /**
     * 刚刚攻击到
     * @param hitId 攻击ID
     * @param includeDefense 包括防御
     * @return
     */
    public function justHit(hitId:String, includeDefense:Boolean = false):Boolean {
        var target:IGameSprite = _fighter.getCurrentTarget();
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

    public function getMcCtrl():FighterMcCtrler {
        return _fighterMcCtrl;
    }

    public function initFighter(fighter:FighterMain):void {
        _fighter = fighter;

        hitModel = new FighterHitModel(_fighter);

        _voiceCtrl = new FighterVoiceCtrler();

        _effectCtrl = new FighterEffectCtrl(fighter);

        _fighterMcCtrl              = new FighterMcCtrler(fighter);
        _fighterMcCtrl.effectCtrler = _effectCtrl;

        if (fighter.mc.initFighter) {
            var param:Object = {
                fighter_ctrler: this,
                mc_ctrler     : _fighterMcCtrl,
                effect_ctrler : _effectCtrl
            };
            fighter.mc.initFighter(param);

        }
        else {
            // 兼容老版本 ****************************************************************************

            if (fighter.mc.setFighterCtrler) {
                fighter.mc.setFighterCtrler(this);
            }
            else {
                throw new Error('初始化失败，SWF未定义setFighterCtrler()');
            }

            if (fighter.mc.setEffectCtrler) {
                fighter.mc.setEffectCtrler(_effectCtrl);
            }
            else {
                throw new Error('初始化效果接口失败，SWF未定义setEffectCtrler()');
            }

            if (fighter.mc.setFighterMcCtrler) {
                fighter.mc.setFighterMcCtrler(_fighterMcCtrl);
            }
            else {
                throw new Error('初始化效果接口失败，SWF未定义setFighterMcCtrler()');
            }
        }


    }

    /**
     * 按GameConfig.FPS_ANIMATE的速率运行
     */
    public function renderAnimate():void {
//			if(fighterMc) fighterMc.renderAnimate();
        if (_fighterMcCtrl) {
            _fighterMcCtrl.renderAnimate();
        }
    }

    /**
     * 按GameConfig.FPS_MAIN的速率运行
     */
    public function render():void {
//			if(fighterMc) fighterMc.render();
        if (_fighterMcCtrl) {
            _fighterMcCtrl.render();
        }
    }

    /**
     * 定义控制器
     */
    public function setActionCtrl(ctrler:IFighterActionCtrl):void {
        if (_fighterMcCtrl) {
            _fighterMcCtrl.setActionCtrler(ctrler);
        }
        else {
            trace('设置ctrler失败！');
        }
    }

    /**
     * 定义攻击数据，由FLASH IDE 调用
     * @param id 攻击KEY
     * @param obj 攻击数据
     * sample : defineAction("tk" , {power:30 , hitType:1 , hitx:2 , hity:6 , hurtTime:300 , hurtType:0 ,
     *         isBreakDef:false});
     */
    public function defineAction(id:String, obj:Object):void {
//			trace("defineAction",id , obj.hitx , obj.hity);
        hitModel.addHitVO(id, obj);
    }

    /**
     * 定义必杀特写
     * @param id
     * @param face 库中的链接类
     */
    public function defineBishaFace(id:String, face:Class):void {
        _effectCtrl.setBishaFace(id, face);
    }

    /**
     * 定义被打时的声音
     * @param 一个或多个库的声音类，随机播放
     */
    public function defineHurtSound(...params):void {
        _voiceCtrl.setVoice(FighterVoice.HURT, params);
    }

    /**
     * 定义击飞时的声音
     * @param 一个或多个库的声音类，随机播放
     */
    public function defineHurtFlySound(...params):void {
        _voiceCtrl.setVoice(FighterVoice.HURT_FLY, params);
    }

    /**
     * 定义死亡时的声音
     * @param 一个或多个库的声音类，随机播放
     */
    public function defineDieSound(...params):void {
        _voiceCtrl.setVoice(FighterVoice.DIE, params);
    }

    /**
     * 初始化子SWF
     */
    public function initMc(mc:MovieClip):void {
        if (mc) {
//				var fighterMc:FighterMC = new FighterMC();
//				fighterMc.initlize(mc , _fighter , _fighterMcCtrl);
//				_fighterMcCtrl.setMc(fighterMc);

//				fighterMc.goFrame(_initAction);
//				trace('_fighter.actionState' , _fighter.actionState);


            var fighterMc:FighterMC = _fighterMcCtrl.initMc(mc);
            if (_doingWankai) {
                _fighter.actionState = FighterActionState.WAN_KAI_ING;
                fighterMc.goFrame(FighterSpecialFrame.SAY_INTRO);
                _doingWankai = false;
            }
            else {
                _fighterMcCtrl.idle();
            }

            _fighter.onMcInited();
//				_fighter.onChangeMC();

        }
        else {
            throw new Error('FighterCtrler.initMc Error :: mc is null!');
        }
    }

    /**
     * 获取当前攻击数据 return [FighterHitVO];
     */
    public function getCurrentHits():Array {
        var areas:Array;
        try {
            areas = _fighter.getMC().getCurrentHitArea();
        }
        catch (e:Error) {
            trace('FighterCtrler.getCurrentHits::', e);
        }

        if (!areas || areas.length < 1) {
            return null;
        }

        var hits:Array = [];

        var i:int;
        var dobj:Object;
        var hitvo:HitVO;
        var area:Rectangle, area2:Rectangle;

//			var fighterDirect:int = _fighter.direct;
//			var fighterX:int = _fighter.getDisplay().x;
//			var fighterY:int = _fighter.getDisplay().y;

        for (i; i < areas.length; i++) {
            dobj             = areas[i];
            var dname:String = dobj.name;
            hitvo            = dobj.hitVO;

            if (!hitvo) {
                continue;
            }

//				trace(hitvo.hitx , hitvo.hity);

            area              = dobj.area;
            //缓存取出后，需要对重新计算位置
            hitvo.currentArea = getCurrentRect(area, 'hit' + i);
            hits.push(hitvo);
        }

        return hits;
    }

    /**
     * 被攻击区域
     */
    public function getBodyArea():Rectangle {
        var area:Rectangle;
        try {
            var mc:FighterMC = _fighter.getMC();
            area             = mc.getCurrentBodyArea();
        }
        catch (e:Error) {
            trace(_fighter.data.name);
            trace('FighterCtrler.getBodyArea::', e);
//				area = _fighter.getMC().getCurrentBodyArea();
        }

        if (area == null) {
            return null;
        }

//			//缓存取出后，需要对重新计算位置
        return getCurrentRect(area, 'body');
    }

    public function getHitCheckRect(name:String):Rectangle {
        var area:Rectangle = _fighter.getMC().getCheckHitRect(name);
        if (area == null) {
            return null;
        }
        return getCurrentRect(area, 'hit_check');
    }

    public function getCurrentRect(rect:Rectangle, cacheId:String = null):Rectangle {
        var newRect:Rectangle;

        if (cacheId == null) {
            newRect = new Rectangle();
        }
        else {
            if (_rectCache[cacheId]) {
                newRect = _rectCache[cacheId];
            }
            else {
                newRect             = new Rectangle();
                _rectCache[cacheId] = newRect;
            }
        }

        newRect.x = rect.x * _fighter.direct + _fighter.x;
        if (_fighter.direct < 0) {
            newRect.x -= rect.width;
        }

        newRect.y      = rect.y + _fighter.y;
        newRect.width  = rect.width;
        newRect.height = rect.height;
        return newRect;
    }

    //万解 SAMPLE: parent.$fighter_ctrler.doWanKai();
    public function doWanKai(frame:int = 0):void {
        _doingWankai = true;
        if (frame == 0) {
            _fighter.mc.nextFrame();
        }
        else {
            _fighter.mc.gotoAndStop(frame);
        }
    }

    /**
     * 面对攻击对象  parent.$fighter_ctrler.setDirectToTarget();
     */
    public function setDirectToTarget():void {
        var target:IGameSprite = _fighter.getCurrentTarget();
        if (!target) {
            return;
        }

//			var display:DisplayObject = _fighter.getDisplay();
//			var targetDisplay:DisplayObject = target.getDisplay();

        _fighter.direct = (
                                  _fighter.x < target.x
                          ) ? 1 : -1;
    }

    /**
     * 移动一次  parent.$fighter_ctrler.moveOnce(0,0);
     */
    public function moveOnce(x:Number = 0, y:Number = 0):void {
        _fighter.x += x * _fighter.direct;
        _fighter.y += y;
    }

    /**
     * 移动到攻击对象
     * @param offsetX X位置偏移
     * @param offsetY Y位置偏移
     * @param setDirect 面对到攻击对象
     * parent.$fighter_ctrler.moveToTarget(0,0,true);
     */
    public function moveToTarget(x:Object = null, y:Object = null, setDirect:Boolean = true):void {
        var target:IGameSprite = _fighter.getCurrentTarget();
        if (!target) {
            return;
        }

//			var display:DisplayObject = _fighter.getDisplay();
//			var targetDisplay:DisplayObject = target.getDisplay();

        if (x != null) {
            var numX:Number = Number(x);
            var fx:Number   = target.x + numX * _fighter.direct;
            if (numX > 0) {
                try {
                    if (target.x < numX) {
                        fx = target.x + numX;
                    }
                    else if (target.x > GameCtrl.I.gameState.getMap().right - numX) {
                        fx = target.x - numX;
                    }
                }
                catch (e:Error) {
                }
            }
            _fighter.x = fx;
        }

        if (y != null) {
            _fighter.y = target.y + Number(y);
        }

        if (setDirect) {
            _fighter.direct = (
                                      _fighter.x < target.x
                              ) ? 1 : -1;
        }
    }

    /**
     * 设置穿越
     */
    public function setCross(v:Boolean):void {
        _fighter.isCross = v;
    }

    public function getHitRange(id:String):Rectangle {
        var area:Rectangle = _fighter.getMC().getHitRange(id);
        if (area == null) {
            return null;
        }
        //			//缓存取出后，需要对重新计算位置
        return getCurrentRect(area, "hitRange_" + id);
    }

}
}
