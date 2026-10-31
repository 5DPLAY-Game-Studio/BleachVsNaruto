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

package net.play5d.game.bvn.ctrler {
import flash.display.StageQuality;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.GameQuality;
import net.play5d.game.bvn.data.vos.ConfigVO;
import net.play5d.game.bvn.interfaces.GameInterface;

/**
 * 把配置值应用到画质、帧率、特效、音量和壳层。
 *
 * @see ConfigVO
 */
public class ConfigCtrl {

    /**
     * 按画质档位刷新运行参数，并通知壳层与音量。
     *
     * @param config 当前配置。
     * @example
     * <listing version="3.0">
     * ConfigCtrl.apply(GameData.I.config);
     * </listing>
     */
    public static function apply(config:ConfigVO):void {
        switch (config.quality) {
        case GameQuality.LOW:
            GameConfig.QUALITY_GAME     = StageQuality.LOW;
            GameConfig.setGameFps(30);
            GameConfig.FPS_SHINE_EFFECT = 15;
            EffectCtrl.EFFECT_SMOOTHING = false;
            break;
        case GameQuality.MEDIUM:
            GameConfig.QUALITY_GAME     = StageQuality.LOW;
            GameConfig.setGameFps(60);
            GameConfig.FPS_SHINE_EFFECT = 30;
            EffectCtrl.EFFECT_SMOOTHING = false;
            break;
        case GameQuality.HIGH:
            GameConfig.QUALITY_GAME     = StageQuality.MEDIUM;
            GameConfig.setGameFps(60);
            GameConfig.FPS_SHINE_EFFECT = 30;
            EffectCtrl.EFFECT_SMOOTHING = false;
            break;
        case GameQuality.HIGHER:
            GameConfig.QUALITY_GAME     = StageQuality.HIGH;
            GameConfig.setGameFps(60);
            GameConfig.FPS_SHINE_EFFECT = 30;
            EffectCtrl.EFFECT_SMOOTHING = true;
            break;
        case GameQuality.BEST:
            GameConfig.QUALITY_GAME     = StageQuality.HIGH;
            GameConfig.setGameFps(60);
            GameConfig.FPS_SHINE_EFFECT = 60;
            EffectCtrl.EFFECT_SMOOTHING = true;
            break;
        }

        GameInterface.instance.applyConfig(config);
        applyVolume(config);
    }

    /**
     * 按配置刷新背景音乐和音效音量。
     *
     * @param config 当前配置。
     * @example
     * <listing version="3.0">
     * ConfigCtrl.applyVolume(GameData.I.config);
     * </listing>
     */
    public static function applyVolume(config:ConfigVO):void {
        SoundCtrl.I.setBgmVolumn(config.bgmVolume);
        SoundCtrl.I.setSoundVolumn(config.soundVolume);
    }
}
}
