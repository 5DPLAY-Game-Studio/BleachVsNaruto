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

package net.play5d.game.bvn.data.musou {
import net.play5d.game.bvn.interfaces.IInstanceVO;
import net.play5d.kyo.utils.WrapInteger;

/**
 * 无双商店里的一个角色和价格。
 */
public class MusouFighterSellVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 记下角色 id 和价格。
     *
     * @param fighterId 角色 id。
     * @param price 价格。
     * @example
     * <listing version="3.0">
     * var sell:MusouFighterSellVO = new MusouFighterSellVO(id, 1000);
     * </listing>
     */
    public function MusouFighterSellVO(fighterId:String, price:int) {
        this.id = fighterId;
        _price.setValue(price);
    }

    /**
     * 角色 id。
     *
     * @default null
     */
    public var id:String;
    /** @private */
    private var _price:WrapInteger = new WrapInteger(0);

    /**
     * 取价格。
     *
     * @return 价格。
     * @example
     * <listing version="3.0">
     * var price:int = sell.getPrice();
     * </listing>
     */
    public function getPrice():int {
        return _price.getValue();
    }

}
}
