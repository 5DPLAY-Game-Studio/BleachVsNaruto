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

package net.play5d.game.bvn.interfaces {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.events.EventDispatcher;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.media.SoundTransform;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.GameRender;
import net.play5d.game.bvn.data.vos.TeamVO;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.kyo.utils.KyoDisplayUtils;
import net.play5d.kyo.utils.UUID;

import net.play5d.kyo.utils.KyoMath;

/**
 * 可移动、受力和挨打的游戏精灵基类。
 *
 * <p>坐标先记在自身，<code>render</code> 或 <code>updatePosition</code> 才写到影片。
 * 构造时没有影片，区域是 null，之后读写影片会抛错。<code>destroy</code> 之后渲染直接返回；参数为 true 时停掉并丢掉影片。
 * 位移会乘当前速度比率。阻尼分量大于 0 时才把对应的力往 0 收。<code>setVelocity</code> 会把阻尼清成 0。
 * <code>setDamping</code> 和 <code>setVec2</code> 的阻尼会乘默认速度比，<code>addDamping</code> 和单轴写入不会。
 * 重力关掉，或竖直速度小于 0 时，已累计的重力清成 0 并返回。<code>setInAir(false)</code> 把重力设成 <code>G_ON_FLOOR</code>。
 * <code>loseHp</code> 扣完小于 0 则血量不动。<code>addHp</code> 可以减过 0，只在超过上限时封顶。
 * 延时回调在同一轮里删除已到期的项，紧跟着的下一项可能被跳过。销毁后不再调用。
 * <code>getArea</code> 每次返回同一块矩形。写入 <code>scale</code> 时影片横竖缩放都变成这个数，朝向先前写在 <code>scaleX</code> 上的倍数会被盖掉。</p>
 *
 * @see IGameSprite
 */
public class BaseGameSprite extends EventDispatcher implements IGameSprite {

    /**
     * 记下影片，并用它相对自己的边界作为区域。
     *
     * @param mainmc 主影片。null 时区域留空。
     */
    public function BaseGameSprite(mainmc:MovieClip) {
        _mainMc = mainmc;
        if (_mainMc) {
            _area = _mainMc.getBounds(_mainMc);
        }
    }
    /**
     * 是否在空中。
     *
     * @default false
     */
    public var isInAir:Boolean;
    /**
     * 是否站在底层地面上。
     *
     * @default false
     */
    public var isTouchBottom:Boolean;
    /**
     * 是否可以被打。
     *
     * @default true
     */
    public var isAllowBeHit:Boolean       = true;
    /**
     * 是否穿过其他角色。
     *
     * @default false
     */
    public var isCross:Boolean            = false;
    /**
     * 是否接受版边攻击造成的反向推动。
     *
     * @default true
     */
    public var isAllowReversePush:Boolean = true;
    /**
     * 是否还活着。<code>destroy</code> 会写成 false。
     *
     * @default true
     */
    public var isAlive:Boolean            = true;
    /**
     * 是否允许 <code>loseHp</code> 扣血。
     *
     * @default true
     */
    public var isAllowLoseHP:Boolean      = true;
    /**
     * 是否累计并施加重力。
     *
     * @default true
     */
    public var isApplyG:Boolean           = true;
    /**
     * 重量，供角色碰撞使用。
     *
     * @default 2
     */
    public var heavy:Number               = 2;
    /**
     * 当前血量。初始等于 <code>GameConfig.FIGHTER_HP_MAX</code>。
     *
     * @default 1000
     */
    public var hp:Number                  = GameConfig.FIGHTER_HP_MAX;
    /**
     * 血量上限。初始等于 <code>GameConfig.FIGHTER_HP_MAX</code>。
     *
     * @default 1000
     */
    public var hpMax:Number               = GameConfig.FIGHTER_HP_MAX;
    /**
     * 防御力。<code>loseHp</code> 会先减掉这个数。
     *
     * @default 0
     */
    public var defense:Number             = 0;
    /**
     * 是否允许穿出地图左右边界。
     *
     * @default false
     */
    public var isAllowCrossX:Boolean      = false;
    /**
     * 是否允许穿出地图底边。
     *
     * @default false
     */
    public var isAllowCrossBottom:Boolean = false;
    /**
     * 实例 id。构造时由 <code>UUID.create</code> 生成。
     */
    public var id:String                  = UUID.create();
    /**
     * 当前累计的重力。关掉重力或竖直速度小于 0 时会被清成 0。
     *
     * @default 0
     */
    protected var _g:Number               = 0;
    /**
     * 主影片。销毁且释放时变成 null。
     */
    protected var _mainMc:MovieClip;
    /**
     * 是否碰到版边。
     *
     * @default false
     */
    protected var _isTouchSide:Boolean    = false;
    /**
     * 是否在场景中。
     *
     * @default false
     */
    protected var _isActive:Boolean       = false;
    /**
     * 构造时取到的本地边界。没有影片时为 null。
     *
     * @default null
     */
    protected var _area:Rectangle;
    /** @private getArea 复用世界坐标矩形 */
    private var _areaWorld:Rectangle      = new Rectangle();
    /**
     * 是否已经销毁。
     *
     * @default false
     */
    protected var _destroyed:Boolean;
    /** @private render 用的延时回调 */
    private var _frameFuncs:Array         = [];
    /** @private renderAnimate 用的延时回调 */
    private var _frameAnimateFuncs:Array  = [];
    /** @private 位移乘数，初始为 GameConfig.SPEED_PLUS */
    private var _speedPlus:Number         = GameConfig.SPEED_PLUS;
    /** @private 阻尼乘数 */
    private var _dampingRate:Number       = 1;
    /** @private */
    private var _velocity:Point           = new Point();
    /** @private */
    private var _damping:Point            = new Point();

    /** @private */
    private var _velocity2:Point = new Point();
    /** @private */
    private var _damping2:Point  = new Point();

    /** @private */
    private var _attackRate:Number  = 1;

    /**
     * 攻击力比例。
     *
     * @return 当前比例。
     * @default 1
     * @example
     * <listing version="3.0">
     * var rate:Number = sprite.attackRate;
     * </listing>
     */
    public function get attackRate():Number {
        return _attackRate;
    }

    /** @private */
    public function set attackRate(value:Number):void {
        _attackRate = value;
    }

    /** @private */
    private var _defenseRate:Number = 1;

    /**
     * 防御比例。<code>loseHp</code> 用 <code>2 - defenseRate</code>，再夹到 0.1 和 1 之间。
     *
     * @return 当前比例。
     * @default 1
     * @example
     * <listing version="3.0">
     * var rate:Number = sprite.defenseRate;
     * </listing>
     */
    public function get defenseRate():Number {
        return _defenseRate;
    }

    /** @private */
    public function set defenseRate(value:Number):void {
        _defenseRate = value;
    }

    /**
     * 当前颜色变换。传入 null 的写入会把字段清成 null，影片则恢复成默认变换。
     */
    protected var _colorTransform:ColorTransform = new ColorTransform();

    /**
     * 当前颜色变换。
     *
     * @return 字段里的变换。写入 null 之后这里是 null。
     * @example
     * <listing version="3.0">
     * var color:ColorTransform = sprite.colorTransform;
     * </listing>
     */
    public function get colorTransform():ColorTransform {
        return _colorTransform;
    }

    /** @private */
    public function set colorTransform(colorTransform:ColorTransform):void {
        _colorTransform = colorTransform;
        _mainMc.transform.colorTransform = colorTransform ? colorTransform : new ColorTransform();
    }

    /**
     * 逻辑坐标 x。渲染前不会自动写到影片。
     *
     * @default 0
     */
    protected var _x:Number = 0;

    /**
     * 逻辑坐标 x。
     *
     * @return 当前 x。
     * @default 0
     * @example
     * <listing version="3.0">
     * var px:Number = sprite.x;
     * </listing>
     */
    public function get x():Number {
        return _x;
    }

    /** @private */
    public function set x(v:Number):void {
        _x = v;
    }

    /**
     * 逻辑坐标 y。渲染前不会自动写到影片。
     *
     * @default 0
     */
    protected var _y:Number = 0;

    /**
     * 逻辑坐标 y。
     *
     * @return 当前 y。
     * @default 0
     * @example
     * <listing version="3.0">
     * var py:Number = sprite.y;
     * </listing>
     */
    public function get y():Number {
        return _y;
    }

    /** @private */
    public function set y(v:Number):void {
        _y = v;
    }

    /** @private 1 朝右，-1 朝左 */
    private var _direct:int = 1;

    /**
     * 朝向。1 朝右，-1 朝左。
     *
     * <p>写入时把影片 <code>scaleX</code> 设成朝向乘当前缩放，不改 <code>scaleY</code>。没有影片时抛错。</p>
     *
     * @return 当前朝向。
     * @default 1
     * @example
     * <listing version="3.0">
     * var face:int = sprite.direct;
     * </listing>
     */
    public function get direct():int {
        return _direct;
    }

    /** @private */
    public function set direct(value:int):void {
        _direct        = value;
        _mainMc.scaleX = _direct * _scale;
    }

    /** @private */
    private var _scale:Number = 1;

    /**
     * 缩放。
     *
     * <p>写入时影片的 <code>scaleX</code> 和 <code>scaleY</code> 都变成这个数，不再乘朝向。没有影片时抛错。</p>
     *
     * @return 当前缩放。
     * @default 1
     * @example
     * <listing version="3.0">
     * var s:Number = sprite.scale;
     * </listing>
     */
    public function get scale():Number {
        return _scale;
    }

    /** @private */
    public function set scale(v:Number):void {
        _scale         = v;
        _mainMc.scaleX = _mainMc.scaleY = v;
    }

    /**
     * 主影片。释放销毁之后是 null。
     *
     * @return 主影片。
     * @example
     * <listing version="3.0">
     * var clip:MovieClip = sprite.mc;
     * </listing>
     */
    public function get mc():MovieClip {
        return _mainMc;
    }

    /** @private */
    private var _team:TeamVO;

    /**
     * 所属队伍。
     *
     * @return 队伍。未设置时为 null。
     * @default null
     * @example
     * <listing version="3.0">
     * var side:TeamVO = sprite.team;
     * </listing>
     */
    public function get team():TeamVO {
        return _team;
    }

    /** @private */
    public function set team(value:TeamVO):void {
        _team = value;
    }

    /**
     * 当前血量占最大血量的比例。
     *
     * <p>最大血量为 0 时，结果是 Infinity 或 NaN。</p>
     *
     * @return 血量百分比。
     * @example
     * <listing version="3.0">
     * var rate:Number = sprite.hpPercent;
     * </listing>
     * @see #hp
     * @see #hpMax
     */
    public function get hpPercent():Number {
        return hp / hpMax;
    }

    /**
     * 已损失的血量，即最大血量与当前血量之差。
     *
     * @return 已损失血量。血量高于上限时为负。
     * @example
     * <listing version="3.0">
     * var lost:Number = sprite.lostHp;
     * </listing>
     * @see #hp
     * @see #hpMax
     */
    public function get lostHp():Number {
        return hpMax - hp;
    }

    /**
     * 已损失血量占最大血量的比例。
     *
     * <p>最大血量为 0 时，结果是 Infinity 或 NaN。</p>
     *
     * @return 已损失血量百分比。
     * @example
     * <listing version="3.0">
     * var rate:Number = sprite.lostHpPercent;
     * </listing>
     * @see #lostHp
     * @see #hpMax
     */
    public function get lostHpPercent():Number {
        return lostHp / hpMax;
    }

    /**
     * 是否在场景中。
     *
     * @return 在场景中时为 true。
     * @default false
     * @example
     * <listing version="3.0">
     * var on:Boolean = sprite.getActive();
     * </listing>
     */
    public function getActive():Boolean {
        return _isActive;
    }

    /**
     * 设置是否在场景中。只改标记。
     *
     * @param v 是否在场景中。
     * @example
     * <listing version="3.0">
     * sprite.setActive(true);
     * </listing>
     */
    public function setActive(v:Boolean):void {
        _isActive = v;
    }

    /**
     * 把逻辑坐标写到影片。没有影片时抛错。
     *
     * @throws TypeError 影片为 null 时。
     * @example
     * <listing version="3.0">
     * sprite.updatePosition();
     * </listing>
     */
    public function updatePosition():void {
        _mainMc.x = _x;
        _mainMc.y = _y;
    }

    /**
     * 设置影片音量。没有影片，或读不到音量变换时直接返回。
     *
     * @param v 音量。
     * @example
     * <listing version="3.0">
     * sprite.setVolume(0.5);
     * </listing>
     */
    public function setVolume(v:Number):void {
        if (_mainMc) {
            var transform:SoundTransform = _mainMc.soundTransform;
            if (transform) {
                transform.volume       = v;
                _mainMc.soundTransform = transform;
            }
        }
    }

    /**
     * 是否已经销毁。
     *
     * @return 已销毁时为 true。
     * @default false
     * @example
     * <listing version="3.0">
     * var gone:Boolean = sprite.isDestroyed();
     * </listing>
     */
    public function isDestroyed():Boolean {
        return _destroyed;
    }

    /**
     * 标记销毁，并停掉自身渲染。
     *
     * <p>活着和可被打都会写成 false。参数为 true 且还有影片时，停掉内部动画并丢掉影片。</p>
     *
     * @param dispose 默认 true。为 true 时释放影片。
     * @example
     * <listing version="3.0">
     * sprite.destroy();
     * </listing>
     */
    public function destroy(dispose:Boolean = true):void {
        _destroyed   = true;
        isAlive      = false;
        isAllowBeHit = false;
        stopRenderSelf();

        if (dispose) {
            if (_mainMc) {
                KyoDisplayUtils.stopAllMovieClips(_mainMc);
                _mainMc = null;
            }
        }

    }

    /**
     * 推进动画延时回调。已销毁时直接返回。
     *
     * @example
     * <listing version="3.0">
     * sprite.renderAnimate();
     * </listing>
     */
    public function renderAnimate():void {
        if (_destroyed) {
            return;
        }

        renderAnimateFrameOut();
    }

    /**
     * 推进力、重力和逻辑延时，再把坐标写到影片。
     *
     * <p>已销毁时直接返回。没有影片时写坐标会抛错。</p>
     *
     * @throws TypeError 未销毁但影片为 null 时。
     * @example
     * <listing version="3.0">
     * sprite.render();
     * </listing>
     */
    public function render():void {
        if (_destroyed) {
            return;
        }

        renderVelocity();
        renderFrameOut();

        _mainMc.x = _x;
        _mainMc.y = _y;
    }

    /**
     * 返回主影片。
     *
     * @return 主影片。释放销毁后为 null。
     * @example
     * <listing version="3.0">
     * var view:DisplayObject = sprite.getDisplay();
     * </listing>
     */
    public function getDisplay():DisplayObject {
        return _mainMc;
    }

    /**
     * 按速度比率移动逻辑坐标。分量为 0 的轴不动。
     *
     * @param x 横向位移，默认 0。
     * @param y 纵向位移，默认 0。
     * @example
     * <listing version="3.0">
     * sprite.move(2, 0);
     * </listing>
     */
    public function move(x:Number = 0, y:Number = 0):void {
        if (x != 0) {
            _x += x * _speedPlus;
        }
        if (y != 0) {
            _y += y * _speedPlus;
        }
    }

    /**
     * 改速度比率。阻尼比率变成 <code>v / SPEED_PLUS_DEFAULT</code>。
     *
     * @param v 新的速度比率。
     * @example
     * <listing version="3.0">
     * sprite.setSpeedRate(1);
     * </listing>
     */
    public function setSpeedRate(v:Number):void {
        _speedPlus   = v;
        _dampingRate = v / GameConfig.SPEED_PLUS_DEFAULT;
    }

    /**
     * 第一路力。返回的是内部点，改它会直接改到对象上。不含重力。
     *
     * @return 力的点。
     * @example
     * <listing version="3.0">
     * var vel:Point = sprite.getVelocity();
     * </listing>
     */
    public function getVelocity():Point {
        return _velocity;
    }

    /**
     * 第一路力的横向分量。
     *
     * @return 横向力。
     * @example
     * <listing version="3.0">
     * var vx:Number = sprite.getVecX();
     * </listing>
     */
    public function getVecX():Number {
        return _velocity.x;
    }

    /**
     * 第一路力的纵向分量。不含重力。
     *
     * @return 纵向力。
     * @example
     * <listing version="3.0">
     * var vy:Number = sprite.getVecY();
     * </listing>
     */
    public function getVecY():Number {
        return _velocity.y;
    }

    /**
     * 设置第一路力的横向分量。
     *
     * @param v 横向力。
     * @example
     * <listing version="3.0">
     * sprite.setVecX(3);
     * </listing>
     */
    public function setVecX(v:Number):void {
        _velocity.x = v;
    }

    /**
     * 设置第一路力的纵向分量。
     *
     * @param v 纵向力。
     * @example
     * <listing version="3.0">
     * sprite.setVecY(-4);
     * </listing>
     */
    public function setVecY(v:Number):void {
        _velocity.y = v;
    }

    /**
     * 设置第一路力，并把阻尼清成 0。
     *
     * @param x 横向力，默认 0。
     * @param y 纵向力，默认 0。
     * @example
     * <listing version="3.0">
     * sprite.setVelocity(2, 0);
     * </listing>
     */
    public function setVelocity(x:Number = 0, y:Number = 0):void {
        _velocity.x = x;
        _velocity.y = y;
        setDamping(0, 0);
    }

    /**
     * 把数值加到第一路力上。阻尼不动。
     *
     * @param x 横向增量，默认 0。
     * @param y 纵向增量，默认 0。
     * @example
     * <listing version="3.0">
     * sprite.addVelocity(0, 1);
     * </listing>
     */
    public function addVelocity(x:Number = 0, y:Number = 0):void {
        _velocity.x += x;
        _velocity.y += y;
    }

    /**
     * 设置第二路力和它的阻尼。阻尼会乘 <code>SPEED_PLUS_DEFAULT * 6</code>。
     *
     * @param x 横向力，默认 0。
     * @param y 纵向力，默认 0。
     * @param dampingX 横向阻尼原值，默认 0。
     * @param dampingY 纵向阻尼原值，默认 0。
     * @example
     * <listing version="3.0">
     * sprite.setVec2(1, 0, 0.1, 0);
     * </listing>
     */
    public function setVec2(x:Number = 0, y:Number = 0, dampingX:Number = 0, dampingY:Number = 0):void {
        _velocity2.x = x;
        _velocity2.y = y;
        _damping2.x  = dampingX * GameConfig.SPEED_PLUS_DEFAULT * 6;
        _damping2.y  = dampingY * GameConfig.SPEED_PLUS_DEFAULT * 6;
    }

    /**
     * 第二路力。返回的是内部点。
     *
     * @return 第二路力。
     * @example
     * <listing version="3.0">
     * var extra:Point = sprite.getVec2();
     * </listing>
     */
    public function getVec2():Point {
        return _velocity2;
    }

    /**
     * 第一路阻尼的横向分量。读到的是已经乘过系数的值。
     *
     * @return 横向阻尼。
     * @example
     * <listing version="3.0">
     * var dx:Number = sprite.getDampingX();
     * </listing>
     */
    public function getDampingX():Number {
        return _damping.x;
    }

    /**
     * 第一路阻尼的纵向分量。读到的是已经乘过系数的值。
     *
     * @return 纵向阻尼。
     * @example
     * <listing version="3.0">
     * var dy:Number = sprite.getDampingY();
     * </listing>
     */
    public function getDampingY():Number {
        return _damping.y;
    }

    /**
     * 直接写入横向阻尼，不再乘默认速度比。
     *
     * @param v 横向阻尼。
     * @example
     * <listing version="3.0">
     * sprite.setDampingX(0.2);
     * </listing>
     */
    public function setDampingX(v:Number):void {
        _damping.x = v;
    }

    /**
     * 直接写入纵向阻尼，不再乘默认速度比。
     *
     * @param v 纵向阻尼。
     * @example
     * <listing version="3.0">
     * sprite.setDampingY(0.2);
     * </listing>
     */
    public function setDampingY(v:Number):void {
        _damping.y = v;
    }

    /**
     * 设置第一路阻尼。写入值是参数乘 <code>SPEED_PLUS_DEFAULT * 2</code>。
     *
     * @param x 横向阻尼原值，默认 0。
     * @param y 纵向阻尼原值，默认 0。
     * @example
     * <listing version="3.0">
     * sprite.setDamping(0.1, 0);
     * </listing>
     */
    public function setDamping(x:Number = 0, y:Number = 0):void {
        _damping.x = x * GameConfig.SPEED_PLUS_DEFAULT * 2;
        _damping.y = y * GameConfig.SPEED_PLUS_DEFAULT * 2;
    }

    /**
     * 把原值加到第一路阻尼上，不再乘默认速度比。
     *
     * @param x 横向增量，默认 0。
     * @param y 纵向增量，默认 0。
     * @example
     * <listing version="3.0">
     * sprite.addDamping(0.1, 0);
     * </listing>
     */
    public function addDamping(x:Number = 0, y:Number = 0):void {
        _damping.x += x;
        _damping.y += y;
    }

    /**
     * 按目标重力累计并施加一帧。
     *
     * <p>重力关掉，或竖直速度小于 0 时，已累计重力清成 0 并返回。
     * 还没到目标值时，每次加上 <code>G_ADD * SPEED_PLUS</code>，超过目标就停在目标上。
     * 然后按当前速度比率向下移动这份重力。</p>
     *
     * @param g 重力上限。
     * @example
     * <listing version="3.0">
     * sprite.applyG(8);
     * </listing>
     */
    public function applyG(g:Number):void {

        if (!isApplyG) {
            _g = 0;
            return;
        }

        if (_velocity.y < 0) {
            _g = 0;
            return;
        }

        if (_g < g) {
            var addG:Number = GameConfig.G_ADD * GameConfig.SPEED_PLUS;
            _g += addG;
            if (_g > g) {
                _g = g;
            }
        }
        move(0, _g);
    }

    /**
     * 设置是否在空中。落地时把累计重力设成 <code>G_ON_FLOOR</code>。升空时不改重力。
     *
     * @param v 是否在空中。
     * @example
     * <listing version="3.0">
     * sprite.setInAir(false);
     * </listing>
     */
    public function setInAir(v:Boolean):void {
        if (!v) {
            _g = GameConfig.G_ON_FLOOR;
        }
        isInAir = v;
    }

    /**
     * 打到别人时，若两人在同一父级且自己排在后面，就把自己换到前面。
     *
     * <p>攻击数据本方法不使用。目标或显示对象缺失时直接返回。</p>
     *
     * @param hitvo 攻击数据。
     * @param target 被打中的精灵。
     * @example
     * <listing version="3.0">
     * sprite.hit(hitvo, target);
     * </listing>
     */
    public function hit(hitvo:HitVO, target:IGameSprite):void {
        if (target && target.getDisplay()) {
            var d:DisplayObject  = getDisplay();
            var td:DisplayObject = target.getDisplay();
            if (d && td && d.parent && d.parent == td.parent) {
                var _parent:DisplayObjectContainer = d.parent;
                var index1:int                     = _parent.getChildIndex(d);
                var index2:int                     = _parent.getChildIndex(td);
                if (index1 != -1 && index2 != -1 && index1 < index2) {
                    _parent.setChildIndex(td, index1);
                    _parent.setChildIndex(d, index2);
                }

            }
        }
    }

    /**
     * 挨打。基类是空的。
     *
     * @param hitvo 攻击数据。
     * @param hitRect 相交区域，默认 null。
     */
    public function beHit(hitvo:HitVO, hitRect:Rectangle = null):void {

    }

    /**
     * 当前打出去的数据。基类返回 null。
     *
     * @return null。
     */
    public function getCurrentHits():Array {
        return null;
    }

    /**
     * 世界坐标下的构造区域。
     *
     * <p>没有区域时返回 null。有区域时写入并返回同一块矩形，下次调用会盖掉上次的数。不含缩放和朝向。</p>
     *
     * @return 区域矩形。
     * @example
     * <listing version="3.0">
     * var area:Rectangle = sprite.getArea();
     * </listing>
     */
    public function getArea():Rectangle {
        if (!_area) {
            return null;
        }

        _areaWorld.setTo(_area.x + _x, _area.y + _y, _area.width, _area.height);
        return _areaWorld;
    }

    /**
     * 可被打中的面。基类返回 null。
     *
     * @return null。
     */
    public function getBodyArea():Rectangle {
        return null;
    }

    /**
     * 是否允许穿出地图左右边界。
     *
     * @return <code>isAllowCrossX</code>。
     * @example
     * <listing version="3.0">
     * var cross:Boolean = sprite.allowCrossMapXY();
     * </listing>
     */
    public function allowCrossMapXY():Boolean {
        return isAllowCrossX;
    }

    /**
     * 是否允许穿出地图底边。
     *
     * @return <code>isAllowCrossBottom</code>。
     * @example
     * <listing version="3.0">
     * var cross:Boolean = sprite.allowCrossMapBottom();
     * </listing>
     */
    public function allowCrossMapBottom():Boolean {
        return isAllowCrossBottom;
    }

    /**
     * 是否碰到版边。
     *
     * @return 碰到时为 true。
     * @default false
     * @example
     * <listing version="3.0">
     * var side:Boolean = sprite.getIsTouchSide();
     * </listing>
     */
    public function getIsTouchSide():Boolean {
        return _isTouchSide;
    }

    /**
     * 设置是否碰到版边。
     *
     * @param v 是否碰到。
     * @example
     * <listing version="3.0">
     * sprite.setIsTouchSide(true);
     * </listing>
     */
    public function setIsTouchSide(v:Boolean):void {
        _isTouchSide = v;
    }

    /**
     * 增加血量，超过上限时停在上限。减血不看 <code>isAllowLoseHP</code>，可以减到 0 以下。
     *
     * @param v 增量。负数就是减。
     * @example
     * <listing version="3.0">
     * sprite.addHp(100);
     * </listing>
     */
    public function addHp(v:Number):void {
        hp += v;
        if (hp > hpMax) {
            hp = hpMax;
        }
    }

    /**
     * 按防御比例和防御力扣血。
     *
     * <p><code>isAllowLoseHP</code> 为 false 时直接返回。比例是 <code>2 - defenseRate</code>，再夹到 0.1 和 1。
     * 伤害减去防御力后小于 0 则血量不动，否则扣到不少于 0。</p>
     *
     * @param v 原始伤害。
     * @example
     * <listing version="3.0">
     * sprite.loseHp(50);
     * </listing>
     */
    public function loseHp(v:Number):void {
        if (!isAllowLoseHP) {
            return;
        }
        var dr:Number = 2 - defenseRate;
        if (dr < 0.1) {
            dr = 0.1;
        }
        if (dr > 1) {
            dr = 1;
        }

        var lose:Number = (
                                  v * dr
                          ) - defense;
        if (lose < 0) {
            return;
        }
        hp -= lose;
        if (hp < 0) {
            hp = 0;
        }
    }

    /**
     * 登记一个在 <code>render</code> 里倒数的回调。剩余帧数降到 1 以下就调用。
     *
     * <p>传入 0 或 1 都会在下一次 <code>render</code> 调用。同一轮删掉到期项时，紧跟着的下一项可能被跳过。销毁后不再调用。</p>
     *
     * @param func 回调。调用时没有参数。
     * @param frame 剩余帧数。
     * @example
     * <listing version="3.0">
     * sprite.delayCall(onDone, 5);
     * </listing>
     */
    public function delayCall(func:Function, frame:int):void {
        _frameFuncs.push({func: func, frame: frame});
    }

    /**
     * 把自己的 <code>render</code> 和 <code>renderAnimate</code> 交给渲染器。同一精灵重复加入会被忽略。
     *
     * @example
     * <listing version="3.0">
     * sprite.renderSelf();
     * </listing>
     */
    public function renderSelf():void {
        GameRender.add(renderSelfEnterFrame, this);
    }

    /**
     * 从渲染器去掉自身渲染。本来没加入时直接返回。
     *
     * @example
     * <listing version="3.0">
     * sprite.stopRenderSelf();
     * </listing>
     */
    public function stopRenderSelf():void {
        GameRender.remove(renderSelfEnterFrame, this);
    }

    /**
     * 登记一个在 <code>renderAnimate</code> 里倒数的回调。剩余帧数降到 1 以下就调用。
     *
     * <p>和 <code>delayCall</code> 一样，同一轮删除时可能跳过紧跟着的下一项。</p>
     *
     * @param func 回调。
     * @param frame 剩余动画帧数。
     * @example
     * <listing version="3.0">
     * sprite.setAnimateFrameOut(onDone, 3);
     * </listing>
     * @see #delayCall()
     */
    public function setAnimateFrameOut(func:Function, frame:int):void {
        _frameAnimateFuncs.push({func: func, frame: frame});
    }

    /** @private 两路力各自在阻尼大于 0 时向 0 收，再按速度比率移动 */
    private function renderVelocity():void {
        var resultX:Number = 0;
        var resultY:Number = 0;

        if (_velocity.x != 0) {
            resultX += _velocity.x;
            if (_damping.x > 0) {
                _velocity.x = KyoMath.weaken(_velocity.x, _damping.x * _dampingRate);
            }
        }
        if (_velocity.y != 0) {
            resultY += _velocity.y;
            if (_damping.y > 0) {
                _velocity.y = KyoMath.weaken(_velocity.y, _damping.y * _dampingRate);
            }
        }
        if (_velocity2.x != 0) {
            resultX += _velocity2.x;
            if (_damping2.x > 0) {
                _velocity2.x = KyoMath.weaken(_velocity2.x, _damping2.x * _dampingRate);
            }
        }
        if (_velocity2.y != 0) {
            resultY += _velocity2.y;
            if (_damping2.y > 0) {
                _velocity2.y = KyoMath.weaken(_velocity2.y, _damping2.y * _dampingRate);
            }
        }
        if (resultX != 0 || resultY != 0) {
            move(resultX, resultY);
        }
    }

    /** @private 未销毁时先 render 再 renderAnimate */
    private function renderSelfEnterFrame():void {
        if (_destroyed) {
            return;
        }
            render();
            renderAnimate();
    }

    /** @private 动画延时减一，到期就调用并删除，下一项可能被跳过 */
    private function renderAnimateFrameOut():void {
        if (_frameAnimateFuncs.length < 1) {
            return;
        }
        for (var i:int; i < _frameAnimateFuncs.length; i++) {
            var o:Object = _frameAnimateFuncs[i];
            o.frame--;
            if (o.frame < 1) {
                o.func();
                _frameAnimateFuncs.splice(i, 1);
            }
        }
    }

    /** @private 逻辑延时减一，到期就调用并删除，下一项可能被跳过 */
    private function renderFrameOut():void {
        if (_frameFuncs.length < 1) {
            return;
        }
        for (var i:int; i < _frameFuncs.length; i++) {
            var o:Object = _frameFuncs[i];
            o.frame--;
            if (o.frame < 1) {
                o.func();
                _frameFuncs.splice(i, 1);
            }
        }
    }

}
}
