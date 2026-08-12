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

package net.play5d.game.bvn.ui.language {
import com.greensock.TweenLite;

import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Matrix;

import net.play5d.game.bvn.utils.MCUtils;
import net.play5d.game.bvn.utils.ResUtils;

/**
 * 语言项目
 */
public class CountryItem extends Sprite {

    // 国旗与文本的间隔
    private const GAP:int                   = 25;
    // 高度系数
    private const HEIGHT_COEFFICIENT:Number = 1.5;
    // 宽度系数
    private const WIDTH_COEFFICIENT:Number  = 2;

    public function CountryItem():void {
        _top = new Sprite();

        _mc   = ResUtils.I.createDisplayObject(ResUtils.swfLib.language, '$language$MC_country');
        _txt  = ResUtils.I.createDisplayObject(ResUtils.swfLib.language, '$language$MC_text');
        _base = ResUtils.I.createDisplayObject(ResUtils.swfLib.language, '$language$MC_base');

        _top.addChild(_mc);
        _top.addChild(_txt);

        _pMc = _mc.p;
        _cMc = _mc.c;

        _cMc.stop();
        _txt.stop();

        _txt.x = _mc.width + GAP;

        addChild(_base);
        addChild(_top);

        _base.scaleX = 0;
        _base.height = height * HEIGHT_COEFFICIENT;
        _base.x      = width / 2;
        _base.y      = height / 2;
    }

    // 国旗元件
    private var _mc:$language$MC_country;
    // 对应文本元件
    private var _txt:$language$MC_text;

    // 国旗进度元件
    private var _pMc:MovieClip;
    // 国旗图案元件
    private var _cMc:MovieClip;

    // 底部元件
    private var _base:$language$MC_base;

    /**
     * 宽度（top）
     */
    override public function get width():Number {
        return _top.width;
    }

    /**
     * 高度（top）
     */
    override public function get height():Number {
        return _top.height;
    }

    // 顶部元件
    private var _top:Sprite;

    /**
     * 顶部元件
     */
    public function get top():Sprite {
        return _top;
    }

    // 当前语言
    private var _language:String;

    /**
     * 当前语言
     */
    public function get language():String {
        return _language;
    }

    public function set language(v:String):void {
        _language = v;

        if (
                MCUtils.hasFrameLabel(_cMc, v) &&
                MCUtils.hasFrameLabel(_txt, v)
        ) {
            _cMc.gotoAndStop(v);
            _txt.gotoAndStop(v);
        }
        else {
            _cMc.gotoAndStop(1);
        }

        refreshLayout();
    }

    // 字体类
    private var _fontCls:Class;

    /**
     * 字体类
     */
    public function get fontCls():Class {
        return _fontCls;
    }

    public function set fontCls(v:Class):void {
        _fontCls = v;
    }

    // 是否被选中
    private var _selected:Boolean;
    /** @private 选中条目标 scaleX（相对元件固有宽度） */
    private var _expandScale:Number = 1;
    /** @private 底条固有宽度（scaleX=1） */
    private var _baseNaturalW:Number = 0;

    /**
     * 是否被选中
     */
    public function get selected():Boolean {
        return _selected;
    }

    public function set selected(b:Boolean):void {
        // 新状态和旧状态相同，返回
        if (_selected == b) {
            return;
        }

        _selected = b;

        if (_expandScale <= 0 || _baseNaturalW < 1) {
            refreshLayout();
        }

        TweenLite.killTweensOf(_base);
        // 用 scaleX 代替 width，避免缓动每帧重算布局
        TweenLite.to(_base, 0.2, {
            scaleX: b ? _expandScale : 0
        });
    }

    /**
     * 预热选中条显示对象与缓动，避免首次悬停时卡顿。
     */
    public function warmUp():void {
        if (_expandScale <= 0 || _baseNaturalW < 1) {
            refreshLayout();
        }

        var targetScale:Number = _expandScale > 0 ? _expandScale : 1;
        TweenLite.killTweensOf(_base);
        _base.scaleX = targetScale;

        // 强制光栅化（仅读 width 不够）
        forceRasterizeBase();

        // 非零时长 scale 缓动，打通悬停真实路径
        TweenLite.to(_base, 0.01, {scaleX: targetScale});
        TweenLite.killTweensOf(_base);
        _base.scaleX = _selected ? targetScale : 0;
    }

    /**
     * 注册一个事件侦听器
     * @param type 事件的类型
     * @param listener 处理事件的侦听器函数
     * @param useCapture 确定侦听器是运行于捕获阶段还是运行于目标和冒泡阶段
     * @param priority 事件侦听器的优先级
     * @param useWeakReference 确定对侦听器的引用是强引用，还是弱引用
     */
    override public function addEventListener(
            type:String, listener:Function,
            useCapture:Boolean       = false,
            priority:int             = 0,
            useWeakReference:Boolean = false
    ):void {
        _top.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    /**
     * 移除一个事件侦听器
     * @param type 事件的类型
     * @param listener 处理事件的侦听器函数
     * @param useCapture 确定侦听器是运行于捕获阶段还是运行于目标和冒泡阶段
     */
    override public function removeEventListener(
            type:String, listener:Function,
            useCapture:Boolean = false
    ):void {
        _top.removeEventListener(type, listener, useCapture);
    }

    /**
     * 销毁
     */
    public function destroy():void {
        TweenLite.killTweensOf(_base);

        _pMc = null;
        _cMc = null;

        _mc  = null;
        _txt = null;

        _top  = null;
        _base = null;

        _fontCls = null;
    }

    /**
     * @private 按当前 top 尺寸刷新底条高度与展开 scale。
     */
    private function refreshLayout():void {
        var topW:Number = _top.width;
        var topH:Number = _top.height;

        _base.scaleX = 1;
        if (_baseNaturalW < 1) {
            _baseNaturalW = _base.width;
            if (_baseNaturalW < 1) {
                _baseNaturalW = 1;
            }
        }

        _expandScale = (topW * WIDTH_COEFFICIENT) / _baseNaturalW;
        _base.height = topH * HEIGHT_COEFFICIENT;
        _base.x      = topW / 2;
        _base.y      = topH / 2;
        _base.scaleX = _selected ? _expandScale : 0;
    }

    /**
     * @private 将底条 draw 到临时位图，强制 Flash 完成一次光栅化。
     */
    private function forceRasterizeBase():void {
        if (!_base) {
            return;
        }
        var w:int = Math.ceil(Math.abs(_base.width));
        var h:int = Math.ceil(Math.abs(_base.height));
        if (w < 1 || h < 1) {
            return;
        }
        try {
            var bd:BitmapData = new BitmapData(w, h, true, 0);
            var m:Matrix      = new Matrix();
            m.translate(w * 0.5, h * 0.5);
            bd.draw(_base, m);
            bd.dispose();
        }
        catch (e:Error) {
        }
    }

}
}
