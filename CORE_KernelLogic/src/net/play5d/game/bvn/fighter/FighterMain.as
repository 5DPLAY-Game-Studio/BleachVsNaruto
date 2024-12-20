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
import flash.display.MovieClip;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.ctrler.mosou_ctrls.MosouLogic;
import net.play5d.game.bvn.data.FighterVO;
import net.play5d.game.bvn.data.TeamVO;
import net.play5d.game.bvn.data.mosou.MosouEnemyVO;
import net.play5d.game.bvn.data.mosou.MosouFighterLogic;
import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
import net.play5d.game.bvn.fighter.ctrler.FighterBuffCtrler;
import net.play5d.game.bvn.fighter.ctrler.FighterCtrler;
import net.play5d.game.bvn.fighter.data.FighterActionState;
import net.play5d.game.bvn.fighter.data.FighterDefenseType;
import net.play5d.game.bvn.fighter.data.FighterSpecialFrame;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameSprite;

/**
 * 作为人物模板基类使用
 */
public class FighterMain extends BaseGameSprite {
    include '../../../../../../include/_INCLUDE_OVERRIDE_.as';

    public const fzqiMax:Number = 100;

    public function FighterMain(mainMc:MovieClip) {
        super(mainMc);

        introSaid = false;
        _area     = null;

        if (!mainMc) {
            ThrowError(Error, GetLang('debug.error.data.fighter_main.main_mc_is_null'));
        }
    }
    public var qi:Number    = 0;
    public var qiMax:Number = 300;
    public var energy:Number          = 100; //体力，关系到瞬步，防御
    public var energyMax:Number       = 100; //体力，关系到瞬步，防御
    public var energyOverLoad:Boolean = false; //体力超载
    public var customHpMax:int = 0; //自定义血量
    public var fzqi:Number      = 100; //辅助气
    public var speed:Number     = 6;
    public var jumpPower:Number = 15;

    public var isSteelBody:Boolean      = false; //刚身状态
    public var isSuperSteelBody:Boolean = false; //超级刚身状态

    public var data:FighterVO; //角色数据
    public var mosouPlayerData:MosouFighterVO; //无双模式时有效
    public var mosouEnemyData:MosouEnemyVO; //无双模式时有效

    public var airHitTimes:int = 1; //允许空中打几次
    public var jumpTimes:int   = 2; //允许跳几次

    public var actionState:int = FighterActionState.NORMAL;  //动作状态

    public var defenseType:int = FighterDefenseType.SWOARD; //防御类型

    public var lastHitVO:HitVO; //上一次攻击到其他角色的动作

    public var introSaid:Boolean = false; //是否播放过开场

    public var mosouLogic:MosouFighterLogic;
    //当前被攻击的数据
    public var hurtHit:HitVO;
    public var defenseHit:HitVO;
    public var targetTeams:Vector.<TeamVO>;
    private var _speed:Number   = 6;
    private var _buffCtrler:FighterBuffCtrler;
    private var _currentHurts:Vector.<HitVO>;
    private var _mosouPlayerLogic:MosouFighterLogic;
    private var _currentTarget:IGameSprite;
    private var _fighterCtrl:FighterCtrler;
    private var _energyAddGap:int;
    private var _explodeHitVO:HitVO;
    private var _explodeHitFrame:int;
    private var _explodeSteelFrame:int;
    private var _replaceSkillFrame:int;
    private var _speedBack:Number = 0;

    public override function set attackRate(value:Number):void {
        super.attackRate = value;
        if (_fighterCtrl && _fighterCtrl.hitModel) {
            _fighterCtrl.hitModel.setPowerRate(value);
        }
    }

    private var _colorTransform:ColorTransform;

    public function get colorTransform():ColorTransform {
        return _colorTransform;
    }

    public function set colorTransform(v:ColorTransform):void {
        _colorTransform                  = v;
        _mainMc.transform.colorTransform = v ? v : new ColorTransform();
    }

    public override function setActive(v:Boolean):void {
        super.setActive(v);
        if (!v && _fighterCtrl && _fighterCtrl.getEffectCtrl()) {
            _fighterCtrl.getEffectCtrl().clean();
        }
    }

    public override function destory(dispose:Boolean = true):void {
        if (!dispose) {
            return;
        }

        if (_fighterCtrl) {
            _fighterCtrl.destory();
            _fighterCtrl = null;
        }
        if (_mainMc) {
            _mainMc.filters = null;
            _mainMc.gotoAndStop(1);
        }
        if (_buffCtrler) {
            _buffCtrler.destory();
            _buffCtrler = null;
        }

        if (data) {
            data = null;
        }

        if (mosouEnemyData) {
            mosouEnemyData = null;
        }

        targetTeams    = null;
        _currentTarget = null;
        _currentHurts  = null;

        super.destory(dispose);
    }

    public override function renderAnimate():void {
        super.renderAnimate();

        if (_destoryed) {
            return;
        }

        renderEnergy();
        renderFzQi();

        if (_fighterCtrl) {
            _fighterCtrl.renderAnimate();
        }
        if (_explodeHitFrame > 0) {
            _explodeHitFrame--;
            if (_explodeHitFrame == 8) {
                idle();
                isAllowBeHit = false;
            }
            if (_explodeHitFrame <= 0) {
                _explodeHitVO = null;
                isAllowBeHit  = true;
            }
        }

        if (_explodeSteelFrame > 0) {
            _explodeSteelFrame--;
            _fighterCtrl.getMcCtrl().setSteelBody(true, true);
            if (_explodeSteelFrame <= 0) {
                _fighterCtrl.getMcCtrl().setSteelBody(false);
            }
        }

        if (_replaceSkillFrame > 0) {
            _replaceSkillFrame--;
            if (_replaceSkillFrame <= 0) {
                isAllowBeHit = true;
            }
        }
    }

    public override function render():void {
        super.render();

        if (_destoryed) {
            return;
        }

        if (_fighterCtrl) {
            _fighterCtrl.render();
        }
        if (_buffCtrler) {
            _buffCtrler.render();
        }

        if (hp < 0) {
            hp = 0;
        }
        if (hp > hpMax) {
            hp = hpMax;
        }

        if (qi < 0) {
            qi = 0;
        }
        if (qi > qiMax) {
            qi = qiMax;
        }

        if (fzqi < 0) {
            fzqi = 0;
        }
        if (fzqi > fzqiMax) {
            fzqi = fzqiMax;
        }
    }

    /**
     * 当前攻击的攻击数据 return [HitVO];
     */
    public override function getCurrentHits():Array {
        if (_explodeHitVO && _explodeHitFrame < 8) {
            return [_explodeHitVO];
        }
        return _fighterCtrl.getCurrentHits();
    }

    public override function getBodyArea():Rectangle {
//			if(!isAllowBeHit) return null;
        if (!_fighterCtrl) {
            return null;
        }
        return _fighterCtrl.getBodyArea();
    }

    /**
     * 攻击到其他人
     * @param target 被攻击对象
     */
    public override function hit(hitvo:HitVO, target:IGameSprite):void {
        super.hit(hitvo, target);
        lastHitVO = hitvo;

        var addqi:Number = 0;
        if (target is FighterMain) {
            if (hitvo.isBisha()) {
                addqi = hitvo.power * GameConfig.QI_ADD_HIT_BISHA_RATE;
            }
            else {
                addqi = hitvo.power * GameConfig.QI_ADD_HIT_RATE;
            }
            if (addqi > GameConfig.QI_ADD_HIT_MAX) {
                addqi = GameConfig.QI_ADD_HIT_MAX;
            }
        }

        addQi(addqi);
        GameLogic.hitTarget(hitvo, this, target);

    }

    /**
     * 被攻击
     * @param hitvo 攻击数据
     * @param hitRect 攻击相交区域
     */
    public override function beHit(hitvo:HitVO, hitRect:Rectangle = null):void {
        if (!isAllowBeHit) {
            return;
        }
        super.beHit(hitvo, hitRect);
        _fighterCtrl.getMcCtrl().beHit(hitvo, hitRect);

        var addqi:Number = hitvo.power * GameConfig.QI_ADD_HURT_RATE;
        if (addqi > GameConfig.QI_ADD_HURT_MAX) {
            addqi = GameConfig.QI_ADD_HURT_MAX;
        }
        addQi(addqi);

        if (actionState == FighterActionState.HURT_ING || actionState == FighterActionState.HURT_FLYING) {
            _currentHurts ||= new Vector.<HitVO>();
            _currentHurts.push(hitvo);
        }

    }

    public override function getArea():Rectangle {
        _area ||= getBodyArea();
        return _area;
    }

    public function changeColor(v:ColorTransform):void {
        _mainMc.transform.colorTransform = v;
    }

    public function resumeColor():void {
        _mainMc.transform.colorTransform = _colorTransform ? _colorTransform : new ColorTransform();
    }

    public function getMosouLogic():MosouFighterLogic {
        return _mosouPlayerLogic;
    }

    /**
     * 当前被打的攻击力总和
     */
    public function currentHurtDamage():int {
        if (!_currentHurts) {
            return 0;
        }
        var damage:int = 0;
        for each(var i:HitVO in _currentHurts) {
            damage += i.getDamage();
        }
        return damage;
    }

    /**
     * 最后一次被打的HITVO
     */
    public function getLastHurtHitVO():HitVO {
        if (!_currentHurts) {
            return null;
        }
        return _currentHurts[_currentHurts.length - 1];
    }

    public function hurtBreakHit():Boolean {
        for each(var i:HitVO in _currentHurts) {
            if (i.isBreakDef) {
                return true;
            }
        }
        return false;
    }

    public function clearHurtHits():void {
        _currentHurts = null;
    }

    public function getCtrler():FighterCtrler {
        return _fighterCtrl;
    }

    public function getBuffCtrl():FighterBuffCtrler {
        return _buffCtrler;
    }

    public function getCurrentTarget():IGameSprite {
        if (_currentTarget) {
            var bsp:BaseGameSprite = _currentTarget as BaseGameSprite;
            if (bsp && bsp.isAlive && bsp.getActive()) {
                return _currentTarget;
            }
        }

        var targets:Vector.<IGameSprite> = getTargets();
        var targetsOrder:Array           = [];
        if (targets && targets.length > 0) {

            for each(var i:IGameSprite in targets) {

                if (i.getBodyArea() == null) {
                    targetsOrder.push({fighter: i, order: 5});
                    continue;
                }

                if (i is FighterMain && (
                        i as FighterMain
                ).isAlive && i.getActive()) {
                    var msd:MosouEnemyVO = (
                            i as FighterMain
                    ).mosouEnemyData;
                    if (msd) {
                        if (msd.isBoss) {
                            targetsOrder.push({fighter: i, order: 0});
                        }
                        else {
                            targetsOrder.push({fighter: i, order: 1});
                        }
                    }
                    else {
                        targetsOrder.push({fighter: i, order: 0});
                    }
                }
                else if (i is BaseGameSprite && (
                        i as BaseGameSprite
                ).isAlive && i.getActive()) {
                    targetsOrder.push({fighter: i, order: 10});
                }
                else {
                    targetsOrder.push({fighter: i, order: 20});
                }
            }
            targetsOrder.sortOn('order', Array.NUMERIC);

            _currentTarget = targetsOrder[0].fighter;
        }

        return _currentTarget;
    }

    public function getTargets():Vector.<IGameSprite> {
        if (!targetTeams || targetTeams.length < 1) {
            return null;
        }
        var ts:Vector.<IGameSprite> = new Vector.<IGameSprite>();
        for (var i:int; i < targetTeams.length; i++) {
            ts = ts.concat(targetTeams[i].getAliveChildren());
        }
        return ts;
    }

    public function getMC():FighterMC {
        if (!_fighterCtrl) {
            return null;
        }
        if (!_fighterCtrl.getMcCtrl()) {
            return null;
        }
        return _fighterCtrl.getMcCtrl().getFighterMc();
    }

    public function initMosouFighter(v:MosouFighterVO):void {
        mosouPlayerData   = v;
        _mosouPlayerLogic = new MosouFighterLogic(v);
        updateProperties();
    }

    public function initMosouEnemy(v:MosouEnemyVO):void {
        mosouEnemyData = v;
    }

    public function updateProperties():void {
        if (!mosouPlayerData || !_mosouPlayerLogic) {
            return;
        }

        hp     = hpMax = _mosouPlayerLogic.getHP();
        qiMax  = _mosouPlayerLogic.getQI();
        energy = energyMax = _mosouPlayerLogic.getEnergy();

        qi = qiMax;

        if (_mosouPlayerLogic) {
            _mosouPlayerLogic.initFighterProps(this);
        }
    }

    public function setActionCtrl(ctrler:IFighterActionCtrl):void {
        if (_fighterCtrl) {
            _fighterCtrl.setActionCtrl(ctrler);
            ctrler.initlize();
        }
    }

//		public override function applayG(g:Number):void{
//			super.applayG(g);
//		}

    public function initlized():Boolean {
        return _fighterCtrl != null;
    }

    public function initlize():void {

        if (_fighterCtrl) {
            throw new Error('fighter 已完成化！');
            ThrowError(Error, GetLang('debug.error.data.fighter_main.fighter_ctrler_initialized'));
            return;
        }

        _fighterCtrl = new FighterCtrler();
        _buffCtrler  = new FighterBuffCtrler(this);

        _fighterCtrl.initFighter(this);

        _mainMc.gotoAndStop(data ? data.startFrame + 1 : 2);
    }

    public function onMcInited():void {
        if (_mosouPlayerLogic) {
            _mosouPlayerLogic.initFighterProps(this);
        }
        if (mosouEnemyData) {
            MosouLogic.I.initEnemyProps(this);
        }
    }

    public function initAttackAddDmg(normal:int, skill:int = 0, bisha:int = 0):void {
        if (!_fighterCtrl || !_fighterCtrl.hitModel) {
            return;
        }

        var hitObj:Object = _fighterCtrl.hitModel.getAll();
        for (var i:String in hitObj) {
            var hv:HitVO = hitObj[i];

            if (hv.isBisha()) {
                hv.powerAdd = bisha;
            }
            else if (hv.isSkill()) {
                hv.powerAdd = skill;
            }
            else {
                hv.powerAdd = normal;
            }

        }
    }

    public function jump():void {
        _g = 0;
        setVelocity(0, -jumpPower);
        setDamping(0, GameConfig.JUMP_DAMPING);
    }

    public function hasEnergy(v:Number, allowOverflow:Boolean = false):Boolean {

        if (energy >= v) {
            return true;
        }

        if (allowOverflow) {
            if (!energyOverLoad) {
                return true;
            }
        }

        return false;
    }

    public function useEnergy(v:Number):void {
        energy -= v;
        _energyAddGap = GameConfig.USE_ENERGY_CD * GameConfig.FPS_ANIMATE;
        if (energy < 0) {
            energy         = 0;
            energyOverLoad = true;
        }
    }

    public function useQi(v:Number):Boolean {
        if (qi < v) {
            return false;
        }
        qi -= v;
        return true;
    }

    public function addQi(v:Number):void {
        qi += v;
        if (qi > qiMax) {
            qi = qiMax;
        }
    }

    /**
     * 开场
     */
    public function sayIntro():void {
        introSaid = true;
        _fighterCtrl.getMcCtrl().sayIntro();
    }

    /**
     * 胜利动作
     */
    public function win():void {
        _fighterCtrl.getMcCtrl().doWin();
    }

    /**
     * 站立
     */
    public function idle():void {
        _fighterCtrl.getMcCtrl().idle();
    }

    /**
     * 失败动作
     */
    public function lose():void {
        _fighterCtrl.getMcCtrl().doLose();
    }

    /**
     * 攻击范围（用于AI）
     */
    public function getHitRange(id:String):Rectangle {
        return _fighterCtrl.getHitRange(id);
    }

    /**
     * 灵压爆发
     */
    public function energyExplode():void {
        _fighterCtrl.getEffectCtrl().energyExplode();
        _fighterCtrl.getMcCtrl().setSteelBody(true, true);
        _explodeHitVO             = new HitVO();
        var rect:Rectangle        = new Rectangle(-100, -200, 200, 210);
        _explodeHitVO.currentArea = _fighterCtrl.getCurrentRect(rect);
        _explodeHitVO.power       = 50;
        _explodeHitVO.hitx        = 15 * direct;
        _explodeHitVO.hitType     = 5;
        _explodeHitVO.hurtType    = 1;
        _explodeHitFrame          = 10;
        _explodeSteelFrame        = 60; //2s
        isAllowBeHit              = false;
    }

    /**
     * 替身术
     */
    public function replaceSkill():void {
        _fighterCtrl.getEffectCtrl().replaceSkill();
        move(250 * direct);
        idle();
        isAllowBeHit = false;
        super.render();
        renderAnimate();
        _fighterCtrl.setDirectToTarget();
        _replaceSkillFrame = 30;
    }

    public function hasWankai():Boolean {
        return _fighterCtrl.getMcCtrl().getFighterMc().checkFrame(FighterSpecialFrame.BANKAI);
    }

//		public function onChangeMC():void{
//			_area = _mainMc.getBounds(_mainMc);
//			_area = getBodyArea();
//		}

    public function die():void {
        hp      = 0;
        isAlive = false;

        if (!FighterActionState.isHurting(actionState) && actionState != FighterActionState.DEAD) {
            _fighterCtrl.getMcCtrl().getFighterMc().playHurtDown();
        }

    }

    /**
     * 复活
     */
    public function relive(reset:Boolean = false):void {
        isAlive = true;

        if (reset) {
            hp = hpMax;
            qi = 0;
        }

        idle();
    }

    /**
     * 无关模式的小兵
     */
    public function isMosouEnemy():Boolean {
        if (!mosouEnemyData) {
            return false;
        }
        return !mosouEnemyData.isBoss;
    }

    /**
     * 无关模式的BOSS
     */
    public function isMosouBoss():Boolean {
        if (!mosouEnemyData) {
            return false;
        }
        return mosouEnemyData.isBoss;
    }

    private function renderEnergy():void {
        if (_energyAddGap > 0) {
            _energyAddGap--;
            return;
        }
        if (energy < energyMax) {
            if (energyOverLoad) {
                energy += GameConfig.ENERGY_ADD_OVER_LOAD_PERFRAME;
                if (energy > GameConfig.ENERGY_ADD_OVER_LOAD_RESUME) {
                    energyOverLoad = false;
                }
            }
            else {
                if (actionState == FighterActionState.DEFENCE_ING) {
                    energy += GameConfig.ENERGY_ADD_DEFENSE;
                }
                else if (FighterActionState.isAttacking(actionState)) {
                    energy += GameConfig.ENERGY_ADD_ATTACKING;
                }
                else {
                    energy += GameConfig.ENERGY_ADD_NORMAL;
                }
            }
        }
    }

    private function renderFzQi():void {
        if (fzqi < fzqiMax) {
            fzqi += GameConfig.FUZHU_QI_ADD_PERFRAME;
        }
    }

}
}
