/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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
import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.fighter.FighterMain;

/**
 * KO 演出里的暂停、镜头和慢放。
 *
 * <p>对战结束和无双结算都走这里。界面只播影片。</p>
 */
public class KoPresentCtrl {

    /**
     * 镜头对准一名角色。
     *
     * @param fighter 被对准的角色。
     * @example
     * <listing version="3.0">
     * KoPresentCtrl.focus(loser);
     * </listing>
     */
    public static function focus(fighter:FighterMain):void {
        if (!fighter || !GameCtrl.I.gameState) {
            return;
        }
        GameCtrl.I.gameState.cameraFocusOne(fighter.getDisplay());
    }

    /**
     * 暂停对局模拟，界面仍继续刷新。
     *
     * @example
     * <listing version="3.0">
     * KoPresentCtrl.hold();
     * </listing>
     */
    public static function hold():void {
        GameCtrl.I.pause();
    }

    /**
     * 恢复对局模拟。
     *
     * @example
     * <listing version="3.0">
     * KoPresentCtrl.release();
     * </listing>
     */
    public static function release():void {
        GameCtrl.I.resume();
    }

    /**
     * 进入慢放。
     *
     * @param rate 慢放倍率。
     * @param time 持续毫秒。0 表示保持到 <code>clearSlow</code>。
     * @example
     * <listing version="3.0">
     * KoPresentCtrl.slow(2, 0);
     * </listing>
     */
    public static function slow(rate:Number, time:int):void {
        GameCtrl.I.slowRate = rate;
        EffectCtrl.I.slowDown(rate, time);
    }

    /**
     * 结束慢放。
     *
     * @example
     * <listing version="3.0">
     * KoPresentCtrl.clearSlow();
     * </listing>
     */
    public static function clearSlow():void {
        EffectCtrl.I.slowDownResume();
    }

}
}
