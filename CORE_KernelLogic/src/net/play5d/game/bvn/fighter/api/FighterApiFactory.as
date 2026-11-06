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

import net.play5d.game.bvn.fighter.ctrler.FighterCameraCtrler;
import net.play5d.game.bvn.fighter.ctrler.FighterCtrler;
import net.play5d.game.bvn.fighter.ctrler.FighterEffectCtrl;
import net.play5d.game.bvn.fighter.ctrler.FighterMcCtrler;

/**
 * 按角色声明的 API 版本组装时间轴门面。
 *
 * <p><code>main_mc.API_VERSION</code> 缺省为 <code>1</code>，对应 <code>api/v1</code>。版本是几就载入 <code>api/v几</code> 的同名门面，没有该类则拒绝。</p>
 *
 * @see FighterApiPorts
 */
public class FighterApiFactory {

    /**
     * 按版本造出四扇门。
     *
     * @param mainMc 角色主时间轴。读取其上的 <code>API_VERSION</code>。
     * @param fighter 角色控制器。
     * @param mcCtrler 动作控制器。
     * @param effect 特效控制器。
     * @param camera 镜头控制器。
     * @return 四扇门。特效门与动作门上的 <code>effectCtrler</code> 是同一个实例。
     * @throws Error <code>mainMc</code> 为空，版本非法，或该版本没有对应门面。
     * @example
     * <listing version="3.0">
     * var ports:FighterApiPorts = FighterApiFactory.create(mainMc, fighter, mc, effect, camera);
     * </listing>
     */
    public static function create(mainMc:MovieClip, fighter:FighterCtrler, mcCtrler:FighterMcCtrler,
                                  effect:FighterEffectCtrl, camera:FighterCameraCtrler
    ):FighterApiPorts {
        if (!mainMc) {
            ThrowError(Error, GetLang('log.error.fight.fighter_api_factory.mc_is_null'));
        }

        var unknownKey:String = 'log.error.fight.fighter_api_factory.unknown_version';
        var version:int       = FighterApiVersion.read(mainMc, unknownKey);
        var effectCls:Class   = FighterApiVersion.find(version, 'FighterEffectApi', unknownKey);
        var cameraCls:Class   = FighterApiVersion.find(version, 'FighterCameraApi', unknownKey);
        var fighterCls:Class  = FighterApiVersion.find(version, 'FighterApi', unknownKey);
        var mcCls:Class       = FighterApiVersion.find(version, 'FighterMcApi', unknownKey);

        var effectApi:FighterApiProxy = new effectCls(effect) as FighterApiProxy;
        var ports:FighterApiPorts     = new FighterApiPorts();
        ports.version = version;
        ports.effect  = effectApi;
        ports.camera  = new cameraCls(camera) as FighterApiProxy;
        ports.fighter = new fighterCls(fighter) as FighterApiProxy;
        ports.mc      = new mcCls(mcCtrler, effectApi) as FighterApiProxy;

        return ports;
    }

}
}
