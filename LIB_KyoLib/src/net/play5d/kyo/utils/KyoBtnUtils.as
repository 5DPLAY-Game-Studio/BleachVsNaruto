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

package net.play5d.kyo.utils {
import com.greensock.TweenLite;
import com.greensock.easing.Elastic;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.utils.Dictionary;

public class KyoBtnUtils {
    private static var _btnMap:Dictionary = new Dictionary();

    private static var _blackTransform:ColorTransform = new ColorTransform(1, 1, 1, 1, -20, -20, -20);
    private static var _emptyTransform:ColorTransform = new ColorTransform();

    private static var _btnTween:TweenLite;

    private static var _curOnClick:Function;
    private static var _curOnClickParam:*;

    /**
     * 定义简单按钮
     * @param d
     * @param click
     * @param clickParam
     *
     */
    public static function initSampleBtn(d:DisplayObject, click:Function = null, clickParam:* = null):void {

        _btnMap[d] = {
            x         : d.x, y: d.y,
            scaleX    : d.scaleX, scaleY: d.scaleY,
            click     : click,
            clickParam: clickParam
        };

        if (click != null) {
            d.addEventListener(MouseEvent.CLICK, sampleBtnHandler);
        }
    }

    public static function disposeSampleBtn(d:DisplayObject):void {
        if (d == null) {
            return;
        }
        _btnMap[d] = null;
        d.removeEventListener(MouseEvent.CLICK, sampleBtnHandler);
    }

    /**
     * 定义按钮
     * @param d
     * @param click 点击事件
     * @param clickParam 点击事件传回参数
     * @param effectType 1-简单效果，2=动画效果
     */
    public static function initBtn(d:DisplayObject, click:Function = null, clickParam:* = null,
                                   effectType:int                                       = 1
    ):void {

        if (d is Sprite) {
            (
                    d as Sprite
            ).mouseChildren = false;
            (
                    d as Sprite
            ).buttonMode    = true;
        }

        _btnMap[d] = {
            x         : d.x, y: d.y,
            scaleX    : d.scaleX, scaleY: d.scaleY,
            effectType: effectType,
            click     : click,
            clickParam: clickParam
        };
        d.addEventListener(MouseEvent.MOUSE_DOWN, btnHandler);
        d.addEventListener(MouseEvent.MOUSE_UP, btnHandler);
        if (click != null) {
            d.addEventListener(MouseEvent.CLICK, btnHandler);
        }
    }

    public static function disposeBtn(d:DisplayObject):void {
        if (d == null) {
            return;
        }
        d.removeEventListener(MouseEvent.MOUSE_DOWN, btnHandler);
        d.removeEventListener(MouseEvent.MOUSE_UP, btnHandler);
        d.removeEventListener(MouseEvent.CLICK, btnHandler);
        _btnMap[d] = null;
    }

    private static function doBtnEffect(d:DisplayObject, param:Object, resume:Boolean = false):void {
        switch (param.effectType) {
        case 2:
            if (!resume) {
                d.y += 10;
                d.transform.colorTransform = _blackTransform;
            }
            else {
                d.transform.colorTransform = _emptyTransform;
                _btnTween                  = TweenLite.to(
                        d, 0.5, {y: param.y, ease: Elastic.easeOut, onComplete: btnEffectFin});
            }
            break;
        case 1:
            if (!resume) {
                d.transform.colorTransform = _blackTransform;
            }
            else {
                d.transform.colorTransform = _emptyTransform;
                //						btnEffectFin();
                //						TweenLite.delayedCall(0.2,btnEffectFin);
            }
            break;
        }
    }

    private static function btnEffectFin():void {
        if (_curOnClick != null) {
            if (_curOnClickParam != null) {
                _curOnClick(_curOnClickParam);
            }
            else {
                _curOnClick();
            }

            _curOnClick      = null;
            _curOnClickParam = null;
        }
    }

    private static function sampleBtnHandler(e:MouseEvent):void {
        var o:Object = _btnMap[e.currentTarget];
        if (o.click != null) {
            if (o.clickParam != null) {
                o.click(o.clickParam);
            }
            else {
                o.click();
            }
        }
    }

    private static function btnHandler(e:MouseEvent):void {
        var d:DisplayObject = e.currentTarget as DisplayObject;
        var o:Object        = _btnMap[d];
        switch (e.type) {
        case MouseEvent.MOUSE_DOWN:
            if (_btnTween && _btnTween.active) {
                _btnTween.kill();
            }
            doBtnEffect(d, o, false);
            break;
        case MouseEvent.MOUSE_UP:

            if (_btnTween && _btnTween.active) {
                _btnTween.kill();
            }

            doBtnEffect(d, o, true);

            break;
        case MouseEvent.CLICK:
            _curOnClick      = o.click;
            _curOnClickParam = o.clickParam;

            if (o.effectType == 1) {
                btnEffectFin();
            }

            break;
        }
    }

}
}
