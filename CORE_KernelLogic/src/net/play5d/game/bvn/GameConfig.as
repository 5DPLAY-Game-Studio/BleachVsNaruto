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

package net.play5d.game.bvn {
import flash.display.StageQuality;
import flash.geom.Point;

import net.play5d.game.bvn.data.MapLogoState;

/**
 * 全局数值。<code>GAME_SIZE</code> 和 <code>GAME_SCALE</code> 各是同一份 <code>Point</code>，改 <code>x</code>、<code>y</code> 会影响所有读取方。
 *
 * <p><code>SPEED_PLUS_DEFAULT</code> 是动画帧率除以游戏帧率。<code>setGameFps</code> 只改 <code>FPS_GAME</code> 和 <code>SPEED_PLUS</code>，不改舞台帧率。游戏帧率写成 0 时，这个比值变成 Infinity。</p>
 */
public class GameConfig {

    /**
     * 是否调试模式。
     *
     * @default false
     */
    public static var DEBUG_MODE:Boolean = false;
    /**
     * 是否触屏。为 true 时，<code>MainGame.initialize</code> 会初始化触摸。
     *
     * @default false
     */
    public static var TOUCH_MODE:Boolean = false;
    /**
     * 触屏返回按钮文件名，相对 <code>assets/ui/bitmap</code>，由壳写入。
     *
     * @default null
     */
    public static var TOUCH_BACK_BTN:String;

    ///////////////////////////////////////////////////////////////////////////

    /**
     * 重力。
     *
     * @default 12
     */
    public static const G:Number          = 12;
    /**
     * 每帧累加的重力增量。
     *
     * @default 1.2
     */
    public static const G_ADD:Number      = 1.2;
    /**
     * 落回地面时写入的重力。
     *
     * @default 4
     */
    public static const G_ON_FLOOR:Number = 4;

    ///////////////////////////////////////////////////////////////////////////

    /**
     * 游戏画面尺寸，800×600。引用不能换，坐标可以改。
     *
     * @default 800,600
     */
    public static const GAME_SIZE:Point = new Point(800, 600);
    /**
     * 游戏相对场景的缩放。单指拖动的位移会除以它。
     *
     * @default 1,1
     */
    public static var GAME_SCALE:Point  = new Point(1, 1);

    ///////////////////////////////////////////////////////////////////////////

    /**
     * 对局帧率。<code>setGameFps</code> 会改它。
     *
     * @default 60
     */
    public static var FPS_GAME:int         = 60;
    /**
     * 界面帧率。
     *
     * @default 30
     */
    public static const FPS_UI:int         = 30;
    /**
     * 动画帧率。
     *
     * @default 30
     */
    public static const FPS_ANIMATE:int    = 30;
    /**
     * 闪光效果帧率。
     *
     * @default 15
     */
    public static var FPS_SHINE_EFFECT:int = 15;

    ///////////////////////////////////////////////////////////////////////////

    /**
     * 发射体持续时间倍率。
     *
     * @default 2
     */
    public static const BULLET_HOLD_FRAME_PLUS:Number      = 2;
    /**
     * 地面起跳停留的动画帧数。
     *
     * @default 2
     */
    public static const JUMP_DELAY_FRAME:int               = 2;
    /**
     * 空中起跳停留的动画帧数。
     *
     * @default 1
     */
    public static const JUMP_DELAY_FRAME_AIR:int           = 1;
    /**
     * 跳跃阻尼。
     *
     * @default 0.5
     */
    public static const JUMP_DAMPING:Number                = 0.5;
    /**
     * 击飞后留在空中的最短动画帧数。
     *
     * @default 15
     */
    public static const HURT_JUMP_FRAME:int                = 15;
    /**
     * 受击后的无敌动画帧数。
     *
     * @default 4
     */
    public static const HURT_GAP_FRAME:int                 = 4;
    /**
     * 破防后的无敌动画帧数。
     *
     * @default 4
     */
    public static const BREAK_DEF_GAP_FRAME:int            = 4;
    /**
     * 破防击飞后的无敌动画帧数。
     *
     * @default 10
     */
    public static const BREAK_DEF_DOWN_GAP_FRAME:int       = 10;
    /**
     * 破防停顿的动画帧数。表达式是 <code>0.7 * 60</code>，赋给 <code>int</code> 时截断。
     */
    public static const BREAK_DEF_HOLD_FRAME:int           = 0.7 * 60;
    /**
     * 防御命中的间隔，动画帧。
     *
     * @default 4
     */
    public static const DEFENSE_GAP_FRAME:int              = 4;
    /**
     * 防御时的横向速度阻尼。
     *
     * @default 1
     */
    public static const DEFENSE_DAMPING_X:Number           = 1;
    /**
     * 防御击倒的间隔，动画帧。
     *
     * @default 8
     */
    public static const DEFENSE_GAP_FRAME_DOWN:int         = 8;
    /**
     * 防御时的扣血比例。
     *
     * @default 0.05
     */
    public static const DEFENSE_LOSE_HP_RATE:Number        = 0.05;
    /**
     * 防御停顿的最短动画帧数。
     *
     * @default 5
     */
    public static const DEFENSE_HOLD_FRAME_MIN:int         = 5;
    /**
     * 防御停顿的最长动画帧数。
     *
     * @default 10
     */
    public static const DEFENSE_HOLD_FRAME_MAX:int         = 10;
    /**
     * 防御击倒的停顿动画帧数。
     *
     * @default 10
     */
    public static const DEFENSE_HOLD_FRAME_DOWN:int        = 10;
    /**
     * 受击时的横向速度阻尼。
     *
     * @default 0.1
     */
    public static const HURT_DAMPING_X:Number              = 0.1;
    /**
     * 受击时的纵向速度阻尼。
     *
     * @default 0.5
     */
    public static const HURT_DAMPING_Y:Number              = 0.5;
    /**
     * 人已经在空中时，再被打上天追加的纵向速度。
     *
     * @default 3
     */
    public static const HURT_Y_ADD_INAIR:Number            = 3;
    /**
     * 被打上天追加的纵向速度。
     *
     * @default 6
     */
    public static const HURT_Y_ADD:Number                  = 6;
    /**
     * 钢体受击的无敌动画帧数。
     *
     * @default 4
     */
    public static const STEEL_HURT_GAP_FRAME:int           = 4;
    /**
     * 钢体被击飞的无敌动画帧数。
     *
     * @default 10
     */
    public static const STEEL_HURT_DOWN_GAP_FRAME:int      = 10;
    /**
     * 钢体受击扣血比例。
     *
     * @default 0.65
     */
    public static const STEEL_HURT_HP_PERCENT:Number       = 0.65;
    /**
     * 超级钢体受击扣血比例。
     *
     * @default 0.3
     */
    public static const STEEL_SUPER_HURT_HP_PERCENT:Number = 0.3;
    /**
     * 击飞时的横向速度阻尼。
     *
     * @default 0
     */
    public static const HURT_FLY_DAMPING_X:Number          = 0;
    /**
     * 击飞时的纵向速度阻尼。
     *
     * @default 0.5
     */
    public static const HURT_FLY_DAMPING_Y:Number          = 0.5;
    /**
     * 击飞落地时的横向阻尼。
     *
     * @default 2
     */
    public static const HIT_FLOOR_DAMPING_X:Number         = 2;
    /**
     * 重击落地时的横向阻尼。
     *
     * @default 4
     */
    public static const HIT_FLOOR_DAMPING_X_HEAVY:Number   = 4;
    /**
     * 落地弹起的最小纵向速度。
     *
     * @default 3
     */
    public static const HIT_FLOOR_TAN_Y_MIN:Number         = 3;
    /**
     * 落地弹起的最大纵向速度。
     *
     * @default 8
     */
    public static const HIT_FLOOR_TAN_Y_MAX:Number         = 8;
    /**
     * 倒地躺着的动画帧数。
     *
     * @default 15
     */
    public static const HIT_DOWN_FRAME:int                 = 15;
    /**
     * 重击倒地躺着的动画帧数。
     *
     * @default 30
     */
    public static const HIT_DOWN_FRAME_HEAVY:int           = 30;
    /**
     * 攻击纵向速度大于这个值时按重击倒地。
     *
     * @default 5
     */
    public static const HIT_DOWN_BY_HITY:int               = 5;
    /**
     * 纵向速度大于这个值时不能落在空中平台上。
     *
     * @default 5
     */
    public static const NO_TOUCH_BAN_ON_VECY:int           = 5;
    /**
     * 角色贴边时的像素补正。
     *
     * @default 10
     */
    public static const X_SIDE_OFFSET:int                  = 10;
    /**
     * 倒地起身的动画帧数。
     *
     * @default 20
     */
    public static const HURT_DOWN_JUMP_FRAME:int           = 20;
    /**
     * 倒地起身时减去的速度。
     *
     * @default 1
     */
    public static const HURT_DOWN_JUMP_DAMPING:int         = 1;

    ///////////////////////////////////////////////////////////////////////////

    /**
     * 用过能量后，隔这么多秒才开始自动回复。
     *
     * @default 0.8
     */
    public static const USE_ENERGY_CD:Number                  = 0.8;
    /**
     * 普通状态每帧增加的能量。
     *
     * @default 2
     */
    public static const ENERGY_ADD_NORMAL:Number              = 2;
    /**
     * 防御时每帧增加的能量。
     *
     * @default 0.8
     */
    public static const ENERGY_ADD_DEFENSE:Number             = 0.8;
    /**
     * 攻击时每帧增加的能量。
     *
     * @default 1.1
     */
    public static const ENERGY_ADD_ATTACKING:Number           = 1.1;
    /**
     * 超载时每帧增加的能量。
     *
     * @default 0.6
     */
    public static const ENERGY_ADD_OVER_LOAD_PERFRAME:Number  = 0.6;
    /**
     * 能量回到这个值时解除超载。
     *
     * @default 30
     */
    public static const ENERGY_ADD_OVER_LOAD_RESUME:Number    = 30;
    /**
     * 被破防时能量减少的比例。
     *
     * @default 0.9
     */
    public static const ENERGY_LOSE_DEFENSE_BREAK_RATE:Number = 0.9;

    ///////////////////////////////////////////////////////////////////////////

    /**
     * 必杀命中时的加气比例。当前是 0。
     *
     * @default 0
     */
    public static const QI_ADD_HIT_BISHA_RATE:Number    = 0;
    /**
     * 普通命中时的加气比例。
     *
     * @default 0.17
     */
    public static const QI_ADD_HIT_RATE:Number          = 0.17;
    /**
     * 子弹命中时的加气比例。
     *
     * @default 0.1
     */
    public static const QI_ADD_HIT_BULLET_RATE:Number   = 0.1;
    /**
     * 攻击体命中时的加气比例。
     *
     * @default 0.13
     */
    public static const QI_ADD_HIT_ATTACKER_RATE:Number = 0.13;
    /**
     * 辅助命中时的加气比例。
     *
     * @default 0.15
     */
    public static const QI_ADD_HIT_ASSISTER_RATE:Number = 0.15;
    /**
     * 命中加气的上限。
     *
     * @default 15
     */
    public static const QI_ADD_HIT_MAX:Number           = 15;
    /**
     * 被打时的加气比例。
     *
     * @default 0.08
     */
    public static const QI_ADD_HURT_RATE:Number         = 0.08;
    /**
     * 被打加气的上限。
     *
     * @default 20
     */
    public static const QI_ADD_HURT_MAX:Number          = 20;
    /**
     * 每帧增加的辅助气。
     *
     * @default 0.2
     */
    public static const FUZHU_QI_ADD_PERFRAME:Number    = 0.2;

    ///////////////////////////////////////////////////////////////////////////

    /**
     * 镜头缓动除数。大于 1 时缓动。
     *
     * @default 2.5
     */
    public static const CAMERA_TWEEN_SPD:Number = 2.5;
    /**
     * 角色血量上限。
     *
     * @default 1000
     */
    public static const FIGHTER_HP_MAX:int      = 1000;

    /**
     * 界面画质。
     *
     * @default low
     */
    public static var QUALITY_UI:String          = StageQuality.LOW;
    /**
     * 对局画质。
     *
     * @default low
     */
    public static var QUALITY_GAME:String        = StageQuality.LOW;
    /**
     * 是否进入操作说明。
     *
     * @default true
     */
    public static var SHOW_HOW_TO_PLAY:Boolean   = true;
    /**
     * 是否允许显示血量数字。
     *
     * @default true
     */
    public static var ALLOW_SHOW_HP_TEXT:Boolean = true;
    /**
     * 当前速度倍率。初始化时等于当时的 <code>SPEED_PLUS_DEFAULT</code>，之后只在 <code>setGameFps</code> 里重算。
     */
    public static var SPEED_PLUS:Number          = SPEED_PLUS_DEFAULT;
    /**
     * 受击时间补正，帧数。
     *
     * @default 3
     */
    public static var HURT_FRAME_OFFSET:int      = 3;
    /**
     * 地图标志。0 隐藏，1 是 4399，2 是自己的标志。
     *
     * @default 0
     * @see net.play5d.game.bvn.data.MapLogoState
     */
    public static var MAP_LOGO_STATE:int         = MapLogoState.HIDE;
    /**
     * 界面布局。0 是默认，1 是紧凑，用于选人顺序栏和对局界面。
     *
     * @default 0
     */
    public static var SHOW_UI_STATUS:int         = 0;

    /**
     * 默认速度倍率，动画帧率除以游戏帧率。
     *
     * @return 当前比值。游戏帧率是 0 时为 Infinity。
     * @example
     * <listing version="3.0">
     * var rate:Number = GameConfig.SPEED_PLUS_DEFAULT;
     * </listing>
     */
    public static function get SPEED_PLUS_DEFAULT():Number {
        return FPS_ANIMATE / FPS_GAME;
    }

    /**
     * 改游戏帧率，并按新比值重写 <code>SPEED_PLUS</code>。不改舞台帧率。
     *
     * @param v 游戏帧率。0 时速度倍率变成 Infinity。
     * @example
     * <listing version="3.0">
     * GameConfig.setGameFps(30);
     * </listing>
     */
    public static function setGameFps(v:int):void {
        FPS_GAME   = v;
        SPEED_PLUS = SPEED_PLUS_DEFAULT;
    }

}
}
