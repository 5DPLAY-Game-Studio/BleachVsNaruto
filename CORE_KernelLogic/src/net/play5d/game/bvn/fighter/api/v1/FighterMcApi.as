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
import flash.display.DisplayObject;

import net.play5d.game.bvn.fighter.api.FighterApiProxy;
import net.play5d.game.bvn.fighter.ctrler.FighterAttackerCtrler;
import net.play5d.game.bvn.fighter.ctrler.FighterMcCtrler;

/**
 * 角色时间轴第 1 版动作门面。
 *
 * <p>签名和默认值与当前 <code>$mc_ctrler</code> 的帧调用一致，调用原样转发。渲染、受击、开场胜负和 <code>doAction</code> 留在控制器。<code>effectCtrler</code> 返回构造时传入的特效门。没有的成员记入 <code>FighterApiProxy.records</code>。</p>
 *
 * @see FighterMcCtrler
 * @see FighterEffectApi
 */
public class FighterMcApi extends FighterApiProxy {

    /** @private */
    private var _mc:FighterMcCtrler;
    /** @private */
    private var _effect:FighterEffectApi;

    /**
     * 绑定要转发的动作控制器和特效门。
     *
     * @param mc 动作控制器。
     * @param effect 与 <code>$effect_ctrler</code> 相同的特效门。
     * @example
     * <listing version="3.0">
     * var api:FighterMcApi = new FighterMcApi(mc, effect);
     * </listing>
     */
    public function FighterMcApi(mc:FighterMcCtrler, effect:FighterEffectApi) {
        _mc     = mc;
        _effect = effect;
    }

    /**
     * 特效门。与注入给 <code>$effect_ctrler</code> 的是同一个实例。
     *
     * @return 特效门。
     * @example
     * <listing version="3.0">
     * api.effectCtrler.shine();
     * </listing>
     */
    public function get effectCtrler():FighterEffectApi {
        return _effect;
    }

    /**
     * 设置霸体。
     *
     * @param v 是否霸体。
     * @param isSuper 是否超级霸体。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * api.setSteelBody(true);
     * </listing>
     */
    public function setSteelBody(v:Boolean, isSuper:Boolean = false):void {
        _mc.setSteelBody(v, isSuper);
    }

    /**
     * 加气。
     *
     * @param qi 增加量。
     * @example
     * <listing version="3.0">
     * api.addQi(10);
     * </listing>
     */
    public function addQi(qi:Number):void {
        _mc.addQi(qi);
    }

    /**
     * 回到待机。
     *
     * @param frame 帧标签。默认 <code>null</code>。
     * @param isIgnoreAlive 是否忽略死亡。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * api.idle();
     * </listing>
     */
    public function idle(frame:String = null, isIgnoreAlive:Boolean = false):void {
        _mc.idle(frame, isIgnoreAlive);
    }

    /**
     * 循环播放。
     *
     * @param frame 帧标签。
     * @example
     * <listing version="3.0">
     * api.loop('走');
     * </listing>
     */
    public function loop(frame:String):void {
        _mc.loop(frame);
    }

    /**
     * 停止播放。
     *
     * @example
     * <listing version="3.0">
     * api.stop();
     * </listing>
     */
    public function stop():void {
        _mc.stop();
    }

    /**
     * 冲刺。
     *
     * @param speedPlus 速度加成。默认 <code>3</code>。
     * @example
     * <listing version="3.0">
     * api.dash();
     * </listing>
     */
    public function dash(speedPlus:Number = 3):void {
        _mc.dash(speedPlus);
    }

    /**
     * 结束冲刺。
     *
     * @param loseSpdPercent 速度保留比例。默认 <code>0.5</code>。
     * @example
     * <listing version="3.0">
     * api.dashStop();
     * </listing>
     */
    public function dashStop(loseSpdPercent:Number = 0.5):void {
        _mc.dashStop(loseSpdPercent);
    }

    /**
     * 登记全部地面动作。
     *
     * @example
     * <listing version="3.0">
     * api.setAllAct();
     * </listing>
     */
    public function setAllAct():void {
        _mc.setAllAct();
    }

    /**
     * 登记全部空中动作。
     *
     * @example
     * <listing version="3.0">
     * api.setAirAllAct();
     * </listing>
     */
    public function setAirAllAct():void {
        _mc.setAirAllAct();
    }

    /**
     * 设置能否空中移动。
     *
     * @param v 能否空中移动。
     * @example
     * <listing version="3.0">
     * api.setAirMove(true);
     * </listing>
     */
    public function setAirMove(v:Boolean):void {
        _mc.setAirMove(v);
    }

    /**
     * 设定行走。
     *
     * @example
     * <listing version="3.0">
     * api.setMove();
     * </listing>
     */
    public function setMove():void {
        _mc.setMove();
    }

    /**
     * 设定向左走。
     *
     * @example
     * <listing version="3.0">
     * api.setMoveLeft();
     * </listing>
     */
    public function setMoveLeft():void {
        _mc.setMoveLeft();
    }

    /**
     * 设定向右走。
     *
     * @example
     * <listing version="3.0">
     * api.setMoveRight();
     * </listing>
     */
    public function setMoveRight():void {
        _mc.setMoveRight();
    }

    /**
     * 设定防御。
     *
     * @example
     * <listing version="3.0">
     * api.setDefense();
     * </listing>
     */
    public function setDefense():void {
        _mc.setDefense();
    }

    /**
     * 设定跳跃。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.setJump();
     * </listing>
     */
    public function setJump(action:String = null):void {
        _mc.setJump(action);
    }

    /**
     * 设定小跳。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.setJumpQuick();
     * </listing>
     */
    public function setJumpQuick(action:String = null):void {
        _mc.setJumpQuick(action);
    }

    /**
     * 设定下跳。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.setJumpDown();
     * </listing>
     */
    public function setJumpDown(action:String = null):void {
        _mc.setJumpDown(action);
    }

    /**
     * 设定冲刺动作。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.setDash();
     * </listing>
     */
    public function setDash(action:String = null):void {
        _mc.setDash(action);
    }

    /**
     * 设定普攻。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.setAttack('砍1');
     * </listing>
     */
    public function setAttack(action:String = null):void {
        _mc.setAttack(action);
    }

    /**
     * 设定技能 1。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.setSkill1();
     * </listing>
     */
    public function setSkill1(action:String = null):void {
        _mc.setSkill1(action);
    }

    /**
     * 设定技能 2。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.setSkill2();
     * </listing>
     */
    public function setSkill2(action:String = null):void {
        _mc.setSkill2(action);
    }

    /**
     * 设定招式 1。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.setZhao1();
     * </listing>
     */
    public function setZhao1(action:String = null):void {
        _mc.setZhao1(action);
    }

    /**
     * 设定招式 2。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.setZhao2();
     * </listing>
     */
    public function setZhao2(action:String = null):void {
        _mc.setZhao2(action);
    }

    /**
     * 设定招式 3。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.setZhao3();
     * </listing>
     */
    public function setZhao3(action:String = null):void {
        _mc.setZhao3(action);
    }

    /**
     * 设定投技 1。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.setCatch1();
     * </listing>
     */
    public function setCatch1(action:String = null):void {
        _mc.setCatch1(action);
    }

    /**
     * 设定投技 2。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.setCatch2();
     * </listing>
     */
    public function setCatch2(action:String = null):void {
        _mc.setCatch2(action);
    }

    /**
     * 设定必杀。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @param qi 耗气。默认 <code>100</code>。
     * @example
     * <listing version="3.0">
     * api.setBisha();
     * </listing>
     */
    public function setBisha(action:String = null, qi:int = 100):void {
        _mc.setBisha(action, qi);
    }

    /**
     * 设定上必杀。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @param qi 耗气。默认 <code>100</code>。
     * @example
     * <listing version="3.0">
     * api.setBishaUP();
     * </listing>
     */
    public function setBishaUP(action:String = null, qi:int = 100):void {
        _mc.setBishaUP(action, qi);
    }

    /**
     * 设定超必杀。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @param qi 耗气。默认 <code>300</code>。
     * @example
     * <listing version="3.0">
     * api.setBishaSUPER();
     * </listing>
     */
    public function setBishaSUPER(action:String = null, qi:int = 300):void {
        _mc.setBishaSUPER(action, qi);
    }

    /**
     * 设定空中普攻。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.setAttackAIR();
     * </listing>
     */
    public function setAttackAIR(action:String = null):void {
        _mc.setAttackAIR(action);
    }

    /**
     * 设定空中技能。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.setSkillAIR();
     * </listing>
     */
    public function setSkillAIR(action:String = null):void {
        _mc.setSkillAIR(action);
    }

    /**
     * 设定空中必杀。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @param qi 耗气。默认 <code>100</code>。
     * @example
     * <listing version="3.0">
     * api.setBishaAIR();
     * </listing>
     */
    public function setBishaAIR(action:String = null, qi:int = 100):void {
        _mc.setBishaAIR(action, qi);
    }

    /**
     * 设定落地动作。
     *
     * @param action 帧标签。默认 <code>null</code>。
     * @param breakAct 落地是否打断当前动作。默认 <code>true</code>。
     * @example
     * <listing version="3.0">
     * api.setTouchFloor();
     * </listing>
     */
    public function setTouchFloor(action:String = null, breakAct:Boolean = true):void {
        _mc.setTouchFloor(action, breakAct);
    }

    /**
     * 设定万解动作。
     *
     * @example
     * <listing version="3.0">
     * api.setBankai();
     * </listing>
     */
    public function setBankai():void {
        _mc.setBankai();
    }

    /**
     * 设定碰到目标后跳转的动作。
     *
     * @param checker 检测区域名。
     * @param action 帧标签。
     * @example
     * <listing version="3.0">
     * api.setHitTarget('body', '砍2');
     * </listing>
     */
    public function setHitTarget(checker:String, action:String):void {
        _mc.setHitTarget(checker, action);
    }

    /**
     * 设定受击动作。
     *
     * @param action 帧标签。
     * @example
     * <listing version="3.0">
     * api.setHurtAction('hurt');
     * </listing>
     */
    public function setHurtAction(action:String):void {
        _mc.setHurtAction(action);
    }

    /**
     * 按朝向设速度。
     *
     * @param x 横向速度。默认 <code>0</code>。
     * @param y 纵向速度。默认 <code>0</code>。
     * @example
     * <listing version="3.0">
     * api.move(1, 0);
     * </listing>
     */
    public function move(x:Number = 0, y:Number = 0):void {
        _mc.move(x, y);
    }

    /**
     * 按速度比例设速度。
     *
     * @param x 横向比例。默认 <code>0</code>。
     * @param y 纵向比例。默认 <code>0</code>。
     * @example
     * <listing version="3.0">
     * api.movePercent(1, 0);
     * </listing>
     */
    public function movePercent(x:Number = 0, y:Number = 0):void {
        _mc.movePercent(x, y);
    }

    /**
     * 停止移动。
     *
     * @example
     * <listing version="3.0">
     * api.stopMove();
     * </listing>
     */
    public function stopMove():void {
        _mc.stopMove();
    }

    /**
     * 设置阻尼。
     *
     * @param x 横向阻尼。默认 <code>0</code>。
     * @param y 纵向阻尼。默认 <code>0</code>。
     * @example
     * <listing version="3.0">
     * api.damping(0, 0);
     * </listing>
     */
    public function damping(x:Number = 0, y:Number = 0):void {
        _mc.damping(x, y);
    }

    /**
     * 按速度比例设置阻尼。
     *
     * @param x 横向比例。默认 <code>0</code>。
     * @param y 纵向比例。默认 <code>0</code>。
     * @example
     * <listing version="3.0">
     * api.dampingPercent(0.5, 0);
     * </listing>
     */
    public function dampingPercent(x:Number = 0, y:Number = 0):void {
        _mc.dampingPercent(x, y);
    }

    /**
     * 结束当前动作。
     *
     * @example
     * <listing version="3.0">
     * api.endAct();
     * </listing>
     */
    public function endAct():void {
        _mc.endAct();
    }

    /**
     * 发射子弹。
     *
     * @param mcName 子弹元件名。
     * @param params 附加参数。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.fire('bullet');
     * </listing>
     */
    public function fire(mcName:String, params:Object = null):void {
        _mc.fire(mcName, params);
    }

    /**
     * 放出攻击体。
     *
     * @param mcName 攻击体元件名。
     * @param params 附加参数。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.addAttacker('atk');
     * </listing>
     */
    public function addAttacker(mcName:String, params:Object = null):void {
        _mc.addAttacker(mcName, params);
    }

    /**
     * 设置是否受重力。
     *
     * @param v 是否受重力。
     * @example
     * <listing version="3.0">
     * api.isApplyG(true);
     * </listing>
     */
    public function isApplyG(v:Boolean):void {
        _mc.isApplyG(v);
    }

    /**
     * 跳到帧并播放。
     *
     * @param frame 帧标签。
     * @example
     * <listing version="3.0">
     * api.gotoAndPlay('砍1');
     * </listing>
     */
    public function gotoAndPlay(frame:String):void {
        _mc.gotoAndPlay(frame);
    }

    /**
     * 跳到帧并停止。
     *
     * @param frame 帧标签。
     * @example
     * <listing version="3.0">
     * api.gotoAndStop('砍1');
     * </listing>
     */
    public function gotoAndStop(frame:String):void {
        _mc.gotoAndStop(frame);
    }

    /**
     * 击飞自身。
     *
     * @param x 横向速度。
     * @param y 纵向速度。
     * @example
     * <listing version="3.0">
     * api.hurtFly(5, -10);
     * </listing>
     */
    public function hurtFly(x:Number, y:Number):void {
        _mc.hurtFly(x, y);
    }

    /**
     * 移动一个显示对象。
     *
     * @param mmc 要移动的显示对象。
     * @param x 横向位置。默认 <code>null</code>。
     * @param y 纵向位置。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.moveMC(clip, 0, 0);
     * </listing>
     */
    public function moveMC(mmc:DisplayObject, x:Object = null, y:Object = null):void {
        _mc.moveMC(mmc, x, y);
    }

    /**
     * 刚刚命中则跳帧。
     *
     * @param hitid 攻击 id，不带 atm。
     * @param frame 命中后的帧标签。
     * @param noIdle 未命中时是否回待机。默认 <code>false</code>。
     * @param inCludeDefense 防御是否也算命中。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * api.justHitToPlay('tk', '砍2');
     * </listing>
     */
    public function justHitToPlay(hitid:String, frame:String, noIdle:Boolean = false,
                                  inCludeDefense:Boolean = false
    ):void {
        _mc.justHitToPlay(hitid, frame, noIdle, inCludeDefense);
    }

    /**
     * 按名字取攻击体控制器。
     *
     * @param name 攻击体名。
     * @return 攻击体控制器。没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.getAttacker('atk');
     * </listing>
     */
    public function getAttacker(name:String):FighterAttackerCtrler {
        return _mc.getAttacker(name);
    }

    /**
     * 移动攻击目标。参数为 <code>null</code> 时结束移动。
     *
     * @param params 位置、跟随元件和速度。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.moveTarget(null);
     * </listing>
     */
    public function moveTarget(params:Object = null):void {
        _mc.moveTarget(params);
    }

}
}
