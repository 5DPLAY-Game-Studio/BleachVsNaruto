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

import flash.display.MovieClip;
import flash.display.Sprite;

import net.play5d.game.bvn.utils.MCUtils;
import net.play5d.game.bvn.utils.ResUtils;

/**
 * 语言项目
 */
public class CountryItem extends Sprite {
    include '../../../../../../../include/_INCLUDE_.as';

    // 国旗与文本的间隔
    private const GAP:int                   = 25;
    // 高度系数
    private const HEIGHT_COEFFICIENT:Number = 1.5;
    // 宽度系数
    private const WIDTH_COEFFICIENT:Number  = 2;

    public function CountryItem():void {
        _top = new Sprite();

        _mc   = ResUtils.I.createDisplayObject(ResUtils.swfLib.language, '$language$MC_country');
        _txt  = ResUtils.I.createDisplayObject(ResUtils.swfLib.language, 'language_mc_country_text');
        _base = ResUtils.I.createDisplayObject(ResUtils.swfLib.language, 'language_mc_base');

        _top.addChild(_mc);
        _top.addChild(_txt);

        _pMc = _mc.p;
        _cMc = _mc.c;

        _cMc.stop();
        _txt.stop();

        _txt.x = _mc.width + GAP;

        addChild(_base);
        addChild(_top);

        _base.width  = 0;
        _base.height = height * HEIGHT_COEFFICIENT;
        _base.x      = width / 2;
        _base.y      = height / 2;
    }

    // 国旗元件
    private var _mc:$language$MC_country;
    // 对应文本元件
    private var _txt:language_mc_country_text;

    // 国旗进度元件
    private var _pMc:MovieClip;
    // 国旗图案元件
    private var _cMc:MovieClip;

    // 底部元件
    private var _base:language_mc_base;

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

            return;
        }

        _cMc.gotoAndStop(1);
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

        TweenLite.to(_base, 0.2, {
            width: b ? width * WIDTH_COEFFICIENT : 0
        });
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
        _pMc = null;
        _cMc = null;

        _mc  = null;
        _txt = null;

        _top  = null;
        _base = null;

        _fontCls = null;
    }

//    public function setProgress(progress:Number = 0):void {
//        var difference:Number = 1 - progress;
//
//        if (difference < 0) {
//            difference = 0;
//        }
//        if (difference > 1) {
//            difference = 1;
//        }
//
//        _pMc.scaleY = difference;
//    }
}
}
