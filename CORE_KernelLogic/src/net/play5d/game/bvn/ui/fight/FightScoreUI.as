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

package net.play5d.game.bvn.ui.fight {
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.display.MCNumber;

/**
 * 对局分数。数字从 0 起，每次 <code>setScore</code> 直接改显示。
 */
public class FightScoreUI {

    /**
     * 在界面的 <code>ct</code> 上放分数数字。界面为 null 时抛错。
     *
     * @param ui 分数影片。
     * @throws TypeError 界面为 null 时。
     */
    public function FightScoreUI(ui:$fight$MC_score) {
        _ui = ui;

        var scoreNumberCls:Class = ResUtils.I.getItemClass(ResUtils.swfLib.fight, '$fight$MC_scoreNumber');
        _numberMc = new MCNumber(scoreNumberCls, 0, 1, 10, 10);
        _ui.ct.addChild(_numberMc);
    }
    private var _ui:$fight$MC_score;
    private var _numberMc:MCNumber;

    /**
     * 把分数写成这个整数。
     *
     * @param v 分数。
     * @example
     * <listing version="3.0">
     * score.setScore(12);
     * </listing>
     */
    public function setScore(v:int):void {
        _numberMc.number = v;
    }

}
}
