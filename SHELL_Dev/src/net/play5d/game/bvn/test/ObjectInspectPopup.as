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
import flash.utils.getQualifiedClassName;

import net.play5d.game.bvn.ctrler.GameRender;

/**
 * 属性详情小窗：可编辑简单类型，勾选锁定后每帧写回冻结值，并随游戏渲染实时刷新。
 *
 * <p>有意义的 <code>toString()</code> 时展示字符串并实时刷新；否则列出公开属性，
 * 可写简单类型可编辑写回，锁定后冻结；复杂子属性可再点击打开下一层小窗。</p>
 *
 * @example
 * <listing version="3.0">
 * var pop:ObjectInspectPopup = new ObjectInspectPopup(owner, theme, true);
 * pop.open('area', rect);
 * </listing>
 * @see #open()
 * @see #close()
 */
public class ObjectInspectPopup {
    /** @private */
    private static const PANEL_W:Number = 344;
    /** @private */
    private static const PANEL_H:Number = 360;
    /** @private */
    private static const PAD:Number = 6;
    /** @private */
    private static const HEADER_H:Number = 22;
    /** @private */
    private static const ROW_H:Number = 22;
    /** @private */
    private static const ROW_GAP:Number = 2;
    /** @private */
    private static const NAME_W:Number = 110;
    /** @private 属性值锁定勾选宽 */
    private static const LOCK_W:Number = 20;
    /** @private */
    private static const VALUE_W:Number = 180;
    /** @private */
    private static const FONT_SIZE:Number = 11;
    /** @private */
    private static const MAX_DEPTH:int = 8;
    /** @private 分帧建行每批数量 */
    private static const BUILD_BATCH:int = 16;
    /** @private 展示模式：tostring / props / empty */
    private static const MODE_TOSTRING:String = 'tostring';
    /** @private */
    private static const MODE_PROPS:String = 'props';
    /** @private */
    private static const MODE_EMPTY:String = 'empty';

    /** @private */
    private var _owner:NativeWindow;
    /** @private */
    private var _window:NativeWindow;
    /** @private */
    private var _root:Sprite;
    /** @private */
    private var _header:Label;
    /** @private */
    private var _scroll:ScrollContainer;
    /** @private */
    private var _scrollBg:Sprite;
    /** @private 共享 Steel 主题（不 dispose） */
    private var _theme:SteelTheme;
    /** @private */
    private var _darkMode:Boolean;
    /** @private */
    private var _depth:int;
    /** @private */
    private var _chromeW:Number;
    /** @private */
    private var _chromeH:Number;
    /** @private */
    private var _title:String;
    /** @private 本层目标对象 */
    private var _value:*;
    /** @private */
    private var _mode:String;
    /** @private tostring 模式文本 */
    private var _toStringLabel:Label;
    /** @private 行列表（顺序遍历） */
    private var _rowList:Array = [];
    /** @private 待分帧构建的属性元数据 */
    private var _pendingProps:Array;
    /** @private 分帧构建游标 */
    private var _buildIndex:int;
    /** @private ScrollContainer 布局（建行时暂卸） */
    private var _scrollLayout:VerticalLayout;
    /** @private 缓存主文字格式 */
    private var _tfMain:TextFormat;
    /** @private 缓存次文字格式 */
    private var _tfSecondary:TextFormat;
    /** @private 上次 tostring 展示，避免重复赋值 */
    private var _lastToString:String;
    /** @private */
    private var _syncing:Boolean;
    /** @private */
    private var _ticking:Boolean;
    /** @private */
    private var _childPopups:Array = [];

    /**
     * @param owner 宿主窗口（用于定位）。
     * @param theme 共享 <code>SteelTheme</code>。
     * @param darkMode 是否暗色。
     * @param depth 递归深度。
     */
    public function ObjectInspectPopup(
            owner   :NativeWindow,
            theme   :SteelTheme,
            darkMode:Boolean,
            depth   :int = 0
    ) {
        _owner    = owner;
        _theme    = theme;
        _darkMode = darkMode;
        _depth    = depth;
    }

    /**
     * 是否已打开。
     * @return 打开中为 <code>true</code>。
     * @default false
     */
    public function get isOpen():Boolean {
        return _window != null && !_window.closed;
    }

    /**
     * 打开或刷新详情内容，并开始实时同步。
     * @param title 窗口标题（属性路径）。
     * @param value 要展示的值。
     * @example
     * <listing version="3.0">
     * popup.open('display', sp.getDisplay());
     * </listing>
     */
    public function open(title:String, value:*):void {
        closeChildren();
        _title = title;
        _value = value;
        ensureWindow(title);
        buildContent();
        placeNearOwner();
        startTick();
        if (isOpen) {
            _window.activate();
        }
    }

    /**
     * 同步亮暗模式并刷新展示。
     * @param darkMode 是否暗色。
     */
    public function setDarkMode(darkMode:Boolean):void {
        _darkMode    = darkMode;
        _tfMain      = null;
        _tfSecondary = null;
        if (isOpen) {
            applyChrome();
            buildContent();
        }
        for each (var child:ObjectInspectPopup in _childPopups) {
            if (child) {
                child.setDarkMode(darkMode);
            }
        }
    }

    /**
     * 关闭本窗及子详情窗。
     * @example
     * <listing version="3.0">
     * popup.close();
     * </listing>
     */
    public function close():void {
        stopTick();
        closeChildren();
        if (_window && !_window.closed) {
            unbind();
            _window.close();
        }
        clearRows();
        _window        = null;
        _root          = null;
        _header        = null;
        _scroll        = null;
        _scrollBg      = null;
        _toStringLabel = null;
        _value         = null;
    }

    /** @private */
    private function startTick():void {
        if (_ticking) {
            return;
        }
        _ticking = true;
        GameRender.addAfter(onTick);
    }

    /** @private */
    private function stopTick():void {
        if (!_ticking) {
            return;
        }
        _ticking = false;
        GameRender.removeAfter(onTick);
    }

    /** @private */
    private function onTick():void {
        if (!isOpen) {
            stopTick();
            return;
        }
        pruneClosedChildren();
        if (_pendingProps) {
            flushBuildBatch();
            return;
        }
        if (_value == null) {
            return;
        }
        if (_mode == MODE_TOSTRING) {
            syncToString();
        }
        else if (_mode == MODE_PROPS) {
            syncRows();
        }
    }

    /** @private */
    private function syncToString():void {
        if (!_toStringLabel) {
            return;
        }
        var text:String;
        try {
            text = String(_value.toString());
        }
        catch (e:Error) {
            text = '<toString error>';
        }
        if (text == _lastToString) {
            return;
        }
        _lastToString         = text;
        _toStringLabel.text = text;
    }

    /** @private */
    private function ensureWindow(title:String):void {
        if (isOpen) {
            _window.title = title;
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
        _window.title           = title;
        _window.stage.scaleMode = StageScaleMode.NO_SCALE;
        _window.stage.align     = StageAlign.TOP_LEFT;
        _window.stage.stageFocusRect = false;

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

        _scrollLayout                 = new VerticalLayout();
        _scrollLayout.gap             = ROW_GAP;
        _scrollLayout.paddingTop      = 1;
        _scrollLayout.paddingBottom   = 1;
        _scrollLayout.paddingLeft     = 1;
        _scrollLayout.paddingRight    = 1;

        _scrollBg              = new Sprite();
        _scroll                = new ScrollContainer();
        _scroll.layout         = _scrollLayout;
        _scroll.backgroundSkin = _scrollBg;
        _scroll.x              = PAD;
        _root.addChild(_scroll);

        _window.width  = PANEL_W;
        _window.height = PANEL_H;
        _window.activate();

        _chromeW = _window.width - _window.stage.stageWidth;
        _chromeH = _window.height - _window.stage.stageHeight;
        _window.width  = PANEL_W + _chromeW;
        _window.height = PANEL_H + _chromeH;

        applyChrome();
        _window.addEventListener(Event.CLOSE, onClose);
        _window.addEventListener(NativeWindowBoundsEvent.RESIZE, onResize);
        if (_owner) {
            _owner.addEventListener(Event.CLOSING, onOwnerClosing);
        }
    }

    /** @private */
    private function buildContent():void {
        clearRows();
        _toStringLabel = null;

        if (!isOpen) {
            return;
        }

        _window.title = _title;

        if (_value == null) {
            _mode = MODE_EMPTY;
            _header.text = 'null';
            addReadonlyRow('(value)', 'null');
            layout();
            return;
        }

        _header.text = getQualifiedClassName(_value);

        if (InspectPropUtil.hasUsefulToString(_value)) {
            _mode = MODE_TOSTRING;
            var text:String;
            try {
                text = _value.toString();
            }
            catch (e:Error) {
                text = '<toString error: ' + e.message + '>';
            }
            _toStringLabel             = new Label(text);
            _toStringLabel.wordWrap    = true;
            _toStringLabel.width       = NAME_W + LOCK_W + VALUE_W + 10;
            _toStringLabel.textFormat  = makeTextFormat(false);
            _scroll.addChild(_toStringLabel);
            layout();
            return;
        }

        if (_depth >= MAX_DEPTH) {
            _mode = MODE_EMPTY;
            addReadonlyRow('(depth)', 'max depth reached');
            layout();
            return;
        }

        var props:Array = InspectPropUtil.getPublicProps(_value);
        if (props.length == 0) {
            _mode = MODE_EMPTY;
            addReadonlyRow('(empty)', InspectPropUtil.formatPreview(_value));
            layout();
            return;
        }

        _mode         = MODE_PROPS;
        _pendingProps = props;
        _buildIndex   = 0;
        if (_scroll) {
            _scroll.layout = null;
        }
        flushBuildBatch();
        layout();
    }

    /**
     * 分帧追加属性行，避免一次创建过多 Feathers 控件卡顿。
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
            addPropRow(_pendingProps[_buildIndex] as Object);
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
        layout();
    }

    /** @private */
    private function addPropRow(meta:Object):void {
        var propName:String  = String(meta.name);
        var typeName:String  = String(meta.type);
        var writable:Boolean = Boolean(meta.writable);
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
            input.width      = VALUE_W;
            input.height     = ROW_H;
            input.textFormat = makeTextFormat(false);
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

    /** @private */
    private function addReadonlyRow(name:String, preview:String):void {
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.gap                  = 4;
        hLayout.verticalAlign        = VerticalAlign.MIDDLE;

        var row:LayoutGroup = new LayoutGroup();
        row.layout          = hLayout;
        row.width           = NAME_W + LOCK_W + VALUE_W + 10;
        row.height          = ROW_H;

        var nameLabel:Label = new Label(name);
        nameLabel.width      = NAME_W;
        nameLabel.height     = ROW_H;
        nameLabel.textFormat = makeTextFormat(true);
        row.addChild(nameLabel);

        var valueLabel:Label = new Label(preview);
        valueLabel.width      = VALUE_W;
        valueLabel.height     = ROW_H;
        valueLabel.textFormat = makeTextFormat(false);
        row.addChild(valueLabel);
        _scroll.addChild(row);
    }

    /** @private */
    private function syncRows():void {
        if (_value == null) {
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
                    _value[row.name] = row.lockedValue;
                }
                catch (lockErr:Error) {
                }
            }

            if (focus && isFocusedBy(control, focus)) {
                continue;
            }

            var childVal:*;
            if (row.locked) {
                childVal = row.lockedValue;
            }
            else {
                try {
                    childVal = _value[row.name];
                }
                catch (e:Error) {
                    childVal = '<error>';
                }
            }

            if (row.kind == 'check') {
                var b:Boolean = Boolean(childVal);
                if (row.lastSelected === b) {
                    continue;
                }
                _syncing = true;
                (control as Check).selected = b;
                _syncing = false;
                row.lastSelected = b;
            }
            else if (row.kind == 'text') {
                var t:String = InspectPropUtil.editableToString(childVal);
                if (row.lastDisplay == t) {
                    continue;
                }
                _syncing = true;
                (control as TextInput).text = t;
                _syncing = false;
                row.lastDisplay = t;
            }
            else {
                if (childVal === row.lastRaw && row.lastDisplay != null
                        && !(childVal is DisplayObject) && !(childVal is Rectangle)) {
                    continue;
                }
                var preview:String = InspectPropUtil.formatPreview(childVal) + ' ›';
                row.lastRaw = childVal;
                if (row.lastDisplay == preview) {
                    continue;
                }
                (control as Label).text = preview;
                row.lastDisplay         = preview;
            }
        }
    }

    /** @private */
    private function onInputChange(e:Event):void {
        if (_syncing) {
            return;
        }
        var input:TextInput = e.currentTarget as TextInput;
        var meta:Object     = findRowByControl(input);
        if (!meta) {
            return;
        }
        InspectPropUtil.applyValue(_value, String(meta.name), String(meta.type), input.text);
        if (meta.locked) {
            captureLockedValue(meta);
        }
    }

    /** @private */
    private function onInputFocusOut(e:FocusEvent):void {
        if (_syncing) {
            return;
        }
        var input:TextInput = e.currentTarget as TextInput;
        var meta:Object     = findRowByControl(input);
        if (!meta) {
            return;
        }
        InspectPropUtil.applyValue(_value, String(meta.name), String(meta.type), input.text);
        if (meta.locked) {
            captureLockedValue(meta);
        }
    }

    /** @private */
    private function onCheckChange(e:Event):void {
        if (_syncing || _value == null) {
            return;
        }
        var check:Check = e.currentTarget as Check;
        var meta:Object = findRowByControl(check);
        if (!meta) {
            return;
        }
        try {
            _value[meta.name] = check.selected;
            if (meta.locked) {
                meta.lockedValue = check.selected;
            }
        }
        catch (err:Error) {
        }
    }

    /** @private */
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

    /** @private */
    private function captureLockedValue(meta:Object):void {
        if (_value == null || !meta) {
            return;
        }
        if (meta.kind == 'check') {
            meta.lockedValue = (meta.control as Check).selected;
            return;
        }
        if (meta.kind == 'text') {
            InspectPropUtil.applyValue(
                    _value, String(meta.name), String(meta.type), (meta.control as TextInput).text
            );
            try {
                meta.lockedValue = _value[meta.name];
            }
            catch (e1:Error) {
                meta.lockedValue = (meta.control as TextInput).text;
            }
            return;
        }
        try {
            meta.lockedValue = _value[meta.name];
        }
        catch (e2:Error) {
            meta.lockedValue = undefined;
        }
    }

    /** @private */
    private function onReadonlyClick(e:MouseEvent):void {
        var label:Label = e.currentTarget as Label;
        var meta:Object = findRowByControl(label);
        if (!meta || _value == null) {
            return;
        }

        var childVal:*;
        try {
            childVal = _value[meta.name];
        }
        catch (err:Error) {
            return;
        }
        if (childVal == null) {
            return;
        }

        pruneClosedChildren();
        var child:ObjectInspectPopup = new ObjectInspectPopup(_window, _theme, _darkMode, _depth + 1);
        _childPopups[_childPopups.length] = child;
        child.open(String(meta.name), childVal);
    }

    /** @private */
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

    /** @private */
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

    /** @private */
    private function clearRows():void {
        _pendingProps = null;
        _buildIndex   = 0;
        _lastToString = null;
        if (_scroll) {
            while (_scroll.numChildren > 0) {
                unbindRowControl(_scroll.removeChildAt(0));
            }
            if (_scrollLayout) {
                _scroll.layout = _scrollLayout;
            }
        }
        _rowList.length = 0;
    }

    /** @private */
    private function unbindRowControl(d:DisplayObject):void {
        var container:DisplayObjectContainer = d as DisplayObjectContainer;
        if (container) {
            for (var i:int = 0; i < container.numChildren; i++) {
                unbindRowControl(container.getChildAt(i));
            }
        }
        var input:TextInput = d as TextInput;
        if (input) {
            input.removeEventListener(Event.CHANGE, onInputChange);
            input.removeEventListener(FocusEvent.FOCUS_OUT, onInputFocusOut);
            return;
        }
        var check:Check = d as Check;
        if (check) {
            check.removeEventListener(Event.CHANGE, onCheckChange);
            check.removeEventListener(Event.CHANGE, onLockChange);
            return;
        }
        var label:Label = d as Label;
        if (label) {
            label.removeEventListener(MouseEvent.CLICK, onReadonlyClick);
        }
    }

    /** @private */
    private function applyChrome():void {
        if (!isOpen) {
            return;
        }
        var bg:uint = DebugThemeChrome.bgColor(_darkMode);
        _window.stage.color = bg;
        if (_scrollBg) {
            _scrollBg.graphics.clear();
            _scrollBg.graphics.beginFill(bg, 1);
            _scrollBg.graphics.drawRect(0, 0, 16, 16);
            _scrollBg.graphics.endFill();
        }
        if (_header) {
            _header.textFormat = makeTextFormat(false);
        }
        layout();
    }

    /** @private */
    private function layout():void {
        if (!isOpen || !_root) {
            return;
        }
        var sw:Number = _window.stage.stageWidth;
        var sh:Number = _window.stage.stageHeight;
        var bg:uint = DebugThemeChrome.bgColor(_darkMode);

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

    /** @private */
    private function placeNearOwner():void {
        if (!isOpen) {
            return;
        }
        if (_owner && !_owner.closed) {
            _window.x = _owner.x + 24;
            _window.y = _owner.y + 48;
        }
    }

    /** @private */
    private function makeTextFormat(secondary:Boolean):TextFormat {
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

    /** @private 剔除已关闭的子详情窗引用。 */
    private function pruneClosedChildren():void {
        var i:int = _childPopups.length;
        while (i--) {
            var child:ObjectInspectPopup = _childPopups[i] as ObjectInspectPopup;
            if (!child || !child.isOpen) {
                _childPopups.splice(i, 1);
            }
        }
    }

    /** @private */
    private function closeChildren():void {
        for each (var child:ObjectInspectPopup in _childPopups) {
            if (child) {
                child.close();
            }
        }
        _childPopups.length = 0;
    }

    /** @private */
    private function unbind():void {
        if (_window) {
            _window.removeEventListener(Event.CLOSE, onClose);
            _window.removeEventListener(NativeWindowBoundsEvent.RESIZE, onResize);
        }
        if (_owner) {
            _owner.removeEventListener(Event.CLOSING, onOwnerClosing);
        }
    }

    /** @private */
    private function onClose(e:Event):void {
        stopTick();
        closeChildren();
        unbind();
        clearRows();
        _window        = null;
        _root          = null;
        _header        = null;
        _scroll        = null;
        _scrollBg      = null;
        _toStringLabel = null;
        _value         = null;
    }

    /** @private */
    private function onResize(e:NativeWindowBoundsEvent):void {
        layout();
    }

    /** @private */
    private function onOwnerClosing(e:Event):void {
        close();
    }
}
}
