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

package net.play5d.game.bvn.ui.musou {
import flash.display.MovieClip;
import flash.text.TextFormatAlign;

import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.ui.Text;
import net.play5d.game.bvn.utils.BtnUtils;

/**
 * 无双金币。构造时就读一次金额。<code>ADD_ABLE</code> 为 false 时停在第 2 帧，不能点。每次金额事件都会把文字再加进影片。
 */
public class CoinUI {

    /**
     * 是否允许点金币加钱。
     *
     * @default true
     */
    public static var ADD_ABLE:Boolean = true;

    /**
     * 按 <code>ADD_ABLE</code> 停到可点或不可点的帧，并立刻刷新金额。
     *
     * @param ui 金币影片。null 或存档缺失时抛错。
     * @throws TypeError 影片或无双存档缺失时。
     */
    public function CoinUI(ui:MovieClip) {
        _ui             = ui;
        _moneyTxt       = new Text(0xFFFFFF, 16);
        _moneyTxt.x     = 45;
        _moneyTxt.y     = 12;
        _moneyTxt.width = 70;
        _moneyTxt.align = TextFormatAlign.CENTER;

        if (ADD_ABLE) {
            _ui.gotoAndStop(1);
            BtnUtils.btnMode(_ui);
            BtnUtils.initBtn(_ui, clickHandler);
        }
        else {
            _ui.gotoAndStop(2);
        }

        GameEvent.addEventListener(GameEvent.MONEY_UPDATE, update);

        update();
    }
    private var _ui:MovieClip;
    private var _moneyTxt:Text;

    /**
     * 不再听金额变化。按钮和文字还留着。
     *
     * @example
     * <listing version="3.0">
     * coin.destroy();
     * </listing>
     */
    public function destroy():void {
        GameEvent.removeEventListener(GameEvent.MONEY_UPDATE, update);
    }

    private function update(...param):void {
        _ui.addChild(_moneyTxt);
        _moneyTxt.text = GameData.I.musouData.getMoney().toString();
    }

    private function clickHandler(b:*):void {
        GameInterface.addMoney(addMoneyBack);
    }

    private function addMoneyBack(money:int):void {
        GameUI.alert(
            GetLang('musou.money.title'),
            GetLang('musou.money', {amount: money})
        );
        GameData.I.musouData.addMoney(money);
    }

}
}
