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
import net.play5d.game.bvn.fighter.api.v1.FighterApi;
import net.play5d.game.bvn.fighter.api.v1.FighterCameraApi;
import net.play5d.game.bvn.fighter.api.v1.FighterEffectApi;
import net.play5d.game.bvn.fighter.api.v1.FighterMcApi;

/**
 * 一次初始化造出的四扇角色时间轴门面。
 *
 * @see FighterApiFactory
 */
public class FighterApiPorts {

    /**
     * 角色声明的 API 版本。没有声明时为 <code>1</code>。
     */
    public var version:int;

    /**
     * 角色门面，对应 <code>$fighter_ctrler</code>。
     */
    public var fighter:FighterApi;

    /**
     * 动作门面，对应 <code>$mc_ctrler</code>。
     */
    public var mc:FighterMcApi;

    /**
     * 特效门面，对应 <code>$effect_ctrler</code>。
     */
    public var effect:FighterEffectApi;

    /**
     * 镜头门面，对应 <code>$camera_ctrler</code>。
     */
    public var camera:FighterCameraApi;

}
}
