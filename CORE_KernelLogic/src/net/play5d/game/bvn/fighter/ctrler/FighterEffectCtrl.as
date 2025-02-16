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
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.filters.GlowFilter;
import flash.geom.Point;

import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.fighter.data.FighterActionState;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.events.FighterEvent;
import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
import net.play5d.game.bvn.interfaces.BaseGameSprite;

public class FighterEffectCtrl {
    include '../../../../../../../include/_INCLUDE_.as';

    public function FighterEffectCtrl(target:BaseGameSprite) {
        _target        = target;
        _targetDisplay = target.getDisplay();
    }
    private var _target:BaseGameSprite;
    private var _targetDisplay:DisplayObject;
    private var _inGhostStep:Boolean;
    private var _faceObj:Object = {};
    private var _isShakeIng:Boolean;
    private var _isShadowIng:Boolean;
    private var _isGlowIng:Boolean;

    public function destory():void {
        _target        = null;
        _targetDisplay = null;
        _faceObj       = null;
    }

    public function setBishaFace(id:String, face:Class):void {
//			trace('setBishaFace',id,face);
        _faceObj[id] = face;
    }

    //SAMPLE: parent.$effect_ctrler.shine();
    public function shine(color:uint = 0xffffff):void {

        var alpha:Number = color == 0xffffff ? 0.3 : 0.2;
        EffectCtrl.I.shine(color, alpha);
    }

    //SAMPLE: parent.$effect_ctrler.shake(0,2);
    public function shake(powX:Number = 0, powY:Number = 3, time:Number = 0):void {
//			trace('shake',powX,powY);
        var pow:Number = Math.max(powX, powY);
        EffectCtrl.I.shake(0, pow * 2, time * 1000);
    }

    //SAMPLE: parent.$effect_ctrler.startShake(0,3);
    public function startShake(powX:Number = 0, powY:Number = 3):void {
        _isShakeIng = true;
        EffectCtrl.I.startShake(powX, powY);
    }

    //SAMPLE: parent.$effect_ctrler.endShake();
    public function endShake():void {
        if (_isShakeIng) {
            EffectCtrl.I.endShake();
            _isShakeIng = false;
        }
    }

    //SAMPLE: parent.$effect_ctrler.shadow(-200,-200,-200);
    public function shadow(r:int = 0, g:int = 0, b:int = 0):void {
        _isShadowIng = true;
        EffectCtrl.I.startShadow(_targetDisplay, r, g, b);
    }

    //MC调用：parent.$effect_ctrler.endShadow();
    public function endShadow():void {
        if (_isShadowIng) {
            EffectCtrl.I.endShadow(_targetDisplay);
        }
    }

    //MC调用：parent.$effect_ctrler.dash();
    public function dash(playSound:Boolean = true):void {
        if (_target.isInAir) {
            EffectCtrl.I.doEffectById('dash_air', _target.x, _target.y, _target.direct, null, playSound);
        }
        else {
            EffectCtrl.I.doEffectById('dash', _target.x, _target.y, _target.direct, null, playSound);
        }
    }

    //SAMPLE: parent.$effect_ctrler.bisha(false,"一户1");
    public function bisha(isSuper:Boolean = false, face:String = null):void {
        var faceDisplay:DisplayObject = getFace(face);
        EffectCtrl.I.bisha(_target, isSuper, faceDisplay);
    }

    //SAMPLE: parent.$effect_ctrler.endBisha();
    public function endBisha():void {
        EffectCtrl.I.endBisha(_target);
    }

    //开始万解 SAMPLE: parent.$effect_ctrler.startWanKai('一户万解');
    public function startWanKai(face:String = null):void {
        var faceDisplay:DisplayObject = face ? getFace(face) : null;
        EffectCtrl.I.wanKai(_target as FighterMain, faceDisplay);
    }

    //结束万解 parent.$effect_ctrler.endWanKai();
    public function endWanKai():void {
        if ((
                    _target as FighterMain
            ).actionState == FighterActionState.WAN_KAI_ING) {
            EffectCtrl.I.endWanKai(_target as FighterMain);
        }
    }

    //结束万解  parent.$effect_ctrler.walk();
    public function walk():void {

        if (_inGhostStep) {
            EffectCtrl.I.doEffectById('ghost_step', _target.x, _target.y, _target.direct);
        }
        else {
            SoundCtrl.I.playAssetSoundRandom('step1', 'step2', 'step3');
        }

    }

    public function jump():void {
        EffectCtrl.I.jumpEffect(_targetDisplay.x, _targetDisplay.y);
    }

    public function jumpAir():void {
        EffectCtrl.I.jumpAirEffect(_targetDisplay.x, _targetDisplay.y);
    }

    public function touchFloor():void {
        EffectCtrl.I.touchFloorEffect(_targetDisplay.x, _targetDisplay.y);
    }

    /**
     * 击落地效果
     * @param type 0=弹，1=正常落地，2=重落地
     * @param shakePow 震动大小
     */
    public function hitFloor(type:int, shakePow:Number = 0):void {
        if (_target is FighterMain && (
                _target as FighterMain
        ).mosouEnemyData && !(
                _target as FighterMain
        ).mosouEnemyData.isBoss) {
            if (shakePow > 1) {
                shakePow = 1;
            }
        }
        if (shakePow > 0) {
            shake(0, shakePow);
        }
        EffectCtrl.I.hitFloorEffect(type, _targetDisplay.x, _targetDisplay.y);
    }

    /**
     * 慢放效果 time(秒)
     */
    public function slowDown(time:Number):void {
        EffectCtrl.I.slowDown(1.5, time * 1000);
    }

    /**
     * 灵压爆发效果
     */
    public function energyExplode():void {
        EffectCtrl.I.energyExplode(_target);
    }

    /**
     * 替身术效果
     */
    public function replaceSkill():void {
        EffectCtrl.I.replaceSkill(_target);
    }

    /**
     * 幽步效果
     */
    public function ghostStep():void {
        _inGhostStep = true;
        shadow(0, 0, 255);
        EffectCtrl.I.ghostStep(_target);
    }

    /**
     * 幽步效果 结束
     */
    public function endGhostStep():void {
        _inGhostStep = false;
        endShadow();
        EffectCtrl.I.endGhostStep(_target);
    }

    /**
     * 发光效果
     */
    public function startGlow(color:uint = 0xffffff):void {
        _isGlowIng = true;

        var offset:Point      = new Point(20, 20);
        var strength:Number   = 2;
        var filter:GlowFilter = new GlowFilter(color, 1, offset.x, offset.y, strength, 1, false, true);
        EffectCtrl.I.startFilter(_target, filter, offset);
    }

    /**
     * 发光效果 结束
     */
    public function endGlow():void {
        if (_isGlowIng) {
            EffectCtrl.I.endFilter(_target);
        }
        _isGlowIng = false;
    }

    public function clean():void {
        endGhostStep();
        endGlow();
        endShadow();
    }

    /**
     * 添加一个跟随特效视图
     * @param mcName 特效 mc 名称
     * @param isUnderBody 是否在角色身体图层下方
     */
    public function addFollowEffect(mcName:String, isUnderBody:Boolean = false):void {
        var fighter:FighterMain = _target is FighterMain ? _target as FighterMain : null;
        if (!fighter) {
            return;
        }

        var mc:MovieClip = fighter.getMC().getChildByName(mcName) as MovieClip;
        if (!mc) {
            fighter.setAnimateFrameOut(function():void {
                addFollowEffect(mcName);
            }, 1);

            return;
        }

        var params:Object = {};
        params.mc = mc;
        params.isUnderBody = isUnderBody;

        FighterEventDispatcher.dispatchEvent(fighter, FighterEvent.ADD_EFFECT, params);
    }

    private function getFace(id:String):DisplayObject {
        if (!id) {
            return null;
        }

        var faceClass:Class = _faceObj[id];
        if (!faceClass) {
            Debugger.errorMsg('未定义必杀特写:' + id);
            return null;
        }
        var bd:BitmapData = new faceClass();
        var bp:Bitmap     = new Bitmap(bd);
        bp.smoothing      = true;
        return bp;
    }

}
}
