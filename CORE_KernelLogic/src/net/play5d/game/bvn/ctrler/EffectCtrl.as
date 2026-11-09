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
import net.play5d.game.bvn.ctrler.effect.DisplayFrameBitmapCache;
import net.play5d.game.bvn.ctrler.effect.EffectManager;
import net.play5d.game.bvn.views.effects.BitmapFilterView;
import net.play5d.game.bvn.views.effects.BuffEffectView;
import net.play5d.game.bvn.views.effects.EffectView;
import net.play5d.game.bvn.views.effects.ShineEffectView;
import net.play5d.game.bvn.views.effects.SpecialEffectView;
import net.play5d.kyo.utils.UUID;

/**
 * 对局特效入口：受击、定格、闪光、震动和黑屏。
 *
 * <p>同一份特效数据在一帧里从第 4 次开始会被丢掉，定格和震动也不会发生。
 * 定格取当前和这次里更长的帧数，更短的一次直接返回，也不会再次暂停。
 * 援助按 <code>comicType == 1</code> 播火影出场，其它播死神；敌人出生正好相反，<code>0</code> 播死神。
 * 移除敌人只在动作帧里把透明度每次减 0.05，到 0 再调用回调，角色本身还在。</p>
 *
 * @see EffectManager
 */
public class EffectCtrl {

    /**
     * 特效是否抗锯齿。
     *
     * @default true
     */
    public static var EFFECT_SMOOTHING:Boolean = true;
    /**
     * 是否开启残影。
     *
     * @default true
     */
    public static var SHADOW_ENABLED:Boolean   = true;
    /**
     * 是否开启震动。
     *
     * @default true
     */
    public static var SHAKE_ENABLED:Boolean    = true;
    /**
     * 是否开启背景模糊。字段名里的拼写是现有接口。
     *
     * @default true
     */
    public static var BG_BULR_ENABLED:Boolean  = true;
    /** @private */
    private static var _i:EffectCtrl;

    /**
     * 唯一实例。第一次读取时创建。
     *
     * @return 特效控制。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.jumpEffect(x, y);
     * </listing>
     */
    public static function get I():EffectCtrl {
        _i ||= new EffectCtrl();
        return _i;
    }

    /**
     * 同时存在的闪光上限。已经超过这个数时，先摘掉最早的一个再加。
     *
     * @default 3
     */
    public var shineMaxCount:int     = 3;
    /**
     * 是否接受定格。
     *
     * @default true
     */
    public var freezeEnabled:Boolean = true;

    /**
     * 是否允许背景模糊。
     *
     * <p>读的是慢放处理器上的开关。</p>
     *
     * @return 允许时为 <code>true</code>。
     */
    public function get bgBlurEnabled():Boolean {
        return _slowHandler.bgBlurEnabled;
    }

    /** @private */
    public function set bgBlurEnabled(v:Boolean):void {
        _slowHandler.bgBlurEnabled = v;
    }

    /** @private */
    private var _gameStage:GameStage;
    /** @private */
    private var _effectLayer:Sprite;
    /** @private */
    private var _manager:EffectManager;
    /** @private */
    private var _freezeFrame:int                         = 0;
    /** @private */
    private var _effects:Vector.<EffectView>;
    /** @private */
    private var _shineEffects:Vector.<ShineEffectView>;
    /** @private */
    private var _filterEffects:Vector.<BitmapFilterView> = new Vector.<BitmapFilterView>();

    /** @private */
    private var _shakeHandler:EffectShakeHandler         = new EffectShakeHandler();
    /** @private */
    private var _slowHandler:EffectSlowHandler           = new EffectSlowHandler();
    /** @private */
    private var _hitHandler:EffectHitHandler             = new EffectHitHandler();
    /** @private */
    private var _shadowHandler:EffectShadowHandler       = new EffectShadowHandler();
    /** @private */
    private var _blackBackHandler:EffectBlackBackHandler = new EffectBlackBackHandler();

    /** @private */
    private var _onFreezeOver:Vector.<Function> = null;

    /** @private */
    private var _frameEffectCount:Dictionary = new Dictionary();
    /** @private */
    private var _removeEnemyMap:Object       = {};

    /**
     * 销毁各处理器并丢掉特效列表。
     *
     * <p>之后再 <code>render</code> 会抛错。</p>
     *
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.destroy();
     * </listing>
     */
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

    /**
     * 建好特效层并初始化各处理器。
     *
     * <p>再调用一次会换掉列表，上一批视图不会销毁。</p>
     *
     * @param gameStage 对局场景。
     * @param effectLayer 特效层。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.initialize(stage, layer);
     * </listing>
     */
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

    /**
     * 推进定格、闪光和特效。动作帧由慢放处理器决定。
     *
     * <p>还没 <code>initialize</code> 时会抛错。</p>
     */
    public function render():void {
        if (freezeEnabled) {
            renderFreeze();
        }

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

    /**
     * 播放受击特效。
     *
     * @param hitvo 受击数据。
     * @param hitRect 命中区域。
     * @param target 受击目标。可省略。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.doHitEffect(hitvo, rect, target);
     * </listing>
     */
    public function doHitEffect(hitvo:HitVO, hitRect:Rectangle, target:IGameSprite = null):void {
        _hitHandler.doHitEffect(hitvo, hitRect, target);
    }

    /**
     * 播放防御特效。
     *
     * @param hitvo 受击数据。
     * @param hitRect 命中区域。
     * @param defenseType 防御类型。
     * @param target 受击目标。可省略。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.doDefenseEffect(hitvo, rect, defenseType, target);
     * </listing>
     */
    public function doDefenseEffect(hitvo:HitVO, hitRect:Rectangle, defenseType:int, target:IGameSprite = null):void {
        _hitHandler.doDefenseEffect(hitvo, hitRect, defenseType, target);
    }

    /**
     * 播放钢体受击特效。
     *
     * @param hitvo 受击数据。
     * @param hitRect 命中区域。
     * @param target 受击目标。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.doSteelHitEffect(hitvo, rect, target);
     * </listing>
     */
    public function doSteelHitEffect(hitvo:HitVO, hitRect:Rectangle, target:IGameSprite):void {
        _hitHandler.doSteelHitEffect(hitvo, hitRect, target);
    }

    /**
     * 按 id 播放特效。找不到这份数据时什么都不做。
     *
     * @param id 特效 id。
     * @param x 横坐标。
     * @param y 纵坐标。
     * @param direct 朝向。默认 1。
     * @param target 跟随目标。可省略。
     * @param playSnd 是否播放特效音。默认 <code>true</code>。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.doEffectById('jump', x, y);
     * </listing>
     */
    public function doEffectById(
            id:String, x:Number, y:Number, direct:int = 1, target:IGameSprite = null, playSnd:Boolean = true):void {
        var effect:EffectVO = EffectModel.I.getEffect(id);
        if (effect) {
            doEffectVO(effect, x, y, direct, target, playSnd);
        }
    }

    /**
     * 播放援助出场特效。
     *
     * <p><code>comicType</code> 为 1 时播火影，其它值播死神。<code>fz</code> 为空时抛错。</p>
     *
     * @param fz 援助。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.assisterEffect(assister);
     * </listing>
     */
    public function assisterEffect(fz:Assister):void {
        var isNaruto:Boolean = fz.data.comicType == 1;
        if (isNaruto) {
            doEffectById('fz_naruto', fz.x, fz.y);
        }
        else {
            doEffectById('fz_bleach', fz.x, fz.y);
        }
    }

    /**
     * 按特效数据播放，并带上定格、震动、闪光和慢放。
     *
     * <p>同一份数据这一帧超过 3 次就直接返回。视图没建出来、又传了 <code>target</code> 时，设置跟随目标会抛错。</p>
     *
     * @param effect 特效数据，同时作为本帧计数的键。
     * @param ex 横坐标。
     * @param ey 纵坐标。
     * @param direct 朝向。默认 1。
     * @param target 跟随目标。可省略。
     * @param playSnd 是否播放特效音。默认 <code>true</code>。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.doEffectVO(effect, x, y);
     * </listing>
     */
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

    /**
     * 播放特殊特效并跟着目标。
     *
     * <p>找不到这份特效时会抛错。</p>
     *
     * @param id 特效 id。
     * @param target 目标。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.doSpecialEffect(id, fighter);
     * </listing>
     */
    public function doSpecialEffect(id:String, target:FighterMain):void {
        var data:EffectVO            = EffectModel.I.getEffect(id);
        var effect:SpecialEffectView = addEffect(data, target.x, target.y, target.direct) as SpecialEffectView;
        if (effect) {
            effect.setTarget(target);
            _effectLayer.addChild(effect.display);
        }
    }

    /**
     * 播放 buff 特效并写上 buff 数据。
     *
     * <p>找不到这份特效时会抛错。</p>
     *
     * @param id 特效 id。
     * @param target 目标。
     * @param buff buff 数据。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.doBuffEffect(id, fighter, buff);
     * </listing>
     */
    public function doBuffEffect(id:String, target:FighterMain, buff:FighterBuffVO):void {
        var data:EffectVO         = EffectModel.I.getEffect(id);
        var effect:BuffEffectView = addEffect(data, target.x, target.y, target.direct) as BuffEffectView;
        if (effect) {
            effect.setTarget(target);
            effect.setBuff(buff);
            _effectLayer.addChild(effect.display);
        }
    }

    /**
     * 按毫秒定格，并暂停对局。
     *
     * <p>开关关掉、时间小于 1，或换算后不足 1 帧时直接返回。当前定格更长时也直接返回，不会改成更短的。
     * 时间大于 300 且当前慢放倍率大于 0 时，再加一段背景模糊。</p>
     *
     * @param time 毫秒。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.freeze(200);
     * </listing>
     */
    public function freeze(time:int):void {
        if (!freezeEnabled) {
            return;
        }
        if (time < 1) {
            return;
        }
        var frame:int = (
                                time * 0.001
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

    /**
     * 在场景上加一层闪光。
     *
     * <p><code>FPS_SHINE_EFFECT</code> 为 0 时直接返回。已经超过 <code>shineMaxCount</code> 时先摘掉最早的一层。
     * 还没初始化时会抛错。</p>
     *
     * @param color 颜色。默认 <code>0xffffff</code>。
     * @param alpha 透明度。默认 0.2。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.shine();
     * </listing>
     */
    public function shine(color:uint = 0xffffff, alpha:Number = 0.2):void {

        if (GameConfig.FPS_SHINE_EFFECT == 0) {
            return;
        }

        if (_shineEffects.length > shineMaxCount) {
            _shineEffects[0].removeSelf();
        }
        var shineEffectView:ShineEffectView = _manager.getShine();
        shineEffectView.init(color, alpha);
        shineEffectView.onRemove = removeShine;
        _shineEffects.push(shineEffectView);
        _gameStage.addChild(shineEffectView);
    }

    /**
     * 开始持续震动。
     *
     * @param sx 横向幅度。
     * @param sy 纵向幅度。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.startShake(4, 0);
     * </listing>
     */
    public function startShake(sx:Number, sy:Number):void {
        _shakeHandler.startShake(sx, sy);
    }

    /**
     * 结束持续震动。
     *
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.endShake();
     * </listing>
     */
    public function endShake():void {
        _shakeHandler.endShake();
    }

    /**
     * 按给定幅度震一段时间。
     *
     * @param powX 横向幅度。默认 0。
     * @param powY 纵向幅度。默认 3。
     * @param time 毫秒。默认 500。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.shake();
     * </listing>
     */
    public function shake(powX:Number = 0, powY:Number = 3, time:int = 500):void {
        _shakeHandler.shake(powX, powY, time);
    }

    /**
     * 给一个显示对象加残影。
     *
     * @param target 显示对象。
     * @param r 红。默认 0。
     * @param g 绿。默认 0。
     * @param b 蓝。默认 0。
     * @param owner 所属精灵。可省略。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.startShadow(display);
     * </listing>
     */
    public function startShadow(
            target:DisplayObject, r:int = 0, g:int = 0, b:int = 0, owner:BaseGameSprite = null
    ):void {
        _shadowHandler.startShadow(target, r, g, b, owner);
    }

    /**
     * 去掉这个显示对象的残影。
     *
     * @param target 显示对象。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.endShadow(display);
     * </listing>
     */
    public function endShadow(target:DisplayObject):void {
        _shadowHandler.endShadow(target);
    }

    /**
     * 播放必杀黑屏。
     *
     * @param target 释放者。
     * @param isSuper 是否超必杀。默认 <code>false</code>。
     * @param face 头像。可省略。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.bisha(fighter);
     * </listing>
     */
    public function bisha(target:BaseGameSprite, isSuper:Boolean = false, face:DisplayObject = null):void {
        _blackBackHandler.bisha(target, isSuper, face);
    }

    /**
     * 结束这个目标的必杀黑屏。
     *
     * @param target 释放者。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.endBisha(fighter);
     * </listing>
     */
    public function endBisha(target:BaseGameSprite):void {
        _blackBackHandler.endBisha(target);
    }

    /**
     * 播放卍解黑屏。
     *
     * @param target 释放者。
     * @param face 头像。可省略。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.banKai(fighter);
     * </listing>
     */
    public function banKai(target:FighterMain, face:DisplayObject = null):void {
        _blackBackHandler.banKai(target, face);
    }

    /**
     * 结束这个目标的卍解黑屏。
     *
     * @param target 释放者。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.endBanKai(fighter);
     * </listing>
     */
    public function endBanKai(target:FighterMain):void {
        _blackBackHandler.endBanKai(target);
    }

    /**
     * 播放起跳特效 <code>jump</code>。
     *
     * @param x 横坐标。
     * @param y 纵坐标。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.jumpEffect(x, y);
     * </listing>
     */
    public function jumpEffect(x:Number, y:Number):void {
        doEffectById('jump', x, y);
    }

    /**
     * 播放空中起跳特效 <code>jump_air</code>。
     *
     * @param x 横坐标。
     * @param y 纵坐标。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.jumpAirEffect(x, y);
     * </listing>
     */
    public function jumpAirEffect(x:Number, y:Number):void {
        doEffectById('jump_air', x, y);
    }

    /**
     * 播放落地特效 <code>touch_floor</code>。
     *
     * @param x 横坐标。
     * @param y 纵坐标。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.touchFloorEffect(x, y);
     * </listing>
     */
    public function touchFloorEffect(x:Number, y:Number):void {
        doEffectById('touch_floor', x, y);
    }

    /**
     * 按落地类型播放击地特效。
     *
     * <p>弹地播 <code>hit_floor</code>，普通播 <code>hit_floor_low</code>，重击同时播 <code>hit_floor_heavy</code> 和 <code>hit_floor_yan</code>。其它类型什么都不做。</p>
     *
     * @param type 落地类型，见 <code>FighterHitFloorType</code>。
     * @param x 横坐标。
     * @param y 纵坐标。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.hitFloorEffect(type, x, y);
     * </listing>
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
     * 慢放。
     *
     * @param rate 倍率。
     * @param time 毫秒。默认 1000。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.slowDown(2);
     * </listing>
     */
    public function slowDown(rate:Number, time:int = 1000):void {
        _slowHandler.slowDown(rate, time);
    }

    /**
     * 背景模糊一段时间。
     *
     * @param blurX 横向模糊。
     * @param blurY 纵向模糊。
     * @param time 毫秒。默认 1000。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.bgBlur(8, 0);
     * </listing>
     */
    public function bgBlur(blurX:Number, blurY:Number, time:int = 1000):void {
        _slowHandler.bgBlur(blurX, blurY, time);
    }

    /**
     * 取消背景模糊。
     *
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.cancelBgBlur();
     * </listing>
     */
    public function cancelBgBlur():void {
        _slowHandler.cancelBgBlur();
    }

    /**
     * 结束慢放。
     *
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.slowDownResume();
     * </listing>
     */
    public function slowDownResume():void {
        _slowHandler.slowDownResume();
    }

    /**
     * 在地图底下播放全屏特效，并先把地图藏起来。
     *
     * <p>找不到特效时直接返回。<code>hold</code> 不是 -1 时写成停留帧；视图没建出来时这一步会抛错。
     * 特效移除后才把地图重新显示。</p>
     *
     * @param id 特效 id。
     * @param hold 停留秒数。默认 -1，表示不改停留帧。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.BGEffect(id);
     * </listing>
     */
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

    /**
     * 登记定格结束时要调用的函数。
     *
     * <p>会追加，不会替换。定格数到 0 时全部调用一次，然后清掉。这次定格没真正开始时，回调会留到下一次定格结束。</p>
     *
     * @param v 回调，没有参数。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.setOnFreezeOver(onOver);
     * </listing>
     */
    public function setOnFreezeOver(v:Function):void {
        if (!_onFreezeOver) {
            _onFreezeOver = new Vector.<Function>();
        }
        _onFreezeOver.push(v);
    }

    /**
     * 播放替身术。
     *
     * @param target 目标。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.replaceSkill(sprite);
     * </listing>
     */
    public function replaceSkill(target:BaseGameSprite):void {
        _blackBackHandler.replaceSkill(target);
    }

    /**
     * 播放灵压爆发。
     *
     * @param target 目标。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.energyExplode(sprite);
     * </listing>
     */
    public function energyExplode(target:BaseGameSprite):void {
        _blackBackHandler.energyExplode(target);
    }

    /**
     * 开始瞬步。
     *
     * @param target 目标。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.ghostStep(sprite);
     * </listing>
     */
    public function ghostStep(target:BaseGameSprite):void {
        _blackBackHandler.ghostStep(target);
    }

    /**
     * 结束瞬步。
     *
     * @param target 目标。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.endGhostStep(sprite);
     * </listing>
     */
    public function endGhostStep(target:BaseGameSprite):void {
        _blackBackHandler.endGhostStep(target);
    }

    /**
     * 给目标加持续滤镜。同一个目标再次调用时改滤镜，不另加一层。
     *
     * <p>新滤镜放进 0 队、深度 0。</p>
     *
     * @param target 目标。
     * @param filter 滤镜。
     * @param filterOffset 偏移。可省略。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.startFilter(sprite, filter);
     * </listing>
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

    /**
     * 去掉这个目标上的持续滤镜，并销毁那一层。
     *
     * <p>只处理第一份匹配。</p>
     *
     * @param target 目标。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.endFilter(sprite);
     * </listing>
     */
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
     * 把显示透明度设成 1，并播放出场特效，不播特效音。
     *
     * <p><code>comicType</code> 为 0 时播死神，其它值播火影。</p>
     *
     * @param f 敌人。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.enemyBirthEffect(enemy);
     * </listing>
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
     * 登记一个敌人，在动作帧里把透明度每次减 0.05。
     *
     * <p>到 0 时调用 <code>callback</code>。角色不会被移出场景。逻辑帧不推进这段淡出。</p>
     *
     * @param f 敌人。
     * @param callback 淡出结束后的回调。可省略。
     * @example
     * <listing version="3.0">
     * EffectCtrl.I.removeEnemyEffect(enemy, onGone);
     * </listing>
     */
    public function removeEnemyEffect(f:FighterMain, callback:Function = null):void {
        _removeEnemyMap[UUID.create()] = {fighter: f, callback: callback};
    }

    private function renderShine():void {
        var i:int, shineEffectView:ShineEffectView;
        for (i = 0; i < _shineEffects.length; i++) {
            shineEffectView = _shineEffects[i];
            shineEffectView.render();
        }
    }

    private function renderAnimate():void {
        var effectView:EffectView;
        var i:int = 0;

        for (i = 0; i < _effects.length; i++) {
            effectView = _effects[i];
            effectView.renderAnimate();
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
        for (var i:String in _removeEnemyMap) {
            var o:Object          = _removeEnemyMap[i];
            var f:FighterMain     = o.fighter;
            var callback:Function = o.callback;

            if (!f) {
                delete _removeEnemyMap[i];
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
                delete _removeEnemyMap[i];
            }
        }

    }


}
}
