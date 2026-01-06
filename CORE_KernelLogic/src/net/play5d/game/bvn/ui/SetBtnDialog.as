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

package net.play5d.game.bvn.ui {
import flash.text.TextField;
import flash.text.TextFormat;

import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.display.bitmap.BitmapFontText;

public class SetBtnDialog {
    include '../../../../../../include/_INCLUDE_.as';

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
    public var ui:$setting$SP_keySetDialog;
    public var isShow:Boolean = true;
    private var _pushTxt:BitmapFontText;
    private var _keyNameTxt:BitmapFontText;
    private var _cntxt:TextField;

    public function show(name:String, cn:String):void {
        ui.visible = true;

        _keyNameTxt.text = name;
        _keyNameTxt.x    = -_keyNameTxt.width / 2;
        _cntxt.text      = '请按下一个键设置【' + cn + '】';

        isShow = true;
    }

    public function hide():void {
        ui.visible = false;
        isShow     = false;
    }

}
}
