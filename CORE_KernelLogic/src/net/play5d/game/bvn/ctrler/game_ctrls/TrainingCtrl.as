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

package net.play5d.game.bvn.ctrler.game_ctrls {
import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.StateCtrl;
import net.play5d.game.bvn.data.fighter.FighterActionState;
import net.play5d.game.bvn.fighter.FighterMain;

/**
 * 练习模式的体力、气和援助气回复。
 *
 * <p>受击中的体力计时每帧被重置为 1 秒，受击结束后才开始倒数。气和援助气不受受击影响，掉下去之后等 2 秒再回满。
 * 开关在倒数到 0 时才看，中途关掉就不会回。</p>
 *
 * @see StateCtrl
 */
public class TrainingCtrl {

    /**
     * 是否回满体力。
     *
     * @default true
     */
    public static var RECOVER_HP:Boolean    = true;
    /**
     * 是否回满气。
     *
     * @default true
     */
    public static var RECOVER_QI:Boolean    = true;
    /**
     * 是否回满援助气。
     *
     * @default true
     */
    public static var RECOVER_FZ_QI:Boolean = true;

    /** @private */
    private var _trainAddDelay:Object;
    /** @private */
    private var _fighters:Array;

    /**
     * 记下角色并把气设为满，然后播放退场。
     *
     * <p><code>fighters</code> 为 <code>null</code> 时会抛错。相同 <code>id</code> 共用一条计时。</p>
     *
     * @param fighters 场上角色。
     * @example
     * <listing version="3.0">
     * ctrl.initialize([p1, p2]);
     * </listing>
     */
    public function initialize(fighters:Array):void {
        _fighters = fighters;

        for each(var i:FighterMain in _fighters) {
            i.qi = i.qiMax;
        }

        _trainAddDelay = {};

        StateCtrl.I.transOut(null, true);
    }

    /**
     * 丢掉角色和计时。
     *
     * <p>之后再 <code>render</code> 会抛错。</p>
     *
     * @example
     * <listing version="3.0">
     * ctrl.destroy();
     * </listing>
     */
    public function destroy():void {
        _fighters      = null;
        _trainAddDelay = null;
    }

    /**
     * 按帧推进回复计时，到点后按开关回满。
     */
    public function render():void {
        for each(var i:FighterMain in _fighters) {
            var hpid:String = i.id + '_hp';
            if (i.actionState == FighterActionState.HURT_ING || i.actionState == FighterActionState.HURT_FLYING) {
                _trainAddDelay[hpid] = 1 * GameConfig.FPS_GAME;
            }
            else {
                if (_trainAddDelay[hpid] != undefined && _trainAddDelay[hpid] > 0) {
                    _trainAddDelay[hpid]--;
                    if (_trainAddDelay[hpid] <= 0 && RECOVER_HP) {
                        i.hp = i.hpMax;
                    }
                }
                else {
                    if (i.hp == i.hpMax) {
                        _trainAddDelay[hpid] = 0;
                    }
                    else {
                        _trainAddDelay[hpid] = 2 * GameConfig.FPS_GAME;
                    }
                }
            }

            var qiid:String = i.id + '_qi';
            if (_trainAddDelay[qiid] != undefined && _trainAddDelay[qiid] > 0) {
                _trainAddDelay[qiid]--;
                if (_trainAddDelay[qiid] <= 0 && RECOVER_QI) {
                    i.qi = i.qiMax;
                }
            }
            else {
                if (i.qi == i.qiMax) {
                    _trainAddDelay[qiid] = 0;
                }
                else {
                    _trainAddDelay[qiid] = 2 * GameConfig.FPS_GAME;
                }
            }

            var fzid:String = i.id + 'fz';
            if (_trainAddDelay[fzid] != undefined && _trainAddDelay[fzid] > 0) {
                _trainAddDelay[fzid]--;
                if (_trainAddDelay[fzid] <= 0 && RECOVER_FZ_QI) {
                    i.fzqi = i.fzqiMax;
                }
            }
            else {
                if (i.fzqi == i.fzqiMax) {
                    _trainAddDelay[fzid] = 0;
                }
                else {
                    _trainAddDelay[fzid] = 2 * GameConfig.FPS_GAME;
                }
            }

        }
    }


}
}
