/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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

package net.play5d.game.bvn.views.effects {
import net.play5d.game.bvn.fighter.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.game.bvn.data.vos.TeamVO;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.utils.MCUtils;
import net.play5d.kyo.utils.KyoUtils;

/**
 * 跟随效果视图
 */
public class FollowEffectView implements IGameSprite {
    include '../../../../../../../include/_INCLUDE_.as';

    // 跟随的目标
    public var target:BaseGameSprite;

    // 特效 mc
    public var mc:MovieClip;
    // 移除自身时调用
    public var onRemove:Function;

    // 主人物的 FighterMC
    private var _fmc:FighterMC;
    // 原缩放大小
    private var _orgScale:Point;
    // 原角度
    private var _orgRotate:int;
    // 原位置
    private var _orgPosition:Point;
    // 原方向
    private var _orgDirect:int;
    // 目标放置的上一帧数
    private var _lastFrame:int;

    // 循环帧
    private var _loopFrame:Object;

    /**
     * 构造方法
     * @param mc 特效 mc
     */
    public function FollowEffectView(mc:MovieClip) {
        this.mc = mc;

        _orgScale  = new Point(mc.scaleX, mc.scaleY);
        _orgRotate = mc.rotation;

        _loopFrame = MCUtils.hasFrameLabel(mc, 'loop_start') ? 'loop_start' : 1;
    }

    /**
     * 置跟随目标
     * @param target 跟随目标
     */
    public function setTarget(target:BaseGameSprite):void {
        this.target = target;
        direct = target.direct;
        _orgDirect = _direct;
        _orgPosition = new Point(mc.x, mc.y);

        if (target is FighterMain) {
            _fmc = (target as FighterMain).getMC();
        }

        // 更新位置
        mc.x = target.x + _orgPosition.x;
        mc.y = target.y + _orgPosition.y;

        if (_fmc) {
            _lastFrame = _fmc.getCurrentFrame();

            mc.x += _fmc.x;
            mc.y += _fmc.y;
        }
        else {
            _lastFrame = target.mc.currentFrame;
        }
    }

    // 方向
    private var _direct:int;
    /**
     * 方向，仅限初始化使用，更新位置不可用
     */
    public function get direct():int {
        return _direct;
    }
    public function set direct(value:int):void {
        _direct = value;

        mc.scaleX   = _orgScale.x * _direct;
        mc.rotation = _orgRotate * _direct;

        mc.x *= _direct;
    }

    /**
     * 坐标 x
     */
    public function get x():Number {
        return mc.x;
    }
    public function set x(v:Number):void {
        mc.x = v;
    }

    /**
     * 坐标 y
     */
    public function get y():Number {
        return mc.y;
    }
    public function set y(v:Number):void {
        mc.y = v;
    }

    // 队伍，同一队伍不可攻击
    private var _team:TeamVO;
    /**
     * 队伍，同一队伍不可攻击
     */
    public function get team():TeamVO {
        return _team;
    }
    public function set team(v:TeamVO):void {
        _team = v;
    }

    /**
     * 销毁
     * @param dispose 处理
     */
    public function destory(dispose:Boolean = true):void {
        if (_destroyed) {
            return;
        }
        _destroyed = true;

        target = null;
        if (mc) {
            mc.stopAllMovieClips();
            mc = null;
        }

        onRemove     = null;
        _fmc         = null;
        _team        = null;
        _orgScale    = null;
        _orgPosition = null;
        _loopFrame   = null;
    }

    // 已销毁
    private var _destroyed:Boolean = false;

    /**
     * 是否已销毁
     * @return 是否已销毁
     */
    public function isDestoryed():Boolean {
        return _destroyed;
    }

    /**
     * 处理逻辑使用，按 GameConfig.FPS_MAIN 帧率调用
     */
    public function render():void {
        // 更新位置
        updatePosition();

        var curFrame:int = _fmc ? _fmc.getCurrentFrame() : target.mc.currentFrame;
        switch (curFrame - _lastFrame) {
        case 1:
        case 0:
            _lastFrame = curFrame;
            break;
        default :
            removeSelf();
        }
    }
    /**
     * 处理动画渲染，按GameConfig.FPS_ANIMATE帧率调用
     */
    public function renderAnimate():void {
        mc.nextFrame();

        // 简单的元件播放控制
        switch (mc.currentLabel) {
        case 'loop':
            mc.gotoAndStop(_loopFrame);
            break;
        case 'remove':
            removeSelf();
            break;
        default :
            if (mc.currentFrame == mc.totalFrames - 1) {
                removeSelf();
            }
        }
    }

    /**
     * 返回显示对象
     * @return 显示对象
     */
    public function getDisplay():DisplayObject {
        return mc;
    }


    /**
     * 攻击到其他人
     * @param hitVO 攻击值对象
     * @param target 目标游戏元件
     */
    public function hit(hitVO:HitVO, target:IGameSprite):void {
    }

    /**
     * 被攻击
     * @param hitVO 攻击值对象
     * @param hitRect 攻击矩形
     */
    public function beHit(hitVO:HitVO, hitRect:Rectangle = null):void {
    }

    /**
     * 返回自身的区域
     * @return 自身的区域
     */
    public function getArea():Rectangle {
        return null;
    }

    /**
     * 返回被打的区域
     * @return 被打的区域
     */
    public function getBodyArea():Rectangle {
        return null;
    }

    /**
     * 返回当前攻击的区域
     * @return 当前攻击的区域 [FighterHitVO]
     */
    public function getCurrentHits():Array {
        return null;
    }

    /**
     * 是否可穿越地图的 XY
     * @return 是否可穿越地图的 XY
     */
    public function allowCrossMapXY():Boolean {
        return true;
    }
    /**
     * 是否可穿越地图的底线
     * @return 是否可穿越地图的底线
     */
    public function allowCrossMapBottom():Boolean {
        return true;
    }

    /**
     * 取是否触碰版边
     * @return 是否触碰版边
     */
    public function getIsTouchSide():Boolean {
        return false;
    }
    /**
     * 置是否触碰版边
     * @param v 是否触碰版边
     */
    public function setIsTouchSide(v:Boolean):void {
    }

    /**
     * 置速度比例
     * @param v 速度比例
     */
    public function setSpeedRate(v:Number):void {
    }

    /**
     * 置音量
     * @param v 音量 0-1
     */
    public function setVolume(v:Number):void {
        KyoUtils.setMcVolume(mc, v);
    }

    /**
     * 取是否在场景中
     * @return 是否在场景中
     */
    public function getActive():Boolean {
        return false;
    }
    /**
     * 置是否在场景中
     * @param v 是否在场景中
     */
    public function setActive(v:Boolean):void {
    }

    //////////////////////////////////////////////////

    /**
     * 移除自身
     */
    private function removeSelf():void {
        if (onRemove != null) {
            onRemove(this);
        }
    }

    /**
     * 更新位置（包含方向）
     */
    private function updatePosition():void {
        if (!mc) {
            return;
        }

        // 更新方向，不可用 Setter direct
        _direct = target.direct;
        mc.scaleX   = _orgScale.x * _direct;
        mc.rotation = _orgRotate * _direct;

        mc.x = target.x + _orgPosition.x * (_direct == _orgDirect ? 1 : -1);
        mc.y = target.y + _orgPosition.y;

        if (_fmc) {
            mc.x = mc.x + _fmc.x * (_direct > 0 ? 1 : -1);
            mc.y = mc.y + _fmc.y;
        }
    }

}
}
