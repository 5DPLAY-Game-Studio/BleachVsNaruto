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
import net.play5d.game.bvn.ide.component.*;

import flash.text.TextField;
import flash.text.TextFormat;

/**
 * 组件 震动特效
 */
public class ShakeEffect extends BaseEffect {

    /////////////// 静态方法 ///////////////

    ///////////////////////////////////////


    /////////////// 构造方法 ///////////////

    /**
     * 构造方法
     */
    public function ShakeEffect() {
        super.title = '效果_震动';
    }

    ///////////////////////////////////////


    /////////////// 实现接口 ///////////////

    ///////////////////////////////////////


    /////////////// 公有属性 ///////////////

    ///////////////////////////////////////


    /////////////// 私有属性 ///////////////

    ///////////////////////////////////////


    /////////// Getter & Setter ///////////

    /* powX 属性 */
    private var _powX:Number = 0;
    /* X 轴幅度 */
    public function get powX():Number {
        return _powX;
    }
    [Inspectable(name='powX', type='Number', defaultValue=0)]
    public function set powX(v:Number):void {
        _powX = v;

        super.text = '(' + _powX + ', ' + _powY + ')';
    }

    /* powY 属性 */
    private var _powY:Number = 0;
    /* Y 轴幅度 */
    public function get powY():Number {
        return _powY;
    }
    [Inspectable(name='powY', type='Number', defaultValue=0)]
    public function set powY(v:Number):void {
        _powY = v;

        super.text = '(' + _powX + ', ' + _powY + ')';
    }

    ///////////////////////////////////////


    /////////////// 公有方法 ///////////////

    /**
     * 要详细执行的动作
     */
    override public function doAction():void {
        shake();
    }

    ///////////////////////////////////////


    /////////////// 私有方法 ///////////////

    /**
     * 执行闪光
     */
    private function shake():void {
        if (!_effectCtrler) {
            return;
        }

        _effectCtrler.shake(_powX, _powY);
    }

    ///////////////////////////////////////

}
}
