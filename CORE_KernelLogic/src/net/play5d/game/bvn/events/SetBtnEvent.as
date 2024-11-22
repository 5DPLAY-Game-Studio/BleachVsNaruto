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

package net.play5d.game.bvn.events
{
	import flash.events.Event;

	public class SetBtnEvent extends Event
	{
		include '../../../../../../include/_INCLUDE_.as';

		public static const SELECT:String = 'SELECT';
		public static const OPTION_CHANGE:String = 'OPTION_CHANGE';
		public static const APPLY_SET:String = 'APPLY_SET';
		public static const CANCEL_SET:String = 'CANCEL_SET';

		public var selectedLabel:String;

		public var optionKey:String;
		public var optionValue:*;

		public function SetBtnEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

		public function newEvent():SetBtnEvent{
			var event:SetBtnEvent = new SetBtnEvent(type,bubbles,cancelable);
			event.selectedLabel = selectedLabel;
			event.optionKey = optionKey;
			event.optionValue = optionValue;
			return event;
		}

	}
}
