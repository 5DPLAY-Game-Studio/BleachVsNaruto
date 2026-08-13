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
import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ScrollContainer;
import feathers.controls.TextInput;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.style.Theme;
import feathers.text.TextFormat;
import feathers.themes.steel.SteelTheme;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowRenderMode;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.events.NativeWindowBoundsEvent;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.utils.getQualifiedClassName;

import net.play5d.game.bvn.ctrler.GameRender;
import net.play5d.game.bvn.debug.DebugSpriteBounds;
import net.play5d.game.bvn.interfaces.IGameSprite;

/**
 * 精灵公开属性检查 / 编辑 NativeWindow。
 *
 * <p>跟随 <code>DebugSpriteBounds.trackedSprite</code>：左键锁定后以 Feathers
 * 控件列出可读公开属性；简单类型可编辑并写回实体，勾选锁定后每帧强制写回冻结值。
 * 使用外部共享 <code>SteelTheme</code>，亮暗由调试窗统一切换。
 * 不可直接编辑的属性可点击打开详情小窗（优先 <code>toString</code>，否则递归公开属性）。
 * 每帧同步未聚焦字段；未锁定或销毁后清空等待下次锁定。</p>
 *
 * @example
 * <listing version="3.0">
 * var win:SpriteInspectorWindow = new SpriteInspectorWindow(stage.nativeWindow, theme, true);
 * win.start();
 * </listing>
 * @see #start()
 * @see #stop()
 * @see net.play5d.game.bvn.debug.DebugSpriteBounds#trackedSprite
 */
public class SpriteInspectorWindow {
    /** @private */
    private static const PANEL_WIDTH:Number = 384;
    /** @private */
    private static const PANEL_HEIGHT:Number = 480;
    /** @private */
    private static const PAD:Number = 6;
    /** @private */
    private static const HEADER_H:Number = 22;
    /** @private */
    private static const ROW_H:Number = 22;
    /** @private */
    private static const ROW_GAP:Number = 2;
    /** @private */
    private static const NAME_W:Number = 120;
    /** @private 属性值锁定勾选宽 */
    private static const LOCK_W:Number = 20;
    /** @private */
    private static const VALUE_W:Number = 200;
    /** @private 控件字号 */
    private static const FONT_SIZE:Number = 11;
    /** @private 分帧建行每批数量 */
    private static const BUILD_BATCH:int = 16;
    /** @private 等待锁定时的提示文案 */
    private static const IDLE_TEXT:String = '点击实体以锁定跟踪\n右键清除跟踪';

    /** @private */
    private var _mainWindow:NativeWindow;
    /** @private */
    private var _window:NativeWindow;
    /** @private */
    private var _root:Sprite;
    /** @private 顶部类名 / 空闲提示 */
    private var _header:Label;
    /** @private 属性行滚动容器 */
    private var _scroll:ScrollContainer;
    /** @private 滚动区背景（随主题重绘） */
    private var _scrollBg:Sprite;
    /** @private 共享 Steel 主题（不 dispose） */
    private var _theme:SteelTheme;
    /** @private 暗色模式（与共享主题同步，驱动底色/文字） */
    private var _darkMode:Boolean = true;
    /** @private */
    private var _running:Boolean;
    /** @private 当前跟踪实体 */
    private var _target:IGameSprite;
    /** @private 已构建控件的目标 */
    private var _builtFor:IGameSprite;
    /** @private 用户手动关窗后，待再次锁定才重开 */
    private var _userClosed:Boolean;
    /** @private 同步写控件时忽略 CHANGE */
    private var _syncing:Boolean;
    /** @private 当前是否处于等待锁定界面 */
    private var _idleMode:Boolean;
    /** @private 窗口装饰条宽度 */
    private var _chromeW:Number;
    /** @private 窗口装饰条高度 */
    private var _chromeH:Number;
    /** @private 行列表（顺序遍历） */
    private var _rowList:Array = [];
    /** @private 待分帧构建的属性 */
    private var _pendingProps:Array;
    /** @private 分帧构建游标 */
    private var _buildIndex:int;
    /** @private Scroll 布局（建行时暂卸） */
    private var _scrollLayout:VerticalLayout;
    /** @private 缓存主文字格式 */
    private var _tfMain:TextFormat;
    /** @private 缓存次文字格式 */
    private var _tfSecondary:TextFormat;
    /** @private 只读属性详情小窗 */
    private var _detailPopup:ObjectInspectPopup;

    /**
     * @param mainWindow 游戏主窗口，用于定位属性窗。
     * @param theme 共享 <code>SteelTheme</code>。
     * @param darkMode 初始是否暗色。
     */
    public function SpriteInspectorWindow(
            mainWindow:NativeWindow,
            theme     :SteelTheme,
            darkMode  :Boolean = true
    ) {
        _mainWindow = mainWindow;
        _theme      = theme;
        _darkMode   = darkMode;
    }

    /**
     * 同步亮暗模式并刷新展示（共享主题已由外部改 <code>darkMode</code>）。
     * @param darkMode 是否暗色。
     * @example
     * <listing version="3.0">
     * inspector.setDarkMode(false);
     * </listing>
     */
    public function setDarkMode(darkMode:Boolean):void {
        _darkMode    = darkMode;
        _tfMain      = null;
        _tfSecondary = null;
        if (!isOpen) {
            return;
        }

        applyThemeChrome();
        if (_detailPopup) {
            _detailPopup.setDarkMode(_darkMode);
        }
        if (_target && !_idleMode) {
            buildRows();
        }
        else if (_idleMode) {
            applyAllTextFormats();
        }
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
     * 开始跟随跟踪实体并刷新 / 编辑属性。
     * @example
     * <listing version="3.0">
     * inspector.start();
     * </listing>
     */
    public function start():void {
        if (_running) {
            return;
        }

        _running = true;
        GameRender.addAfter(onRender);
        ensureOpen();
        showIdle();
    }

    /**
     * 停止刷新并关闭窗口。
     * @example
     * <listing version="3.0">
     * inspector.stop();
     * </listing>
     */
    public function stop():void {
        if (!_running) {
            return;
        }

        _running    = false;
        _userClosed = false;
        _idleMode   = false;
        _builtFor   = null;
        _target     = null;
        GameRender.removeAfter(onRender);
        closeDetailPopup();
        closeWindow();
    }

    /**
     * 每帧：有跟踪则构建/同步属性行；无跟踪则显示等待。
     */
    private function onRender():void {
        if (!DebugSpriteBounds.I.isRender) {
            _target     = null;
            _builtFor   = null;
            _idleMode   = false;
            _userClosed = false;
            closeWindow();

            return;
        }

        var tracked:IGameSprite = DebugSpriteBounds.I.trackedSprite;
        if (!tracked || tracked.isDestroyed()) {
            _target   = null;
            _builtFor = null;
            if (_userClosed) {
                return;
            }
            ensureOpen();
            if (isOpen && !_idleMode) {
                showIdle();
            }

            return;
        }

        if (_userClosed) {
            _userClosed = false;
        }

        ensureOpen();
        if (!isOpen) {
            return;
        }

        _idleMode = false;
        _target   = tracked;
        if (_builtFor != _target) {
            buildRows();
            _builtFor = _target;
        }
        else if (_pendingProps) {
            flushBuildBatch();
        }
        else {
            syncRows();
        }
    }

    /**
     * 显示等待锁定提示，并清空属性行。
     */
    private function showIdle():void {
        if (!isOpen || !_header) {
            return;
        }

        _idleMode     = true;
        _window.title = 'Sprite Inspector';
        _header.text  = IDLE_TEXT;
        clearRows();
        closeDetailPopup();
        _scroll.visible = false;
        applyAllTextFormats();
        resizeToDefault();
    }

    /**
     * 确保属性窗已创建并显示。
     */
    private function ensureOpen():void {
        if (isOpen) {
            return;
        }

        if (!_mainWindow || _mainWindow.closed) {
            return;
        }

        var options:NativeWindowInitOptions = new NativeWindowInitOptions();
        options.type         = NativeWindowType.NORMAL;
        options.systemChrome = NativeWindowSystemChrome.STANDARD;
        options.renderMode   = NativeWindowRenderMode.GPU;
        options.transparent  = false;
        options.resizable    = true;
        options.maximizable  = false;
        options.minimizable  = true;

        _window                 = new NativeWindow(options);
        _window.title           = 'Sprite Inspector';
        _window.stage.scaleMode = StageScaleMode.NO_SCALE;
        _window.stage.align     = StageAlign.TOP_LEFT;
        _window.stage.stageFocusRect = false;

        // 挂共享主题到本窗 stage，再创建控件
        if (_theme) {
            _theme.darkMode = _darkMode;
            _theme.fontName = DebugThemeChrome.fontName();
            Theme.setTheme(_theme, _window.stage, false);
        }

        _root = new Sprite();
        _window.stage.addChild(_root);

        _header          = new Label('');
        _header.wordWrap = true;
        _header.x        = PAD;
        _header.y        = PAD;
        _root.addChild(_header);

        _scrollLayout               = new VerticalLayout();
        _scrollLayout.gap           = ROW_GAP;
        _scrollLayout.paddingTop    = 1;
        _scrollLayout.paddingBottom = 1;
        _scrollLayout.paddingLeft   = 1;
        _scrollLayout.paddingRight  = 1;

        _scrollBg = new Sprite();

        _scroll                = new ScrollContainer();
        _scroll.layout         = _scrollLayout;
        _scroll.backgroundSkin = _scrollBg;
        _scroll.x             = PAD;
        _root.addChild(_scroll);

        applyThemeChrome();

        _window.width  = PANEL_WIDTH;
        _window.height = PANEL_HEIGHT;
        _window.activate();

        _chromeW = _window.width - _window.stage.stageWidth;
        _chromeH = _window.height - _window.stage.stageHeight;
        resizeToDefault();

        _window.addEventListener(Event.CLOSE, onWindowClose);
        _window.addEventListener(NativeWindowBoundsEvent.RESIZE, onWindowResize);
        _mainWindow.addEventListener(Event.CLOSING, onMainClosing);
    }

    /**
     * 按当前模式更新底色与文字颜色。
     */
    private function applyThemeChrome():void {
        if (!isOpen) {
            return;
        }

        var bg:uint = currentBgColor();
        _window.stage.color = bg;

        if (_scrollBg) {
            _scrollBg.graphics.clear();
            _scrollBg.graphics.beginFill(bg, 1);
            _scrollBg.graphics.drawRect(0, 0, 16, 16);
            _scrollBg.graphics.endFill();
        }

        applyAllTextFormats();
        layout();
    }

    /**
     * 当前主题对应的窗口底色。
     * @return 底色。
     */
    private function currentBgColor():uint {
        return DebugThemeChrome.bgColor(_darkMode);
    }

    /**
     * 生成与当前亮暗模式、全局 FONT 匹配的文字格式（缓存）。
     * @param secondary 是否次要文字色。
     * @return 文本格式。
     */
    private function makeTextFormat(secondary:Boolean = false):TextFormat {
        if (secondary) {
            if (!_tfSecondary) {
                _tfSecondary = DebugThemeChrome.textFormat(_darkMode, true, FONT_SIZE);
            }
            return _tfSecondary;
        }
        if (!_tfMain) {
            _tfMain = DebugThemeChrome.textFormat(_darkMode, false, FONT_SIZE);
        }
        return _tfMain;
    }

    /**
     * 将当前模式文字色应用到页眉与属性行。
     */
    private function applyAllTextFormats():void {
        if (_header) {
            _header.textFormat = makeTextFormat(false);
        }

        var n:int = _rowList.length;
        for (var i:int = 0; i < n; i++) {
            var row:Object = _rowList[i];
            if (row.nameLabel) {
                (row.nameLabel as Label).textFormat = makeTextFormat(true);
            }

            if (row.kind == 'label') {
                (row.control as Label).textFormat = makeTextFormat(false);
            }
            else if (row.kind == 'text') {
                (row.control as TextInput).textFormat = makeTextFormat(false);
            }
        }
    }

    /**
     * 为当前目标构建可编辑属性行，并适配窗口高度。
     */
    private function buildRows():void {
        clearRows();
        _scroll.visible = true;

        var qname:String = getQualifiedClassName(_target);
        var short:String = InspectPropUtil.shortClassName(_target);
        _window.title    = 'Sprite · ' + short;
        _header.text     = qname;

        var props:Array = InspectPropUtil.getPublicProps(_target);
        fitWindowToRows(props.length);
        _pendingProps = props;
        _buildIndex   = 0;
        if (_scroll) {
            _scroll.layout = null;
        }
        flushBuildBatch();
    }

    /**
     * 分帧追加属性行，避免一次创建过多控件卡顿。
     */
    private function flushBuildBatch():void {
        if (!_pendingProps) {
            return;
        }

        var end:int = _buildIndex + BUILD_BATCH;
        if (end > _pendingProps.length) {
            end = _pendingProps.length;
        }
        while (_buildIndex < end) {
            addRow(_pendingProps[_buildIndex] as Object);
            _buildIndex++;
        }

        if (_buildIndex < _pendingProps.length) {
            return;
        }

        _pendingProps = null;
        if (_scroll && _scrollLayout) {
            _scroll.layout = _scrollLayout;
        }
        syncRows();
        applyAllTextFormats();
    }

    /**
     * 添加一行属性控件。
     * @param meta 属性元数据 <code>{name, type, writable}</code>。
     */
    private function addRow(meta:Object):void {
        var propName:String   = String(meta.name);
        var typeName:String   = String(meta.type);
        var writable:Boolean  = Boolean(meta.writable);
        var editable:Boolean = writable && InspectPropUtil.isEditableType(typeName);

        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.gap                  = 4;
        hLayout.verticalAlign        = VerticalAlign.MIDDLE;

        var row:LayoutGroup = new LayoutGroup();
        row.layout          = hLayout;
        row.width           = NAME_W + LOCK_W + VALUE_W + 10;
        row.height          = ROW_H;

        var nameLabel:Label = new Label(propName);
        nameLabel.width      = NAME_W;
        nameLabel.height     = ROW_H;
        nameLabel.textFormat = makeTextFormat(true);
        row.addChild(nameLabel);

        var lockCheck:Check = new Check();
        lockCheck.text         = '';
        lockCheck.width        = LOCK_W;
        lockCheck.height       = ROW_H;
        lockCheck.mouseEnabled = writable;
        lockCheck.alpha        = writable ? 1 : 0.35;
        if (writable) {
            lockCheck.addEventListener(Event.CHANGE, onLockChange);
        }
        row.addChild(lockCheck);

        var kind:String = 'label';
        var control:DisplayObject;

        if (editable && typeName == 'Boolean') {
            var check:Check = new Check();
            check.text      = '';
            check.width     = VALUE_W;
            check.height    = ROW_H;
            check.addEventListener(Event.CHANGE, onCheckChange);
            control = check;
            kind    = 'check';
        }
        else if (editable) {
            var input:TextInput = new TextInput('');
            input.width         = VALUE_W;
            input.height        = ROW_H;
            input.textFormat    = makeTextFormat(false);
            input.addEventListener(Event.CHANGE, onInputChange);
            input.addEventListener(FocusEvent.FOCUS_OUT, onInputFocusOut);
            control = input;
            kind    = 'text';
        }
        else {
            var valueLabel:Label = new Label('');
            valueLabel.width         = VALUE_W;
            valueLabel.height        = ROW_H;
            valueLabel.textFormat    = makeTextFormat(false);
            valueLabel.buttonMode    = true;
            valueLabel.useHandCursor = true;
            valueLabel.mouseChildren = false;
            valueLabel.addEventListener(MouseEvent.CLICK, onReadonlyClick);
            control = valueLabel;
        }

        row.addChild(control);
        _scroll.addChild(row);

        var metaRow:Object = {
            name        : propName,
            type        : typeName,
            writable    : writable,
            kind        : kind,
            control     : control,
            nameLabel   : nameLabel,
            lockCheck   : lockCheck,
            locked      : false,
            lockedValue : undefined,
            lastDisplay : null,
            lastRaw     : undefined,
            lastSelected: undefined
        };
        _rowList[_rowList.length] = metaRow;
    }

    /**
     * 点击只读属性：打开详情小窗。
     * @param e 鼠标事件。
     */
    private function onReadonlyClick(e:MouseEvent):void {
        var label:Label = e.currentTarget as Label;
        var meta:Object = findRowByControl(label);
        if (!meta || !_target) {
            return;
        }

        var value:*;
        try {
            value = _target[meta.name];
        }
        catch (err:Error) {
            return;
        }

        openDetailPopup(String(meta.name), value);
    }

    /**
     * 打开或刷新属性详情小窗（可编辑简单类型并实时刷新）。
     * @param title 属性名。
     * @param value 属性值。
     */
    private function openDetailPopup(title:String, value:*):void {
        if (!_window || _window.closed) {
            return;
        }

        if (!_detailPopup) {
            _detailPopup = new ObjectInspectPopup(_window, _theme, _darkMode, 0);
        }
        else {
            _detailPopup.setDarkMode(_darkMode);
        }
        _detailPopup.open(title, value);
    }

    /**
     * 关闭详情小窗。
     */
    private function closeDetailPopup():void {
        if (_detailPopup) {
            _detailPopup.close();
            _detailPopup = null;
        }
    }

    /**
     * 同步未聚焦的属性控件数值；已锁定属性每帧强制写回冻结值。
     */
    private function syncRows():void {
        if (!_target) {
            return;
        }

        var focus:DisplayObject = null;
        if (isOpen && _window.stage) {
            focus = _window.stage.focus as DisplayObject;
        }

        var n:int = _rowList.length;
        for (var i:int = 0; i < n; i++) {
            var row:Object            = _rowList[i];
            var control:DisplayObject = row.control as DisplayObject;

            if (row.locked && row.writable) {
                try {
                    _target[row.name] = row.lockedValue;
                }
                catch (lockErr:Error) {
                }
            }

            if (focus && isFocusedBy(control, focus)) {
                continue;
            }

            var value:*;
            if (row.locked) {
                value = row.lockedValue;
            }
            else {
                try {
                    value = _target[row.name];
                }
                catch (e:Error) {
                    value = '<error>';
                }
            }

            if (row.kind == 'check') {
                var b:Boolean = Boolean(value);
                if (row.lastSelected === b) {
                    continue;
                }
                _syncing = true;
                (control as Check).selected = b;
                _syncing = false;
                row.lastSelected = b;
            }
            else if (row.kind == 'text') {
                var t:String = InspectPropUtil.editableToString(value);
                if (row.lastDisplay == t) {
                    continue;
                }
                _syncing = true;
                (control as TextInput).text = t;
                _syncing = false;
                row.lastDisplay = t;
            }
            else {
                if (value === row.lastRaw && row.lastDisplay != null
                        && !(value is DisplayObject) && !(value is Rectangle)) {
                    continue;
                }
                var preview:String = InspectPropUtil.formatPreview(value) + ' ›';
                row.lastRaw = value;
                if (row.lastDisplay == preview) {
                    continue;
                }
                (control as Label).text = preview;
                row.lastDisplay         = preview;
            }
        }
    }

    /**
     * 清空属性行控件。
     */
    private function clearRows():void {
        _pendingProps = null;
        _buildIndex   = 0;
        if (_scroll) {
            while (_scroll.numChildren > 0) {
                var child:DisplayObject = _scroll.removeChildAt(0);
                unbindRowControl(child);
            }
            if (_scrollLayout) {
                _scroll.layout = _scrollLayout;
            }
        }
        _rowList.length = 0;
    }

    /**
     * 移除行内控件事件。
     * @param rowOrControl 行或控件。
     */
    private function unbindRowControl(rowOrControl:DisplayObject):void {
        var container:DisplayObjectContainer = rowOrControl as DisplayObjectContainer;
        if (container) {
            for (var i:int = 0; i < container.numChildren; i++) {
                unbindRowControl(container.getChildAt(i));
            }
        }

        var input:TextInput = rowOrControl as TextInput;
        if (input) {
            input.removeEventListener(Event.CHANGE, onInputChange);
            input.removeEventListener(FocusEvent.FOCUS_OUT, onInputFocusOut);
            return;
        }

        var check:Check = rowOrControl as Check;
        if (check) {
            check.removeEventListener(Event.CHANGE, onCheckChange);
            check.removeEventListener(Event.CHANGE, onLockChange);
            return;
        }

        var label:Label = rowOrControl as Label;
        if (label) {
            label.removeEventListener(MouseEvent.CLICK, onReadonlyClick);
        }
    }

    /**
     * TextInput 变更时写回。
     * @param e 变更事件。
     */
    private function onInputChange(e:Event):void {
        if (_syncing) {
            return;
        }

        var input:TextInput = e.currentTarget as TextInput;
        var meta:Object     = findRowByControl(input);
        if (!meta) {
            return;
        }

        InspectPropUtil.applyValue(_target, String(meta.name), String(meta.type), input.text);
        if (meta.locked) {
            captureLockedValue(meta);
        }
    }

    /**
     * 失焦时再尝试写回（补全中间态数字）。
     * @param e 焦点事件。
     */
    private function onInputFocusOut(e:FocusEvent):void {
        if (_syncing) {
            return;
        }

        var input:TextInput = e.currentTarget as TextInput;
        var meta:Object     = findRowByControl(input);
        if (!meta) {
            return;
        }

        InspectPropUtil.applyValue(_target, String(meta.name), String(meta.type), input.text);
        if (meta.locked) {
            captureLockedValue(meta);
        }
    }

    /**
     * Check 变更时写回布尔值。
     * @param e 变更事件。
     */
    private function onCheckChange(e:Event):void {
        if (_syncing || !_target) {
            return;
        }

        var check:Check = e.currentTarget as Check;
        var meta:Object = findRowByControl(check);
        if (!meta) {
            return;
        }

        try {
            _target[meta.name] = check.selected;
            if (meta.locked) {
                meta.lockedValue = check.selected;
            }
        }
        catch (err:Error) {
            // 写回失败时忽略，下帧 sync 恢复显示
        }
    }

    /**
     * 锁定勾选变更：开启时冻结当前值并每帧写回。
     * @param e 变更事件。
     */
    private function onLockChange(e:Event):void {
        if (_syncing) {
            return;
        }

        var lockCheck:Check = e.currentTarget as Check;
        var meta:Object     = findRowByControl(lockCheck);
        if (!meta || !meta.writable) {
            return;
        }

        meta.locked = lockCheck.selected;
        if (meta.locked) {
            captureLockedValue(meta);
        }
        else {
            meta.lockedValue = undefined;
        }
    }

    /**
     * 从目标或当前控件捕获锁定冻结值。
     * @param meta 行元数据。
     */
    private function captureLockedValue(meta:Object):void {
        if (!_target || !meta) {
            return;
        }

        if (meta.kind == 'check') {
            meta.lockedValue = (meta.control as Check).selected;
            return;
        }
        if (meta.kind == 'text') {
            InspectPropUtil.applyValue(
                    _target, String(meta.name), String(meta.type), (meta.control as TextInput).text
            );
            try {
                meta.lockedValue = _target[meta.name];
            }
            catch (e1:Error) {
                meta.lockedValue = (meta.control as TextInput).text;
            }
            return;
        }

        try {
            meta.lockedValue = _target[meta.name];
        }
        catch (e2:Error) {
            meta.lockedValue = undefined;
        }
    }

    /**
     * 按控件反查行元数据。
     * @param control 行内控件。
     * @return 行元数据。
     */
    private function findRowByControl(control:DisplayObject):Object {
        var n:int = _rowList.length;
        for (var i:int = 0; i < n; i++) {
            var row:Object = _rowList[i];
            if (row.control == control || row.lockCheck == control) {
                return row;
            }
        }

        return null;
    }

    /**
     * 判断指定焦点是否落在控件内。
     * @param d 控件。
     * @param focus 当前焦点。
     * @return 聚焦中为 <code>true</code>。
     */
    private function isFocusedBy(d:DisplayObject, focus:DisplayObject):Boolean {
        if (!d || !focus) {
            return false;
        }
        if (focus == d) {
            return true;
        }

        var c:DisplayObjectContainer = d as DisplayObjectContainer;

        return c != null && c.contains(focus);
    }

    /**
     * 将属性窗放到主窗左侧对齐。
     */
    private function placeBesideMain():void {
        if (!isOpen || !_mainWindow) {
            return;
        }

        _window.x = _mainWindow.x - _window.width;
        _window.y = _mainWindow.y;
    }

    /**
     * 恢复默认面板宽高。
     */
    private function resizeToDefault():void {
        if (!isOpen) {
            return;
        }

        _window.width  = PANEL_WIDTH + _chromeW;
        _window.height = PANEL_HEIGHT + _chromeH;
        placeBesideMain();
        layout();
    }

    /**
     * 按属性行数调整窗口高度，尽量完整显示。
     * @param rowCount 行数。
     */
    private function fitWindowToRows(rowCount:int):void {
        if (!isOpen) {
            return;
        }

        var needW:Number = PANEL_WIDTH;
        var needH:Number = PAD * 2 + HEADER_H + 6 + rowCount * (ROW_H + ROW_GAP) + 16;
        needH = Math.max(140, needH);

        var maxH:Number = Math.max(200, Capabilities.screenResolutionY - 80);
        if (needH > maxH) {
            needH = maxH;
        }

        _window.width  = needW + _chromeW;
        _window.height = needH + _chromeH;
        placeBesideMain();
        layout();
    }

    /**
     * 按客户区尺寸铺背景并布局控件。
     */
    private function layout():void {
        if (!isOpen || !_root) {
            return;
        }

        var sw:Number = _window.stage.stageWidth;
        var sh:Number = _window.stage.stageHeight;
        var bg:uint   = currentBgColor();

        _root.graphics.clear();
        _root.graphics.beginFill(bg, 1);
        _root.graphics.drawRect(0, 0, sw, sh);
        _root.graphics.endFill();

        if (_header) {
            _header.width  = Math.max(40, sw - PAD * 2);
            _header.height = HEADER_H;
        }

        if (_scroll) {
            _scroll.y      = PAD + HEADER_H + 4;
            _scroll.width  = Math.max(40, sw - PAD * 2);
            _scroll.height = Math.max(40, sh - _scroll.y - PAD);
        }
    }

    /**
     * @private
     */
    private function onWindowResize(e:NativeWindowBoundsEvent):void {
        layout();
    }

    /**
     * @private
     */
    private function onWindowClose(e:Event):void {
        _userClosed = true;
        _idleMode   = false;
        _builtFor   = null;
        _target     = null;
        DebugSpriteBounds.I.clearTrack();
        clearRows();
        closeDetailPopup();
        unbindWindow();
        _window   = null;
        _root     = null;
        _header   = null;
        _scroll   = null;
        _scrollBg = null;
    }

    /**
     * @private
     */
    private function onMainClosing(e:Event):void {
        stop();
    }

    /**
     * 关闭属性窗。
     */
    private function closeWindow():void {
        closeDetailPopup();
        if (_window && !_window.closed) {
            clearRows();
            unbindWindow();
            _window.close();
        }

        _window   = null;
        _root     = null;
        _header   = null;
        _scroll   = null;
        _scrollBg = null;
    }

    /**
     * 移除窗口相关监听。
     */
    private function unbindWindow():void {
        if (_window) {
            _window.removeEventListener(Event.CLOSE, onWindowClose);
            _window.removeEventListener(NativeWindowBoundsEvent.RESIZE, onWindowResize);
        }

        if (_mainWindow) {
            _mainWindow.removeEventListener(Event.CLOSING, onMainClosing);
        }
    }
}
}
