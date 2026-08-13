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
 * 内嵌 UI SWF 资源库契约。
 *
 * <p>各入口在启动时注入实现，供运行时按模块取出对应 SWF 的 <code>Class</code>
 * 再实例化界面元件。默认实现为 <code>SwfLib</code>。</p>
 *
 * @see net.play5d.game.bvn.SwfLib
 * @example
 * <listing version="3.0">
 * var lib:ISwfLib = new SwfLib();
 * var titleSwf:Class = lib.title;
 * </listing>
 */
public interface ISwfLib {

    /**
     * 大地图 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = swfLib.big_map;
     * </listing>
     */
    function get big_map():Class;

    /**
     * 共享通用 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = swfLib.common;
     * </listing>
     */
    function get common():Class;

    /**
     * 对话框 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = swfLib.dialog;
     * </listing>
     */
    function get dialog():Class;

    /**
     * 战斗 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = swfLib.fight;
     * </listing>
     */
    function get fight():Class;

    /**
     * 游戏结束 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = swfLib.game_over;
     * </listing>
     */
    function get game_over():Class;

    /**
     * 操作说明 / 教程 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = swfLib.how2play;
     * </listing>
     */
    function get how2play():Class;

    /**
     * 多语言选择 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = swfLib.language;
     * </listing>
     */
    function get language():Class;

    /**
     * 加载界面 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = swfLib.loading;
     * </listing>
     */
    function get loading():Class;

    /**
     * 无双模式 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = swfLib.musou;
     * </listing>
     */
    function get musou():Class;

    /**
     * 选人 / 选图界面 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = swfLib.select;
     * </listing>
     */
    function get select():Class;

    /**
     * 设置界面 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = swfLib.setting;
     * </listing>
     */
    function get setting():Class;

    /**
     * 标题（主菜单）界面 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = swfLib.title;
     * </listing>
     */
    function get title():Class;
}
}
