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

package net.play5d.game.bvn {
import net.play5d.game.bvn.interfaces.ISwfLib;

/**
 * 共享 UI SWF 资源库默认实现。
 *
 * <p>将 <code>shared/lib/swf</code> 下各界面 SWF Embed 进库，供 Dev / Pc / Mob
 * 等入口统一注入。Embed 路径以本模块 <code>src</code> 为根解析到仓库
 * <code>shared/lib/swf</code>。</p>
 *
 * @see ISwfLib
 * @example
 * <listing version="3.0">
 * // 入口启动时注入（示例）
 * // ResUtils.swfLib = new SwfLib();
 * var lib:ISwfLib = new SwfLib();
 * var titleCls:Class = lib.title;
 * </listing>
 */
public class SwfLib implements ISwfLib {
    /** @private 大地图 UI */
    [Embed(source='/../../shared/lib/swf/big_map.swf')]
    private var _big_map:Class;

    /** @private 共享通用 UI */
    [Embed(source='/../../shared/lib/swf/common.swf')]
    private var _common:Class;

    /** @private 对话框 UI */
    [Embed(source='/../../shared/lib/swf/dialog.swf')]
    private var _dialog:Class;

    /** @private 战斗 UI */
    [Embed(source='/../../shared/lib/swf/fight.swf')]
    private var _fight:Class;

    /** @private 游戏结束 UI */
    [Embed(source='/../../shared/lib/swf/game_over.swf')]
    private var _game_over:Class;

    /** @private 操作说明 / 教程 UI */
    [Embed(source='/../../shared/lib/swf/how2play.swf')]
    private var _how2play:Class;

    /** @private 多语言选择 UI */
    [Embed(source='/../../shared/lib/swf/language.swf')]
    private var _language:Class;

    /** @private 加载界面 UI */
    [Embed(source='/../../shared/lib/swf/loading.swf')]
    private var _loading:Class;

    /** @private 无双模式 UI */
    [Embed(source='/../../shared/lib/swf/musou.swf')]
    private var _musou:Class;

    /** @private 选人 / 选图界面 UI */
    [Embed(source='/../../shared/lib/swf/select.swf')]
    private var _select:Class;

    /** @private 设置界面 UI */
    [Embed(source='/../../shared/lib/swf/setting.swf')]
    private var _setting:Class;

    /** @private 标题（主菜单）界面 UI */
    [Embed(source='/../../shared/lib/swf/title.swf')]
    private var _title:Class;

    /**
     * 大地图 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = new SwfLib().big_map;
     * </listing>
     */
    public function get big_map():Class {
        return _big_map;
    }

    /**
     * 共享通用 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = new SwfLib().common;
     * </listing>
     */
    public function get common():Class {
        return _common;
    }

    /**
     * 对话框 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = new SwfLib().dialog;
     * </listing>
     */
    public function get dialog():Class {
        return _dialog;
    }

    /**
     * 战斗 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = new SwfLib().fight;
     * </listing>
     */
    public function get fight():Class {
        return _fight;
    }

    /**
     * 游戏结束 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = new SwfLib().game_over;
     * </listing>
     */
    public function get game_over():Class {
        return _game_over;
    }

    /**
     * 操作说明 / 教程 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = new SwfLib().how2play;
     * </listing>
     */
    public function get how2play():Class {
        return _how2play;
    }

    /**
     * 多语言选择 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = new SwfLib().language;
     * </listing>
     */
    public function get language():Class {
        return _language;
    }

    /**
     * 加载界面 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = new SwfLib().loading;
     * </listing>
     */
    public function get loading():Class {
        return _loading;
    }

    /**
     * 无双模式 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = new SwfLib().musou;
     * </listing>
     */
    public function get musou():Class {
        return _musou;
    }

    /**
     * 选人 / 选图界面 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = new SwfLib().select;
     * </listing>
     */
    public function get select():Class {
        return _select;
    }

    /**
     * 设置界面 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = new SwfLib().setting;
     * </listing>
     */
    public function get setting():Class {
        return _setting;
    }

    /**
     * 标题（主菜单）界面 UI SWF 类。
     * @return Embed 得到的 SWF <code>Class</code>。
     * @example
     * <listing version="3.0">
     * var c:Class = new SwfLib().title;
     * </listing>
     */
    public function get title():Class {
        return _title;
    }
}
}
