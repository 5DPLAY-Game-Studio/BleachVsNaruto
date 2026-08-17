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

package net.play5d.game.bvn.ctrler {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.filters.BitmapFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.effect.EffectBlackBackHandler;
import net.play5d.game.bvn.ctrler.effect.EffectHitHandler;
import net.play5d.game.bvn.ctrler.effect.EffectShadowHandler;
import net.play5d.game.bvn.ctrler.effect.EffectShakeHandler;
import net.play5d.game.bvn.ctrler.effect.EffectSlowHandler;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.EffectModel;
import net.play5d.game.bvn.data.fighter.FighterHitFloorType;
import net.play5d.game.bvn.data.vos.EffectVO;
import net.play5d.game.bvn.fighter.Assister;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.fighter.vos.FighterBuffVO;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.stage.GameStage;
import net.play5d.game.bvn.utils.DisplayFrameBitmapCache;
import net.play5d.game.bvn.utils.EffectManager;
import net.play5d.game.bvn.views.effects.BitmapFilterView;
import net.play5d.game.bvn.views.effects.BuffEffectView;
import net.play5d.game.bvn.views.effects.EffectView;
import net.play5d.game.bvn.views.effects.ShineEffectView;
import net.play5d.game.bvn.views.effects.SpecialEffectView;
import net.play5d.kyo.utils.UUID;

public class EffectCtrl {

    public static var EFFECT_SMOOTHING:Boolean = true; //特效抗锯齿
    public static var SHADOW_ENABLED:Boolean   = true; //残影开关
    public static var SHAKE_ENABLED:Boolean    = true; //震动开关
    public static var BG_BULR_ENABLED:Boolean  = true; //背景模糊开关
    private static var _i:EffectCtrl;

    public static function get I():EffectCtrl {
        _i ||= new EffectCtrl();
        return _i;
    }

    public var shineMaxCount:int = 3;
    public var freezeEnabled:Boolean = true;

    /**
     * 是否允许背景模糊。
     */
    public function get bgBlurEnabled():Boolean {
        return _slowHandler.bgBlurEnabled;
    }

    /** @private */
    public function set bgBlurEnabled(v:Boolean):void {
        _slowHandler.bgBlurEnabled = v;
    }

    private var _gameStage:GameStage;
    private var _effectLayer:Sprite;
    private var _manager:EffectManager;
    private var _freezeFrame:int                         = 0;
    private var _effects:Vector.<EffectView>;
    private var _shineEffects:Vector.<ShineEffectView>;
    private var _filterEffects:Vector.<BitmapFilterView> = new Vector.<BitmapFilterView>();

    private var _shakeHandler:EffectShakeHandler         = new EffectShakeHandler();
    private var _slowHandler:EffectSlowHandler           = new EffectSlowHandler();
    private var _hitHandler:EffectHitHandler             = new EffectHitHandler();
    private var _shadowHandler:EffectShadowHandler       = new EffectShadowHandler();
    private var _blackBackHandler:EffectBlackBackHandler = new EffectBlackBackHandler();

    private var _onFreezeOver:Vector.<Function> = null;

    private var _frameEffectCount:Dictionary = new Dictionary();
    private var _removeEnemieMap:Object = {};
    //P 当前，N前提条件
    private var wayPoints:Array = [

        {P: "p1", N: null},

        {P: "p2", N: "p1"},
        {P: "p2_1", N: "p2"},
        {P: "p2_2", N: "p2"},


        {P: "p3", N: ["p2_1", "p2_2"]},
        {P: "p3_1", N: "p3"},
        {P: "p3_1_1", N: "p3_1"},
        {P: "p3_1_2", N: "p3_1_1"},

        {P: "p3_2", N: "p3"},
        {P: "p3_2_4", N: "p3_2"}, {P: "p3_2_3", N: "p3_2_4"},
        {P: "p3_2_1", N: "p3_2"}, {P: "p3_2_2", N: "p3_2_1"},
        {P: "p3_2_5", N: "p3_2_4"},
        {P: "p3_2_6", N: ["p3_2_5", "p3_2_4"]},

        {P: "p4", N: ["p3_1_2", "p3_2_5"]},

        {P: "p5", N: "p3_2_6"},
    ];

    public function destroy():void {
        // 执行销毁时结束震动
        _shakeHandler.destroy();

        if (_manager) {
            _manager.destroy();
            _manager = null;
        }

        _blackBackHandler.destroy();
        _shadowHandler.destroy();
        _hitHandler.destroy();
        _slowHandler.destroy();

        _effects       = null;
        _shineEffects  = null;
        _gameStage     = null;
        _effectLayer   = null;

        DisplayFrameBitmapCache.I.clear();

    }

    public function initialize(gameStage:GameStage, effectLayer:Sprite):void {
        DisplayFrameBitmapCache.I.clear();

        _manager = new EffectManager();

        _gameStage   = gameStage;
        _effectLayer = effectLayer;

        _effects      = new Vector.<EffectView>();
        _shineEffects = new Vector.<ShineEffectView>();

        _shakeHandler.initialize(gameStage);
        _slowHandler.initialize(gameStage);
        _hitHandler.bind(this, _manager);
        _shadowHandler.initialize(effectLayer);
        _blackBackHandler.initialize(this, gameStage);

    }

    public function render():void {
        if (freezeEnabled) {
            renderFreeze();
        }

        //			if(_shineEffect) _shineEffect.render();

        _slowHandler.render();
        renderShine();

        clearFrameEffectCount();

        for (var i:int = 0; i < _effects.length; i++) {
            _effects[i].render();
        }

        if (_slowHandler.isRenderAnimate()) {
            renderAnimate();
        }

        _blackBackHandler.render();

    }

    public function doHitEffect(hitvo:HitVO, hitRect:Rectangle, target:IGameSprite = null):void {
        _hitHandler.doHitEffect(hitvo, hitRect, target);
    }

    public function doDefenseEffect(hitvo:HitVO, hitRect:Rectangle, defenseType:int, target:IGameSprite = null):void {
        _hitHandler.doDefenseEffect(hitvo, hitRect, defenseType, target);
    }

    public function doSteelHitEffect(hitvo:HitVO, hitRect:Rectangle, target:IGameSprite):void {
        _hitHandler.doSteelHitEffect(hitvo, hitRect, target);
    }

    public function doEffectById(
            id:String, x:Number, y:Number, direct:int = 1, target:IGameSprite = null, playSnd:Boolean = true):void {
        var effect:EffectVO = EffectModel.I.getEffect(id);
        if (effect) {
            doEffectVO(effect, x, y, direct, target, playSnd);
        }
    }

    public function assisterEffect(fz:Assister):void {
        var isNaruto:Boolean = fz.data.comicType == 1;
        if (isNaruto) {
            doEffectById('fz_naruto', fz.x, fz.y);
        }
        else {
            doEffectById('fz_bleach', fz.x, fz.y);
        }
    }

    public function doEffectVO(
            effect:EffectVO, ex:Number, ey:Number, direct:int = 1, target:IGameSprite = null,
            playSnd:Boolean                                                           = true
    ):void {

        // 性能优化，每一帧只能同时存在N个同样的特效
        if (!_frameEffectCount[effect]) {
            _frameEffectCount[effect] = 0;
        }
        var v:int = _frameEffectCount[effect];
        if ((
                    _frameEffectCount[effect] = (
                            ++v
                    )
            ) > 3) {
            return;
        }

        var effectView:EffectView = addEffect(effect, ex, ey, direct, playSnd);

        if (effectView) {
            _effectLayer.addChild(effectView.display);
        }

        if (effect.freeze > 0) {
            freeze(effect.freeze);
        }

        if (effect.shake) {
            var time:Number   = effect.shake.time != undefined ? effect.shake.time : 0;
            var shakex:Number = effect.shake.x != undefined ? effect.shake.x : 0;
            var shakey:Number = effect.shake.y != undefined ? effect.shake.y : 0;

            shake(shakex, shakey, time);
        }

        if (effect.shine) {
            var color:uint   = effect.shine.color != undefined ? effect.shine.color : 0xffffff;
            var alpha:Number = effect.shine.alpha != undefined ? effect.shine.alpha : 0.2;
            shine(color, alpha);
        }

        if (effect.slowDown) {
            var rate:Number      = effect.slowDown.rate != undefined ? effect.slowDown.rate : 1.5;
            var slowDownTime:int = effect.slowDown.time != undefined ? effect.slowDown.time : 1000;
            slowDown(rate, slowDownTime);
        }

        if (target) {
            effectView.setTarget(target);
        }

        if (effect.specialEffectId && target && target is FighterMain) {
            doSpecialEffect(effect.specialEffectId, target as FighterMain);
        }
    }

    public function doSpecialEffect(id:String, target:FighterMain):void {
        var data:EffectVO            = EffectModel.I.getEffect(id);
        var effect:SpecialEffectView = addEffect(data, target.x, target.y, target.direct) as SpecialEffectView;
        if (effect) {
            effect.setTarget(target);
            _effectLayer.addChild(effect.display);
        }
    }

    public function doBuffEffect(id:String, target:FighterMain, buff:FighterBuffVO):void {
        var data:EffectVO         = EffectModel.I.getEffect(id);
        var effect:BuffEffectView = addEffect(data, target.x, target.y, target.direct) as BuffEffectView;
        if (effect) {
            effect.setTarget(target);
            effect.setBuff(buff);
            _effectLayer.addChild(effect.display);
        }
    }

    public function freeze(time:int):void {
        if (!freezeEnabled) {
            return;
        }
        if (time < 1) {
            return;
        }
        var frame:int = (
                                time / 1000
                        ) * GameConfig.FPS_GAME;
        if (frame < 1) {
            return;
        }
        if (_freezeFrame > frame) {
            return;
        }
        _freezeFrame = frame;

        if (time > 300) {
            if (GameCtrl.I.slowRate > 0) {
                _slowHandler.bgBlur(GameCtrl.I.slowRate * 4, 0, 500);
            }
        }

        GameCtrl.I.pause();
    }

    public function shine(color:uint = 0xffffff, alpha:Number = 0.2):void {

        if (GameConfig.FPS_SHINE_EFFECT == 0) {
            return;
        }

        if (_shineEffects.length > shineMaxCount) {
            _shineEffects[0].removeSelf();
        }
        var sv:ShineEffectView = _manager.getShine();
        sv.init(color, alpha);
        sv.onRemove = removeShine;
        _shineEffects.push(sv);
        _gameStage.addChild(sv);
    }

    public function startShake(sx:Number, sy:Number):void {
        _shakeHandler.startShake(sx, sy);
    }

    public function endShake():void {
        _shakeHandler.endShake();
    }

    public function shake(powX:Number = 0, powY:Number = 3, time:int = 500):void {
        _shakeHandler.shake(powX, powY, time);
    }

    public function startShadow(
            target:DisplayObject, r:int = 0, g:int = 0, b:int = 0, owner:BaseGameSprite = null
    ):void {
        _shadowHandler.startShadow(target, r, g, b, owner);
    }

    public function endShadow(target:DisplayObject):void {
        _shadowHandler.endShadow(target);
    }

    public function bisha(target:BaseGameSprite, isSuper:Boolean = false, face:DisplayObject = null):void {
        _blackBackHandler.bisha(target, isSuper, face);
    }

    public function endBisha(target:BaseGameSprite):void {
        _blackBackHandler.endBisha(target);
    }

    public function wanKai(target:FighterMain, face:DisplayObject = null):void {
        _blackBackHandler.wanKai(target, face);
    }

    public function endWanKai(target:FighterMain):void {
        _blackBackHandler.endWanKai(target);
    }

    public function jumpEffect(x:Number, y:Number):void {
        doEffectById('jump', x, y);
    }

    public function jumpAirEffect(x:Number, y:Number):void {
        doEffectById('jump_air', x, y);
    }

    public function touchFloorEffect(x:Number, y:Number):void {
        doEffectById('touch_floor', x, y);
    }

    /**
     * 击落地效果
     * @param type 0=弹，1=正常落地，2=重落地
     */
    public function hitFloorEffect(type:int, x:Number, y:Number):void {
        switch (type) {
        case FighterHitFloorType.TAN:
            doEffectById('hit_floor', x, y);
            break;
        case FighterHitFloorType.NORMAL:
            doEffectById('hit_floor_low', x, y);
            break;
        case FighterHitFloorType.HEAVY:
            doEffectById('hit_floor_heavy', x, y);
            doEffectById('hit_floor_yan', x, y);
            break;
        }

    }

    /**
     * 慢放效果
     */
    public function slowDown(rate:Number, time:int = 1000):void {
        _slowHandler.slowDown(rate, time);
    }

    public function bgBlur(blurX:Number, blurY:Number, time:int = 1000):void {
        _slowHandler.bgBlur(blurX, blurY, time);
    }

    public function cancelBgBlur():void {
        _slowHandler.cancelBgBlur();
    }

    public function slowDownResume():void {
        _slowHandler.slowDownResume();
    }

    //		public function dash(target:FighterMain):void{
    //			doEffectById('dash',target.x,target.y);
    //		}

    public function BGEffect(id:String, hold:Number = -1):void {
        var data:EffectVO = EffectModel.I.getEffect(id);
        if (!data) {
            return;
        }

        var effect:EffectView = addEffect(data, 0, 0, 1);
        if (hold != -1) {
            effect.holdFrame = hold * GameConfig.FPS_ANIMATE;
        }
        if (effect) {
            effect.addRemoveBack(function ():void {
                _gameStage.getMap().setVisible(true);
            });
            _gameStage.getMap().setVisible(false);
            _gameStage.addChildAt(effect.display, 0);
        }
    }

    public function setOnFreezeOver(v:Function):void {
        if (!_onFreezeOver) {
            _onFreezeOver = new Vector.<Function>();
        }
        _onFreezeOver.push(v);
    }

    /**
     * 替身术
     * @param target
     */
    public function replaceSkill(target:BaseGameSprite):void {
        _blackBackHandler.replaceSkill(target);
    }

    /**
     * 灵压爆发
     */
    public function energyExplode(target:BaseGameSprite):void {
        _blackBackHandler.energyExplode(target);
    }

    public function ghostStep(target:BaseGameSprite):void {
        _blackBackHandler.ghostStep(target);
    }

    public function endGhostStep(target:BaseGameSprite):void {
        _blackBackHandler.endGhostStep(target);
    }

    /**
     * 持续滤镜效果
     */
    public function startFilter(target:BaseGameSprite, filter:BitmapFilter, filterOffset:Point = null):void {
        var bv:BitmapFilterView;
        for each(var i:BitmapFilterView in _filterEffects) {
            if (i.target == target) {
                bv = i;
                break;
            }
        }

        if (!bv) {
            bv = new BitmapFilterView(target, filter, filterOffset);
            GameCtrl.I.addGameSprite(0, bv, 0);
            _filterEffects.push(bv);
        }
        else {
            bv.update(filter, filterOffset);
        }

    }

    public function endFilter(target:BaseGameSprite):void {
        for (var i:int = 0; i < _filterEffects.length; i++) {
            var bv:BitmapFilterView = _filterEffects[i];
            if (bv.target == target) {
                GameCtrl.I.removeGameSprite(bv, true);
                _filterEffects.splice(i, 1);
                break;
            }
        }
    }

    /**
     * 敌人出生效果
     */
    public function enemyBirthEffect(f:FighterMain):void {
        f.getDisplay().alpha = 1;
        if (f.data.comicType == 0) {
            EffectCtrl.I.doEffectById('fz_bleach', f.x, f.y, f.direct, null, false);
        }
        else {
            EffectCtrl.I.doEffectById('fz_naruto', f.x, f.y, f.direct, null, false);
        }
    }

    /**
     * 移除敌人效果
     */
    public function removeEnemyEffect(f:FighterMain, callback:Function = null):void {
        _removeEnemieMap[UUID.create()] = {fighter: f, callback: callback};
    }

    private function renderShine():void {
        var i:int, sv:ShineEffectView;
        for (i = 0; i < _shineEffects.length; i++) {
            sv = _shineEffects[i];
            sv.render();
        }
    }

    private function renderAnimate():void {
        var ev:EffectView;
        var i:int = 0;

        for (i = 0; i < _effects.length; i++) {
            ev = _effects[i];
            ev.renderAnimate();
        }

        _shadowHandler.renderAnimate();
        _blackBackHandler.renderAnimate();

        _shakeHandler.renderAnimate();

        renderRemoveEnemy();

        _slowHandler.renderAnimate();
    }

    /**
     * @private 清空本帧特效计数表，复用 Dictionary 避免每帧分配。
     */
    private function clearFrameEffectCount():void {
        for (var k:* in _frameEffectCount) {
            delete _frameEffectCount[k];
        }
    }

    /**
     * 开始渲染必杀背景变暗。
     *
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.startRenderBlackBack();
     * </listing>
     */
    public function startRenderBlackBack():void {
        _blackBackHandler.startRenderBlackBack();
    }

    private function renderFreeze():void {
        if (_freezeFrame > 0) {
            _freezeFrame--;
            if (_freezeFrame <= 0) {
                if (_onFreezeOver) {
                    for (var i:int; i < _onFreezeOver.length; i++) {
                        _onFreezeOver[i]();
                    }
                    _onFreezeOver = null;
                }

                _hitHandler.clearHitFocusOnFreezeEnd();

                GameCtrl.I.resume();
            }
        }
    }

    private function addEffect(data:EffectVO, x:Number, y:Number, direct:int = 1, playSound:Boolean = true):EffectView {
        var effectView:EffectView = _manager.getEffectView(data);
        if (!effectView) {
            return null;
        }
        effectView.start(x, y, direct, playSound);
        effectView.addRemoveBack(removeEffect);
        _effects.push(effectView);
        return effectView;
    }

    private function removeEffect(effect:EffectView):void {
        var id:int = _effects.indexOf(effect);
        if (id != -1) {
            _effects.splice(id, 1);
        }
    }

    private function removeShine(s:ShineEffectView):void {
        var id:int = _shineEffects.indexOf(s);
        if (id != -1) {
            _shineEffects.splice(id, 1);
        }
    }

    private function renderRemoveEnemy():void {
        for (var i:String in _removeEnemieMap) {
            var o:Object          = _removeEnemieMap[i];
            var f:FighterMain     = o.fighter;
            var callback:Function = o.callback;

            if (!f) {
                delete _removeEnemieMap[i];
                continue;
            }

            if (f.getDisplay().alpha > 0) {
                f.getDisplay().alpha -= 0.05;
            }
            else {
                if (callback != null) {
                    callback();
                }
                o.fighter  = null;
                o.callback = null;
                delete _removeEnemieMap[i];
            }
        }

    }


}
}
