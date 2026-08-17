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

package net.play5d.game.bvn.ctrler {
import net.play5d.game.bvn.ui.GameUI;

/**
 * 场景转场控制（门面转到 <code>GameUI</code> 静态转场 API）。
 *
 * @see GameUI#transIn()
 * @see GameUI#transOut()
 * @see GameUI#quickTrans()
 */
public class StateCtrl {

    private static var _i:StateCtrl;

    /**
     * 单例。
     */
    public static function get I():StateCtrl {
        _i ||= new StateCtrl();

        return _i;
    }

    /** 是否启用转场 */
    public var transEnabled:Boolean = true;

    /**
     * 转场淡入。
     *
     * @param back 完成回调。
     * @param removeAfterComplete 完成后是否移除转场层。
     */
    public function transIn(back:Function = null, removeAfterComplete:Boolean = false):void {
        if (!transEnabled) {
            if (back != null) {
                back();
            }

            return;
        }
        GameUI.transIn(back, removeAfterComplete);
    }

    /**
     * 转场淡出。
     *
     * @param back 完成回调。
     * @param removeAfterComplete 完成后是否移除转场层。
     */
    public function transOut(back:Function = null, removeAfterComplete:Boolean = true):void {
        if (!transEnabled) {
            if (back != null) {
                back();
            }

            return;
        }
        GameUI.transOut(back, removeAfterComplete);
    }

    /**
     * 快速转场。
     *
     * @param back 完成回调。
     */
    public function quickTrans(back:Function = null):void {
        GameUI.quickTrans(back);
    }

    /**
     * 清除转场层。
     */
    public function clearTrans():void {
        GameUI.clearTrans();
    }

}
