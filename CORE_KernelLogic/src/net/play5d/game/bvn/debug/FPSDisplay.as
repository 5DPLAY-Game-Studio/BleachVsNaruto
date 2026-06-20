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
 * Stage 刷新率 FPS 叠加层工具
 *
 * <p>在 Stage 左上角渲染实时帧率信息，供调试与性能观测使用。统计
 * {@link flash.display.Stage#ENTER_FRAME} 事件频率，反映当前<strong>舞台实际刷新帧率</strong>，
 * 并与 {@link net.play5d.game.bvn.MainGame#setFPS} 设置的目标帧率进行对比展示。</p>
 *
 * <p><b>核心设计理念：</b></p>
 * <ul>
 *   <li><b>单一职责：</b>仅负责 FPS 采样、平滑与 UI 渲染，不耦合游戏逻辑</li>
 *   <li><b>静态工具类：</b>全局唯一叠加层，通过 {@link #show} / {@link #hide} 管理生命周期</li>
 *   <li><b>低侵入：</b>独立监听 Stage 帧事件，无需修改 {@link net.play5d.game.bvn.ctrler.GameRender}</li>
 *   <li><b>可读优先：</b>EMA 平滑 + 颜色分级，避免帧率数字剧烈跳动</li>
 * </ul>
 *
 * <p><b>设计特点：</b></p>
 * <ul>
 *   <li><b>滑动窗口采样：</b>每 <code>100</code> ms 统计一次瞬时帧率</li>
 *   <li><b>EMA 指数平滑：</b>系数 <code>0.15</code>，兼顾响应速度与显示稳定</li>
 *   <li><b>目标帧率同步：</b>自动读取 {@link Stage#frameRate}，菜单 30fps / 战斗 60fps 切换时即时对齐</li>
 *   <li><b>异常窗口丢弃：</b>切后台或停顿超过 <code>500</code> ms 时重置采样，防止 EMA 失真</li>
 *   <li><b>设备字体渲染：</b>使用 <code>embedFonts = false</code>，避免字体未加载时文字不可见</li>
 *   <li><b>层级置顶：</b>每次更新后将 TextField 重新 <code>addChild</code> 至 Stage 顶层，避免被后续 UI 遮挡</li>
 * </ul>
 *
 * <p><b>显示格式：</b></p>
 * <pre>
 * fps: 59.8/60 (16.7ms)
 *       │    │     └── 平滑帧耗时（毫秒）
 *       │    └── 目标帧率（Stage.frameRate）
 *       └── 平滑实际帧率
 * </pre>
 *
 * <p><b>颜色分级（相对目标帧率）：</b></p>
 * <ul>
 *   <li><b>绿色 <code>0x44FF44</code>：</b>实际帧率 ≥ 目标 × <code>0.95</code></li>
 *   <li><b>黄色 <code>0xFFFF00</code>：</b>实际帧率 ≥ 目标 × <code>0.85</code></li>
 *   <li><b>红色 <code>0xFF4444</code>：</b>实际帧率 &lt; 目标 × <code>0.85</code></li>
 * </ul>
 *
 * <p><b>工作原理：</b></p>
 * <ol>
 *   <li><b>初始化阶段：</b>{@link #show} 创建 TextField、注册 {@link Event#ENTER_FRAME} 监听</li>
 *   <li><b>计数阶段：</b>每帧递增帧计数器，累计采样窗口内的 ENTER_FRAME 次数</li>
 *   <li><b>采样阶段：</b>窗口达到 <code>100</code> ms 时，计算瞬时 FPS = 帧数 / 秒数</li>
 *   <li><b>平滑阶段：</b>对瞬时 FPS 应用 EMA 公式，更新 {@link #_smoothedFPS}</li>
 *   <li><b>渲染阶段：</b>刷新文本内容与颜色，并将叠加层置顶</li>
 *   <li><b>清理阶段：</b>{@link #hide} 移除监听、销毁 TextField 并释放 Stage 引用</li>
 * </ol>
 *
 * <p><b>使用示例：</b></p>
 * <pre>
 * // 示例1：调试入口中启用 FPS 显示
 * FPSDisplay.show(stage);
 *
 * // 示例2：通过 Debugger 间接调用（SHELL_Dev / DEBUG_ENABLED）
 * Debugger.initDebug(stage);
 *
 * // 示例3：场景切换或退出调试时关闭
 * FPSDisplay.hide();
 * </pre>
 *
 * <p><b>性能考量：</b></p>
 * <ul>
 *   <li>每帧仅执行 <code>getTimer()</code> 与整数自增，开销可忽略</li>
 *   <li>文本与颜色更新限制在采样窗口内（约 10 次/秒），避免每帧修改 TextField</li>
 *   <li>不使用嵌入字体与 UIUtils.formatText，减少字体依赖与布局计算</li>
 *   <li>单例式静态状态，无额外 DisplayObject 容器层级</li>
 * </ul>
 *
 * <p><b>注意事项：</b></p>
 * <ul>
 *   <li>测量的是 Stage 刷新帧率，而非 {@link net.play5d.game.bvn.ctrler.GameRender} 逻辑帧率</li>
 *   <li>{@link #show} 重复调用会被忽略，需先 {@link #hide} 再重新显示</li>
 *   <li>正式包默认不启用，通常由 {@link Debugger#initDebug} 在调试模式下调用</li>
 * </ul>
 *
 * @see Debugger#initDebug
 * @see Debugger#showFPS
 * @see net.play5d.game.bvn.MainGame#setFPS
 * @author 5DPLAY Game Studio
 * @version 1.0
 */
public class FPSDisplay {

    /** 当前绑定的 Stage 引用，{@link #hide} 时置空 */
    private static var _stage:Stage;

    /** 上一次采样窗口的起始时间（{@link getTimer} 毫秒） */
    private static var _fpsLastTime:int;

    /** 当前采样窗口内累计的 ENTER_FRAME 次数 */
    private static var _fpsFrameCount:int;

    /** FPS 文本显示控件 */
    private static var _fpsText:TextField;

    /** EMA 平滑后的实际帧率 */
    private static var _smoothedFPS:Number;

    /** 上一次记录的目标帧率，用于检测 {@link Stage#frameRate} 变化 */
    private static var _fpsLastTarget:Number;

    /** EMA 平滑系数，值越大对新采样越敏感 */
    private static const _FPS_ALPHA:Number      = 0.15;

    /** 采样窗口时长（毫秒），达到此值后计算一次瞬时 FPS */
    private static const _FPS_SAMPLE_MS:int     = 100;

    /** 采样窗口上限（毫秒），超出则视为异常停顿并重置 */
    private static const _FPS_MAX_DELTA_MS:int  = 500;

    /** 良好帧率阈值：实际 / 目标 ≥ 此值时显示绿色 */
    private static const _FPS_GOOD_RATIO:Number = 0.95;

    /** 警告帧率阈值：实际 / 目标 ≥ 此值时显示黄色，否则红色 */
    private static const _FPS_WARN_RATIO:Number = 0.85;

    /** 良好状态文字颜色 */
    private static const _FPS_COLOR_GOOD:uint   = 0x44FF44;

    /** 警告状态文字颜色 */
    private static const _FPS_COLOR_WARN:uint   = 0xFFFF00;

    /** 异常状态文字颜色 */
    private static const _FPS_COLOR_BAD:uint    = 0xFF4444;

    /** 叠加层左上角 X 坐标（像素） */
    private static const _FPS_POS_X:Number      = 4;

    /** 叠加层左上角 Y 坐标（像素） */
    private static const _FPS_POS_Y:Number      = 4;

    /** 设备字体字号 */
    private static const _FPS_FONT_SIZE:int     = 10;

    /**
     * 在指定 Stage 上显示 FPS 叠加层
     *
     * <p>创建 TextField、注册帧监听并开始采样。若叠加层已存在或 <code>stage</code> 为
     * <code>null</code>，则静默返回。</p>
     *
     * <p><b>工作流程：</b></p>
     * <ol>
     *   <li>保存 Stage 引用并重置采样状态</li>
     *   <li>以 {@link Stage#frameRate} 初始化平滑帧率与目标帧率</li>
     *   <li>创建设备字体 TextField，设置位置、描边滤镜与占位文本</li>
     *   <li>添加至 Stage 并注册 {@link Event#ENTER_FRAME} 监听</li>
     * </ol>
     *
     * <p><b>使用示例：</b></p>
     * <pre>
     * FPSDisplay.show(stage);
     * </pre>
     *
     * <p><b>注意事项：</b></p>
     * <ul>
     *   <li>首次采样完成前显示占位文本 <code>fps: --/目标 (--ms)</code></li>
     *   <li>不使用嵌入字体，确保在 {@link net.play5d.game.bvn.ui.UIUtils#LOCK_FONT} 加载前也可显示</li>
     * </ul>
     *
     * @param stage 目标舞台，不可为 <code>null</code>
     * @see #hide
     * @see Debugger#initDebug
     */
    public static function show(stage:Stage):void {
        if (_fpsText != null || stage == null) {
            return;
        }

        _stage         = stage;
        _fpsLastTime   = getTimer();
        _fpsFrameCount = 0;
        _smoothedFPS   = _stage.frameRate;
        _fpsLastTarget = _stage.frameRate;

        _fpsText                   = new TextField();
        _fpsText.autoSize          = TextFieldAutoSize.LEFT;
        _fpsText.selectable        = false;
        _fpsText.mouseEnabled      = false;
        _fpsText.x                 = _FPS_POS_X;
        _fpsText.y                 = _FPS_POS_Y;
        _fpsText.filters           = [new GlowFilter(0x000000, 1, 2, 2, 3)];
        _fpsText.embedFonts        = false;
        _fpsText.defaultTextFormat = new TextFormat('_sans', _FPS_FONT_SIZE);
        _fpsText.textColor         = _FPS_COLOR_WARN;

        setPlaceholderText();
        _stage.addChild(_fpsText);
        ensureOnTop();
        _stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    /**
     * 隐藏并销毁 FPS 叠加层
     *
     * <p>移除 {@link Event#ENTER_FRAME} 监听，从显示列表中移除 TextField，
     * 并清空所有静态引用。若叠加层未显示，则静默返回。</p>
     *
     * <p><b>工作流程：</b></p>
     * <ol>
     *   <li>从 Stage 移除帧事件监听</li>
     *   <li>从父容器移除 TextField</li>
     *   <li>将 {@link #_fpsText} 与 {@link #_stage} 置为 <code>null</code></li>
     * </ol>
     *
     * <p><b>使用示例：</b></p>
     * <pre>
     * FPSDisplay.hide();
     * </pre>
     *
     * @see #show
     * @see Debugger#hideFPS
     */
    public static function hide():void {
        if (_fpsText == null || _stage == null) {
            return;
        }

        _stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

        if (_fpsText.parent != null) {
            _fpsText.parent.removeChild(_fpsText);
        }

        _fpsText = null;
        _stage   = null;
    }

    /**
     * Stage ENTER_FRAME 回调，驱动 FPS 采样与显示更新
     *
     * <p>每帧递增计数；当采样窗口达到 {@link #_FPS_SAMPLE_MS} ms 时计算瞬时 FPS
     * 并更新 EMA；异常长窗口则委托 {@link #resetSample} 处理。</p>
     *
     * @param e ENTER_FRAME 事件对象（未使用）
     */
    private static function onEnterFrame(e:Event):void {
        _fpsFrameCount++;

        var currentTime:int = getTimer();
        var deltaTime:int   = currentTime - _fpsLastTime;

        // 切后台或长时间停顿后，丢弃异常采样窗口，避免 EMA 被一次性拉偏
        if (deltaTime > _FPS_MAX_DELTA_MS) {
            resetSample(currentTime);
            return;
        }

        if (deltaTime < _FPS_SAMPLE_MS) {
            return;
        }

        syncTargetFPS();

        var instantFPS:Number = _fpsFrameCount / (deltaTime / 1000);

        _smoothedFPS = _FPS_ALPHA * instantFPS + (1 - _FPS_ALPHA) * _smoothedFPS;

        updateDisplay();
        ensureOnTop();

        _fpsLastTime   = currentTime;
        _fpsFrameCount = 0;
    }

    /**
     * 重置采样状态并恢复占位文本
     *
     * <p>在切后台、长时间卡顿等异常场景下调用，避免将极低瞬时 FPS
     * 写入 EMA 导致显示长时间偏低。</p>
     *
     * @param currentTime 当前 {@link getTimer} 时间戳，作为新采样窗口起点
     */
    private static function resetSample(currentTime:int):void {
        _fpsLastTime   = currentTime;
        _fpsFrameCount = 0;
        _smoothedFPS   = _stage.frameRate;
        _fpsLastTarget = _stage.frameRate;
        setPlaceholderText();
    }

    /**
     * 同步目标帧率变化
     *
     * <p>当 {@link Stage#frameRate} 与上次记录值不同时（如菜单 30fps 切换至
     * 战斗 60fps），将平滑帧率重置为新目标值，避免 EMA 从旧目标缓慢收敛。</p>
     */
    private static function syncTargetFPS():void {
        var targetFPS:Number = _stage.frameRate;

        if (_fpsLastTarget > 0 && targetFPS != _fpsLastTarget) {
            _smoothedFPS = targetFPS;
        }

        _fpsLastTarget = targetFPS;
    }

    /**
     * 设置占位文本
     *
     * <p>在初始化或采样重置后显示，格式为 <code>fps: --/目标 (--ms)</code>，
     * 表示尚未完成首次有效采样。</p>
     */
    private static function setPlaceholderText():void {
        if (_fpsText == null) {
            return;
        }

        _fpsText.textColor = _FPS_COLOR_WARN;
        _fpsText.text      = 'fps: --/' + _stage.frameRate.toFixed(0) + ' (--ms)';
    }

    /**
     * 刷新 FPS 文本内容与颜色
     *
     * <p>根据 {@link #_smoothedFPS} 与 {@link Stage#frameRate} 更新显示字符串，
     * 并按实际/目标比率切换绿、黄、红三色。</p>
     *
     * <p><b>显示格式：</b><code>fps: 实际/目标 (帧耗时ms)</code></p>
     */
    private static function updateDisplay():void {
        if (_fpsText == null) {
            return;
        }

        var targetFPS:Number = _stage.frameRate;
        var frameMs:Number   = _smoothedFPS > 0 ? 1000 / _smoothedFPS : 0;
        var ratio:Number     = targetFPS > 0 ? _smoothedFPS / targetFPS : 1;

        _fpsText.text = 'fps: ' + _smoothedFPS.toFixed(1)
                + '/' + targetFPS.toFixed(0)
                + ' (' + frameMs.toFixed(1) + 'ms)';

        if (ratio >= _FPS_GOOD_RATIO) {
            _fpsText.textColor = _FPS_COLOR_GOOD;
        }
        else if (ratio >= _FPS_WARN_RATIO) {
            _fpsText.textColor = _FPS_COLOR_WARN;
        }
        else {
            _fpsText.textColor = _FPS_COLOR_BAD;
        }
    }

    /**
     * 确保 FPS 叠加层位于 Stage 显示列表顶层
     *
     * <p>对已挂载的 TextField 再次调用 {@link Stage#addChild}，
     * 将其移动到同层级最后，避免被后续 <code>addChild</code> 的 UI 遮挡。</p>
     */
    private static function ensureOnTop():void {
        if (_fpsText == null || _stage == null || _fpsText.parent != _stage) {
            return;
        }

        _stage.addChild(_fpsText);
    }

}

}
