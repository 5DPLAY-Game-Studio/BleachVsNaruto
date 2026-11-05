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

package net.play5d.game.bvn.fighter.api {
import flash.display.MovieClip;

import net.play5d.game.bvn.fighter.api.v1.AssisterApi;
import net.play5d.game.bvn.fighter.api.v1.FighterCameraApi;
import net.play5d.game.bvn.fighter.api.v1.FighterEffectApi;
import net.play5d.game.bvn.fighter.ctrler.AssisterCtrler;

/**
 * 按辅助声明的 API 版本组装时间轴门面。
 *
 * <p><code>main_mc.API_VERSION</code> 缺省为 <code>1</code>，与主人的角色版本无关。只有整数 <code>1</code> 会造出门面。</p>
 *
 * @see AssisterApi
 */
public class AssisterApiFactory {

    /**
     * 按版本造出辅助门面。
     *
     * @param mainMc 辅助主时间轴。读取其上的 <code>API_VERSION</code>。
     * @param ctrler 已经 <code>initAssister</code> 的控制器。
     * @return 第 1 版门面。特效门和镜头门绑定在这个辅助上。
     * @throws Error <code>mainMc</code> 为空，或版本不是受支持的整数。
     * @example
     * <listing version="3.0">
     * var api:AssisterApi = AssisterApiFactory.create(mainMc, ctrler);
     * </listing>
     */
    public static function create(mainMc:MovieClip, ctrler:AssisterCtrler):AssisterApi {
        if (!mainMc) {
            ThrowError(Error, GetLang('debug.error.data.assister.mc_is_null'));
        }

        var version:int = versionOf(mainMc);
        if (version != 1) {
            ThrowError(Error, GetLang('debug.error.data.assister.unknown_version', {version: version}));
        }

        return new AssisterApi(ctrler, new FighterEffectApi(ctrler.effect), new FighterCameraApi(ctrler.camera));
    }

    /**
     * @private 读取版本。缺省为 1；非整数在此拒绝。
     */
    private static function versionOf(mainMc:MovieClip):int {
        var raw:* = mainMc.API_VERSION;
        if (raw == undefined || raw == null) {
            return 1;
        }
        var numeric:Boolean = raw is int || raw is uint || raw is Number;
        if (!numeric || isNaN(raw) || raw == Infinity || raw == -Infinity || int(raw) != raw) {
            ThrowError(Error, GetLang('debug.error.data.assister.unknown_version', {version: String(raw)}));
        }

        return int(raw);
    }

}
}
