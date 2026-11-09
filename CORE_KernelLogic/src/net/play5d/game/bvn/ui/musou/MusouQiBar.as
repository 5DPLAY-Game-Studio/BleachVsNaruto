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

package net.play5d.game.bvn.ui.musou {
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Point;

import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.ui.QiBarScale;

/**
 * 无双气条。气按 100 一格，超过 3 记成 3。差小于 0.01 时贴齐，否则每帧补上差值的 0.4。结果低于 0.0001 时写成 0.0001。满 3 时藏起三截并只播一次满条。掉下去时从第 1 帧再播，三截按大于 0、1、2 显示。
 */
public class MusouQiBar {

    /**
     * 记下三截气条和满条影片。满条先停在第 1 帧并隐藏。缺件时抛错。
     *
     * @param ui 气条容器。
     * @throws TypeError 容器或子件缺失时。
     */
    public function MusouQiBar(ui:Sprite) {
        _ui = ui;

        _bar1 = _ui.getChildByName('bar1');
        _bar2 = _ui.getChildByName('bar2');
        _bar3 = _ui.getChildByName('bar3');

        _maxBar = _ui.getChildByName('maxmc') as MovieClip;
        _maxBar.gotoAndStop(1);
        _maxBar.visible = false;
    }
    private var _ui:Sprite;
    private var _fighter:FighterMain;
    private var _qiRate:Number   = 0;
    private var _orgPose:Point;
    private var _tweenSpd:Number = 0.5;
    private var _moveFin:Boolean = true;
    private var _moveType:int    = 0;
    private var _isFadeIn:Boolean;
    private var _isRenderAnimate:Boolean;
    private var _faceBp:Bitmap;
    private var _bar1:DisplayObject;
    private var _bar2:DisplayObject;
    private var _bar3:DisplayObject;
    private var _maxBar:MovieClip;
    private var _maxPlaying:Boolean;
    private var _process:Number  = 0;

    /**
     * 记下角色。传 null 时，下次渲染抛错。
     *
     * @param fighter 角色。
     * @example
     * <listing version="3.0">
     * bar.setFighter(fighter);
     * </listing>
     */
    public function setFighter(fighter:FighterMain):void {
        _fighter = fighter;
    }

    /**
     * 按气量推进显示。没有角色时抛错。
     *
     * @throws TypeError 还没有角色时。
     * @example
     * <listing version="3.0">
     * bar.render();
     * </listing>
     */
    public function render():void {
        _qiRate = _fighter.qi / 100;
        if (_qiRate > 3) {
            _qiRate = 3;
        }

        var per:Number  = _process;
        var diff:Number = _qiRate - per;
        if (Math.abs(diff) < 0.01) {
            per = _qiRate;
        }
        else {
            per += (
                    diff * 0.4
            );
        }
        if (per < 0.0001) {
            per = 0.0001;
        }
        setProcess(per);
    }

    //0-3
    /**
     * 直接写成这个进度。大于等于 3 时只留满条。
     *
     * @param v 进度，通常在 0 到 3。
     * @example
     * <listing version="3.0">
     * bar.setProcess(1.5);
     * </listing>
     */
    public function setProcess(v:Number):void {
        _process        = v;
        _maxBar.visible = v >= 3;
        if (_maxBar.visible) {
            _bar1.visible = _bar2.visible = _bar3.visible = false;
            if (!_maxPlaying) {
                _maxBar.gotoAndPlay(2);
                _maxPlaying = true;
            }
        }
        else {
            if (_maxPlaying) {
                _maxBar.gotoAndPlay(1);
                _maxPlaying = false;
            }
            _bar1.visible = v > 0;
            _bar2.visible = v > 1;
            _bar3.visible = v > 2;
        }

        QiBarScale.apply(_bar1, _bar2, _bar3, v);
    }

}
}
