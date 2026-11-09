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

/**
 * 盖住目标的调试色块。宽高小于 30 时按 30 画。只在构造时抄一次坐标。<code>applySet</code> 把当前坐标写回目标。
 */
public class DebugSprite extends Sprite {

    /**
     * 按目标的位置和尺寸画实心矩形。目标为 null 时抛错。
     *
     * @param color 填充色。
     * @param target 被盖住的显示对象。默认 null，传 null 会抛错。
     * @throws TypeError 目标为 null 时。
     */
    public function DebugSprite(color:uint, target:DisplayObject = null) {

        var w:Number = target.width < 30 ? 30 : target.width;
        var h:Number = target.height < 30 ? 30 : target.height;

        this.x = target.x;
        this.y = target.y;
        this.graphics.beginFill(color, 1);
        this.graphics.drawRect(0, 0, w, h);

        this.target = target;
    }
    /**
     * 被盖住的显示对象。销毁后是 null。
     */
    public var target:DisplayObject;

    /**
     * 把这个色块的坐标写回目标。目标已清空时抛错。
     *
     * @throws TypeError 目标为 null 时。
     * @example
     * <listing version="3.0">
     * mark.applySet();
     * </listing>
     */
    public function applySet():void {
        target.x = x;
        target.y = y;

        GameLogger.debug('sys', 'debug apply set x=' + target.x + ' y=' + target.y
                + ' width=' + target.width + ' height=' + target.height);
    }

    /**
     * 清空目标并尝试从父级移除。没有父级时吞掉错误。
     *
     * @example
     * <listing version="3.0">
     * mark.destroy();
     * </listing>
     */
    public function destroy():void {
        target = null;
        try {
            this.parent.removeChild(this);
        }
        catch (e:Error) {
        }
    }

}

}
