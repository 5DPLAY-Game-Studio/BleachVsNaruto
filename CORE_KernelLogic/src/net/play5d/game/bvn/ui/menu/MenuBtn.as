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

package net.play5d.game.bvn.ui.menu {
import com.greensock.TweenLite;
import com.greensock.easing.Elastic;

import flash.display.BitmapData;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.ColorTransform;

import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.display.BitmapText;
import net.play5d.kyo.display.bitmap.BitmapFontText;

public class MenuBtn extends EventDispatcher {

    /** @private */
    private static var _commonWarmed:Boolean;

    /**
     * 预热菜单按钮底板光栅化与悬停 scale 路径，避免首次悬停卡顿。
     *
     * <p>幂等；不入显示列表、不发声。须在 <code>loadBasic</code> / <code>font1</code> 之后调用。</p>
     *
     * @example
     * <listing version="3.0">
     * MenuBtn.warmCommon();
     * </listing>
     */
    public static function warmCommon():void {
        if (_commonWarmed) {
            return;
        }
        _commonWarmed = true;

        try {
            var btn:MenuBtn = new MenuBtn('WARM', '');
            var bg:*        = btn.ui.bg;
            bg.visible      = true;
            bg.scaleX       = 1;
            bg.gotoAndStop(1);
            forceRasterizeDisplay(bg);

            bg.gotoAndStop(2);
            forceRasterizeDisplay(bg);
            bg.gotoAndStop(1);

            TweenLite.killTweensOf(bg);
            bg.scaleX = 0.01;
            TweenLite.to(bg, 0.01, {scaleX: 1});
            TweenLite.killTweensOf(bg);
            bg.scaleX  = 1;
            bg.visible = false;

            btn.dispose();
        }
        catch (e:Error) {
        }
    }

    /**
     * @private 强制光栅化显示对象。
     */
    private static function forceRasterizeDisplay(target:*):void {
        if (!target) {
            return;
        }
        var w:int = Math.ceil(Math.abs(target.width));
        var h:int = Math.ceil(Math.abs(target.height));
        if (w < 1 || h < 1) {
            return;
        }
        try {
            var bd:BitmapData = new BitmapData(w, h, true, 0);
            bd.draw(target);
            bd.dispose();
        }
        catch (e:Error) {
        }
    }

    public function MenuBtn(label:String, cn:String = '', func:Function = null) {
        this.cn    = cn;
        this.label = label;
        this.func  = func;

        ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.common, '$common$MC_menuBtn');

        ui.buttonMode    = true;
        ui.mouseChildren = false;

        _bitmapText      = new BitmapFontText(AssetManager.I.getFont('font1'));
        _bitmapText.text = label;
        _bitmapText.x    = -_bitmapText.width / 2;
        ui.addChild(_bitmapText);


        ui.bg.mouseChildren = ui.bg.mouseEnabled = false;
        ui.bg.visible       = false;

        if (GameUI.SHOW_CN_TEXT) {
            _cnTxt = new BitmapText();
            UIUtils.formatText(_cnTxt.textfield, {size: 18});
            _cnTxt.text = cn;
            _cnTxt.x    = 10;
            _cnTxt.y    = 43;
            ui.bg.addChild(_cnTxt);
        }

    }
    public var ui:$common$MC_menuBtn;
    public var cn:String;
    public var label:String;
    public var func:Function;
    public var height:Number = 75;
    public var index:int;
    public var children:Array;
    private var _bitmapText:BitmapFontText;
    private var _cnTxt:BitmapText;
    private var _listeners:Object = {};
    private var _isOpen:Boolean;

    public override function addEventListener(
            type:String, listener:Function, useCapture:Boolean = false, priority:int = 0,
            useWeakReference:Boolean                                                 = false
    ):void {
        if (ui.hasEventListener(type)) {
            return;
        }
        ui.addEventListener(type, selfHandler, useCapture, priority, useWeakReference);
        _listeners[type] = listener;
    }

    public function removeAllEventListener():void {
        for (var i:String in _listeners) {
            ui.removeEventListener(i, _listeners[i]);
        }
        _listeners = {};
    }

    public function isHover():Boolean {
        return ui.bg.visible;
    }

    public function hover():void {
        if (_isOpen) {
            return;
        }
        if (ui.bg.visible) {
            return;
        }
        ui.bg.visible = true;
        var sx:Number = ui.bg.scaleX;
        ui.bg.scaleX  = 0.01;
        TweenLite.to(ui.bg, 0.2, {scaleX: sx});
        SoundCtrl.I.sndSelect();
    }

    public function normal():void {
        if (_isOpen) {
            return;
        }
        ui.bg.visible = false;
//			TweenLite.to(ui.bg,0.1,{scaleX:0.01,onComplete:function():void{
//				ui.bg.visible = false;
//			}});
    }

    public function select(back:Function = null):void {
        ui.alpha = -1;
        TweenLite.to(ui, 1, {alpha: 1, ease: Elastic.easeOut, onComplete: back});
        SoundCtrl.I.sndConfrim();
    }

    public function openChild():void {
        if (_isOpen) {
            return;
        }
        _isOpen = true;
        ui.bg.gotoAndStop(2);
        var ct:ColorTransform = new ColorTransform();
        ct.redOffset          = 50;
        ct.greenOffset        = -30;
        ct.blueOffset         = -30;
        _bitmapText.applyColorTransform(ct);
    }

    public function closeChild():void {
        if (!_isOpen) {
            return;
        }
        _isOpen = false;
        ui.bg.gotoAndStop(1);

        _bitmapText.applyColorTransform(null);
    }

    public function dispose():void {
        if (_bitmapText) {
            _bitmapText.dispose();
            _bitmapText = null;
        }
        removeAllEventListener();

        if (children) {
            for each(var b:MenuBtn in children) {
                b.dispose();
            }
            children = null;
        }

        if (_cnTxt) {
            _cnTxt.destroy();
            _cnTxt = null;
        }

    }

    public function childMode():void {
        var ct:ColorTransform = new ColorTransform();
        ct.redOffset          = 50;
        ct.greenOffset        = -30;
        ct.blueOffset         = -30;

        _bitmapText.applyColorTransform(ct);
        _bitmapText.scaleX = _bitmapText.scaleY = 0.75;
        _bitmapText.x      = -_bitmapText.width / 2;

        ui.bg.scaleY = 0.75;
        ui.bg.scaleX = 0.9;
        ui.bg.gotoAndStop(2);
        height = 55;
    }

    private function selfHandler(e:Event):void {
        _listeners[e.type](e.type, this);
    }


}
}
