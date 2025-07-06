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

package net.play5d.game.bvn.interfaces {

/**
 * SWF 资源库接口
 */
public interface ISwfLib {

    /**
     * 大地图 UI
     */
    function get big_map():Class;

    /**
     * 共享 UI
     */
    function get common():Class;

    /**
     * 对话框 UI
     */
    function get dialog():Class;

    /**
     * 战斗 UI
     */
    function get fight():Class;

    /**
     * 游戏结束 UI
     */
    function get game_over():Class;

    /**
     * 如何游戏教程 UI
     */
    function get how2play():Class;

    /**
     * 多语言 UI
     */
    function get language():Class;

    /**
     * 加载中界面 UI
     */
    function get loading():Class;

    /**
     * 无双模式 UI
     */
    function get musou():Class;

    /**
     * 选择界面 UI
     */
    function get select():Class;

    /**
     * 设置界面 UI
     */
    function get setting():Class;

    /**
     * 标题（主菜单）界面 UI
     */
    function get title():Class;
}
}
