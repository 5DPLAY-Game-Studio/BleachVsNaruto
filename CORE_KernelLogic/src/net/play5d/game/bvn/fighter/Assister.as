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
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.fighter.ctrler.AssisterCtrler;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.fighter.utils.HitAreaUtil;
import net.play5d.game.bvn.fighter.utils.McAreaCacher;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IGameSprite;

public class Assister extends BaseGameSprite {

    public function Assister(mainmc:MovieClip) {
        super(mainmc);

        // TODO

        if (_mainMc.setAssistCtrler) {
            _ctrler = new AssisterCtrler();
            _ctrler.initAssister(this);
            _mainMc.setAssistCtrler(_ctrler);
        }
        else {
            ThrowError(Error, GetLang('debug.error.data.assister.init_fail', {functionName: 'setAssistCtrler()'}));
        }
    }
    public var onRemove:Function;
    public var data:FighterVO;
    public var isAttacking:Boolean;
    private var _hitAreaCache:McAreaCacher      = new McAreaCacher('hit');
    private var _hitCheckAreaCache:McAreaCacher = new McAreaCacher('hit_check');
    private var _rectCache:Object               = {};
    /** @private getCurrentHits 复用缓冲 */
    private var _hitsBuf:Array                  = [];
    private var _mcOrgPoint:Point;
    private var _owner:IGameSprite;
    private var _isRenderMainAnimate:Boolean    = true;
    private var _ctrler:AssisterCtrler;

    public function get name():String {
        return _mainMc.name;
    }

    public override function destroy(dispose:Boolean = true):void {
        if (!dispose) {
            return;
        }

        if (_hitAreaCache) {
            _hitAreaCache.destroy();
            _hitAreaCache = null;
        }
        if (_hitCheckAreaCache) {
            _hitCheckAreaCache.destroy();
            _hitCheckAreaCache = null;
        }
        if (_ctrler) {
            _ctrler.destroy();
            _ctrler = null;
        }
        data        = null;
        _rectCache  = null;
        _mcOrgPoint = null;
        _owner      = null;
        super.destroy(dispose);
    }

    public override function render():void {
        super.render();
        _ctrler.render();
    }

    public override function renderAnimate():void {
        if (!_isRenderMainAnimate) {
            return;
        }
        super.renderAnimate();
        renderChildren();
        mc.nextFrame();
        findHitArea();
        if (mc.currentFrame == mc.totalFrames - 1) {
            _ctrler.finish(true);
        }
    }

    public override function hit(hitvo:HitVO, target:IGameSprite):void {
        if (target && _owner && _owner is FighterMain) {
            (
                    _owner as FighterMain
            ).addQi(hitvo.power * GameConfig.QI_ADD_HIT_ASSISTER_RATE);
            GameLogic.hitTarget(hitvo, _owner, target);
        }
    }

    /**
     * 当前攻击的攻击数据 return [FighterHitVO];
     */
    public override function getCurrentHits():Array {
        if (!_hitAreaCache) {
            return null;
        }

        return HitAreaUtil.collectCurrentHits(
                _hitAreaCache.getAreaByFrame(_mainMc.currentFrame) as Array,
                _hitsBuf,
                getCurrentRect
        );
    }

    public function getOwner():IGameSprite {
        return _owner;
    }

    public function setOwner(v:IGameSprite):void {
        _owner = v;
    }

    public function getCtrler():AssisterCtrler {
        return _ctrler;
    }

    public function goFight():void {

        isAttacking = true;
        gotoAndPlay(2);
    }

    public function stop():void {
        _isRenderMainAnimate = false;
    }

    public function gotoAndPlay(frame:Object):void {
        _mainMc.gotoAndStop(frame);
        _isRenderMainAnimate = true;
    }

    public function gotoAndStop(frame:Object):void {
        _mainMc.gotoAndStop(frame);
        _isRenderMainAnimate = false;
    }

    public function getTargets():Vector.<IGameSprite> {
        if (!_owner is FighterMain) {
            return null;
        }
        return (
                _owner as FighterMain
        ).getTargets();
    }

    public function removeSelf():void {
        isAttacking = false;
        isAlive     = false;
        if (onRemove != null) {
            onRemove(this);
        }
    }

    public function getHitCheckRect(name:String):Rectangle {
        var area:Rectangle = getCheckHitRect(name);
        if (area == null) {
            return null;
        }
        return getCurrentRect(area, 'hit_check');
    }

    public function getCheckHitRect(name:String):Rectangle {
        return HitAreaUtil.getCheckHitRect(_mainMc, name, _hitCheckAreaCache, _mainMc);
    }

    public function getCurrentTarget():IGameSprite {
        if (_owner is FighterMain) {
            return (
                    _owner as FighterMain
            ).getCurrentTarget();
        }
        return null;
    }

    /**
     * 播放子MC
     */
    private function renderChildren():void {
        for (var i:int; i < _mainMc.numChildren; i++) {
            var mc:MovieClip = _mainMc.getChildAt(i) as MovieClip;
            if (mc) {
                var mcName:String = mc.name;
                if (mcName == 'bdmn' || mcName.indexOf('atm') != -1) {
                    continue;
                }

                var totalFrames:int = mc.totalFrames;
                if (totalFrames < 2) {
                    continue;
                }

                switch (mc.currentFrameLabel) {
                case 'stop':
                    break;
                default:
                    if (mc.currentFrame == totalFrames) {
                        mc.gotoAndStop(1);
                    }
                    else {
                        mc.nextFrame();
                    }
                }

            }
        }
    }

    private function getCurrentRect(rect:Rectangle, cacheId:String = null):Rectangle {
        return HitAreaUtil.toWorldRect(rect, direct, _x, _y, _rectCache, cacheId);
    }

    private function findHitArea():void {
        if (!_hitAreaCache) {
            return;
        }

        HitAreaUtil.findHitArea(_mainMc, _mainMc.currentFrame, _hitAreaCache, _mainMc, _ctrler.hitModel, false);
    }

}
}
