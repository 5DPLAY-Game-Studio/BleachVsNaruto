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

package net.play5d.game.bvn.stage
{
	import flash.display.DisplayObject;
	import flash.events.Event;

	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.stage.IStage;

	public class LogoStage implements IStage
	{
		include '../../../../../../include/_INCLUDE_.as';

		private var _ui:logo_movie;


		/**
		 * 显示对象
		 */
		public function get display():DisplayObject
		{
			return _ui;
		}

		/**
		 * 构建
		 */
		public function build():void
		{
			_ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.common_ui , 'logo_movie');
			_ui.addEventListener(Event.COMPLETE,playComplete);
			_ui.gotoAndPlay(2);
		}

		private function playComplete(e:Event):void{
			_ui.removeEventListener(Event.COMPLETE,playComplete);
			MainGame.I.goMenu();
		}

		/**
		 * 稍后构建
		 */
		public function afterBuild():void
		{
		}

		/**
		 * 销毁
		 * @param back 回调函数
		 */
		public function destroy(back:Function =null):void
		{
			_ui.removeEventListener(Event.COMPLETE,playComplete);
		}
	}
}
