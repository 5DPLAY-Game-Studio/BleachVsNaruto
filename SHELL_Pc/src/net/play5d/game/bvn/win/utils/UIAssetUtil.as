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

package net.play5d.game.bvn.win.utils {
import net.play5d.game.bvn.utils.EmbedSwfAssetUtil;

/**
 * PC 壳 UI Embed 资源（<code>win_ui.swf</code>）。
 *
 * @see EmbedSwfAssetUtil
 */
public class UIAssetUtil extends EmbedSwfAssetUtil {

    private static var _i:UIAssetUtil;

    public static function get I():UIAssetUtil {
        _i ||= new UIAssetUtil();
        return _i;
    }


    [Embed(source='/../../shared/lib/swf/win_ui.swf')]
    public var win_ui:Class;

    override protected function getUiClass():Class {
        return win_ui;
    }

}
}
