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

package net.play5d.game.bvn.interfaces
{
	public interface ISwfLib
	{

		function get common_ui():Class;
		function get fight():Class;
		function get gameover():Class;
		function get howtoplay():Class;
		function get loading():Class;
		function get select():Class;
		function get setting():Class;
		function get title():Class;
		function get mosou():Class;
		function get bigMap():Class;
		function get dialog():Class;

	}
}
