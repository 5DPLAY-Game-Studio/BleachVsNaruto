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
import flash.display.MovieClip;
import flash.geom.Rectangle;

import net.play5d.game.bvn.fighter.api.FighterApiProxy;
import net.play5d.game.bvn.fighter.ctrler.FighterCtrler;
import net.play5d.game.bvn.fighter.models.FighterHitModel;
import net.play5d.game.bvn.interfaces.IGameSprite;

/**
 * 角色时间轴第 1 版角色门面。
 *
 * <p>签名和默认值与当前 <code>$fighter_ctrler</code> 一致，调用原样转发。时间轴起始帧的 <code>initMc</code> 也从这里转到控制器。销毁、渲染和控制器取值留在 <code>FighterCtrler</code>。没有的成员记入 <code>FighterApiProxy.records</code>。</p>
 *
 * @see FighterCtrler
 */
public class FighterApi extends FighterApiProxy {

    /** @private */
    private var _fighter:FighterCtrler;

    /**
     * 绑定要转发的角色控制器。
     *
     * @param fighter 角色控制器。
     * @example
     * <listing version="3.0">
     * var api:FighterApi = new FighterApi(fighter);
     * </listing>
     */
    public function FighterApi(fighter:FighterCtrler) {
        _fighter = fighter;
    }

    /**
     * 装上动作元件并停到待机。时间轴在起始帧调用。
     *
     * @param mc 动作元件。
     * @example
     * <listing version="3.0">
     * api.initMc(mc);
     * </listing>
     */
    public function initMc(mc:MovieClip):void {
        _fighter.initMc(mc);
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
        return _fighter.hitModel;
    }

    /** @private */
    public function set hitModel(v:FighterHitModel):void {
        _fighter.hitModel = v;
    }

    /**
     * 当前血量。写入时同时写入上限。
     *
     * @return 当前血量。
     * @example
     * <listing version="3.0">
     * api.hp = 1000;
     * </listing>
     */
    public function get hp():Number {
        return _fighter.hp;
    }

    /** @private */
    public function set hp(v:Number):void {
        _fighter.hp = v;
    }

    /**
     * 灵压上限。读取的是上限，写入时同时写入当前灵压。
     *
     * @return 灵压上限。
     * @example
     * <listing version="3.0">
     * api.energy = 100;
     * </listing>
     */
    public function get energy():Number {
        return _fighter.energy;
    }

    /** @private */
    public function set energy(v:Number):void {
        _fighter.energy = v;
    }

    /**
     * 移动速度。
     *
     * @return 移动速度。
     * @example
     * <listing version="3.0">
     * api.speed = 8;
     * </listing>
     */
    public function get speed():Number {
        return _fighter.speed;
    }

    /** @private */
    public function set speed(v:Number):void {
        _fighter.speed = v;
    }

    /**
     * 跳跃力。
     *
     * @return 跳跃力。
     * @example
     * <listing version="3.0">
     * api.jumpPower = 20;
     * </listing>
     */
    public function get jumpPower():Number {
        return _fighter.jumpPower;
    }

    /** @private */
    public function set jumpPower(v:Number):void {
        _fighter.jumpPower = v;
    }

    /**
     * 体格。
     *
     * @return 体格。
     * @example
     * <listing version="3.0">
     * api.heavy = 1;
     * </listing>
     */
    public function get heavy():Number {
        return _fighter.heavy;
    }

    /** @private */
    public function set heavy(v:Number):void {
        _fighter.heavy = v;
    }

    /**
     * 防御类型。
     *
     * @return 防御类型。
     * @example
     * <listing version="3.0">
     * api.defenseType = 0;
     * </listing>
     */
    public function get defenseType():int {
        return _fighter.defenseType;
    }

    /** @private */
    public function set defenseType(v:int):void {
        _fighter.defenseType = v;
    }

    /**
     * 自身显示对象。
     *
     * @return 自身显示对象。
     * @example
     * <listing version="3.0">
     * api.self;
     * </listing>
     */
    public function get self():DisplayObject {
        return _fighter.self;
    }

    /**
     * 当前目标的显示对象。没有目标时为 <code>null</code>。
     *
     * @return 目标显示对象。
     * @example
     * <listing version="3.0">
     * api.target;
     * </listing>
     */
    public function get target():DisplayObject {
        return _fighter.target;
    }

    /**
     * 获取目标。当前实现固定返回 <code>null</code>。
     *
     * @return 目标精灵。
     * @example
     * <listing version="3.0">
     * api.getTarget();
     * </listing>
     */
    public function getTarget():IGameSprite {
        return _fighter.getTarget();
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
        return _fighter.getTargetAll(isOnlyAlive);
    }

    /**
     * 获取主人。当前实现固定返回 <code>null</code>。
     *
     * @return 主人。
     * @example
     * <listing version="3.0">
     * api.getOwner();
     * </listing>
     */
    public function getOwner():IGameSprite {
        return _fighter.getOwner();
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
        return _fighter.getOwnerTop();
    }

    /**
     * 获取自身精灵。
     *
     * @return 自身精灵。
     * @example
     * <listing version="3.0">
     * api.getSelf();
     * </listing>
     */
    public function getSelf():IGameSprite {
        return _fighter.getSelf();
    }

    /**
     * 加血。
     *
     * @param v 增加量。
     * @example
     * <listing version="3.0">
     * api.addHp(100);
     * </listing>
     */
    public function addHp(v:Number):void {
        _fighter.addHp(v);
    }

    /**
     * 按上限比例加血。
     *
     * @param v 比例。
     * @example
     * <listing version="3.0">
     * api.addHpPercent(0.1);
     * </listing>
     */
    public function addHpPercent(v:Number):void {
        _fighter.addHpPercent(v);
    }

    /**
     * 扣血。
     *
     * @param v 扣除量。
     * @example
     * <listing version="3.0">
     * api.loseHp(100);
     * </listing>
     */
    public function loseHp(v:Number):void {
        _fighter.loseHp(v);
    }

    /**
     * 按上限比例扣血。
     *
     * @param v 比例。
     * @example
     * <listing version="3.0">
     * api.loseHpPercent(0.1);
     * </listing>
     */
    public function loseHpPercent(v:Number):void {
        _fighter.loseHpPercent(v);
    }

    /**
     * 读取当前灵压。
     *
     * @return 当前灵压。
     * @example
     * <listing version="3.0">
     * api.getEnergy();
     * </listing>
     */
    public function getEnergy():Number {
        return _fighter.getEnergy();
    }

    /**
     * 灵压是否过载。
     *
     * @return 过载时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * api.getEnergyOverload();
     * </listing>
     */
    public function getEnergyOverload():Boolean {
        return _fighter.getEnergyOverload();
    }

    /**
     * 消耗灵压。
     *
     * @param v 消耗量。
     * @example
     * <listing version="3.0">
     * api.loseEnergy(30);
     * </listing>
     */
    public function loseEnergy(v:Number):void {
        _fighter.loseEnergy(v);
    }

    /**
     * 消耗气。
     *
     * @param v 消耗量。
     * @example
     * <listing version="3.0">
     * api.loseQi(100);
     * </listing>
     */
    public function loseQi(v:Number):void {
        _fighter.loseQi(v);
    }

    /**
     * 当前目标精灵。没有目标时为 <code>null</code>。
     *
     * @return 目标精灵。
     * @example
     * <listing version="3.0">
     * api.getTargetSP();
     * </listing>
     */
    public function getTargetSP():IGameSprite {
        return _fighter.getTargetSP();
    }

    /**
     * 当前目标的动作状态。没有目标时为普通状态。
     *
     * @return 动作状态。
     * @example
     * <listing version="3.0">
     * api.getTargetState();
     * </listing>
     */
    public function getTargetState():int {
        return _fighter.getTargetState();
    }

    /**
     * 设置目标速度。
     *
     * @param x 横向速度。
     * @param y 纵向速度。
     * @example
     * <listing version="3.0">
     * api.setTargetVelocity(0, -10);
     * </listing>
     */
    public function setTargetVelocity(x:Number, y:Number):void {
        _fighter.setTargetVelocity(x, y);
    }

    /**
     * 设置目标阻尼。
     *
     * @param x 横向阻尼。
     * @param y 纵向阻尼。
     * @example
     * <listing version="3.0">
     * api.setTargetDamping(0.5, 0);
     * </listing>
     */
    public function setTargetDamping(x:Number, y:Number):void {
        _fighter.setTargetDamping(x, y);
    }

    /**
     * 目标是否落在给定范围内。
     *
     * @param rx 横向区间。默认 <code>null</code>，表示不限制。
     * @param ry 纵向区间。默认 <code>null</code>，表示不限制。
     * @return 在范围内时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * api.targetInRange([0, 200], [-50, 50]);
     * </listing>
     */
    public function targetInRange(rx:Array = null, ry:Array = null):Boolean {
        return _fighter.targetInRange(rx, ry);
    }

    /**
     * 是否刚刚命中指定攻击。
     *
     * @param hitId 攻击 id。
     * @param includeDefense 是否把防御也算上。默认 <code>false</code>。
     * @return 刚刚命中时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * api.justHit('tk');
     * </listing>
     */
    public function justHit(hitId:String, includeDefense:Boolean = false):Boolean {
        return _fighter.justHit(hitId, includeDefense);
    }

    /**
     * 登记一条攻击数据。
     *
     * @param id 攻击键。
     * @param obj 攻击数据。
     * @example
     * <listing version="3.0">
     * api.defineAction('tk', {power: 30});
     * </listing>
     */
    public function defineAction(id:String, obj:Object):void {
        _fighter.defineAction(id, obj);
    }

    /**
     * 登记必杀立绘。
     *
     * @param id 立绘 id。
     * @param face 库链接类。
     * @example
     * <listing version="3.0">
     * api.defineBishaFace('一户1', faceClass);
     * </listing>
     */
    public function defineBishaFace(id:String, face:Class):void {
        _fighter.defineBishaFace(id, face);
    }

    /**
     * 登记受击音。
     *
     * @param params 一个或多个库里的声音类。
     * @example
     * <listing version="3.0">
     * api.defineHurtSound(hurtSnd);
     * </listing>
     */
    public function defineHurtSound(...params):void {
        _fighter.defineHurtSound.apply(null, params);
    }

    /**
     * 登记击飞音。
     *
     * @param params 一个或多个库里的声音类。
     * @example
     * <listing version="3.0">
     * api.defineHurtFlySound(flySnd);
     * </listing>
     */
    public function defineHurtFlySound(...params):void {
        _fighter.defineHurtFlySound.apply(null, params);
    }

    /**
     * 登记死亡音。
     *
     * @param params 一个或多个库里的声音类。
     * @example
     * <listing version="3.0">
     * api.defineDieSound(dieSnd);
     * </listing>
     */
    public function defineDieSound(...params):void {
        _fighter.defineDieSound.apply(null, params);
    }

    /**
     * 当前帧的攻击数据。
     *
     * @return 攻击数据列表。
     * @example
     * <listing version="3.0">
     * api.getCurrentHits();
     * </listing>
     */
    public function getCurrentHits():Array {
        return _fighter.getCurrentHits();
    }

    /**
     * 当前受击区域。
     *
     * @return 世界坐标矩形。没有区域时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.getBodyArea();
     * </listing>
     */
    public function getBodyArea():Rectangle {
        return _fighter.getBodyArea();
    }

    /**
     * 按名字取检测矩形。
     *
     * @param name 检测区域名。
     * @return 世界坐标矩形。没有区域时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.getHitCheckRect('hit_check');
     * </listing>
     */
    public function getHitCheckRect(name:String):Rectangle {
        return _fighter.getHitCheckRect(name);
    }

    /**
     * 把本地矩形换成世界坐标。
     *
     * @param rect 本地矩形。
     * @param cacheId 缓存键。默认 <code>null</code>。
     * @return 世界坐标矩形。
     * @example
     * <listing version="3.0">
     * api.getCurrentRect(rect, 'body');
     * </listing>
     */
    public function getCurrentRect(rect:Rectangle, cacheId:String = null):Rectangle {
        return _fighter.getCurrentRect(rect, cacheId);
    }

    /**
     * 进入万解。
     *
     * @param frame 要停的帧。默认 <code>0</code>，表示下一帧。
     * @example
     * <listing version="3.0">
     * api.doBanKai();
     * </listing>
     */
    public function doBanKai(frame:int = 0):void {
        _fighter.doBanKai(frame);
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
        _fighter.setDirectToTarget();
    }

    /**
     * 按朝向平移一次。
     *
     * @param x 横向距离。默认 <code>0</code>。
     * @param y 纵向距离。默认 <code>0</code>。
     * @example
     * <listing version="3.0">
     * api.moveOnce(0, 0);
     * </listing>
     */
    public function moveOnce(x:Number = 0, y:Number = 0):void {
        _fighter.moveOnce(x, y);
    }

    /**
     * 移到当前目标。
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
        _fighter.moveToTarget(x, y, setDirect);
    }

    /**
     * 设置能否穿人。
     *
     * @param v 能否穿人。
     * @example
     * <listing version="3.0">
     * api.setCross(true);
     * </listing>
     */
    public function setCross(v:Boolean):void {
        _fighter.setCross(v);
    }

    /**
     * 按攻击 id 取打击范围。
     *
     * @param id 攻击 id。
     * @return 世界坐标矩形。没有区域时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * api.getHitRange('tk');
     * </listing>
     */
    public function getHitRange(id:String):Rectangle {
        return _fighter.getHitRange(id);
    }

}
}
