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
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.text.Font;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.ctrler.WarmupCtrl;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.LanguageType;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.ui.language.CountryItem;
import net.play5d.game.bvn.utils.MultiLangUtils;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.stage.IStage;

public class LanguageStage implements IStage {

    // 加载进度条
    private var _loadingBar:$language$MC_loadingBar;
    // 显示对象
    private var _ui:Sprite = new Sprite();
    // 背景位图
    private var _backGround:Bitmap;

    // 国家集合
    [ArrayElementType('net.play5d.game.bvn.ui.language.CountryItem')]
    private var _insCountries:Array = [];

    // 点击回调事件
    private var _clickCallBack:Function;
    /** @private 当前选中项，悬停时只切换两项 */
    private var _currentSelected:CountryItem;
    /** @private 正在加载所选语言字体，禁止重复点击 */
    private var _fontLoading:Boolean;

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
        // backGroundData
        // 背景位图数据
        var bgd:BitmapData = ResUtils.I.createBitmapData(
                ResUtils.swfLib.loading,
                '$loading$BM_coverBackGround',
                GameConfig.GAME_SIZE.x,
                GameConfig.GAME_SIZE.y
        );
        _backGround        = new Bitmap(bgd);
        _ui.addChild(_backGround);

        // 初始化加载进度条
        _loadingBar   = ResUtils.I.createDisplayObject(ResUtils.swfLib.language, '$language$MC_loadingBar');
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

        hideLoadingBar(true);

        if (_insCountries) {
            for each (var country:CountryItem in _insCountries) {
                country.removeEventListener(TouchEvent.TOUCH_TAP, touchTapHandler);
                country.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
                country.removeEventListener(MouseEvent.CLICK, clickHandler);
                country.destroy();

                _ui.removeChild(country);
            }

            _insCountries = null;
        }

        _currentSelected = null;
        _clickCallBack   = null;
        _fontLoading     = false;
//        _ui            = null;
    }

    ////////////////////////////////////////////////////////////////////////////////

    /**
     * 加载进度
     * @param progress 加载进度
     */
    private function loadProgress(progress:Number):void {
        if (!_loadingBar) {
            return;
        }

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
        // 字体资源路径集合（与 languages 一一对应，可含重复）
        var loadUrls:Array  = [];

        // 提取语言与对应字体文件路径（进页不预载字体 SWF）
        for each (var langObj:Object in languagesObj) {
            for (var lang:String in langObj) {
                languages.push(lang);
                loadUrls.push(fontDir + langObj[lang]);
            }
        }

        hideLoadingBar(false);
        addLanguageItem(languages, loadUrls);
    }

    /**
     * 字体 SWF 加载最终失败（含一次重试后仍失败）
     * @param url 失败的字体路径
     */
    private function loadFontFail(url:String):void {
        _fontLoading = false;
        hideLoadingBar(false);
        setCountriesInteractive(true);

        // 语言包尚未就绪，无法 GetLang；可见提示走 Debugger
        Debugger.errorMsg('LanguageStage: font SWF load fail: ' + url);
    }

    /**
     * 加载配置失败回调
     */
    private function loadConfigFail():void {
        _fontLoading = false;
        hideLoadingBar(false);
        setCountriesInteractive(true);

        Debugger.errorMsg('LanguageStage: language config / pack load fail');
    }

    ////////////////////////////////////////////////////////////////////////////////

    /**
     * 添加语言项目
     * @param langArr
     * @param fontPathArr 字体路径数组
     */
    private function addLanguageItem(langArr:Array, fontPathArr:Array):void {
        if (langArr.length != fontPathArr.length) {
            ThrowError(Error, GetLang('debug.error.data.language_stage.element_count_mismatch'));
            return;
        }

        // 先预热引擎与音效，再创建列表，缩短可交互后的冷路径
        WarmupCtrl.I.warmEarly();

        var len:int    = langArr.length;
        var gap:Number = GameConfig.GAME_SIZE.y / (
                len + 1
        );

        for (var i:int = 1; i <= len; i++) {
            // 当前语言
            var lang:String     = langArr[i - 1];
            // 当前字体路径（点击后再 loadSWFs）
            var fontPath:String = fontPathArr[i - 1];

            // 国家元件
            var country:CountryItem = new CountryItem();

            country.language   = lang;
            country.fontUrl    = fontPath;
            country.y          = i * gap - country.height / 2;
            country.x          = GameConfig.GAME_SIZE.x / 2 - country.width / 2;
            country.buttonMode = true;

            // 语言帧确定后再设选中，避免展开宽度按默认帧计算
            if (GameData.I.config.language == lang) {
                country.selected = true;
                _currentSelected = country;
            }

            // 进行触摸或者鼠标逻辑处理
            if (GameConfig.TOUCH_MODE) {
                country.addEventListener(TouchEvent.TOUCH_TAP, touchTapHandler);
            }
            else {
                country.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
                country.addEventListener(MouseEvent.CLICK, clickHandler);
            }

            _ui.addChild(country);
            _insCountries.push(country);
        }

        WarmupCtrl.I.warmCountryItems(_insCountries);
    }

    ////////////////////////////////////////////////////////////////////////////////

    private function touchTapHandler(e:Event):void {
        var target:CountryItem = e.currentTarget.parent as CountryItem;
        if (!target || _fontLoading) {
            return;
        }

        if (target.selected) {
            // 当前项已被选中
            // 则执行和鼠标点击时间相同的处理流程
            clickHandler(e);
        }
        else {
            // 当前项未被选中
            // 则执行和鼠标移入事件相同的处理流程
            mouseOverHandler(e);
        }
    }

    /**
     * 鼠标移入事件
     * @param e 鼠标事件
     */
    private function mouseOverHandler(e:Event):void {
        var target:CountryItem = e.currentTarget.parent as CountryItem;
        if (!target || target == _currentSelected || _fontLoading) {
            return;
        }

        SoundCtrl.I.sndSelect();

        if (_currentSelected) {
            _currentSelected.selected = false;
        }
        target.selected  = true;
        _currentSelected = target;
    }

    /**
     * 鼠标点击事件
     * @param e 鼠标事件
     */
    private function clickHandler(e:Event):void {
        if (_fontLoading) {
            return;
        }

        var target:CountryItem = e.currentTarget.parent as CountryItem;
        if (!target) {
            return;
        }

        SoundCtrl.I.sndConfrim();

        // 所选语言
        var language:String = target.language;
        // 所选语言的字体路径
        var fontUrl:String  = target.fontUrl;

        // 如果是不支持的语言，输出不支持
        if (!LanguageType.isSupported(language)) {
            ThrowError(Error, GetLang('debug.error.data.language_stage.unsupported_language'));
            return;
        }

        _fontLoading = true;
        setCountriesInteractive(false);
        showLoadingBar();

        // 仅加载所选语言字体
        AssetManager.I.loadSWFs(
                [fontUrl],
                function ():void {
                    applyLanguageFont(language, fontUrl);
                },
                loadProgress,
                loadFontFail
        );
    }

    /**
     * 注册所选字体并加载语言包
     * @param language 语言码
     * @param fontUrl 字体 SWF 路径
     */
    private function applyLanguageFont(language:String, fontUrl:String):void {
        var fontCls:Class = AssetManager.I.getClass('font', fontUrl);

        Font.registerFont(fontCls);

        GameData.I.config.language = language;
        LANGUAGE                   = language;
        FONT                       = new fontCls() as Font;

        hideLoadingBar(true);

        // 加载语言 Json 文件
        MultiLangUtils.I.initialize(language, _clickCallBack, loadConfigFail);
    }

    /**
     * 显示字体加载进度条
     */
    private function showLoadingBar():void {
        if (!_loadingBar) {
            _loadingBar   = ResUtils.I.createDisplayObject(ResUtils.swfLib.language, '$language$MC_loadingBar');
            _loadingBar.x = 17;
            _loadingBar.y = 555;
        }

        _loadingBar.bar.scaleX = 0;
        if (!_ui.contains(_loadingBar)) {
            _ui.addChild(_loadingBar);
        }
    }

    /**
     * 隐藏加载进度条
     * @param dispose 是否销毁实例
     */
    private function hideLoadingBar(dispose:Boolean):void {
        if (!_loadingBar) {
            return;
        }

        if (_ui.contains(_loadingBar)) {
            _ui.removeChild(_loadingBar);
        }

        if (dispose) {
            _loadingBar = null;
        }
    }

    /**
     * 设置语言列表是否可交互
     * @param enabled 是否可交互
     */
    private function setCountriesInteractive(enabled:Boolean):void {
        if (!_insCountries) {
            return;
        }

        for each (var country:CountryItem in _insCountries) {
            country.mouseEnabled  = enabled;
            country.mouseChildren = enabled;
            country.buttonMode    = enabled;
        }
    }

}
}
