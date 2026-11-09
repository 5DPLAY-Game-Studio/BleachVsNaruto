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

package net.play5d.game.bvn.utils {
import net.play5d.game.bvn.interfaces.ISwfLib;

/**
 * 界面 SWF 路径。
 *
 * <p>返回相对 <code>assets/</code> 的路径，文件在 <code>assets/ui</code>。供 Dev / Pc / Mob 入口注入。</p>
 *
 * @example
 * <listing version="3.0">
 * var lib:ISwfLib = new SwfLib();
 * var titleUrl:String = lib.title;
 * </listing>
 * @see net.play5d.game.bvn.interfaces.ISwfLib
 */
public class SwfLib implements ISwfLib {

    /**
     * 大地图 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @default ui/big_map.swf
     * @example
     * <listing version="3.0">
     * var url:String = new SwfLib().big_map;
     * </listing>
     */
    public function get big_map():String {
        return 'ui/big_map.swf';
    }

    /**
     * 共享通用 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @default ui/common.swf
     * @example
     * <listing version="3.0">
     * var url:String = new SwfLib().common;
     * </listing>
     */
    public function get common():String {
        return 'ui/common.swf';
    }

    /**
     * 对话框 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @default ui/dialog.swf
     * @example
     * <listing version="3.0">
     * var url:String = new SwfLib().dialog;
     * </listing>
     */
    public function get dialog():String {
        return 'ui/dialog.swf';
    }

    /**
     * 战斗 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @default ui/fight.swf
     * @example
     * <listing version="3.0">
     * var url:String = new SwfLib().fight;
     * </listing>
     */
    public function get fight():String {
        return 'ui/fight.swf';
    }

    /**
     * 游戏结束 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @default ui/game_over.swf
     * @example
     * <listing version="3.0">
     * var url:String = new SwfLib().game_over;
     * </listing>
     */
    public function get game_over():String {
        return 'ui/game_over.swf';
    }

    /**
     * 操作说明 / 教程 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @default ui/how2play.swf
     * @example
     * <listing version="3.0">
     * var url:String = new SwfLib().how2play;
     * </listing>
     */
    public function get how2play():String {
        return 'ui/how2play.swf';
    }

    /**
     * 多语言选择 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @default ui/language.swf
     * @example
     * <listing version="3.0">
     * var url:String = new SwfLib().language;
     * </listing>
     */
    public function get language():String {
        return 'ui/language.swf';
    }

    /**
     * 加载界面 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @default ui/loading.swf
     * @example
     * <listing version="3.0">
     * var url:String = new SwfLib().loading;
     * </listing>
     */
    public function get loading():String {
        return 'ui/loading.swf';
    }

    /**
     * 无双模式 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @default ui/musou.swf
     * @example
     * <listing version="3.0">
     * var url:String = new SwfLib().musou;
     * </listing>
     */
    public function get musou():String {
        return 'ui/musou.swf';
    }

    /**
     * 选人 / 选图界面 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @default ui/select.swf
     * @example
     * <listing version="3.0">
     * var url:String = new SwfLib().select;
     * </listing>
     */
    public function get select():String {
        return 'ui/select.swf';
    }

    /**
     * 设置界面 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @default ui/setting.swf
     * @example
     * <listing version="3.0">
     * var url:String = new SwfLib().setting;
     * </listing>
     */
    public function get setting():String {
        return 'ui/setting.swf';
    }

    /**
     * 标题（主菜单）界面 UI SWF。
     * @return 相对 <code>assets/</code> 的路径。
     * @default ui/title.swf
     * @example
     * <listing version="3.0">
     * var url:String = new SwfLib().title;
     * </listing>
     */
    public function get title():String {
        return 'ui/title.swf';
    }
}
}
