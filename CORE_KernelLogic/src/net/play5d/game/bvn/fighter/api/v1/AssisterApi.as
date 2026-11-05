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
import flash.display.MovieClip;

import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.api.FighterApiProxy;
import net.play5d.game.bvn.fighter.ctrler.AssisterCtrler;
import net.play5d.game.bvn.fighter.models.FighterHitModel;
import net.play5d.game.bvn.interfaces.IGameSprite;

/**
 * 辅助时间轴第 1 版门面。
 *
 * <p>由 <code>setAssistCtrler</code> 注入。签名和默认值与当前 <code>AssisterCtrler</code> 的时间轴调用一致。<code>owner_mc_ctrler</code> 和 <code>owner_fighter_ctrler</code> 返回主人已经注入的门面。没有的成员记入 <code>FighterApiProxy.records</code>。</p>
 *
 * @see AssisterCtrler
 */
public class AssisterApi extends FighterApiProxy {

    /** @private */
    private var _ctrler:AssisterCtrler;
    /** @private */
    private var _effect:FighterEffectApi;
    /** @private */
    private var _camera:FighterCameraApi;

    /**
     * 绑定辅助控制器和它自己的特效、镜头门。
     *
     * @param ctrler 辅助控制器。
     * @param effect 绑定在该辅助上的特效门。
     * @param camera 绑定在该辅助上的镜头门。
     * @example
     * <listing version="3.0">
     * var api:AssisterApi = new AssisterApi(ctrler, effect, camera);
     * </listing>
     */
    public function AssisterApi(ctrler:AssisterCtrler, effect:FighterEffectApi, camera:FighterCameraApi) {
        _ctrler = ctrler;
        _effect = effect;
        _camera = camera;
    }

    /**
     * 特效门。
     *
     * @return 该辅助自己的特效门。
     * @example
     * <listing version="3.0">
     * api.effect.shine();
     * </listing>
     */
    public function get effect():FighterEffectApi {
        return _effect;
    }

    /**
     * 镜头门。
     *
     * @return 该辅助自己的镜头门。
     * @example
     * <listing version="3.0">
     * api.camera.focusSelf();
     * </listing>
     */
    public function get camera():FighterCameraApi {
        return _camera;
    }

    /**
     * 判定表。与控制器上的是同一个对象。
     *
     * @return 判定表。
     * @example
     * <listing version="3.0">
     * api.hitModel;
     * </listing>
     */
    public function get hitModel():FighterHitModel {
        return _ctrler.hitModel;
    }

    /** @private */
    public function set hitModel(v:FighterHitModel):void {
        _ctrler.hitModel = v;
    }

    /**
     * 碰到目标后要播的动作。
     *
     * @return 帧标签。
     * @example
     * <listing version="3.0">
     * api.hitTargetAction;
     * </listing>
     */
    public function get hitTargetAction():String {
        return _ctrler.hitTargetAction;
    }

    /** @private */
    public function set hitTargetAction(v:String):void {
        _ctrler.hitTargetAction = v;
    }

    /**
     * 碰到目标时使用的检测区名字。
     *
     * @return 检测区名字。
     * @example
     * <listing version="3.0">
     * api.hitTargetChecker;
     * </listing>
     */
    public function get hitTargetChecker():String {
        return _ctrler.hitTargetChecker;
    }

    /** @private */
    public function set hitTargetChecker(v:String):void {
        _ctrler.hitTargetChecker = v;
    }

    /**
     * 主人的动作门面。
     *
     * <p>主人时间轴上已有 <code>$mc_ctrler</code> 时返回它。没有注入时退回主人的动作控制器。</p>
     *
     * @return 主人的动作入口。没有主人时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.owner_mc_ctrler;
     * </listing>
     */
    public function get owner_mc_ctrler():* {
        return ownerInjected('$mc_ctrler');
    }

    /**
     * 主人的角色门面。
     *
     * <p>主人时间轴上已有 <code>$fighter_ctrler</code> 时返回它。没有注入时退回主人的角色控制器。</p>
     *
     * @return 主人的角色入口。没有主人时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.owner_fighter_ctrler;
     * </listing>
     */
    public function get owner_fighter_ctrler():* {
        return ownerInjected('$fighter_ctrler');
    }

    /**
     * 获取目标。
     *
     * @return 主人的当前目标。没有主人时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.getTarget();
     * </listing>
     */
    public function getTarget():IGameSprite {
        return _ctrler.getTarget();
    }

    /**
     * 获取全部目标。当前实现固定返回 <code>null</code>。
     *
     * @param isOnlyAlive 是否只要存活目标。默认 <code>true</code>。
     * @return 目标列表。
     * @example
     * <listing version="3.0">
     * api.getTargetAll();
     * </listing>
     */
    public function getTargetAll(isOnlyAlive:Boolean = true):Vector.<IGameSprite> {
        return _ctrler.getTargetAll(isOnlyAlive);
    }

    /**
     * 获取主人。
     *
     * @return 主人。
     * @example
     * <listing version="3.0">
     * api.getOwner();
     * </listing>
     */
    public function getOwner():IGameSprite {
        return _ctrler.getOwner();
    }

    /**
     * 获取最上层主人。当前实现固定返回 <code>null</code>。
     *
     * @return 最上层主人。
     * @example
     * <listing version="3.0">
     * api.getOwnerTop();
     * </listing>
     */
    public function getOwnerTop():IGameSprite {
        return _ctrler.getOwnerTop();
    }

    /**
     * 获取自身。
     *
     * @return 辅助自身。
     * @example
     * <listing version="3.0">
     * api.getSelf();
     * </listing>
     */
    public function getSelf():IGameSprite {
        return _ctrler.getSelf();
    }

    /**
     * 设置是否受重力。
     *
     * @param v 是否受重力。
     * @example
     * <listing version="3.0">
     * api.setApplyG(true);
     * </listing>
     */
    public function setApplyG(v:Boolean):void {
        _ctrler.setApplyG(v);
    }

    /**
     * 结束本次出场。
     *
     * @param showEffect 是否播退场特效。默认 <code>true</code>。
     * @example
     * <listing version="3.0">
     * api.finish();
     * </listing>
     */
    public function finish(showEffect:Boolean = true):void {
        _ctrler.finish(showEffect);
    }

    /**
     * 登记一条攻击数据。
     *
     * @param id 攻击键。
     * @param obj 攻击数据。
     * @example
     * <listing version="3.0">
     * api.defineAction('atm1', {power: 30});
     * </listing>
     */
    public function defineAction(id:String, obj:Object):void {
        _ctrler.defineAction(id, obj);
    }

    /**
     * 结束攻击标记。
     *
     * @example
     * <listing version="3.0">
     * api.endAct();
     * </listing>
     */
    public function endAct():void {
        _ctrler.endAct();
    }

    /**
     * 移到主人的当前目标。
     *
     * @param x 横向偏移。默认 <code>null</code>，表示不改 X。
     * @param y 纵向偏移。默认 <code>null</code>，表示不改 Y。
     * @param setDirect 是否面向目标。默认 <code>true</code>。
     * @example
     * <listing version="3.0">
     * api.moveToTarget(0, 0, true);
     * </listing>
     */
    public function moveToTarget(x:Object = null, y:Object = null, setDirect:Boolean = true):void {
        _ctrler.moveToTarget(x, y, setDirect);
    }

    /**
     * 面向当前目标。
     *
     * @example
     * <listing version="3.0">
     * api.setDirectToTarget();
     * </listing>
     */
    public function setDirectToTarget():void {
        _ctrler.setDirectToTarget();
    }

    /**
     * 按朝向设速度。
     *
     * @param x 横向速度。默认 <code>0</code>。
     * @param y 纵向速度。默认 <code>0</code>。
     * @example
     * <listing version="3.0">
     * api.move(0, 0);
     * </listing>
     */
    public function move(x:Number = 0, y:Number = 0):void {
        _ctrler.move(x, y);
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
        _ctrler.damping(x, y);
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
        _ctrler.stop();
    }

    /**
     * 跳到帧并播放。
     *
     * @param frame 帧标签。
     * @example
     * <listing version="3.0">
     * api.gotoAndPlay('atk');
     * </listing>
     */
    public function gotoAndPlay(frame:String):void {
        _ctrler.gotoAndPlay(frame);
    }

    /**
     * 跳到帧并停止。
     *
     * @param frame 帧标签。
     * @example
     * <listing version="3.0">
     * api.gotoAndStop('atk');
     * </listing>
     */
    public function gotoAndStop(frame:String):void {
        _ctrler.gotoAndStop(frame);
    }

    /**
     * 落地后要播的帧。
     *
     * @param frame 帧标签。
     * @example
     * <listing version="3.0">
     * api.setTouchFloor('land');
     * </listing>
     */
    public function setTouchFloor(frame:String):void {
        _ctrler.setTouchFloor(frame);
    }

    /**
     * 刚刚命中则跳帧。
     *
     * @param hitId 攻击 id。
     * @param playFrame 命中后的帧标签。默认 <code>null</code>，表示不跳帧。
     * @param includeDefense 防御是否也算命中。默认 <code>false</code>。
     * @return 刚刚命中时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * api.justHit('atm1');
     * </listing>
     */
    public function justHit(hitId:String, playFrame:String = null, includeDefense:Boolean = false):Boolean {
        return _ctrler.justHit(hitId, playFrame, includeDefense);
    }

    /**
     * 设定碰到目标后跳转的动作。
     *
     * @param checker 检测区名字。
     * @param action 帧标签。
     * @example
     * <listing version="3.0">
     * api.setHitTarget('body', 'atk2');
     * </listing>
     */
    public function setHitTarget(checker:String, action:String):void {
        _ctrler.setHitTarget(checker, action);
    }

    /**
     * 从场上移除。
     *
     * @example
     * <listing version="3.0">
     * api.removeSelf();
     * </listing>
     */
    public function removeSelf():void {
        _ctrler.removeSelf();
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
        _ctrler.fire(mcName, params);
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
        _ctrler.addAttacker(mcName, params);
    }

    /**
     * 检测区是否碰到主人。
     *
     * @param mcName 检测区名字。
     * @return 相交时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * api.checkHitOwner('body');
     * </listing>
     */
    public function checkHitOwner(mcName:String):Boolean {
        return _ctrler.checkHitOwner(mcName);
    }

    /**
     * @private 主人时间轴上的门面。没有注入时退回控制器。
     */
    private function ownerInjected(prop:String):* {
        var owner:FighterMain = _ctrler.getOwner() as FighterMain;
        if (!owner || !owner.getCtrler()) {
            return null;
        }

        var mc:MovieClip = owner.mc;
        if (mc) {
            var port:* = mc[prop];
            if (port != undefined && port != null) {
                return port;
            }
        }
        if (prop == '$mc_ctrler') {
            return owner.getCtrler().getMcCtrl();
        }

        return owner.getCtrler();
    }

}
}
