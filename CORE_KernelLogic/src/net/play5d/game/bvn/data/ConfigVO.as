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

package net.play5d.game.bvn.data {
import flash.display.StageQuality;
import flash.ui.Keyboard;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.GameQuality;
import net.play5d.game.bvn.ctrl.EffectCtrl;
import net.play5d.game.bvn.ctrl.SoundCtrl;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.interfaces.IExtendConfig;
import net.play5d.game.bvn.interfaces.IInstanceVO;
import net.play5d.kyo.utils.KyoUtils;
import net.play5d.pcl.utils.ClassUtils;

public class ConfigVO implements ISaveData, IInstanceVO {
    include '../../../../../../include/_INCLUDE_.as';
    include '../../../../../../include/Clone.as';

    public const key_menu:KeyConfigVO = new KeyConfigVO(0);
    public const key_p1:KeyConfigVO   = new KeyConfigVO(1);
    public const key_p2:KeyConfigVO   = new KeyConfigVO(2);

    public function ConfigVO() {
        if (GameInterface.instance) {
            extendConfig = GameInterface.instance.getConfigExtend();
        }

        setDefaultConfig(key_menu);
        setDefaultConfig(key_p1);
        setDefaultConfig(key_p2);
    }
    public var select_config:SelectStageConfigVO = new SelectStageConfigVO();
    // 显示语言
    public var language:String = null;
    public var AI_level:int     = 1;
    public var fighterHP:Number = 1; //HP比例
    public var fightTime:int    = 60;
    public var quality:String   = StageQuality.LOW;
    public var soundVolume:Number = 0.7; // SOUND音量
    public var bgmVolume:Number   = 0.7; // BGM音量
    public var keyInputMode:int = 1; //0标准, 1经典（长按式）
    /**
     * 扩展设置
     */
    public var extendConfig:IExtendConfig;
    private var _cloneKeys:Array = ClassUtils.getClassProperty(ConfigVO);

    public function setDefaultConfig(keyConfig:KeyConfigVO):void {
        switch (keyConfig.id) {
        case 0: //MENU
            keyConfig.setKeys(
                    Keyboard.W, Keyboard.S, Keyboard.A, Keyboard.D,
                    Keyboard.J, Keyboard.K, Keyboard.L,
                    Keyboard.U, Keyboard.I, Keyboard.O
            );
            keyConfig.selects = [Keyboard.J, Keyboard.K, Keyboard.L, Keyboard.U, Keyboard.I, Keyboard.O];
            break;
        case 1:
            keyConfig.setKeys(
                    Keyboard.W, Keyboard.S, Keyboard.A, Keyboard.D,
                    Keyboard.J, Keyboard.K, Keyboard.L,
                    Keyboard.U, Keyboard.I, Keyboard.O
            );
            break;
        case 2:
            keyConfig.setKeys(
                    Keyboard.UP, Keyboard.DOWN, Keyboard.LEFT, Keyboard.RIGHT,
                    Keyboard.NUMPAD_1, Keyboard.NUMPAD_2, Keyboard.NUMPAD_3,
                    Keyboard.NUMPAD_4, Keyboard.NUMPAD_5, Keyboard.NUMPAD_6
            );
            break;
        }
    }

    public function toSaveObj():Object {
        var o:Object = {};
        o.key_p1     = key_p1.toSaveObj();
        o.key_p2     = key_p2.toSaveObj();

        o.language     = language;
        o.AI_level     = AI_level;
        o.fighterHP    = fighterHP;
        o.fightTime    = fightTime;
        o.quality      = quality;
        o.keyInputMode = keyInputMode;
        o.soundVolume  = soundVolume;
        o.bgmVolume    = bgmVolume;

        if (extendConfig) {
            o.extend_config = extendConfig.toSaveObj();
        }

        return o;
    }

    public function readSaveObj(o:Object):void {
        key_p1.readSaveObj(o.key_p1);
        key_p2.readSaveObj(o.key_p2);

        if (o.extend_config && extendConfig) {
            extendConfig.readSaveObj(o.extend_config);
        }

        delete o['key_p1'];
        delete o['key_p2'];

        KyoUtils.setValueByObject(this, o);
    }

    public function getValueByKey(key:String):* {
        if (this.hasOwnProperty(key)) {
            return this[key];
        }
        if (extendConfig) {
            try {
                return extendConfig[key];
            }
            catch (e:Error) {
                trace(e);
            }
        }
        return null;
    }

    public function setValueByKey(key:String, value:*):void {
        if (this.hasOwnProperty(key)) {
            this[key] = value;

            switch (key) {
            case 'bgmVolume':
                SoundCtrl.I.setBgmVolumn(bgmVolume);
                break;
            case 'soundVolume':
                SoundCtrl.I.setSoundVolumn(soundVolume);
                break;
            }

            return;
        }
        if (extendConfig) {
            try {
                extendConfig[key] = value;
            }
            catch (e:Error) {
                trace(e);
            }
        }
    }


//		/**
//		 * 扩展设置
//		 * @param key
//		 * @param value
//		 */
//		public function setExtend(key:String , value:Object):void{
//			extendObj ||= {};
//			extendObj[key] = value;
//		}

    public function applyConfig():void {
        switch (quality) {
        case GameQuality.LOW:
            GameConfig.QUALITY_GAME = StageQuality.LOW;
            GameConfig.setGameFps(30);
            GameConfig.FPS_SHINE_EFFECT = 15;
            EffectCtrl.EFFECT_SMOOTHING = false;
            break;
        case GameQuality.MEDIUM:
            GameConfig.QUALITY_GAME = StageQuality.LOW;
            GameConfig.setGameFps(60);
            GameConfig.FPS_SHINE_EFFECT = 30;
            EffectCtrl.EFFECT_SMOOTHING = false;
            break;
        case GameQuality.HIGH:
            GameConfig.QUALITY_GAME = StageQuality.MEDIUM;
            GameConfig.setGameFps(60);
            GameConfig.FPS_SHINE_EFFECT = 30;
            EffectCtrl.EFFECT_SMOOTHING = false;
            break;
        case GameQuality.HIGHER:
            GameConfig.QUALITY_GAME = StageQuality.HIGH;
            GameConfig.setGameFps(60);
            GameConfig.FPS_SHINE_EFFECT = 30;
            EffectCtrl.EFFECT_SMOOTHING = true;
            break;
        case GameQuality.BEST:
            GameConfig.QUALITY_GAME = StageQuality.HIGH;
            GameConfig.setGameFps(60);
            GameConfig.FPS_SHINE_EFFECT = 60;
            EffectCtrl.EFFECT_SMOOTHING = true;
            break;
        }

        GameInterface.instance.applyConfig(this);
        SoundCtrl.I.setBgmVolumn(bgmVolume);
        SoundCtrl.I.setSoundVolumn(soundVolume);

    }


}
}
