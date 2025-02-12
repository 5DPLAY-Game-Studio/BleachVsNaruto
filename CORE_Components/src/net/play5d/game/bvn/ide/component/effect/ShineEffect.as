/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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

package net.play5d.game.bvn.ide.component.effect {
import flash.text.TextFormat;

import net.play5d.game.bvn.ide.component.BaseEffect;
import net.play5d.game.bvn.ide.utils.ColorUtils;

/**
 * 组件 闪光特效
 */
public class ShineEffect extends BaseEffect {

    /////////////// 静态方法 ///////////////

    ///////////////////////////////////////


    /////////////// 构造方法 ///////////////

    /**
     * 构造方法
     */
    public function ShineEffect() {
        super.title = '效果_闪光';
    }

    ///////////////////////////////////////


    /////////////// 实现接口 ///////////////

    ///////////////////////////////////////


    /////////////// 公有属性 ///////////////

    ///////////////////////////////////////


    /////////////// 私有属性 ///////////////

    ///////////////////////////////////////


    /////////// Getter & Setter ///////////

    /* color 属性 */
    private var _color:uint = 0xffffff;
    /* 颜色 */
    public function get color():uint {
        return _color;
    }
    [Inspectable(name='color', type='Color', defaultValue='ffffff')]
    public function set color(v:uint):void {
        _color = v;

        var textFormat:TextFormat = new TextFormat();
        textFormat.color          = _color;

        super.text = ColorUtils.dec2hex(_color);
        textTxt.setTextFormat(textFormat);
    }

    ///////////////////////////////////////


    /////////////// 公有方法 ///////////////

    /**
     * 要详细执行的动作
     */
    override public function doAction():void {
        shine();
    }

    ///////////////////////////////////////


    /////////////// 私有方法 ///////////////

    /**
     * 执行闪光
     */
    private function shine():void {
        if (!_effectCtrler) {
            return;
        }

        _effectCtrler.shine(_color);
    }

    ///////////////////////////////////////

}
}
