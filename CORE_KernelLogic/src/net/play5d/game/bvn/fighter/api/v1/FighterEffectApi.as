/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.fighter.api.v1 {
import net.play5d.game.bvn.fighter.api.FighterApiProxy;
import net.play5d.game.bvn.fighter.ctrler.FighterEffectCtrl;

/**
 * 角色时间轴第 1 版特效门面。
 *
 * <p>签名和默认值与当前 <code>$effect_ctrler</code> 一致，调用原样转发。销毁、必杀立绘登记和 <code>clean</code> 留在控制器。没有的成员记入 <code>FighterApiProxy.records</code>。</p>
 *
 * @see FighterEffectCtrl
 */
public class FighterEffectApi extends FighterApiProxy {

    /** @private */
    private var _effect:FighterEffectCtrl;

    /**
     * 绑定要转发的特效控制器。
     *
     * @param effect 角色特效控制器。
     * @example
     * <listing version="3.0">
     * var api:FighterEffectApi = new FighterEffectApi(effect);
     * </listing>
     */
    public function FighterEffectApi(effect:FighterEffectCtrl) {
        _effect = effect;
    }

    /**
     * 全屏闪光。
     *
     * @param color 颜色。默认白色 <code>0xffffff</code>。
     * @example
     * <listing version="3.0">
     * api.shine();
     * </listing>
     */
    public function shine(color:uint = 0xffffff):void {
        _effect.shine(color);
    }

    /**
     * 震动一段时间。
     *
     * @param powX 横向强度。默认 <code>0</code>。
     * @param powY 纵向强度。默认 <code>3</code>。
     * @param time 秒。默认 <code>0</code>。
     * @example
     * <listing version="3.0">
     * api.shake(0, 2);
     * </listing>
     */
    public function shake(powX:Number = 0, powY:Number = 3, time:Number = 0):void {
        _effect.shake(powX, powY, time);
    }

    /**
     * 开始持续震动。
     *
     * @param powX 横向强度。默认 <code>0</code>。
     * @param powY 纵向强度。默认 <code>3</code>。
     * @example
     * <listing version="3.0">
     * api.startShake(0, 3);
     * </listing>
     */
    public function startShake(powX:Number = 0, powY:Number = 3):void {
        _effect.startShake(powX, powY);
    }

    /**
     * 结束持续震动。
     *
     * @example
     * <listing version="3.0">
     * api.endShake();
     * </listing>
     */
    public function endShake():void {
        _effect.endShake();
    }

    /**
     * 开始残影。
     *
     * @param r 红。默认 <code>0</code>。
     * @param g 绿。默认 <code>0</code>。
     * @param b 蓝。默认 <code>0</code>。
     * @example
     * <listing version="3.0">
     * api.shadow(-200, -200, -200);
     * </listing>
     */
    public function shadow(r:int = 0, g:int = 0, b:int = 0):void {
        _effect.shadow(r, g, b);
    }

    /**
     * 结束残影。
     *
     * @example
     * <listing version="3.0">
     * api.endShadow();
     * </listing>
     */
    public function endShadow():void {
        _effect.endShadow();
    }

    /**
     * 冲刺特效。
     *
     * @param playSound 是否播音效。默认 <code>true</code>。
     * @example
     * <listing version="3.0">
     * api.dash();
     * </listing>
     */
    public function dash(playSound:Boolean = true):void {
        _effect.dash(playSound);
    }

    /**
     * 必杀演出。
     *
     * @param isSuper 是否超必杀。默认 <code>false</code>。
     * @param face 立绘 id。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.bisha(false, '一户1');
     * </listing>
     */
    public function bisha(isSuper:Boolean = false, face:String = null):void {
        _effect.bisha(isSuper, face);
    }

    /**
     * 结束必杀演出。
     *
     * @example
     * <listing version="3.0">
     * api.endBisha();
     * </listing>
     */
    public function endBisha():void {
        _effect.endBisha();
    }

    /**
     * 开始万解。
     *
     * @param face 立绘 id。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.startWanKai('一户万解');
     * </listing>
     */
    public function startWanKai(face:String = null):void {
        _effect.startBanKai(face);
    }

    /**
     * 结束万解。
     *
     * @example
     * <listing version="3.0">
     * api.endWanKai();
     * </listing>
     */
    public function endWanKai():void {
        _effect.endBanKai();
    }

    /**
     * 走路音效或幽步拖影。
     *
     * @example
     * <listing version="3.0">
     * api.walk();
     * </listing>
     */
    public function walk():void {
        _effect.walk();
    }

    /**
     * 地面跳跃特效。
     *
     * @example
     * <listing version="3.0">
     * api.jump();
     * </listing>
     */
    public function jump():void {
        _effect.jump();
    }

    /**
     * 空中跳跃特效。
     *
     * @example
     * <listing version="3.0">
     * api.jumpAir();
     * </listing>
     */
    public function jumpAir():void {
        _effect.jumpAir();
    }

    /**
     * 落地特效。
     *
     * @example
     * <listing version="3.0">
     * api.touchFloor();
     * </listing>
     */
    public function touchFloor():void {
        _effect.touchFloor();
    }

    /**
     * 击落地效果。
     *
     * @param type <code>0</code> 弹起，<code>1</code> 普通落地，<code>2</code> 重落地。
     * @param shakePow 震动强度。默认 <code>0</code>。
     * @example
     * <listing version="3.0">
     * api.hitFloor(1, 0);
     * </listing>
     */
    public function hitFloor(type:int, shakePow:Number = 0):void {
        _effect.hitFloor(type, shakePow);
    }

    /**
     * 慢放。
     *
     * @param time 秒。
     * @example
     * <listing version="3.0">
     * api.slowDown(1);
     * </listing>
     */
    public function slowDown(time:Number):void {
        _effect.slowDown(time);
    }

    /**
     * 灵压爆发。
     *
     * @example
     * <listing version="3.0">
     * api.energyExplode();
     * </listing>
     */
    public function energyExplode():void {
        _effect.energyExplode();
    }

    /**
     * 替身术。
     *
     * @example
     * <listing version="3.0">
     * api.replaceSkill();
     * </listing>
     */
    public function replaceSkill():void {
        _effect.replaceSkill();
    }

    /**
     * 开始幽步。
     *
     * @example
     * <listing version="3.0">
     * api.ghostStep();
     * </listing>
     */
    public function ghostStep():void {
        _effect.ghostStep();
    }

    /**
     * 结束幽步。
     *
     * @example
     * <listing version="3.0">
     * api.endGhostStep();
     * </listing>
     */
    public function endGhostStep():void {
        _effect.endGhostStep();
    }

    /**
     * 开始发光。
     *
     * @param color 颜色。默认白色 <code>0xffffff</code>，黄色 <code>0xffff00</code> 走另一套滤镜。
     * @example
     * <listing version="3.0">
     * api.startGlow();
     * </listing>
     */
    public function startGlow(color:uint = 0xffffff):void {
        _effect.startGlow(color);
    }

    /**
     * 结束发光。
     *
     * @example
     * <listing version="3.0">
     * api.endGlow();
     * </listing>
     */
    public function endGlow():void {
        _effect.endGlow();
    }

    /**
     * 添加跟随特效。
     *
     * @param mcName 特效元件名。
     * @param isUnderBody 是否画在身体下层。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * api.addFollowEffect('fx', false);
     * </listing>
     */
    public function addFollowEffect(mcName:String, isUnderBody:Boolean = false):void {
        _effect.addFollowEffect(mcName, isUnderBody);
    }

}
}
