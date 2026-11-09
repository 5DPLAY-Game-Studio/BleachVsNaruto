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
import flash.geom.ColorTransform;

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
import net.play5d.kyo.utils.KyoDisplayUtils;
/**
 * 跟着角色影片走的特效。
 *
 * <p>设置目标时会走一次方向设置，影片横坐标会被再乘上方向，然后才把这个位置记成原点。之后的跟随自己改缩放和坐标，不要再设置方向。角色帧和上次相差不是 0 或 1 时只调用 <code>onRemove</code>，不把影片拿下来。动画播到总帧数减 1 时同样只通知移除，最后一帧不会出现。标签 <code>loop</code> 停到 <code>loop_start</code>，没有这个标签就停到第 1 帧。</p>
 *
 * <p><code>destroy</code> 不看 <code>dispose</code>，也不从父级移除，也不调用 <code>onRemove</code>。<code>getActive</code> 固定返回 false。</p>
 */
public class FollowEffectView implements IGameSprite {

    /**
     * 跟随的目标。销毁后是 null。
     */
    public var target:BaseGameSprite;

    /**
     * 特效影片。销毁后是 null。
     */
    public var mc:MovieClip;
    /**
     * 帧跳开或播到移除标签时调用，参数是这个视图。null 时不调用。
     *
     * @default null
     */
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
     * 创建跟随特效。有 <code>loop_start</code> 标签时循环停在那里，否则停在第 1 帧。影片为 null 时抛错。
     *
     * @param mc 特效影片。
     * @throws TypeError 影片为 null 时。
     */
    public function FollowEffectView(mc:MovieClip) {
        this.mc = mc;

        _orgScale  = new Point(mc.scaleX, mc.scaleY);
        _orgRotate = mc.rotation;

        _loopFrame = MCUtils.hasFrameLabel(mc, 'loop_start') ? 'loop_start' : 1;
    }

    /**
     * 开始跟随。目标为 null 时抛错。不是角色时要能读到 <code>mc.currentFrame</code>，没有影片会抛错。
     *
     * @param target 跟随目标。
     * @throws TypeError 目标为 null，或不是角色且没有影片时。
     * @example
     * <listing version="3.0">
     * view.setTarget(fighter);
     * </listing>
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

    // 颜色变换通道
    private var _colorTransform:ColorTransform = new ColorTransform();

    /**
     * 颜色变换。设置 null 时字段变成 null，影片上换成一份恒等变换。影片已清空时抛错。
     *
     * @return 当前变换。设置 null 之后是 null。
     */
    public function get colorTransform():ColorTransform {
        return _colorTransform;
    }
    /** @private */
    public function set colorTransform(colorTransform:ColorTransform):void {
        _colorTransform = colorTransform;
        mc.transform.colorTransform = colorTransform ? colorTransform : new ColorTransform();
    }

    // 方向
    private var _direct:int;
    /**
     * 方向。设置时把缩放和旋转乘上方向，并把当前横坐标再乘一次。跟随过程中的位置更新不走这个设置。
     *
     * @return 当前方向。
     */
    public function get direct():int {
        return _direct;
    }
    /** @private */
    public function set direct(value:int):void {
        _direct = value;

        mc.scaleX   = _orgScale.x * _direct;
        mc.rotation = _orgRotate * _direct;

        mc.x *= _direct;
    }

    /**
     * 影片横坐标。影片已清空时抛错。
     *
     * @return 横坐标。
     * @throws TypeError 影片为 null 时。
     */
    public function get x():Number {
        return mc.x;
    }
    /** @private */
    public function set x(v:Number):void {
        mc.x = v;
    }

    /**
     * 影片纵坐标。影片已清空时抛错。
     *
     * @return 纵坐标。
     * @throws TypeError 影片为 null 时。
     */
    public function get y():Number {
        return mc.y;
    }
    /** @private */
    public function set y(v:Number):void {
        mc.y = v;
    }

    // 队伍，同一队伍不可攻击
    private var _team:TeamVO;
    /**
     * 队伍。只存下来，攻击判定不读它。
     *
     * @return 队伍。默认 null。
     */
    public function get team():TeamVO {
        return _team;
    }
    /** @private */
    public function set team(v:TeamVO):void {
        _team = v;
    }

    /**
     * 停掉影片并清空引用。第二次调用直接返回。<code>dispose</code> 不使用，传 false 也会清掉。不从父级移除，也不调用 <code>onRemove</code>。
     *
     * @param dispose 不使用。默认 true。
     * @example
     * <listing version="3.0">
     * view.destroy();
     * </listing>
     */
    public function destroy(dispose:Boolean = true):void {
        if (_destroyed) {
            return;
        }
        _destroyed = true;

        target = null;
        if (mc) {
            KyoDisplayUtils.stopAllMovieClips(mc);
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
    public function isDestroyed():Boolean {
        return _destroyed;
    }

    /**
     * 跟上目标，并比较角色帧。和上次相差不是 0 或 1 时通知移除。目标已清空时抛错。
     *
     * @throws TypeError 目标为 null 时。
     * @example
     * <listing version="3.0">
     * view.render();
     * </listing>
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
     * 影片下一帧。标签 <code>loop</code> 停到循环帧，<code>remove</code> 通知移除。没有这两个标签、且当前帧等于总帧数减 1 时也通知移除。影片已清空时抛错。
     *
     * @throws TypeError 影片为 null 时。
     * @example
     * <listing version="3.0">
     * view.renderAnimate();
     * </listing>
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
     * 自身范围。
     *
     * @return 固定 null。
     */
    public function getArea():Rectangle {
        return null;
    }

    /**
     * 受击范围。
     *
     * @return 固定 null。
     */
    public function getBodyArea():Rectangle {
        return null;
    }

    /**
     * 当前攻击数据。
     *
     * @return 固定 null。
     */
    public function getCurrentHits():Array {
        return null;
    }

    /**
     * 是否允许穿出地图左右和上沿。
     *
     * @return 固定 true。
     */
    public function allowCrossMapXY():Boolean {
        return true;
    }
    /**
     * 是否允许穿出地图底边。
     *
     * @return 固定 true。
     */
    public function allowCrossMapBottom():Boolean {
        return true;
    }

    /**
     * 是否贴边。
     *
     * @return 固定 false。
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
     * @param v 音量。不限制在 0 到 1。影片为 null 时直接返回。
     */
    public function setVolume(v:Number):void {
        KyoDisplayUtils.setMcVolume(mc, v);
    }

    /**
     * 是否在场景中。
     *
     * @return 固定 false。
     */
    public function getActive():Boolean {
        return false;
    }
    /**
     * 空实现。
     *
     * @param v 不使用。
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
