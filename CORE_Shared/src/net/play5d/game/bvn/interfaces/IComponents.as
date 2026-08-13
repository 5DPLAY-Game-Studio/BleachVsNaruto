/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.interfaces {

/**
 * Animate 组件可销毁契约。
 *
 * <p>约定组件可主动释放自身资源；具体实现位于组件库 SWC，本库仅公开接口。</p>
 */
public interface IComponents {

    /**
     * 销毁自身。
     *
     * @example
     * <listing version="3.0">
     * component.destroy();
     * </listing>
     */
    function destroy():void;
}
}
