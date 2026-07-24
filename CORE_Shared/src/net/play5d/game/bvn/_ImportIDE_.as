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
import flash.display.Sprite;

import net.play5d.game.bvn.data.*;
import net.play5d.game.bvn.data.fighter.*;
import net.play5d.game.bvn.interfaces.*;

/**
 * shared SWC 在 Flash / Animate IDE 中的导入主类。
 *
 * <p>通过引用共享类型，保证编译进 <code>BleachVsNaruto_FlashSrc\SRC_XFL\swc\shared</code>。</p>
 *
 * @private
 */
public class _ImportIDE_ extends Sprite {

    /** @private 强制链接共享类型，防止被优化剔除 */
    private static const _NO_USE_:Array = [
        // net.play5d.game.bvn.data
        DefinedClass,
        GameMode,
        HitType,
        LanguageType,
        MapLogoState,
        TeamID,

        // net.play5d.game.bvn.data.fighter
        FighterActionState,
        FighterDefenseType,
        FighterHitRange,
        FighterHurtType,
        FighterSpecialFrame,

        // net.play5d.game.bvn.interfaces
        IAssetLoader,
        IComponents,
        IExtendConfig,
        ILogger,
        ISaveData
    ];

    /**
     * 构造导入主类，并触发全局符号链接。
     */
    public function _ImportIDE_() {
        _SHARED_GLOBALS_;
    }
}
}
