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

package net.play5d.game.bvn.win.utils {
import flash.filesystem.File;

/**
 * 扫描 AIR 应用目录下 <code>assets/mods</code> 角色/地图包，供 PackRegistry 合并。
 */
public class PackModScanner {

    /**
     * 列出 mods 下可用包。
     *
     * @return 每项 <code>{ kind, id, root }</code>；无则空数组。
     * @example
     * <listing version="3.0">
     * var list:Array = PackModScanner.listExtraPacks();
     * </listing>
     */
    public static function listExtraPacks():Array {
        var result:Array = [];
        appendKind(result, 'fighter', 'mods/fighters');
        appendKind(result, 'assist', 'mods/assists');
        appendKind(result, 'map', 'mods/maps');

        return result;
    }

    /** @private */
    private static function appendKind(out:Array, kind:String, relDir:String):void {
        var dir:File;
        try {
            dir = File.applicationDirectory.resolvePath('assets/' + relDir);
        }
        catch (e:Error) {
            return;
        }
        if (!dir || !dir.exists || !dir.isDirectory) {
            return;
        }

        var listing:Array = dir.getDirectoryListing();
        for each (var f:File in listing) {
            if (!f || !f.isDirectory) {
                continue;
            }
            var meta:File = f.resolvePath('meta.json');
            if (!meta.exists) {
                continue;
            }
            out.push({
                kind: kind,
                id  : f.name,
                root: relDir + '/' + f.name + '/'
            });
        }
    }

}
}
