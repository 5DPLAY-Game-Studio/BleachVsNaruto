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

package net.play5d.game.bvn.data.mosou
{
	import net.play5d.game.bvn.utils.WrapInteger;

	public class MosouFighterSellVO
	{
		include '../../../../../../../include/_INCLUDE_.as';

		public var id:String;

//		public var sold:Boolean = false;
//		public var allowSell:Boolean = false;

		private var _price:WrapInteger = new WrapInteger(0);

		public function MosouFighterSellVO(fighterId:String, price:int)
		{
			this.id = fighterId;
//			this.allowSell = allowSell;
			_price.setValue(price);
		}

		public function getPrice():int{
			return _price.getValue();
		}

	}
}
