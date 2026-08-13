/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.test {
import feathers.style.Theme;
import feathers.themes.steel.SteelTheme;

import flash.display.NativeWindow;
import flash.display.NativeWindowDisplayState;
import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowRenderMode;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.NativeWindowBoundsEvent;
import flash.events.NativeWindowDisplayStateEvent;

/**
 * 吸附于主窗口右侧的调试 NativeWindow。
 *
 * <p>与主窗同为 <code>gpu</code> 渲染模式；主窗移动/缩放时同步位置与高度，
 * 并将内容在窗口客户区内居中。亮暗模式由外部按钮调用 <code>toggleDarkMode()</code>，
 * 作用于共享 <code>SteelTheme</code>，并通过 <code>onDarkModeChange</code> 通知持久化。</p>
 *
 * @example
 * <listing version="3.0">
 * var win:DockedDebugWindow = new DockedDebugWindow(stage.nativeWindow);
 * win.onDarkModeChange = onDarkModeChange;
 * win.open(root, inner, 'Debug', 400, 600, 520, theme, true);
 * </listing>
 * @see #open()
 * @see #close()
 * @see #toggleDarkMode()
 * @see #darkMode
 */
public class DockedDebugWindow {
    /** @private 默认内容宽 */
    private static const DEFAULT_WIDTH:Number = 400;
    /** @private 默认内容高 */
    private static const DEFAULT_HEIGHT:Number = 600;
    /** @private 默认内容底边（用于垂直居中） */
    private static const DEFAULT_CONTENT_BOTTOM:Number = 520;

    /**
     * 亮暗切换回调 <code>function(darkMode:Boolean):void</code>。
     */
    public var onDarkModeChange:Function;

    /** @private */
    private var _mainWindow:NativeWindow;
    /** @private */
    private var _window:NativeWindow;
    /** @private 根容器（绘制背景） */
    private var _root:Sprite;
    /** @private 内容组（居中） */
    private var _inner:Sprite;
    /** @private */
    private var _panelWidth:Number;
    /** @private */
    private var _panelHeight:Number;
    /** @private */
    private var _contentBottom:Number;
    /** @private 共享 Steel 主题（不由本类 dispose） */
    private var _theme:SteelTheme;
    /** @private */
    private var _darkMode:Boolean;
    /** @private 正在执行吸附，避免 MOVE 回调递归 */
    private var _docking:Boolean;

    /**
     * @param mainWindow 游戏主窗口。
     */
    public function DockedDebugWindow(mainWindow:NativeWindow) {
        _mainWindow = mainWindow;
    }

    /**
     * 是否已打开且未关闭。
     * @return 打开中为 <code>true</code>。
     * @default false
     */
    public function get isOpen():Boolean {
        return _window != null && !_window.closed;
    }

    /**
     * 当前是否暗色模式。
     * @return 暗色为 <code>true</code>。
     * @default true
     */
    public function get darkMode():Boolean {
        return _darkMode;
    }

    /**
     * 打开调试窗并放入内容，吸附到主窗右侧。
     *
     * @param root 根容器，用于铺满背景。
     * @param inner 内容组，在客户区内居中；省略则与 <code>root</code> 相同。
     * @param title 窗口标题。
     * @param panelWidth 设计内容宽。
     * @param panelHeight 设计内容高。
     * @param contentBottom 内容底边 y，用于垂直居中。
     * @param theme 共享 <code>SteelTheme</code>；提供时挂到本窗 stage。
     * @param darkMode 初始是否暗色。
     * @example
     * <listing version="3.0">
     * win.open(panelRoot, panelInner, 'Debug', 400, 600, 520, theme, true);
     * </listing>
     */
    public function open(
            root         :Sprite,
            inner        :Sprite     = null,
            title        :String     = 'Debug',
            panelWidth   :Number     = DEFAULT_WIDTH,
            panelHeight  :Number     = DEFAULT_HEIGHT,
            contentBottom:Number     = DEFAULT_CONTENT_BOTTOM,
            theme        :SteelTheme = null,
            darkMode     :Boolean    = true
    ):void {
        if (!_mainWindow || isOpen || !root) {
            return;
        }

        _root          = root;
        _inner         = inner || root;
        _panelWidth    = panelWidth;
        _panelHeight   = panelHeight;
        _contentBottom = contentBottom;
        _theme         = theme;
        _darkMode      = darkMode;

        var options:NativeWindowInitOptions = new NativeWindowInitOptions();
        options.type         = NativeWindowType.NORMAL;
        options.systemChrome = NativeWindowSystemChrome.STANDARD;
        // 与 app.xml 主窗 renderMode=gpu 一致，否则 NativeWindow 抛 #1508
        options.renderMode   = NativeWindowRenderMode.GPU;
        options.transparent  = false;
        options.resizable    = false;
        options.maximizable  = false;
        options.minimizable  = false;

        _window                 = new NativeWindow(options);
        _window.title           = title;
        _window.stage.scaleMode = StageScaleMode.NO_SCALE;
        _window.stage.align     = StageAlign.TOP_LEFT;
        _window.stage.color     = currentBgColor();
        // 独立 stage，需单独关闭焦点黄框（主窗 stageFocusRect 不影响此处）
        _window.stage.stageFocusRect = false;

        if (_theme) {
            _theme.darkMode = _darkMode;
            Theme.setTheme(_theme, _window.stage, false);
        }

        _window.stage.addChild(_root);

        _window.width  = _panelWidth;
        _window.height = _panelHeight;
        _window.activate();

        // 按系统边框修正，使内容区达到面板设计尺寸
        var chromeW:Number = _window.width - _window.stage.stageWidth;
        var chromeH:Number = _window.height - _window.stage.stageHeight;
        _window.width  = _panelWidth + chromeW;
        _window.height = _panelHeight + chromeH;

        dock();
        layoutContent();

        _mainWindow.addEventListener(NativeWindowBoundsEvent.MOVE, onBoundsChange);
        _mainWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, onBoundsChange);
        _mainWindow.addEventListener(
                NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,
                onMainDisplayStateChange
        );
        _mainWindow.addEventListener(Event.CLOSING, onMainClosing);
        _window.addEventListener(NativeWindowBoundsEvent.MOVE, onBoundsChange);
    }

    /**
     * 切换亮暗模式并通知 <code>onDarkModeChange</code>。
     * @example
     * <listing version="3.0">
     * win.toggleDarkMode();
     * </listing>
     */
    public function toggleDarkMode():void {
        applyDarkMode(!_darkMode, true);
    }

    /**
     * 同步亮暗模式（不触发 <code>onDarkModeChange</code>）。
     * @param darkMode 是否暗色。
     * @example
     * <listing version="3.0">
     * win.setDarkMode(false);
     * </listing>
     */
    public function setDarkMode(darkMode:Boolean):void {
        applyDarkMode(darkMode, false);
    }

    /**
     * 关闭调试窗并移除监听。
     */
    public function close():void {
        unbindMainListeners();

        if (_window && !_window.closed) {
            _window.close();
        }

        _window = null;
        _root   = null;
        _inner  = null;
        _theme  = null;
    }

    /**
     * 吸附到主窗右侧并对齐高度。
     */
    private function dock():void {
        if (!isOpen || _docking || !_mainWindow) {
            return;
        }

        var dockX:Number = _mainWindow.x + _mainWindow.width;
        var dockY:Number = _mainWindow.y;

        _docking = true;
        _window.height = _mainWindow.height;
        _window.x      = dockX;
        _window.y      = dockY;
        _docking = false;

        layoutContent();
    }

    /**
     * 将内容在窗口客户区内居中，并铺满背景。
     */
    private function layoutContent():void {
        if (!isOpen || !_root) {
            return;
        }

        var sw:Number = _window.stage.stageWidth;
        var sh:Number = _window.stage.stageHeight;
        var bg:uint   = currentBgColor();

        _window.stage.color = bg;
        _root.graphics.clear();
        _root.graphics.beginFill(bg, 1);
        _root.graphics.drawRect(0, 0, sw, sh);
        _root.graphics.endFill();

        if (_inner) {
            _inner.x = (sw - _panelWidth) * 0.5;
            _inner.y = Math.max(0, (sh - _contentBottom) * 0.5);
        }
    }

    /**
     * 应用亮暗并可选通知外部。
     * @param darkMode 是否暗色。
     * @param notify 是否回调 <code>onDarkModeChange</code>。
     */
    private function applyDarkMode(darkMode:Boolean, notify:Boolean):void {
        _darkMode = darkMode;
        if (_theme) {
            _theme.darkMode = _darkMode;
        }
        layoutContent();

        if (notify && onDarkModeChange != null) {
            onDarkModeChange(_darkMode);
        }
    }

    /** @private */
    private function currentBgColor():uint {
        return DebugThemeChrome.bgColor(_darkMode);
    }

    private function onBoundsChange(e:NativeWindowBoundsEvent):void {
        dock();
    }

    private function onMainDisplayStateChange(e:NativeWindowDisplayStateEvent):void {
        if (!isOpen) {
            return;
        }

        if (_mainWindow.displayState == NativeWindowDisplayState.MINIMIZED) {
            _window.visible = false;
        }
        else {
            _window.visible = true;
            dock();
        }
    }

    private function onMainClosing(e:Event):void {
        close();
    }

    private function unbindMainListeners():void {
        if (!_mainWindow) {
            return;
        }

        _mainWindow.removeEventListener(NativeWindowBoundsEvent.MOVE, onBoundsChange);
        _mainWindow.removeEventListener(NativeWindowBoundsEvent.RESIZE, onBoundsChange);
        _mainWindow.removeEventListener(
                NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,
                onMainDisplayStateChange
        );
        _mainWindow.removeEventListener(Event.CLOSING, onMainClosing);

        if (_window && !_window.closed) {
            _window.removeEventListener(NativeWindowBoundsEvent.MOVE, onBoundsChange);
        }
    }
}
}
