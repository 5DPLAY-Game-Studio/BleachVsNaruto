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

package net.play5d.game.bvn.debug {
import flash.display.Stage;
import flash.events.Event;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.getTimer;

/**
 * Stage 刷新率 FPS 叠加层。
 *
 * <p>统计 <code>ENTER_FRAME</code> 频率（舞台实际刷新率），经 EMA 平滑后与
 * <code>Stage.frameRate</code> 对比显示。格式：<code>fps: 实际/目标 (帧耗时ms)</code>。</p>
 *
 * @example
 * <listing version="3.0">
 * FPSDisplay.show(stage);
 * // ...
 * FPSDisplay.hide();
 * </listing>
 * @see #show()
 * @see #hide()
 * @see Debugger#initDebug()
 */
public class FPSDisplay {
    /** @private EMA 平滑系数 */
    private static const EMA_ALPHA:Number = 0.15;
    /** @private 1 - EMA_ALPHA，避免每帧重复计算 */
    private static const EMA_KEEP:Number = 1 - EMA_ALPHA;
    /** @private 采样窗口（毫秒） */
    private static const SAMPLE_MS:int = 100;
    /** @private 异常停顿阈值（毫秒），超出则重置采样 */
    private static const MAX_DELTA_MS:int = 500;
    /** @private 良好：实际/目标 ≥ 此值 → 绿 */
    private static const GOOD_RATIO:Number = 0.95;
    /** @private 警告：实际/目标 ≥ 此值 → 黄，否则红 */
    private static const WARN_RATIO:Number = 0.85;
    /** @private */
    private static const COLOR_GOOD:uint = 0x44FF44;
    /** @private */
    private static const COLOR_WARN:uint = 0xFFFF00;
    /** @private */
    private static const COLOR_BAD:uint = 0xFF4444;
    /** @private */
    private static const POS_X:Number = 4;
    /** @private */
    private static const POS_Y:Number = 4;
    /** @private */
    private static const FONT_SIZE:int = 10;

    /** @private 复用描边，避免 show 时重复分配 */
    private static const GLOW:GlowFilter = new GlowFilter(0x000000, 1, 2, 2, 3);
    /** @private 复用字号格式 */
    private static const FORMAT:TextFormat = new TextFormat('_sans', FONT_SIZE);

    /** @private */
    private static var _stage:Stage;
    /** @private 采样窗口起点（getTimer） */
    private static var _lastTime:int;
    /** @private 窗口内 ENTER_FRAME 次数 */
    private static var _frameCount:int;
    /** @private */
    private static var _text:TextField;
    /** @private EMA 平滑后的实际帧率 */
    private static var _smoothedFPS:Number;
    /** @private 上次记录的目标帧率 */
    private static var _lastTarget:Number;
    /** @private 上次写入的文字颜色，避免无谓赋值 */
    private static var _lastColor:uint;

    /**
     * 在指定 Stage 上显示 FPS 叠加层。
     *
     * <p>已显示或 <code>stage</code> 为 <code>null</code> 时忽略。</p>
     *
     * @param stage 目标舞台。
     * @example
     * <listing version="3.0">
     * FPSDisplay.show(stage);
     * </listing>
     * @see #hide()
     */
    public static function show(stage:Stage):void {
        if (_text || !stage) {
            return;
        }

        _stage       = stage;
        _lastTime    = getTimer();
        _frameCount  = 0;
        _smoothedFPS = _stage.frameRate;
        _lastTarget  = _smoothedFPS;
        _lastColor   = COLOR_WARN;

        _text                   = new TextField();
        _text.autoSize          = TextFieldAutoSize.LEFT;
        _text.selectable        = false;
        _text.mouseEnabled      = false;
        _text.x                 = POS_X;
        _text.y                 = POS_Y;
        _text.filters           = [GLOW];
        _text.embedFonts        = false;
        _text.defaultTextFormat = FORMAT;
        _text.textColor         = COLOR_WARN;

        setPlaceholderText();
        _stage.addChild(_text);
        _stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    /**
     * 隐藏并销毁 FPS 叠加层。
     *
     * @example
     * <listing version="3.0">
     * FPSDisplay.hide();
     * </listing>
     * @see #show()
     */
    public static function hide():void {
        if (!_text || !_stage) {
            return;
        }

        _stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

        if (_text.parent) {
            _text.parent.removeChild(_text);
        }

        _text  = null;
        _stage = null;
    }

    /**
     * 采样并按窗口刷新显示。
     * @param e 未使用。
     */
    private static function onEnterFrame(e:Event):void {
        _frameCount++;

        var now:int   = getTimer();
        var delta:int = now - _lastTime;

        // 切后台或长停顿：丢弃异常窗口，避免 EMA 被拉偏
        if (delta > MAX_DELTA_MS) {
            resetSample(now);

            return;
        }

        if (delta < SAMPLE_MS) {
            return;
        }

        syncTargetFPS();

        var instant:Number = _frameCount * 1000 / delta;
        _smoothedFPS = EMA_ALPHA * instant + EMA_KEEP * _smoothedFPS;

        updateDisplay();
        ensureOnTop();

        _lastTime   = now;
        _frameCount = 0;
    }

    /**
     * 重置采样并显示占位文本。
     * @param now 新窗口起点（getTimer）。
     */
    private static function resetSample(now:int):void {
        _lastTime    = now;
        _frameCount  = 0;
        _smoothedFPS = _stage.frameRate;
        _lastTarget  = _smoothedFPS;
        setPlaceholderText();
    }

    /**
     * 目标帧率变化时重置平滑值，避免从旧目标缓慢收敛。
     */
    private static function syncTargetFPS():void {
        var target:Number = _stage.frameRate;
        if (_lastTarget > 0 && target != _lastTarget) {
            _smoothedFPS = target;
        }
        _lastTarget = target;
    }

    /**
     * 写入尚未完成采样时的占位文案。
     */
    private static function setPlaceholderText():void {
        if (!_text) {
            return;
        }

        setTextColor(COLOR_WARN);
        _text.text = 'fps: --/' + _stage.frameRate.toFixed(0) + ' (--ms)';
    }

    /**
     * 按平滑帧率刷新文案与颜色。
     */
    private static function updateDisplay():void {
        if (!_text) {
            return;
        }

        var target:Number  = _stage.frameRate;
        var frameMs:Number = _smoothedFPS > 0 ? 1000 / _smoothedFPS : 0;
        var ratio:Number   = target > 0 ? _smoothedFPS / target : 1;

        _text.text = 'fps: ' + _smoothedFPS.toFixed(1)
                + '/' + target.toFixed(0)
                + ' (' + frameMs.toFixed(1) + 'ms)';

        if (ratio >= GOOD_RATIO) {
            setTextColor(COLOR_GOOD);
        }
        else if (ratio >= WARN_RATIO) {
            setTextColor(COLOR_WARN);
        }
        else {
            setTextColor(COLOR_BAD);
        }
    }

    /**
     * 仅在颜色变化时写入，减少 TextField 内部更新。
     * @param color 目标文字色。
     */
    private static function setTextColor(color:uint):void {
        if (color == _lastColor) {
            return;
        }

        _lastColor      = color;
        _text.textColor = color;
    }

    /**
     * 仅在未置顶时抬升，避免无谓 addChild。
     */
    private static function ensureOnTop():void {
        if (!_text || !_stage || _text.parent != _stage) {
            return;
        }

        var top:int = _stage.numChildren - 1;
        if (_stage.getChildIndex(_text) != top) {
            _stage.setChildIndex(_text, top);
        }
    }
}
}
