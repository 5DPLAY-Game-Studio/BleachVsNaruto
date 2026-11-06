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
import flash.utils.getDefinitionByName;

import net.play5d.game.bvn.fighter.api.v1.AssisterApi;
import net.play5d.game.bvn.fighter.api.v1.FighterApi;
import net.play5d.game.bvn.fighter.api.v1.FighterCameraApi;
import net.play5d.game.bvn.fighter.api.v1.FighterEffectApi;
import net.play5d.game.bvn.fighter.api.v1.FighterMcApi;

/**
 * 按 <code>API_VERSION</code> 找到 <code>api/vN</code> 里的门面类。
 *
 * <p>缺省为 <code>1</code>。非整数、小于 <code>1</code>，或 <code>vN</code> 里没有该类，都拒绝，不回退到其它版本。各版本类名固定：<code>FighterApi</code>、<code>FighterMcApi</code>、<code>FighterEffectApi</code>、<code>FighterCameraApi</code>、<code>AssisterApi</code>，构造参数与第 1 版相同。</p>
 *
 * @see FighterApiFactory
 * @see AssisterApiFactory
 */
public class FighterApiVersion {

    /** @private 包前缀，后面接版本号和类名 */
    private static const _package:String = 'net.play5d.game.bvn.fighter.api.v';
    /**
     * @private 发布版会裁掉没有静态引用的类。已有版本留在这里，<code>find</code> 仍按版本号查找。
     */
    private static const _link:Array     = [
        FighterApi, FighterMcApi, FighterEffectApi, FighterCameraApi, AssisterApi
    ];

    /**
     * 读取时间轴上的版本。
     *
     * @param mainMc 主时间轴。
     * @param unknownKey 非法版本用的文案键。
     * @return 不小于 <code>1</code> 的整数。没有声明时为 <code>1</code>。
     * @throws Error 声明了值，但不是不小于 <code>1</code> 的整数。
     * @example
     * <listing version="3.0">
     * FighterApiVersion.read(mainMc, 'log.error.fight.fighter_api_factory.unknown_version');
     * </listing>
     */
    public static function read(mainMc:MovieClip, unknownKey:String):int {
        var raw:* = mainMc.API_VERSION;
        if (raw == undefined || raw == null) {
            return 1;
        }
        var numeric:Boolean = raw is int || raw is uint || raw is Number;
        if (!numeric || isNaN(raw) || raw == Infinity || raw == -Infinity || int(raw) != raw || int(raw) < 1) {
            ThrowError(Error, GetLang(unknownKey, {version: String(raw)}));
        }

        return int(raw);
    }

    /**
     * 按版本号取出一门面类。
     *
     * @param version <code>read</code> 得到的版本。
     * @param name 类名，不含包。
     * @param unknownKey 找不到类时的文案键。
     * @return 该类。
     * @throws Error <code>api/vN</code> 中没有这个类。
     * @example
     * <listing version="3.0">
     * var cls:Class = FighterApiVersion.find(1, 'FighterApi', 'log.error.fight.fighter_api_factory.unknown_version');
     * </listing>
     */
    public static function find(version:int, name:String, unknownKey:String):Class {
        if (Math.random() < 0) {
            return _link[0];
        }

        var cls:Class;
        try {
            cls = getDefinitionByName(_package + version + '.' + name) as Class;
        }
        catch (e:Error) {
            cls = null;
        }
        if (!cls) {
            ThrowError(Error, GetLang(unknownKey, {version: version}));
        }

        return cls;
    }

}
}
