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

package net.play5d.game.bvn.utils {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.ColorTransform;
import flash.utils.Dictionary;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.kyo.utils.KyoDisplayUtils;

/**
 * 游戏 UI 按钮：触控/鼠标、点击音效与按下色变。
 *
 * <p>玩法界面首选本类。壳 LAN 的 Tween 按钮用库 <code>KyoBtnUtils</code>；两套依赖不同，勿合并。</p>
 */
public class BtnUtils {

    private static var _btnMap:Dictionary = new Dictionary();


    /**
     * 设置按钮光标和子对象鼠标。按钮为 null 时直接返回。
     *
     * @param btn 按钮。
     * @param buttonMode 是否手型。默认 true。
     * @param mouseChildren 子对象是否接收鼠标。默认 false。
     * @example
     * <listing version="3.0">
     * BtnUtils.btnMode(btn);
     * </listing>
     */
    public static function btnMode(btn:Sprite, buttonMode:Boolean = true, mouseChildren:Boolean = false):void {
        if (!btn) {
            return;
        }

        btn.buttonMode    = buttonMode;
        btn.mouseChildren = mouseChildren;
    }

    /**
     * 登记点击。按钮为 null 时直接返回。目标为空时改成按钮自己，包括 0 和空字符串。
     *
     * <p>触控模式只听抬起。鼠标模式听移入、移出和点击，移入会变亮并播放选择音。同一个按钮再登记，监听不会加第二次，回调和当时的颜色换成新的一份。回调为 null 时，点击不播放确认音。</p>
     *
     * @param btn 按钮。
     * @param handler 点击回调，参数是目标。
     * @param target 交给回调的对象。默认 null，实际改成按钮自己。
     * @example
     * <listing version="3.0">
     * BtnUtils.initBtn(btn, onClick);
     * </listing>
     */
    public static function initBtn(btn:DisplayObject, handler:Function, target:* = null):void {
        if (!btn) {
            return;
        }

        target ||= btn;

        _btnMap[btn] = {
            handler: handler, target: target, transform: KyoDisplayUtils.cloneColorTransform(btn.transform.colorTransform)
        };

        if (GameConfig.TOUCH_MODE) {
            btn.addEventListener(TouchEvent.TOUCH_END, touchHandler);
        }
        else {
            btn.addEventListener(MouseEvent.MOUSE_OVER, btnHandler);
            btn.addEventListener(MouseEvent.MOUSE_OUT, btnHandler);
            btn.addEventListener(MouseEvent.CLICK, btnHandler);
        }

    }

    /**
     * 摘掉触控和鼠标监听，并忘掉回调。按钮为 null 时直接返回。没登记过时，移除监听没有效果。
     *
     * @param btn 按钮。
     * @example
     * <listing version="3.0">
     * BtnUtils.destroyBtn(btn);
     * </listing>
     */
    public static function destroyBtn(btn:DisplayObject):void {
        if (!btn) {
            return;
        }

        btn.removeEventListener(TouchEvent.TOUCH_END, touchHandler);

        btn.removeEventListener(MouseEvent.MOUSE_OVER, btnHandler);
        btn.removeEventListener(MouseEvent.MOUSE_OUT, btnHandler);
        btn.removeEventListener(MouseEvent.CLICK, btnHandler);

        delete _btnMap[btn];

    }

    private static function overEffect(btn:DisplayObject, v:Boolean):void {
        var obj:Object                       = _btnMap[btn];
        var orgColorTransform:ColorTransform = obj.transform;

        if (v) {
            var colorTransform:ColorTransform        = KyoDisplayUtils.cloneColorTransform(orgColorTransform);
            colorTransform.redOffset += 30;
            colorTransform.greenOffset += 30;
            colorTransform.blueOffset += 30;
            btn.transform.colorTransform             = colorTransform;
            SoundCtrl.I.sndSelect();
        }
        else {
            btn.transform.colorTransform             = orgColorTransform;
        }
    }

    private static function applyBtnFunc(btn:DisplayObject):void {
        var o:Object = _btnMap[btn];
        if (!o || !o.handler) {
            return;
        }

        SoundCtrl.I.sndConfirm();
        o.handler(o.target);
    }

    private static function btnHandler(e:MouseEvent):void {
        var btn:DisplayObject = e.currentTarget as DisplayObject;

        switch (e.type) {
        case MouseEvent.CLICK:
            applyBtnFunc(btn);
            break;
        case MouseEvent.MOUSE_OVER:
            overEffect(btn, true);
            break;
        case MouseEvent.MOUSE_OUT:
            overEffect(btn, false);
            break;
        }
    }

    private static function touchHandler(e:TouchEvent):void {
        var btn:DisplayObject = e.currentTarget as DisplayObject;

        switch (e.type) {
        case TouchEvent.TOUCH_END:
            applyBtnFunc(btn);
            break;
        }
    }

}
}
