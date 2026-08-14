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

package net.play5d.game.bvn.ide.component {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import net.play5d.game.bvn.ide.interfaces.BaseComponent;
import net.play5d.game.bvn.ide.utils.IdeRuntimeUtils;

/**
 * 绑定 FighterMain 注入控制器的 IDE 组件基类。
 *
 * <p>提供检查器预览文本，以及带动态方法校验的 <code>invokeCtrler</code>。</p>
 * <p>皮肤约定：根下实例 <code>mc</code> 为公用模板，内含 <code>titleTxt</code> /
 * <code>textTxt</code> / <code>bg</code>；缺 <code>mc</code> 时回退到根节点查找。</p>
 * <p>子类覆盖 <code>resolveCtrler</code> 解析对应 <code>$xxx_ctrler</code>。</p>
 *
 * @see net.play5d.game.bvn.ide.utils.IdeRuntimeUtils
 */
public class BaseIdeCtrler extends BaseComponent {

    /**
     * 公用模板实例。
     *
     * @default null
     */
    public var mc:MovieClip = null;

    /**
     * 背景板。
     *
     * @default null
     */
    public var bg:DisplayObject = null;

    /**
     * 标题文本。
     *
     * @default null
     */
    public var titleTxt:TextField = null;

    /**
     * 预览文字文本。
     *
     * @default null
     */
    public var textTxt:TextField = null;

    /** @private 已解析的控制器 */
    protected var _ctrler:* = null;

    /** @private 诊断用属性名（如 <code>$effect_ctrler</code>） */
    protected var _ctrlerProp:String = '';

    /** @private 背景最小宽度（取自模板初始宽度） */
    private var _minWidth:Number = 400;

    /** @private 文本左右边距合计 */
    private static const PAD_X:Number = 4;

    /**
     * 构造方法。
     */
    public function BaseIdeCtrler() {
        super();
        bindSkin();
    }

    /**
     * @inheritDoc
     */
    override public function destroy():void {
        mc       = null;
        bg       = null;
        titleTxt = null;
        textTxt  = null;

        _ctrler     = null;
        _ctrlerProp = '';

        super.destroy();
    }

    /**
     * 标题文本内容。
     *
     * <p>显示为注释样式，如 <code>// 效果_必杀</code>。</p>
     *
     * @return 标题字符串；无文本框时返回空串。
     */
    public function get title():String {
        return titleTxt ? titleTxt.text : '';
    }

    /** @private */
    public function set title(v:String):void {
        if (!titleTxt) {
            return;
        }

        var label:String = v ? v : '';
        if (label.indexOf('//') != 0) {
            label = '// ' + label;
        }

        titleTxt.text = label;
        layoutPreview();
    }

    /**
     * 预览文字内容。
     *
     * @return 预览字符串；无文本框时返回空串。
     */
    public function get text():String {
        return textTxt ? textTxt.text : '';
    }

    /** @private */
    public function set text(v:String):void {
        updatePreviewText(v);
    }

    /**
     * 第一帧要执行的代码。
     *
     * <p>解析控制器后隐藏、执行动作并销毁。</p>
     */
    override public function init():void {
        resolveCtrler();

        hidden();
        doAction();
        destroy();
    }

    /**
     * 绑定模板皮肤子节点。
     *
     * <p>优先从 <code>mc</code> 取 <code>titleTxt</code> / <code>textTxt</code> / <code>bg</code>。</p>
     */
    protected function bindSkin():void {
        mc = getChildByName('mc') as MovieClip;

        var skin:DisplayObjectContainer = mc ? mc : this;
        titleTxt = skin.getChildByName('titleTxt') as TextField;
        textTxt  = skin.getChildByName('textTxt') as TextField;
        bg       = skin.getChildByName('bg');

        if (bg) {
            _minWidth = bg.width;
        }

        if (textTxt) {
            textTxt.autoSize  = TextFieldAutoSize.LEFT;
            textTxt.wordWrap  = false;
            textTxt.multiline = false;
        }
    }

    /**
     * 按预览文字宽度调节文本框与背景板。
     */
    protected function layoutPreview():void {
        if (!textTxt && !titleTxt) {
            return;
        }

        var titleW:Number   = titleTxt ? titleTxt.textWidth : 0;
        var textW:Number    = textTxt ? textTxt.textWidth : 0;
        var contentW:Number = titleW > textW ? titleW : textW;
        var w:Number        = contentW + PAD_X;

        if (w < _minWidth) {
            w = _minWidth;
        }

        if (titleTxt) {
            titleTxt.width = w - PAD_X;
        }
        if (textTxt) {
            textTxt.autoSize  = TextFieldAutoSize.LEFT;
            textTxt.wordWrap  = false;
            textTxt.multiline = false;
        }
        if (bg) {
            bg.width = w;
        }
    }

    /**
     * 更新检查器预览文字。
     *
     * @param v 预览字符串。
     */
    protected function updatePreviewText(v:String):void {
        if (textTxt) {
            textTxt.text = v;
            layoutPreview();
        }
    }

    /**
     * 更新带成功/失败着色的预览文字。
     *
     * <p>成功为绿色，失败为红色。</p>
     *
     * @param v 预览字符串。
     * @param success 成功时为 <code>true</code>（绿色）；失败为红色。
     *
     * @example
     * <listing version="3.0">
     * updateStatusText('ok', true);
     * updateStatusText('missing ctrler', false);
     * </listing>
     */
    protected function updateStatusText(v:String, success:Boolean):void {
        if (!textTxt) {
            return;
        }

        textTxt.text = v;

        var textFormat:TextFormat = new TextFormat();
        textFormat.color          = success ? 0x00aa00 : 0xff0000;
        textTxt.setTextFormat(textFormat);
        layoutPreview();
    }

    /**
     * 显示等价时间轴调用代码。
     *
     * <p>形如 <code>parent.$effect_ctrler.bisha(false, 'ichigo1');</code>。</p>
     *
     * @param methodName 方法名。
     * @param args 参数列表。
     * @param rawArgs 为 <code>true</code> 时参数已是字面量字符串，不再二次格式化。
     *
     * @example
     * <listing version="3.0">
     * updateCallPreview('bisha', [false, 'ichigo1']);
     * updateCallPreview('shine', [ColorUtils.asLiteral(0xffffff)]);
     * </listing>
     */
    protected function updateCallPreview(methodName:String, args:Array = null, rawArgs:Boolean = false):void {
        updatePreviewText(formatCallCode(methodName, args, rawArgs));
    }

    /**
     * 拼凑等价时间轴调用代码。
     *
     * @param methodName 方法名。
     * @param args 参数列表。
     * @param rawArgs 为 <code>true</code> 时参数已是字面量字符串，不再二次格式化。
     * @return 形如 <code>parent.$effect_ctrler.bisha(false, 'ichigo1');</code> 的字符串。
     */
    protected function formatCallCode(methodName:String, args:Array = null, rawArgs:Boolean = false):String {
        var prop:String = _ctrlerProp ? _ctrlerProp : '$ctrler';
        var parts:Array = [];
        var i:int;
        var len:int;

        if (args) {
            len = args.length;
            for (i = 0; i < len; i++) {
                parts.push(rawArgs ? String(args[i]) : formatLiteral(args[i]));
            }
        }

        return 'parent.' + prop + '.' + methodName + '(' + parts.join(', ') + ');';
    }

    /**
     * 校验参数是否符合预期。
     *
     * <p>失败时以红色显示完整错误提示；通过时不改预览文字，由调用方继续更新。</p>
     * <p><code>expected</code> 为 <code>null</code>：校验非空（非 <code>null</code>、非空串）。
     * 为 <code>Array</code>：值须为其中之一；其它：值须与期望相等。</p>
     *
     * @param name 参数名（错误提示用）。
     * @param value 实际值。
     * @param expected 期望；默认 <code>null</code> 表示非空校验。
     * @return 通过返回 <code>true</code>。
     *
     * @example
     * <listing version="3.0">
     * validateParam('face', _face);
     * validateParam('type', _type, [0, 1, 2]);
     * validateParam('mode', _mode, 'hard');
     * </listing>
     */
    protected function validateParam(name:String, value:*, expected:* = null):Boolean {
        var ok:Boolean;
        var tip:String;

        if (expected == null) {
            ok  = !isBlankParam(value);
            tip = '参数错误: [' + name + '] 不能为空';
        }
        else if (expected is Array) {
            ok  = (expected as Array).indexOf(value) != -1;
            tip = '参数错误: [' + name + '] 须为 ' + (expected as Array).join('/');
        }
        else {
            ok  = value == expected;
            tip = '参数错误: [' + name + '] 须为 ' + expected;
        }

        if (ok) {
            return true;
        }

        updateStatusText(tip, false);
        trace('[BaseIdeCtrler]', tip, 'value=', value, this);
        return false;
    }

    /**
     * 解析注入控制器。
     *
     * <p>子类覆盖：调用对应 <code>IdeRuntimeUtils.findXxxCtrler</code>，并设置 <code>_ctrlerProp</code>。</p>
     */
    protected function resolveCtrler():void {
    }

    /**
     * 安全调用已解析控制器的方法。
     *
     * @param methodName 方法名。
     * @param args 参数列表。
     * @return 调用成功返回 <code>true</code>。
     *
     * @example
     * <listing version="3.0">
     * invokeCtrler('shine', [0xffffff]);
     * </listing>
     */
    protected function invokeCtrler(methodName:String, args:Array = null):Boolean {
        if (!_ctrler) {
            return false;
        }

        if (!IdeRuntimeUtils.hasMethod(_ctrler, methodName)) {
            trace('[BaseIdeCtrler] method missing on', _ctrlerProp || '(ctrler)', ':', methodName, this);
            return false;
        }

        try {
            var fn:Function = _ctrler[methodName] as Function;
            fn.apply(_ctrler, args);
            return true;
        }
        catch (e:Error) {
            trace('[BaseIdeCtrler] invoke failed:', _ctrlerProp, methodName, e.message, this);
        }
        return false;
    }

    /** @private 是否视为空参数（null / 空串） */
    private static function isBlankParam(value:*):Boolean {
        if (value == null) {
            return true;
        }
        if (value is String) {
            return String(value).length == 0;
        }
        return false;
    }

    /** @private 将参数格式化为 AS 字面量 */
    private static function formatLiteral(value:*):String {
        if (value == null) {
            return 'null';
        }
        if (value is String) {
            var s:String = String(value);
            // 0x / # 色值字面量：原样输出，不加引号
            if (isColorLiteral(s)) {
                return normalizeColorLiteral(s);
            }
            return "'" + s.split("'").join("\\'") + "'";
        }
        if (value is Boolean) {
            return value ? 'true' : 'false';
        }
        return String(value);
    }

    /** @private 是否为色值字面量（0xRRGGBB / #RRGGBB） */
    private static function isColorLiteral(s:String):Boolean {
        if (!s) {
            return false;
        }
        if (s.indexOf('0x') == 0 || s.indexOf('0X') == 0) {
            return s.length > 2;
        }
        if (s.charAt(0) == '#') {
            return s.length > 1;
        }
        return false;
    }

    /** @private #RRGGBB → 0xrrggbb；已是 0x 则保持 */
    private static function normalizeColorLiteral(s:String):String {
        if (s.charAt(0) == '#') {
            return '0x' + s.substring(1).toLowerCase();
        }
        return s;
    }
}
}
