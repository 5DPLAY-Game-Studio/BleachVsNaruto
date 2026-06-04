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
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.system.System;
import flash.text.TextField;
import flash.utils.getTimer;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ui.UIUtils;
import net.play5d.kyo.display.BitmapText;

public class Debugger {
    include '../../../../../../include/_INCLUDE_.as';

    public static const DRAW_AREA:Boolean      = false;
    public static const SAFE_MODE:Boolean      = false;
    public static const DEBUG_ENABLED:Boolean  = false;
    public static const HIDE_MAP:Boolean       = false;
    public static const HIDE_HITEFFECT:Boolean = false;
    public static var onErrorMsgCall:Function;
    private static var _stage:Stage;

    public static function log(...params):void {
        trace.call(null, params);
    }

    public static function errorMsg(msg:String):void {
        TraceLang('debug.trace.data.debugger.error_msg', {message: '\n' + msg});
        if (onErrorMsgCall != null) {
            onErrorMsgCall(msg);
        }
    }

    public static function initDebug(stage:Stage):void {
        _stage = stage;

        showFPS();
    }

    public static function addChild(d:DisplayObject):void {
        _stage.addChild(d);
    }

    /**
     * 显示当前提交哈希
     *
     * @param hash 提交哈希
     */
    public static function showCommitHash(hash:String):void {
        if (!hash) {
            return;
        }

        var hashText:BitmapText = new BitmapText(
                true,
                0xFFFF00,
                [new GlowFilter(0x000000, 1, 2, 2, 3)]
        );

        hashText.font = FONT.fontName;
        hashText.text = hash;

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

    private static var _fpsLastTime:int;
    private static var _fpsFrameCount:int;
    private static var _fpsText:TextField;
    private static var _smoothedFPS:Number = 60;
    private static const _FPS_ALPHA:Number = 0.15;

    public static function showFPS():void {
        if (_fpsText != null) {
            return;
        }

        _fpsLastTime   = getTimer();
        _fpsFrameCount = 0;
        _smoothedFPS   = 60;

        _fpsText              = new TextField();
        _fpsText.textColor    = 0xffff00;
        _fpsText.mouseEnabled = false;
        _stage.addChild(_fpsText);
        _stage.addEventListener(Event.ENTER_FRAME, updateFPS);
    }

    private static function updateFPS(e:Event):void {
        _fpsFrameCount++;

        var currentTime:int = getTimer();
        var deltaTime:int   = currentTime - _fpsLastTime;

        if (deltaTime >= 100) {
            var instantFPS:Number = _fpsFrameCount / (deltaTime / 1000);

            _smoothedFPS = _FPS_ALPHA * instantFPS + (1 - _FPS_ALPHA) * _smoothedFPS;

            _fpsText.text = 'fps:' + _smoothedFPS.toFixed(1);

            _fpsLastTime   = currentTime;
            _fpsFrameCount = 0;
        }
    }

}
}
