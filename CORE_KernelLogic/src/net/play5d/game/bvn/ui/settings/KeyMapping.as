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
import fl.motion.ColorMatrix;

import flash.display.Sprite;
import flash.filters.ColorMatrixFilter;

import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.kyo.display.bitmap.BitmapFontText;
import net.play5d.kyo.input.KyoKeyCode;

/**
 * 一个键位的显示。方向键缩到 0.8，最宽 40，并下移 5。其它键最宽 60。超宽时改宽度，再把纵向缩放设成横向缩放。
 */
public class KeyMapping {

    /**
     * 记下键位并把变暗的文字加到容器上。字体缺失时抛错。
     *
     * @param mc 容器。null 时抛错。
     * @param keyId 键编号。
     * @param name 显示名。
     * @param cn 中文名。
     * @throws TypeError 容器或字体缺失时。
     */
    public function KeyMapping(mc:Sprite, keyId:String, name:String, cn:String) {
        this.mc    = mc;
        this.keyId = keyId;
        this.name  = name;
        this.cn    = cn;

        _keyTxt = new BitmapFontText(AssetManager.I.getFont('font1'));

        var matrix:ColorMatrix = new ColorMatrix();
        matrix.SetBrightnessMatrix(-100);
        matrix.SetSaturationMatrix(0);
        _keyTxt.filters = [new ColorMatrixFilter(matrix.GetFlatArray())];

        mc.addChild(_keyTxt);
    }
    /**
     * 键的显示名。
     */
    public var name:String;
    /**
     * 键位容器。
     */
    public var mc:Sprite;
    /**
     * 键编号。方向键是 up、down、left、right。
     */
    public var keyId:String;
    /**
     * 中文名。
     */
    public var cn:String;
    private var _keyTxt:BitmapFontText;

    /**
     * 显示这个键。没传名字，或名字是空字符串时，用键码去查。查不到再转大写会抛错。
     *
     * @param code 键码。
     * @param keyName 显示文字。默认 null，改为按键码查询。
     * @throws TypeError 名字最终是 null 时。
     * @example
     * <listing version="3.0">
     * mapping.setKey(code);
     * </listing>
     */
    public function setKey(code:int, keyName:String = null):void {
        keyName ||= KyoKeyCode.code2name(code);
        _keyTxt.text = keyName.toUpperCase();

        var _maxWidth:Number = 0;
        var _scale:Number    = 1;
        var offsetY:Number   = 0;

        if (keyId == 'up' || keyId == 'down' || keyId == 'left' || keyId == 'right') {
            _scale    = 0.8;
            _maxWidth = 40;
            offsetY   = 5;
        }
        else {
            _maxWidth = 60;
        }

        if (_keyTxt.width > _maxWidth) {
            _keyTxt.width  = _maxWidth;
            _keyTxt.scaleY = _keyTxt.scaleX;
        }
        else {
            _keyTxt.scaleX = _keyTxt.scaleY = _scale;
        }

        _keyTxt.x = -_keyTxt.width / 2;
        _keyTxt.y = -_keyTxt.height / 2 + offsetY;
    }

}
}
