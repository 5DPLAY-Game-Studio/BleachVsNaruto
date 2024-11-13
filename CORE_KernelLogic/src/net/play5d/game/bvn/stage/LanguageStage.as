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

package net.play5d.game.bvn.stage {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.Font;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrl.AssetManager;
import net.play5d.game.bvn.ctrl.SoundCtrl;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.LanguageType;
import net.play5d.game.bvn.utils.MultiLangUtils;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.stage.IStage;

public class LanguageStage implements IStage {
    include "_INCLUDE_.as";

    // 加载进度条
    private var _loadingBar:language_mc_loadingbar;
    // 显示对象
    private var _ui:Sprite = new Sprite();
    // 背景位图
    private var _backGround:Bitmap;

    // 国家集合
    [ArrayElementType('InsCountry')]
    private var _insCountries:Array = [];

    // 点击回调事件
    private var _clickCallBack:Function;

    /**
     * 点击回调事件
     * @param v
     */
    public function set clickCallBack(v:Function):void {
        _clickCallBack = v;
    }

    /**
     * 显示对象
     */
    public function get display():DisplayObject {
        return _ui;
    }

    /**
     * 构建
     */
    public function build():void {
        // 背景位图数据
        var backGroundData:BitmapData =
                    ResUtils.I.createBitmapData(
                            ResUtils.swfLib.common_ui,
                            'cover_bgimg',
                            GameConfig.GAME_SIZE.x,
                            GameConfig.GAME_SIZE.y
                    );
        _backGround                   = new Bitmap(backGroundData)
        _ui.addChild(_backGround);

        // 初始化加载进度条
        _loadingBar   = ResUtils.I.createDisplayObject(ResUtils.swfLib.language, 'language_mc_loadingbar');
        _loadingBar.x = 17;
        _loadingBar.y = 555;
        _ui.addChild(_loadingBar);

        // 加载多语言配置
        AssetManager.I.loadJSON(
                'config/language.json',
                loadConfigBack,
                loadConfigFail
        );
    }

    /**
     * 稍后构建
     */
    public function afterBuild():void {
    }

    /**
     * 销毁
     * @param back 回调函数
     */
    public function destroy(back:Function = null):void {
        if (_backGround) {
            _ui.removeChild(_backGround);

            _backGround = null;
        }

        if (_loadingBar) {
            if (_ui.contains(_loadingBar)) {
                _ui.removeChild(_loadingBar);
            }

            _loadingBar = null;
        }

        if (_insCountries) {
            for each (var country:InsCountry in _insCountries) {
                country.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
                country.removeEventListener(MouseEvent.CLICK, clickHandler);
                country.destroy();

                _ui.removeChild(country);
            }

            _insCountries = null;
        }

        _clickCallBack = null;
//        _ui            = null;
    }

    ////////////////////////////////////////////////////////////////////////////////

    /**
     * 加载进度
     * @param progress 加载进度
     */
    private function loadProgress(progress:Number):void {
        if (progress > 1) {
            progress = 1;
        }

        _loadingBar.bar.scaleX = progress;
    }

    /**
     * 加载配置成功回调
     * @param data 加载的数据
     */
    private function loadConfigBack(data:Object):void {
        // 字体目录
        var fontDir:String     = data['font_dir'];
        // 语言对象集合 {"language": "font_swf_path"}
        var languagesObj:Array = data['languages'];

        // 语言集合
        var languages:Array = [];
        // 字体资源路径集合
        var loadUrls:Array  = [];

        // 提取语言与对应字体文件路径
        for each (var langObj:Object in languagesObj) {
            for (var lang:String in langObj) {
                languages.push(lang);
                loadUrls.push(fontDir + langObj[lang]);
            }
        }

//        trace(languages);
//        trace(loadUrls);

        // 开始载入字体
        AssetManager.I.loadSWFs(
                loadUrls,
                function ():void {
                    // 载入字体成功回调

                    _loadingBar.visible = false;
                    _ui.removeChild(_loadingBar);

                    // 添加语言项目
                    addLanguageItem(languages, loadUrls);
                },
                loadProgress
        );
    }

    /**
     * 加载配置失败回调
     */
    private function loadConfigFail():void {

    }

    ////////////////////////////////////////////////////////////////////////////////

//    /**
//     * 注册字体
//     * @param fontPathArr 字体路径数组
//     */
//    private function registerFont(fontPathArr:Array):void {
//        for each (var fontPath:String in fontPathArr) {
//            var fontCls:Class = AssetManager.I.getClass('font', fontPath);
////            trace(new fontCls().fontName);
//            // 注册字体
//            Font.registerFont(fontCls);
//        }
//    }

    /**
     * 添加语言项目
     * @param langArr
     * @param fontPathArr 字体路径数组
     */
    private function addLanguageItem(langArr:Array, fontPathArr:Array):void {
        if (langArr.length != fontPathArr.length) {
            throw new Error('语言元素数目不匹配！');
        }

        var len:int    = langArr.length;
        var gap:Number = GameConfig.GAME_SIZE.y / (
                len + 1
        );

        for (var i:int = 1; i <= len; i++) {
            // 当前语言
            var lang:String     = langArr[i - 1];
            // 当前字体路径
            var fontPath:String = fontPathArr[i - 1];
            // 当前字体类
            var fontCls:Class   = AssetManager.I.getClass('font', fontPath);

            // 注册字体
            Font.registerFont(fontCls);

            // 国家元件
            var country:InsCountry = new InsCountry();

            // 判断是否和存档的语言一致
            if (GameData.I.config.language == lang) {
                country.selected = true;
            }
            country.language   = lang;
            country.fontCls    = fontCls;
            country.y          = i * gap - country.height / 2;
            country.x          = GameConfig.GAME_SIZE.x / 2 - country.width / 2;
            country.buttonMode = true;
            country.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
//            country.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
            country.addEventListener(MouseEvent.CLICK, clickHandler);

            _ui.addChild(country);
            _insCountries.push(country);
        }
    }

    ////////////////////////////////////////////////////////////////////////////////

    /**
     * 鼠标移入事件
     * @param e 鼠标事件
     */
    private function mouseOverHandler(e:MouseEvent):void {
        SoundCtrl.I.sndSelect();

        var target:InsCountry = e.currentTarget.parent as InsCountry;
        target.selected       = true;

        // 设置其他的 InsCountry 元件 selected 属性为 false
        for each (var country:InsCountry in _insCountries) {
            if (country != target) {
                country.selected = false;
            }
        }
    }

//    /**
//     * 鼠标移出事件
//     * @param e 鼠标事件
//     */
//    private function mouseOutHandler(e:MouseEvent):void {
//        var target:InsCountry = e.currentTarget.parent as InsCountry;
//        target.selected       = false;
//    }

    /**
     * 鼠标点击事件
     * @param e 鼠标事件
     */
    private function clickHandler(e:MouseEvent):void {
        SoundCtrl.I.sndConfrim();

        var target:InsCountry = e.currentTarget.parent as InsCountry;
        // 所选语言
        var language:String   = target.language;
        // 所选语言的字体类
        var fontCls:Class     = target.fontCls;

        // 如果是不支持的语言，输出不支持
        if (!LanguageType.isSupported(language)) {
            throw new Error('不支持的语言！');
        }

        GameData.I.config.language = language;
        LanguageType.currentLang   = language;
        FONT                       = new fontCls() as Font;

        // 加载语言 Json 文件
        MultiLangUtils.I.initialize(language, _clickCallBack, loadConfigFail);
    }

}
}

import com.greensock.TweenLite;

import flash.display.MovieClip;
import flash.display.Sprite;

import net.play5d.game.bvn.utils.MCUtils;
import net.play5d.game.bvn.utils.ResUtils;

/**
 * 内部国家语言类
 */
class InsCountry extends Sprite {
    // 国旗与文本的间隔
    private const GAP:int                   = 25;
    // 高度系数
    private const HEIGHT_COEFFICIENT:Number = 1.5;
    // 宽度系数
    private const WIDTH_COEFFICIENT:Number  = 2;

    public function InsCountry():void {
        _top = new Sprite();

        _mc   = ResUtils.I.createDisplayObject(ResUtils.swfLib.language, 'language_mc_country');
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
    private var _mc:language_mc_country;
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
