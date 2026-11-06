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
 * 界面 SWF 路径契约。
 *
 * <p>各入口注入实现后，运行时按模块取出相对 <code>assets/</code> 的路径，再载入当前域实例化界面元件。
 * 默认实现位于工具层的 <code>SwfLib</code>。</p>
 *
 * @example
 * <listing version="3.0">
 * var lib:ISwfLib = swfLib;
 * var titleSwf:String = lib.title;
 * </listing>
 */
public interface ISwfLib {

    /**
     * 大地图 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @example
     * <listing version="3.0">
     * var url:String = swfLib.big_map;
     * </listing>
     */
    function get big_map():String;

    /**
     * 共享通用 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @example
     * <listing version="3.0">
     * var url:String = swfLib.common;
     * </listing>
     */
    function get common():String;

    /**
     * 对话框 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @example
     * <listing version="3.0">
     * var url:String = swfLib.dialog;
     * </listing>
     */
    function get dialog():String;

    /**
     * 战斗 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @example
     * <listing version="3.0">
     * var url:String = swfLib.fight;
     * </listing>
     */
    function get fight():String;

    /**
     * 游戏结束 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @example
     * <listing version="3.0">
     * var url:String = swfLib.game_over;
     * </listing>
     */
    function get game_over():String;

    /**
     * 操作说明 / 教程 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @example
     * <listing version="3.0">
     * var url:String = swfLib.how2play;
     * </listing>
     */
    function get how2play():String;

    /**
     * 多语言选择 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @example
     * <listing version="3.0">
     * var url:String = swfLib.language;
     * </listing>
     */
    function get language():String;

    /**
     * 加载界面 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @example
     * <listing version="3.0">
     * var url:String = swfLib.loading;
     * </listing>
     */
    function get loading():String;

    /**
     * 无双模式 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @example
     * <listing version="3.0">
     * var url:String = swfLib.musou;
     * </listing>
     */
    function get musou():String;

    /**
     * 选人 / 选图界面 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @example
     * <listing version="3.0">
     * var url:String = swfLib.select;
     * </listing>
     */
    function get select():String;

    /**
     * 设置界面 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @example
     * <listing version="3.0">
     * var url:String = swfLib.setting;
     * </listing>
     */
    function get setting():String;

    /**
     * 标题（主菜单）界面 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @example
     * <listing version="3.0">
     * var url:String = swfLib.title;
     * </listing>
     */
    function get title():String;
}
}
