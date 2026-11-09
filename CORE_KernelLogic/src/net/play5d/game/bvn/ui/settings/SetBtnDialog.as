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

package net.play5d.game.bvn.ui.settings {
import flash.text.TextField;
import flash.text.TextFormat;

import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.display.bitmap.BitmapFontText;

/**
 * 等按键的提示。构造后影片是隐藏的，但 <code>isShow</code> 初始是 true，要等 <code>show</code> 或 <code>hide</code> 才和可见性一致。
 */
public class SetBtnDialog {

    /**
     * 创建提示并先隐藏。字体缺失时抛错。
     *
     * @throws TypeError 资源或字体缺失时。
     */
    public function SetBtnDialog() {
        ui         = ResUtils.I.createDisplayObject(ResUtils.swfLib.setting, '$setting$SP_keySetDialog');
        ui.visible = false;

        _pushTxt    = new BitmapFontText(AssetManager.I.getFont('font1'));
        _keyNameTxt = new BitmapFontText(AssetManager.I.getFont('font1'));

        _pushTxt.y = _keyNameTxt.y = -30;

        _pushTxt.text = 'PUSH A KEY FOR';
        _pushTxt.x    = -_pushTxt.width / 2;
        ui.ct_msg.addChild(_pushTxt);

        ui.ct_keyname.addChild(_keyNameTxt);

        _cntxt                   = ui.txt;
        _cntxt.defaultTextFormat = new TextFormat('楷体', 20);
    }
    /**
     * 提示影片。构造后是隐藏的。
     */
    public var ui:$setting$SP_keySetDialog;
    /**
     * 是否算显示中。构造后是 true，和影片的隐藏不一致。
     *
     * @default true
     */
    public var isShow:Boolean = true;
    private var _pushTxt:BitmapFontText;
    private var _keyNameTxt:BitmapFontText;
    private var _cntxt:TextField;

    /**
     * 显示提示，并把 <code>isShow</code> 写成 true。
     *
     * @param name 键名，画在中间。
     * @param cn 中文名，交给文案。
     * @example
     * <listing version="3.0">
     * dialog.show(name, cn);
     * </listing>
     */
    public function show(name:String, cn:String):void {
        ui.visible = true;

        _keyNameTxt.text = name;
        _keyNameTxt.x    = -_keyNameTxt.width / 2;
        _cntxt.text      = GetLang('settings.push_key', {name: cn});

        isShow = true;
    }

    /**
     * 隐藏提示，并把 <code>isShow</code> 写成 false。
     *
     * @example
     * <listing version="3.0">
     * dialog.hide();
     * </listing>
     */
    public function hide():void {
        ui.visible = false;
        isShow     = false;
    }

}
}
