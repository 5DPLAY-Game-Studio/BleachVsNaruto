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

package net.play5d.game.bvn.win {
import net.play5d.game.bvn.interfaces.ISwfLib;

/**
 * SHELL_Pc 的 SWF 资源库
 */
public class SwfLib implements ISwfLib {
    // 大地图 UI
    [Embed(source='/../../shared/lib/swf/big_map.swf')]
    private var _big_map:Class;

    // 共享 UI
    [Embed(source='/../../shared/lib/swf/common.swf')]
    private var _common:Class;

    // 对话框 UI
    [Embed(source='/../../shared/lib/swf/dialog.swf')]
    private var _dialog:Class;

    // 战斗 UI
    [Embed(source='/../../shared/lib/swf/fight.swf')]
    private var _fight:Class;

    // 游戏结束 UI
    [Embed(source='/../../shared/lib/swf/game_over.swf')]
    private var _game_over:Class;

    // 如何游戏教程 UI
    [Embed(source='/../../shared/lib/swf/how2play.swf')]
    private var _how2play:Class;

    // 多语言 UI
    [Embed(source='/../../shared/lib/swf/language.swf')]
    private var _language:Class;

    // 加载中界面 UI
    [Embed(source='/../../shared/lib/swf/loading.swf')]
    private var _loading:Class;

    // 无双模式 UI
    [Embed(source='/../../shared/lib/swf/musou.swf')]
    private var _musou:Class;

    // 选择界面 UI
    [Embed(source='/../../shared/lib/swf/select.swf')]
    private var _select:Class;

    // 设置界面 UI
    [Embed(source='/../../shared/lib/swf/setting.swf')]
    private var _setting:Class;

    // 标题（主菜单）界面 UI
    [Embed(source='/../../shared/lib/swf/title.swf')]
    private var _title:Class;

    /**
     * 大地图 UI
     */
    public function get big_map():Class {
        return _big_map;
    }

    /**
     * 共享 UI
     */
    public function get common():Class {
        return _common;
    }

    /**
     * 对话框 UI
     */
    public function get dialog():Class {
        return _dialog;
    }

    /**
     * 战斗 UI
     */
    public function get fight():Class {
        return _fight;
    }

    /**
     * 游戏结束 UI
     */
    public function get game_over():Class {
        return _game_over;
    }

    /**
     * 如何游戏教程 UI
     */
    public function get how2play():Class {
        return _how2play;
    }

    /**
     * 多语言 UI
     */
    public function get language():Class {
        return _language;
    }

    /**
     * 加载中界面 UI
     */
    public function get loading():Class {
        return _loading;
    }

    /**
     * 无双模式 UI
     */
    public function get musou():Class {
        return _musou;
    }

    /**
     * 选择界面 UI
     */
    public function get select():Class {
        return _select;
    }

    /**
     * 设置界面 UI
     */
    public function get setting():Class {
        return _setting;
    }

    /**
     * 标题（主菜单）界面 UI
     */
    public function get title():Class {
        return _title;
    }
}
}
