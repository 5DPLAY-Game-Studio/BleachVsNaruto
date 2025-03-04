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
import flash.geom.Rectangle;

import net.play5d.game.bvn.data.vos.TeamVO;
import net.play5d.game.bvn.fighter.models.HitVO;

/**
 * 游戏元件接口
 */
public interface IGameSprite {

    /**
     * 方向
     */
    function get direct():int;
    function set direct(value:int):void;

    /**
     * 坐标 x
     */
    function get x():Number;
    function set x(v:Number):void;

    /**
     * 坐标 y
     */
    function get y():Number;
    function set y(v:Number):void;

//    /**
//     * 宽度
//     */
//    function get width():Number;
//
//    /**
//     * 高度
//     */
//    function get height():Number;

    /**
     * 队伍，同一队伍不可攻击
     */
    function get team():TeamVO;
    function set team(v:TeamVO):void;

    ////////////////////////////////////////////////////////////

    /**
     * 销毁
     * @param dispose 处理
     */
    function destory(dispose:Boolean = true):void;

    /**
     * 是否已销毁
     * @return 是否已销毁
     */
    function isDestoryed():Boolean;

    ////////////////////////////////////////////////////////////

    /**
     * 处理逻辑使用，按 GameConfig.FPS_MAIN 帧率调用
     */
    function render():void;

    /**
     * 处理动画渲染，按GameConfig.FPS_ANIMATE帧率调用
     */
    function renderAnimate():void;



    /**
     * 返回显示对象
     * @return 显示对象
     */
    function getDisplay():DisplayObject;

//    /**
//     * 应用重力
//     * @param g 重力大小
//     */
//    function applyG(g:Number):void;
//
//    /**
//     * 置是否在空中
//     * @param v 是否在空中
//     */
//    function setInAir(v:Boolean):void;

    ////////////////////////////////////////////////////////////

    /**
     * 攻击到其他人
     * @param hitVO 攻击值对象
     * @param target 目标游戏元件
     */
    function hit(hitVO:HitVO, target:IGameSprite):void;

    /**
     * 被攻击
     * @param hitVO 攻击值对象
     * @param hitRect 攻击矩形
     */
    function beHit(hitVO:HitVO, hitRect:Rectangle = null):void;

    ////////////////////////////////////////////////////////////

    /**
     * 返回自身的区域
     * @return 自身的区域
     */
    function getArea():Rectangle;

    /**
     * 返回被打的区域
     * @return 被打的区域
     */
    function getBodyArea():Rectangle;

    /**
     * 返回当前攻击的区域
     * @return 当前攻击的区域 [FighterHitVO]
     */
    function getCurrentHits():Array;

    ////////////////////////////////////////////////////////////

    /**
     * 是否可穿越地图的 XY
     * @return 是否可穿越地图的 XY
     */
    function allowCrossMapXY():Boolean;

    /**
     * 是否可穿越地图的底线
     * @return 是否可穿越地图的底线
     */
    function allowCrossMapBottom():Boolean;



    /**
     * 取是否触碰版边
     * @return 是否触碰版边
     */
    function getIsTouchSide():Boolean;

    /**
     * 置是否触碰版边
     * @param v 是否触碰版边
     */
    function setIsTouchSide(v:Boolean):void;



    /**
     * 置速度比例
     * @param v 速度比例
     */
    function setSpeedRate(v:Number):void;

    /**
     * 置音量
     * @param v 音量 0-1
     */
    function setVolume(v:Number):void;



    /**
     * 取是否在场景中
     * @return 是否在场景中
     */
    function getActive():Boolean;

    /**
     * 置是否在场景中
     * @param v 是否在场景中
     */
    function setActive(v:Boolean):void;

}
}
