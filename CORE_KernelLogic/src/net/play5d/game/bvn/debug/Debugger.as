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

package net.play5d.game.bvn.debug {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.system.System;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.utils.GameLogger;
import net.play5d.game.bvn.ui.UIUtils;
import net.play5d.kyo.display.BitmapText;

/**
 * 调试开关、错误回调和舞台上的调试显示。
 *
 * <p><code>DEBUG_ENABLED</code> 为 <code>false</code> 时，PC 启动不会调用 <code>initDebug</code>。
 * <code>initDebug</code> 只记下舞台并打开帧率。还没记下舞台时，<code>addChild</code> 和提交哈希都会在加入显示列表时抛错。
 * <code>SAFE_MODE</code> 固定为 <code>false</code>，工程里没有读取它的代码。</p>
 *
 * @see FPSDisplay
 */
public class Debugger {

    /**
     * 为 <code>true</code> 时，对局画出身体和攻击矩形，并在每帧渲染前清掉这些矩形。
     *
     * @default false
     */
    public static const DRAW_AREA:Boolean      = false;
    /**
     * 安全模式开关。当前没有读取方。
     *
     * @default false
     */
    public static const SAFE_MODE:Boolean      = false;
    /**
     * PC 启动是否自动打开调试显示。
     *
     * @default false
     */
    public static const DEBUG_ENABLED:Boolean  = false;
    /**
     * 为 <code>true</code> 时，地图 <code>setVisible(true)</code> 直接返回，初始化结束也会把地图藏起来。
     *
     * @default false
     */
    public static const HIDE_MAP:Boolean       = false;
    /**
     * 为 <code>true</code> 时，命中特效和钢体命中特效直接返回。
     *
     * @default false
     */
    public static const HIDE_HITEFFECT:Boolean = false;
    /**
     * <code>errorMsg</code> 打完日志后调用。参数是同一条消息。
     *
     * @default null
     */
    public static var onErrorMsgCall:Function;
    /** @private */
    private static var _stage:Stage;

    /**
     * 把参数用空格拼成一条 <code>sys</code> 调试日志。
     *
     * @param params 要拼进去的内容。
     * @example
     * <listing version="3.0">
     * Debugger.log('pack skip', id);
     * </listing>
     */
    public static function log(...params):void {
        GameLogger.debug('sys', params.join(' '));
    }

    /**
     * 打一条错误日志。回调不为空时，再用同一条消息调用它。
     *
     * @param msg 错误内容。
     * @example
     * <listing version="3.0">
     * Debugger.errorMsg(msg);
     * </listing>
     * @see #onErrorMsgCall
     */
    public static function errorMsg(msg:String):void {
        TraceLang('debugger.error_msg', {message: '\n' + msg});
        if (onErrorMsgCall != null) {
            onErrorMsgCall(msg);
        }
    }

    /**
     * 记下舞台并显示帧率。
     *
     * <p><code>stage</code> 为空时帧率层不出现，舞台引用仍写成 <code>null</code>。</p>
     *
     * @param stage 目标舞台。
     * @example
     * <listing version="3.0">
     * Debugger.initDebug(stage);
     * </listing>
     * @see FPSDisplay#show()
     */
    public static function initDebug(stage:Stage):void {
        _stage = stage;

        FPSDisplay.show(stage);
    }

    /**
     * 把显示对象加到 <code>initDebug</code> 记下的舞台末尾。
     *
     * <p>还没记下舞台时抛错。</p>
     *
     * @param d 要加上的显示对象。
     * @example
     * <listing version="3.0">
     * Debugger.addChild(sprite);
     * </listing>
     */
    public static function addChild(d:DisplayObject):void {
        _stage.addChild(d);
    }

    /**
     * 在画面底部显示提交文本。点击时把完整哈希复制到剪贴板。
     *
     * <p><code>hash</code> 为空时直接返回。每次调用都再加一层，不替换上一层。
     * 全局 <code>FONT</code> 还是 <code>null</code> 时，读字体名会抛错。舞台还没记下时，加入显示列表会抛错。</p>
     *
     * @param hash 完整提交哈希。点击复制的是它，不是屏幕上的短文本。
     * @param displayText 屏幕上的文字。默认 <code>null</code>，改用 <code>hash</code>。空字符串也改用 <code>hash</code>。
     * @example
     * <listing version="3.0">
     * Debugger.showCommitHash(hash, label);
     * </listing>
     */
    public static function showCommitHash(hash:String, displayText:String = null):void {
        if (!hash) {
            return;
        }

        var label:String = displayText || hash;

        var hashText:BitmapText = new BitmapText(
                true,
                0xFFFF00,
                [new GlowFilter(0x000000, 1, 2, 2, 3)]
        );

        hashText.font = FONT.fontName;
        hashText.text = label;

        UIUtils.formatText(hashText.textfield, {
            color: 0xFFFF00,
            size : 10
        });

        var sp:Sprite = new Sprite();
        sp.y          = GameConfig.GAME_SIZE.y - 20;
        sp.addChild(hashText);
        sp.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
            System.setClipboard(hash);
        });

        addChild(sp);
    }

    /**
     * 显示帧率层。
     *
     * <p>没传舞台时用 <code>initDebug</code> 记下的舞台。两边都没有，或帧率层已经在显示，则直接返回。</p>
     *
     * @param stage 目标舞台。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * Debugger.showFPS(stage);
     * </listing>
     * @see FPSDisplay#show()
     */
    public static function showFPS(stage:Stage = null):void {
        FPSDisplay.show(stage || _stage);
    }
    /**
     * 关掉帧率层。还没显示时直接返回。
     *
     * @example
     * <listing version="3.0">
     * Debugger.hideFPS();
     * </listing>
     * @see FPSDisplay#hide()
     */
    public static function hideFPS():void {
        FPSDisplay.hide();
    }

}
}
