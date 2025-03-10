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
import net.play5d.game.bvn.utils.WrapInteger;

public class MosouFighterSellVO implements IInstanceVO {
    include '../../../../../../../include/_INCLUDE_.as';
    include '../../../../../../../include/Clone.as';

    public function MosouFighterSellVO(fighterId:String, price:int) {
        this.id = fighterId;
//			this.allowSell = allowSell;
        _price.setValue(price);
    }

//		public var sold:Boolean = false;
//		public var allowSell:Boolean = false;
    public var id:String;
    private var _price:WrapInteger = new WrapInteger(0);

    public function getPrice():int {
        return _price.getValue();
    }

}
}
