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

package net.play5d.game.bvn.fighter.vos {
import flash.geom.Point;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.interfaces.IInstanceVO;

public class MoveTargetParamVO implements IInstanceVO {
    include '../../../../../../../include/_INCLUDE_.as';
    include '../../../../../../../include/Clone.as';

    /**
     * params:{
     * 		x:Number X位置
     * 		y:Number Y位置
     * 		followmc:String 按MC的位置移动目标，MC名称
     * 		speed:Number|{x:Number,y:Number} 移动速度，0或不设置时，直接移动到相应位置
     * }
     */
    public function MoveTargetParamVO(params:Object = null) {
        if (!params) {
            return;
        }

        x            = params.x != undefined ? params.x : 0;
        y            = params.y != undefined ? params.y : 0;
        followMcName = params.followmc != undefined ? params.followmc : null;

        if (params.speed) {
            speed = new Point();
            if (params.speed is Number) {
                speed.x = speed.y = params.speed * GameConfig.SPEED_PLUS;
            }
            else {
                speed.x = params.speed.x != undefined ? params.speed.x * GameConfig.SPEED_PLUS : 0;
                speed.y = params.speed.y != undefined ? params.speed.y * GameConfig.SPEED_PLUS : 0;
            }
        }

    }
    public var x:Number;
    public var y:Number;
    public var followMcName:String;
    public var target:IGameSprite;
    //移动速度，为NULL时，直接移动到相应位置
    public var speed:Point;

    public function setTarget(v:IGameSprite):void {
        target = v;
        if (target is BaseGameSprite) {
//				(target as BaseGameSprite).isApplyG = false;
            (
                    target as BaseGameSprite
            ).setVelocity(0, 0);
        }
    }

    public function clear():void {
        if (target) {
            if (target is BaseGameSprite) {
                (
                        target as BaseGameSprite
                ).isApplyG = true;
            }
        }
    }

}
}
