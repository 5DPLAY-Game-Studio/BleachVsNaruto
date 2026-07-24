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

package {
import net.play5d.game.bvn.GameVersion;

/**
 * 检查共享库版本是否与期望一致。
 *
 * <p>一致返回 <code>true</code>；不一致时若提供回调则先调用，再返回 <code>false</code>。</p>
 *
 * @param version 期望版本号。
 * @param back 版本不匹配时的回调；可为 <code>null</code>。
 * @return 版本匹配时为 <code>true</code>，否则为 <code>false</code>。
 * @example
 * <listing version="3.0">
 * CheckVersion(GameVersion.VERSION); // true
 * </listing>
 * @see net.play5d.game.bvn.GameVersion#VERSION
 */
public function CheckVersion(version:String, back:Function = null):Boolean {
    if (GameVersion.VERSION == version) {
        return true;
    }

    if (back != null) {
        back();
    }

    return false;
}
}
