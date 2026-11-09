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
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import net.play5d.game.bvn.GameConfig;

/**
 * 把支付二维码做成可点击的放大按钮。
 *
 * <p>第一次点击铺满画面并居中显示，再次点击还原位置和尺寸。</p>
 *
 * @see #getPaySp()
 */
public class PayUtils {
    /** @private 放大前的位置和尺寸 */
    private static var _orgRect:Rectangle;

    /**
     * 用位图做成支付按钮。
     *
     * @param bp 二维码位图。
     * @return 可点击的按钮。
     * @example
     * <listing version="3.0">
     * var btn:Sprite = PayUtils.getPaySp(qr);
     * </listing>
     */
    public static function getPaySp(bp:Bitmap):Sprite {
        var sp:Sprite = new Sprite();
        sp.buttonMode = true;
        sp.addChild(bp);
        sp.addEventListener(MouseEvent.MOUSE_UP, payMouseHandler, false, 0, true);
        return sp;
    }

    /** @private 在放大和还原之间切换 */
    private static function payMouseHandler(e:MouseEvent):void {

        e.stopImmediatePropagation();
        e.stopPropagation();

        var sp:Sprite = e.currentTarget as Sprite;
        if (!sp) {
            return;
        }

        var bp:DisplayObject = sp.getChildAt(0);

        // 已经放大：清掉遮罩并还原
        if (_orgRect && sp.width != _orgRect.width) {
            sp.graphics.clear();
            if (bp) {
                bp.scaleX = bp.scaleY = 1;
                bp.x      = 0;
                bp.y      = 0;
            }
            sp.x      = _orgRect.x;
            sp.y      = _orgRect.y;
            sp.width  = _orgRect.width;
            sp.height = _orgRect.height;

            _orgRect = null;
            return;
        }

        // 记下原尺寸，铺满画面后把二维码居中
        _orgRect = new Rectangle(sp.x, sp.y, sp.width, sp.height);

        sp.graphics.beginFill(0, 0.7);
        sp.graphics.drawRect(0, 0, GameConfig.GAME_SIZE.x, GameConfig.GAME_SIZE.y + 20);
        sp.graphics.endFill();

        sp.parent.addChild(sp);

        sp.x      = 0;
        sp.y      = 0;
        sp.width  = GameConfig.GAME_SIZE.x;
        sp.height = GameConfig.GAME_SIZE.y;

        if (bp) {
            bp.scaleX = bp.scaleY = 0.8;
            bp.x      = (
                                GameConfig.GAME_SIZE.x - bp.width
                        ) / 2;
            bp.y      = (
                                GameConfig.GAME_SIZE.y - bp.height
                        ) / 2;
        }

    }

}
}
