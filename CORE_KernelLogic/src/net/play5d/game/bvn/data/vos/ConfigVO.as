/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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

package net.play5d.game.bvn.data.vos {

import flash.display.StageQuality;
import flash.ui.Keyboard;

import net.play5d.game.bvn.interfaces.ISaveData;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.interfaces.IExtendConfig;
import net.play5d.game.bvn.interfaces.IInstanceVO;
import net.play5d.game.bvn.utils.GameLogger;
import net.play5d.kyo.utils.KyoUtils;

/**
 * 配置值对象。
 *
 * <p>只保存键位、画质、音量等值。应用到画面和声音由 <code>ConfigCtrl</code> 负责。
 * 存档不含菜单键。读档时没有 <code>key_p1</code> 或 <code>key_p2</code> 会抛错。
 * 按名字取值时，本对象没有这个字段才去扩展配置；扩展配置抛错时记日志并返回 <code>null</code>。</p>
 *
 * @see net.play5d.game.bvn.ctrler.ConfigCtrl
 */
public class ConfigVO implements ISaveData, IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /** 菜单键。构造时写成 WASD 与 JKL、UIO，确认键是这六个键。 */
    public const key_menu:KeyConfigVO = new KeyConfigVO(0);
    /** P1 键。构造时与菜单方向、技能键相同，确认键只有攻击键。 */
    public const key_p1:KeyConfigVO   = new KeyConfigVO(1);
    /** P2 键。构造时是方向键和小键盘 1 到 6。 */
    public const key_p2:KeyConfigVO   = new KeyConfigVO(2);

    /**
     * 构造三套默认键。有壳时取扩展配置。
     *
     * @example
     * <listing version="3.0">
     * var config:ConfigVO = new ConfigVO();
     * </listing>
     */
    public function ConfigVO() {
        if (GameInterface.instance) {
            extendConfig = GameInterface.instance.getConfigExtend();
        }

        setDefaultConfig(key_menu);
        setDefaultConfig(key_p1);
        setDefaultConfig(key_p2);
    }

    /**
     * 选人界面配置。
     */
    public var select_config:SelectStageConfigVO = new SelectStageConfigVO();
    /**
     * 显示语言。未设置时为 <code>null</code>。
     *
     * @default null
     */
    public var language:String                   = null;
    /**
     * AI 等级。
     *
     * @default 1
     */
    public var AI_level:int                      = 1;
    /**
     * 体力比例。
     *
     * @default 1
     */
    public var fighterHP:Number                  = 1;
    /**
     * 对局时间，单位秒。
     *
     * @default 60
     */
    public var fightTime:int                     = 60;
    /**
     * 画面质量。
     *
     * @default low
     */
    public var quality:String                    = StageQuality.LOW;
    /**
     * 音效音量。
     *
     * @default 0.7
     */
    public var soundVolume:Number                = 0.7;
    /**
     * 背景音乐音量。
     *
     * @default 0.7
     */
    public var bgmVolume:Number                  = 0.7;
    /**
     * 键位模式。0 为标准，1 为经典长按。
     *
     * @default 1
     */
    public var keyInputMode:int                  = 1;

    /**
     * 是否显示血量数字。
     *
     * @default false
     */
    public var isShowHp:Boolean = false;
    /**
     * 壳提供的扩展设置。没有壳时为 <code>null</code>。
     *
     * @default null
     */
    public var extendConfig:IExtendConfig;

    /**
     * 按 id 写成默认键。
     *
     * <p>0 是菜单，1 是 P1，2 是 P2。其它 id 什么都不做。</p>
     *
     * @param keyConfig 键位。为空时抛错。
     * @example
     * <listing version="3.0">
     * config.setDefaultConfig(config.key_p1);
     * </listing>
     */
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

    /**
     * 做成可保存的对象。不含菜单键和选人配置。
     *
     * @return 存档对象。
     * @example
     * <listing version="3.0">
     * var o:Object = config.toSaveObj();
     * </listing>
     */
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
        o.isShowHp     = isShowHp;

        if (extendConfig) {
            o.extend_config = extendConfig.toSaveObj();
        }

        return o;
    }

    /**
     * 从存档写回。会改传入的对象，删掉里面的两套键。
     *
     * <p>没有 <code>key_p1</code> 或 <code>key_p2</code> 时抛错。菜单键不读。</p>
     *
     * @param o 存档对象。
     * @example
     * <listing version="3.0">
     * config.readSaveObj(o);
     * </listing>
     */
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

    /**
     * 按字段名取值。先看本对象，没有再看扩展配置。
     *
     * @param key 字段名。
     * @return 值。都没有，或扩展配置抛错时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var hp:Number = config.getValueByKey('fighterHP');
     * </listing>
     */
    public function getValueByKey(key:String):* {
        if (this.hasOwnProperty(key)) {
            return this[key];
        }
        if (extendConfig) {
            try {
                return extendConfig[key];
            }
            catch (e:Error) {
                GameLogger.error('sys', 'ConfigVO.getValueByKey: ' + e);
            }
        }

        return null;
    }

    /**
     * 按字段名写入。本对象没有这个字段时写到扩展配置。
     *
     * <p>两边都没有时什么都不做。扩展配置抛错时只记日志。</p>
     *
     * @param key 字段名。
     * @param value 值。
     * @example
     * <listing version="3.0">
     * config.setValueByKey('fightTime', 90);
     * </listing>
     */
    public function setValueByKey(key:String, value:*):void {
        if (this.hasOwnProperty(key)) {
            this[key] = value;
            return;
        }
        if (extendConfig) {
            try {
                extendConfig[key] = value;
            }
            catch (e:Error) {
                GameLogger.error('sys', 'ConfigVO.setValueByKey: ' + e);
            }
        }
    }

}
}
