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

import net.play5d.game.bvn.fighter.ctrler.AssisterCtrler;

/**
 * 按辅助声明的 API 版本组装时间轴门面。
 *
 * <p><code>main_mc.API_VERSION</code> 缺省为 <code>1</code>，与主人的角色版本无关。版本是几就载入 <code>api/v几</code> 的 <code>AssisterApi</code>，没有该类则拒绝。</p>
 *
 * @see FighterApiVersion
 */
public class AssisterApiFactory {

    /**
     * 按版本造出辅助门面。
     *
     * @param mainMc 辅助主时间轴。读取其上的 <code>API_VERSION</code>。
     * @param ctrler 已经 <code>initAssister</code> 的控制器。
     * @return 该版本的辅助门面。特效门和镜头门绑定在这个辅助上。
     * @throws Error <code>mainMc</code> 为空，版本非法，或该版本没有对应门面。
     * @example
     * <listing version="3.0">
     * AssisterApiFactory.create(mainMc, ctrler);
     * </listing>
     */
    public static function create(mainMc:MovieClip, ctrler:AssisterCtrler):FighterApiProxy {
        if (!mainMc) {
            ThrowError(Error, GetLang('debug.error.data.assister.mc_is_null'));
        }

        var unknownKey:String = 'debug.error.data.assister.unknown_version';
        var version:int       = FighterApiVersion.read(mainMc, unknownKey);
        var effectCls:Class   = FighterApiVersion.find(version, 'FighterEffectApi', unknownKey);
        var cameraCls:Class   = FighterApiVersion.find(version, 'FighterCameraApi', unknownKey);
        var assistCls:Class   = FighterApiVersion.find(version, 'AssisterApi', unknownKey);

        return new assistCls(ctrler, new effectCls(ctrler.effect), new cameraCls(ctrler.camera)) as FighterApiProxy;
    }

}
}
