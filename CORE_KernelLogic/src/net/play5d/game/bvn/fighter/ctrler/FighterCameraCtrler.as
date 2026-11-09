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
 * 把角色、援助转成显示对象后再交给镜头。
 *
 * <p>聚焦参数为空，或里面没有角色时直接返回。攻击体和子弹对对手聚焦时不选目标。
 * 援助的主人不是角色时，对对手聚焦会抛错。</p>
 *
 * @see net.play5d.game.bvn.ctrler.game_ctrls.GameCameraCtrler
 */
public class FighterCameraCtrler extends GameCameraCtrler {

    /** @private */
    private var _target:IGameSprite;

    /**
     * 把镜头交给父类保存。
     *
     * @param camera 游戏镜头。
     * @example
     * <listing version="3.0">
     * var cam:FighterCameraCtrler = new FighterCameraCtrler(camera);
     * </listing>
     */
    public function FighterCameraCtrler(camera:GameCamera) {
        super(camera);
    }

    /**
     * 记下要跟着的对象。可以是 <code>null</code>。
     *
     * @param target 角色、援助、攻击体或子弹。
     * @example
     * <listing version="3.0">
     * cam.setTarget(fighter);
     * </listing>
     */
    public function setTarget(target:IGameSprite):void {
        _target = target;
    }

    /**
     * 当前跟着的对象。
     *
     * @return 对象。还没设置时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var sp:IGameSprite = cam.getTarget();
     * </listing>
     */
    public function getTarget():IGameSprite {
        return _target;
    }

    /**
     * 把角色换成显示对象后聚焦。
     *
     * <p>参数为空时返回。不是角色的项会跳过。</p>
     *
     * @param focusParam 一个角色，或角色数组。
     * @param noTween 是否跳过补间。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * cam.focus(fighter, false);
     * </listing>
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
     * 聚焦当前对象。对象为空时什么都不做。
     *
     * @param noTween 是否跳过补间。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * cam.focusSelf(false);
     * </listing>
     */
    public function focusSelf(noTween:Boolean = false):void {
        focus(_target, noTween);
    }

    /**
     * 聚焦当前对象的对手。
     *
     * <p>攻击体和子弹没有对手，直接返回。援助的主人不是角色时抛错。</p>
     *
     * @param noTween 是否跳过补间。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * cam.focusTarget(false);
     * </listing>
     */
    public function focusTarget(noTween:Boolean = false):void {
        var focusTarget:IGameSprite = null;

        if (_target is FighterMain) {
            var fighter:FighterMain = _target as FighterMain;
            focusTarget = fighter.getCurrentTarget() as FighterMain;
        }
        else if (_target is Assister) {
            var assister:Assister         = _target as Assister;
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
