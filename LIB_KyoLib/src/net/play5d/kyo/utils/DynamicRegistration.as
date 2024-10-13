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
import flash.display.DisplayObject;
import flash.geom.Point;

//动态设置注册点
public class DynamicRegistration {
    function DynamicRegistration(target:DisplayObject, regpoint:Point) {
        this._target   = target;
        this._regpoint = regpoint;
    }
    //需更改的注册点位置
    private var _regpoint:Point;
    //更改注册的显示对象
    private var _target:DisplayObject;

    //设置显示对象的属性
    public function flush(prop:String, value:Number):void {
        var mc:DisplayObject = this._target;
        //转换为全局坐标
        var A:Point          = mc.parent.globalToLocal(mc.localToGlobal(_regpoint));
        if (prop == 'x' || prop == 'y') {
            mc[prop] = value - _regpoint[prop];
        }
        else {
            mc[prop]    = value;
            //执行旋转等属性后，再重新计算全局坐标
            var B:Point = mc.parent.globalToLocal(mc.localToGlobal(_regpoint));
            //把注册点从B点移到A点
            mc.x += A.x - B.x;
            mc.y += A.y - B.y;
        }
    }

//		//设置属性后，不直接改变MC的属性，返回X,Y的差值
//		public function getOffset(prop:String,value:Number):Point {
//			var offset:Point = new Point();
//			var mc:DisplayObject=this._target;
//			//转换为全局坐标
//			var A:Point=mc.parent.globalToLocal(mc.localToGlobal(_regpoint));
//			if (prop=="x"||prop=="y") {
//				offset[prop] = value-_regpoint[prop];
//			} else {
//				mc[prop]=value;
//				//执行旋转等属性后，再重新计算全局坐标
//				var B:Point=mc.parent.globalToLocal(mc.localToGlobal(_regpoint));
//				//把注册点从B点移到A点
//				offset.x = A.x-B.x;
//				offset.y = A.y-B.y;
//			}
//
//			return offset;
//		}

}
}
