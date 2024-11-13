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

package net.play5d.game.bvn.ui
{
	import flash.text.TextField;
	import flash.text.TextFormat;

	import net.play5d.kyo.utils.KyoUtils;

	public class UIUtils
	{
		include "_INCLUDE_.as";

		public static var formatTextFunction:Function;
		public static var DEFAULT_FONT:String = "黑体";
		public static var LOCK_FONT:String = null;

		public function UIUtils()
		{
		}

		/**
		 * 格式化文本
		 * @param text
		 * @param textFormatParam 对应TextFormat的属性
		 */
		public static function formatText(text:TextField , textFormatParam:Object = null):void{
			if(textFormatParam){
				var tf:TextFormat = new TextFormat();
				tf.font = DEFAULT_FONT;
				KyoUtils.setValueByObject(tf,textFormatParam);
				if(LOCK_FONT) tf.font = LOCK_FONT;
				text.defaultTextFormat = tf;

//				var tf:TextFormat = new TextFormat();
//				if(textFormatParam.font != null) textFormatParam.font = undefined;
//				KyoUtils.setValueByObject(tf,textFormatParam);
//				text.defaultTextFormat = tf;

			}

			if(formatTextFunction != null) formatTextFunction(text);
		}

	}
}
