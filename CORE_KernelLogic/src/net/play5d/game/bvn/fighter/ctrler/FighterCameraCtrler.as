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

package net.play5d.game.bvn.fighter.ctrler {
import net.play5d.game.bvn.ctrler.game_ctrls.GameCameraCtrler;
import net.play5d.game.bvn.fighter.Assister;
import net.play5d.game.bvn.fighter.Bullet;
import net.play5d.game.bvn.fighter.FighterAttacker;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.stage.GameCamera;

/**
 * 角色镜头控制器
 */
public class FighterCameraCtrler extends GameCameraCtrler {
    include '../../../../../../../include/_INCLUDE_OVERRIDE_.as';

    // 绑定目标
    private var _target:IGameSprite;

    public function FighterCameraCtrler(camera:GameCamera) {
        super(camera);
    }

    public function setTarget(target:IGameSprite):void {
        _target = target;
    }

    public function getTarget():IGameSprite {
        return _target;
    }

    /**
     * 镜头聚焦
     *
     * @param focusParam 要聚焦的显示对象参数，该参数类型可为 IGameSprite 或者其数组
     * @param noTween 是否不进行补间
     */
    override public function focus(focusParam:Object, noTween:Boolean = false):void {
        if (!focusParam) {
            return;
        }

        var focusArr:Array = focusParam is Array ? focusParam as Array : [focusParam]
        if (!focusArr || focusArr.length == 0) {
            return;
        }

        var newFocusArr:Array = [];

        for (var i:int = 0; i < focusArr.length; i++) {
            var sp:IGameSprite = focusArr[i] as IGameSprite;
            if (!sp) {
                continue;
            }

            newFocusArr.push(sp.getDisplay());
        }

        super.focus(newFocusArr, noTween);
    }

    /**
     * 镜头聚焦自身
     *
     * @param noTween 是否不进行补间
     */
    public function focusSelf(noTween:Boolean = false):void {
        focus(_target, noTween);
    }

    /**
     * 镜头聚焦对手
     *
     * @param noTween 是否不进行补间
     */
    public function focusTarget(noTween:Boolean = false):void {
        var focusTarget:IGameSprite = null;

        if (_target is FighterMain) {
            var fighter:FighterMain = _target as FighterMain;
            focusTarget = fighter.getCurrentTarget() as FighterMain;
        }
        else if (_target is Assister) {
            var assister:Assister = _target as Assister;
            var assisterOwner:FighterMain = assister.getOwner() as FighterMain;
            focusTarget = assisterOwner.getCurrentTarget() as FighterMain;
        }
        else if (_target is FighterAttacker) {

        }
        else if (_target is Bullet) {

        }

        focus(focusTarget, noTween);
    }
}
}
