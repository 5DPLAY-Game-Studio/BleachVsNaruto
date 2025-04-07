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

public class CoinUI {
    include '../../../../../../../include/_INCLUDE_.as';

    public static var ADD_ABLE:Boolean = true;

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

    public function destory():void {
        GameEvent.removeEventListener(GameEvent.MONEY_UPDATE, update);
    }

    private function update(...param):void {
        _ui.addChild(_moneyTxt);
        _moneyTxt.text = GameData.I.mosouData.getMoney().toString();
    }

    private function clickHandler(b:*):void {
        GameInterface.addMoney(addMoneyBack);
    }

    private function addMoneyBack(money:int):void {
        GameUI.alert('MONEY', '获得金币 ' + money + ' !');
        GameData.I.mosouData.addMoney(money);
    }

}
}
