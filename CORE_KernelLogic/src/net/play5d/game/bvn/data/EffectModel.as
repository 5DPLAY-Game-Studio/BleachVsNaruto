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
import flash.display.BlendMode;

import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.data.vos.EffectVO;

import net.play5d.game.bvn.data.fighter.FighterDefenseType;

/**
 * 内置特效表。
 *
 * <p>还没 <code>initialize</code> 时取值会抛错。徒手防御会把斩击类型改成打。
 * 普通防御找不到对应类型时改用重魔法防御。无双小兵防御没有这个回退。</p>
 *
 * @see EffectVO
 * @see net.play5d.game.bvn.data.fighter.FighterDefenseType
 */
public class EffectModel {

    /** @private */
    private static var _i:EffectModel;

    /**
     * 唯一实例。第一次读取时创建。
     *
     * @return 特效表。
     * @example
     * <listing version="3.0">
     * EffectModel.I.initialize();
     * </listing>
     */
    public static function get I():EffectModel {
        _i ||= new EffectModel();
        return _i;
    }

    /** @private */
    private var _effect:Object;

    /**
     * 建表、缓存位图，并预热用到的音效。
     *
     * <p>再调用一次会换掉整张表。</p>
     *
     * @example
     * <listing version="3.0">
     * EffectModel.I.initialize();
     * </listing>
     */
    public function initialize():void {
        initEffects();
        cacheEffects();
        warmSounds();
    }

    /**
     * 按 id 取特效。
     *
     * @param id 特效 id。
     * @return 特效。没有时为 <code>undefined</code>。表还没建时抛错。
     * @example
     * <listing version="3.0">
     * var fx:EffectVO = EffectModel.I.getEffect('jump');
     * </listing>
     */
    public function getEffect(id:String):EffectVO {
        return _effect[id];
    }

    /**
     * 按受击类型取普通受击特效。
     *
     * @param type 受击类型。
     * @return 特效。没有这个类型时为 <code>undefined</code>。
     * @example
     * <listing version="3.0">
     * var fx:EffectVO = EffectModel.I.getHitEffect(type);
     * </listing>
     */
    public function getHitEffect(type:int):EffectVO {
        return _effect['hit_' + type];
    }

    /**
     * 按受击类型取无双小兵受击特效。
     *
     * @param type 受击类型。
     * @return 特效。没有这个类型时为 <code>undefined</code>。
     * @example
     * <listing version="3.0">
     * var fx:EffectVO = EffectModel.I.getMusouEnemyHitEffect(type);
     * </listing>
     */
    public function getMusouEnemyHitEffect(type:int):EffectVO {
        return _effect['hit_enemy_' + type];
    }

    /**
     * 按受击和防御类型取无双小兵防御特效。
     *
     * <p>徒手时，斩和重斩会改成打和重打。找不到时为 <code>undefined</code>，没有回退。</p>
     *
     * @param hitType 受击类型。
     * @param defenseType 防御类型。
     * @return 特效。
     * @example
     * <listing version="3.0">
     * var fx:EffectVO = EffectModel.I.getMusouEnemyDefenseEffect(hitType, defenseType);
     * </listing>
     */
    public function getMusouEnemyDefenseEffect(hitType:int, defenseType:int):EffectVO {
        switch (defenseType) {
        case FighterDefenseType.SWORD:
            break;
        case FighterDefenseType.HAND:
            if (hitType == HitType.KAN) {
                hitType = HitType.DA;
            }
            if (hitType == HitType.KAN_HEAVY) {
                hitType = HitType.DA_HEAVY;
            }
            break;
        }

        return _effect['defense_enemy_' + hitType];
    }

    /**
     * 按受击和防御类型取普通防御特效。
     *
     * <p>徒手时的改类型和无双小兵相同。找不到时改用重魔法防御。</p>
     *
     * @param hitType 受击类型。
     * @param defenseType 防御类型。
     * @return 特效。
     * @example
     * <listing version="3.0">
     * var fx:EffectVO = EffectModel.I.getDefenseEffect(hitType, defenseType);
     * </listing>
     */
    public function getDefenseEffect(hitType:int, defenseType:int):EffectVO {
        switch (defenseType) {
        case FighterDefenseType.SWORD:
            break;
        case FighterDefenseType.HAND:
            if (hitType == HitType.KAN) {
                hitType = HitType.DA;
            }
            if (hitType == HitType.KAN_HEAVY) {
                hitType = HitType.DA_HEAVY;
            }
            break;
        }


        var effect:EffectVO = _effect['defense_' + hitType];
        return effect ? effect : _effect['defense_' + HitType.MAGIC_HEAVY];
    }

    /** @private */
    private function initEffects():void {
        _effect = {};

        _effect['bisha']       = new EffectVO('XG_bs', {sound: 'snd_bs', blendMode: BlendMode.ADD});
        _effect['bisha_super'] = new EffectVO('XG_cbs', {sound: 'snd_cbs', blendMode: BlendMode.ADD});

        _effect['dash']     = new EffectVO('XG_rush', {sound: 'snd_dash_air'});
        _effect['dash_air'] = new EffectVO('XG_rush_air', {sound: 'snd_dash_air'});

        _effect['jump']        = new EffectVO('XG_jump', {sound: 'snd_jump'});
        _effect['jump_air']    = new EffectVO('XG_jump_air', {sound: 'snd_jump', blendMode: BlendMode.ADD});
        _effect['touch_floor'] = new EffectVO('XG_luodi', {sound: 'snd_luodi'});

        _effect['hit_floor']       = new EffectVO('XG_hitfloor', {sound: 'snd_hitfloor'});
        _effect['hit_floor_low']   = new EffectVO('xg_hitfloor_low', {sound: 'snd_hitfloor_low'});
        _effect['hit_floor_heavy'] = new EffectVO('xg_hitfllor_heavy', {sound: 'snd_hitfloor_heavy'});
        _effect['hit_floor_yan']   = new EffectVO('xg_hitfloor_yan', {blendMode: BlendMode.LIGHTEN});

        _effect['hit_end'] = new EffectVO('xg_hitover');

        _effect['break_def'] = new EffectVO('XG_mfdjx', {
            sound: 'snd_mfdjx', blendMode: BlendMode.ADD, slowDown: {rate: 1.5, time: 1500}, freeze: 500,
            shake: {x: 6, time: 400}
        });

        _effect['fz_bleach'] = new EffectVO('XG_fz_bleach_mc', {sound: 'snd_dash'});
        _effect['fz_naruto'] = new EffectVO('XG_fz_naruto_mc', {sound: 'snd_fz'});

        _effect['replaceSp']  = new EffectVO('XG_tishen', {sound: 'snd_fz'});
        _effect['replaceSp2'] = new EffectVO('XG_tishen2');

        _effect['explodeSp']  = new EffectVO('XG_bsq', {sound: 'snd_baoqi1'});
        _effect['explodeSp2'] = new EffectVO('XG_baoqi', {sound: 'snd_baoqi'});

        _effect['ghost_step'] = new EffectVO('XG_ghost_step', {sound: 'snd_ghost_step', blendMode: BlendMode.ADD});

        _effect['kobg'] = new EffectVO('kobg_effect_mc');

        _effect['level_up']         = new EffectVO('xg_mc_levelup', {sound: 'snd_level_up'});
        _effect['level_up_new_act'] = new EffectVO('xg_mc_levelup_newaction', {sound: 'snd_level_up'});

        _effect['team_change'] = new EffectVO('xg_mc_change', {sound: 'snd_change1', blendMode: BlendMode.ADD});

        initHitEffect();
        initDefenseEffect();
        initSpecialEffect();
        initBuffEffect();
        initSteelHitEffect();

        initMusouEnemyHitEffect();
        initMusouEnemyDefenseEffect();
    }

    /** @private */
    private function cacheEffects():void {
        for each(var e:EffectVO in _effect) {
            e.cacheBitmapData();
        }
    }

    /** @private */
    private function warmSounds():void {
        var seen:Object = {};
        for each(var e:EffectVO in _effect) {
            if (!e.sound || seen[e.sound]) {
                continue;
            }
            seen[e.sound] = true;
            SoundCtrl.I.warmEffectSound(e.sound);
        }
    }

    /** @private */
    private function initHitEffect():void {

        addHitEffect(HitType.CATCH, 'xg_catch_hit', {freeze: 400, sound: 'snd_hit_cache'});

        addHitEffect(HitType.KAN, 'XG_kan2',
                     {sound: 'snd_kan1', freeze: 50, blendMode: BlendMode.ADD, randRotate: true}
        );
        addHitEffect(HitType.KAN_HEAVY, 'XG_kanx2', {
            sound     : 'snd_kan2', freeze: 400, blendMode: BlendMode.ADD, shine: {color: 0xffffff, alpha: 0.2},
            randRotate: true, shake: {pow: 6, time: 400}
        });

        addHitEffect(HitType.DA, 'XG_qdj', {sound: 'snd_hit2', blendMode: BlendMode.ADD, freeze: 50, randRotate: true});
        addHitEffect(HitType.DA_HEAVY, 'XG_qdjx', {
            sound: 'snd_hit_heavy', blendMode: BlendMode.ADD, randRotate: true, freeze: 400,
            shine: {color: 0xffffff, alpha: 0.2}, shake: {pow: 6, time: 400}
        });

        addHitEffect(HitType.MAGIC, 'XG_mfdj',
                     {sound: 'snd_hit2', freeze: 50, blendMode: BlendMode.ADD, randRotate: true}
        );
        addHitEffect(HitType.MAGIC_HEAVY, 'XG_mfdjx', {
            sound: 'snd_mfdjx', freeze: 400, blendMode: BlendMode.ADD, randRotate: true,
            shine: {color: 0xffffff, alpha: 0.2}, shake: {pow: 6, time: 400}
        });

        addHitEffect(HitType.FIRE, 'XG_fire', {
            sound: 'snd_hit_fire', blendMode: BlendMode.ADD, specialEffectId: 'fire_ing', freeze: 400,
            shine: {color: 0xFFFF67, alpha: 0.2}, shake: {pow: 6, time: 400}
        });
        addHitEffect(HitType.ICE, 'XG_ice', {
            sound: 'snd_hit_ice', blendMode: BlendMode.ADD, specialEffectId: 'ice_ing', freeze: 400,
            shine: {color: 0xA3E5F5, alpha: 0.2}, shake: {pow: 6, time: 400}
        });
        addHitEffect(HitType.ELECTRIC, 'XG_leidian', {
            sound: 'snd_hit_dian', blendMode: BlendMode.HARDLIGHT, specialEffectId: 'shock_ing', freeze: 400,
            shine: {color: 0x8288D2, alpha: 0.2}, shake: {pow: 6, time: 400}
        });

    }

    /** @private */
    private function initDefenseEffect():void {

        addDefenseEffect(HitType.KAN, 'XG_fykan',
                         {sound: 'snd_fykan', freeze: 50, blendMode: BlendMode.ADD, followDirect: true}
        );
        addDefenseEffect(HitType.KAN_HEAVY, 'XG_fykanx', {
            sound: 'snd_fykanx', freeze: 400, blendMode: BlendMode.ADD,
            shine: {color: 0xffffff, blendMode: BlendMode.SCREEN, alpha: 0.1}, followDirect: true,
            shake: {pow: 6, time: 400}
        });

        addDefenseEffect(HitType.DA, 'XG_fyq',
                         {sound: 'snd_def', freeze: 50, blendMode: BlendMode.ADD, followDirect: true}
        );
        addDefenseEffect(HitType.DA_HEAVY, 'XG_fyqx', {
            sound: 'snd_defx', freeze: 400, blendMode: BlendMode.ADD, followDirect: true,
            shine: {color: 0xffffff, alpha: 0.1}, shake: {pow: 6, time: 400}
        });

        addDefenseEffect(HitType.MAGIC, 'XG_mffy',
                         {sound: 'snd_def', freeze: 50, blendMode: BlendMode.ADD, followDirect: true}
        );
        addDefenseEffect(HitType.MAGIC_HEAVY, 'XG_mffyx', {
            sound: 'snd_defx', freeze: 400, blendMode: BlendMode.ADD, followDirect: true,
            shine: {color: 0xffffff, alpha: 0.15}, shake: {pow: 6, time: 400}
        });

        addDefenseEffect(HitType.FIRE, 'XG_fire_fy', {
            sound: 'snd_defx', freeze: 400, blendMode: BlendMode.ADD, followDirect: true,
            shine: {color: 0xFFFF67, alpha: 0.2}, shake: {pow: 6, time: 400}
        });
        addDefenseEffect(HitType.ICE, 'XG_ice_fy', {
            sound: 'snd_defx', freeze: 400, blendMode: BlendMode.ADD, followDirect: true,
            shine: {color: 0xA3E5F5, alpha: 0.2}, shake: {pow: 6, time: 400}
        });
        addDefenseEffect(HitType.ELECTRIC, 'XG_dian_fy', {
            sound: 'snd_defx', freeze: 400, blendMode: BlendMode.ADD, followDirect: true,
            shine: {color: 0x8288D2, alpha: 0.2}, shake: {pow: 6, time: 400}
        });

    }

    /** @private */
    private function initMusouEnemyHitEffect():void {
        addEnemyHitEffect(HitType.CATCH, 'xg_catch_hit', {freeze: 200, sound: 'snd_hit_cache'});

        addEnemyHitEffect(HitType.KAN, 'XG_kan2',
                          {sound: 'snd_kan1', freeze: 50, blendMode: BlendMode.ADD, randRotate: true}
        );
        addEnemyHitEffect(HitType.KAN_HEAVY, 'XG_kanx2', {
            sound     : 'snd_kan2', freeze: 200, blendMode: BlendMode.ADD, shine: {color: 0xffffff, alpha: 0.2},
            randRotate: true, shake: {pow: 2, time: 100}
        });

        addEnemyHitEffect(HitType.DA, 'XG_qdj',
                          {sound: 'snd_hit2', blendMode: BlendMode.ADD, freeze: 0, randRotate: true}
        );
        addEnemyHitEffect(HitType.DA_HEAVY, 'XG_qdjx', {
            sound: 'snd_hit_heavy', blendMode: BlendMode.ADD, randRotate: true, freeze: 200,
            shine: {color: 0xffffff, alpha: 0.2}, shake: {pow: 2, time: 100}
        });

        addEnemyHitEffect(HitType.MAGIC, 'XG_mfdj',
                          {sound: 'snd_hit2', freeze: 0, blendMode: BlendMode.ADD, randRotate: true}
        );
        addEnemyHitEffect(HitType.MAGIC_HEAVY, 'XG_mfdjx', {
            sound: 'snd_mfdjx', freeze: 200, blendMode: BlendMode.ADD, randRotate: true,
            shine: {color: 0xffffff, alpha: 0.2}, shake: {pow: 2, time: 100}
        });

        addEnemyHitEffect(HitType.FIRE, 'XG_fire', {
            sound: 'snd_hit_fire', blendMode: BlendMode.ADD, specialEffectId: 'fire_ing', freeze: 200,
            shine: {color: 0xFFFF67, alpha: 0.2}, shake: {pow: 2, time: 100}
        });
        addEnemyHitEffect(HitType.ICE, 'XG_ice', {
            sound: 'snd_hit_ice', blendMode: BlendMode.ADD, specialEffectId: 'ice_ing', freeze: 200,
            shine: {color: 0xA3E5F5, alpha: 0.2}, shake: {pow: 2, time: 100}
        });
        addEnemyHitEffect(HitType.ELECTRIC, 'XG_leidian', {
            sound: 'snd_hit_dian', blendMode: BlendMode.HARDLIGHT, specialEffectId: 'shock_ing', freeze: 200,
            shine: {color: 0x8288D2, alpha: 0.2}, shake: {pow: 2, time: 100}
        });
    }

    /** @private */
    private function initMusouEnemyDefenseEffect():void {
        addEnemyDefenseEffect(HitType.KAN, 'XG_fykan',
                              {sound: 'snd_fykan', freeze: 50, blendMode: BlendMode.ADD, followDirect: true}
        );
        addEnemyDefenseEffect(HitType.KAN_HEAVY, 'XG_fykanx', {
            sound: 'snd_fykanx', freeze: 100, blendMode: BlendMode.ADD,
            shine: {color: 0xffffff, blendMode: BlendMode.SCREEN, alpha: 0.1}, followDirect: true,
            shake: {pow: 2, time: 100}
        });

        addEnemyDefenseEffect(HitType.DA, 'XG_fyq',
                              {sound: 'snd_def', freeze: 50, blendMode: BlendMode.ADD, followDirect: true}
        );
        addEnemyDefenseEffect(HitType.DA_HEAVY, 'XG_fyqx', {
            sound: 'snd_defx', freeze: 100, blendMode: BlendMode.ADD, followDirect: true,
            shine: {color: 0xffffff, alpha: 0.1}, shake: {pow: 2, time: 100}
        });

        addEnemyDefenseEffect(HitType.MAGIC, 'XG_mffy',
                              {sound: 'snd_def', freeze: 50, blendMode: BlendMode.ADD, followDirect: true}
        );
        addEnemyDefenseEffect(HitType.MAGIC_HEAVY, 'XG_mffyx', {
            sound: 'snd_defx', freeze: 100, blendMode: BlendMode.ADD, followDirect: true,
            shine: {color: 0xffffff, alpha: 0.15}, shake: {pow: 2, time: 100}
        });

        addEnemyDefenseEffect(HitType.FIRE, 'XG_fire_fy', {
            sound: 'snd_defx', freeze: 100, blendMode: BlendMode.ADD, followDirect: true,
            shine: {color: 0xFFFF67, alpha: 0.2}, shake: {pow: 2, time: 100}
        });
        addEnemyDefenseEffect(HitType.ICE, 'XG_ice_fy', {
            sound: 'snd_defx', freeze: 100, blendMode: BlendMode.ADD, followDirect: true,
            shine: {color: 0xA3E5F5, alpha: 0.2}, shake: {pow: 2, time: 100}
        });
        addEnemyDefenseEffect(HitType.ELECTRIC, 'XG_dian_fy', {
            sound: 'snd_defx', freeze: 100, blendMode: BlendMode.ADD, followDirect: true,
            shine: {color: 0x8288D2, alpha: 0.2}, shake: {pow: 2, time: 100}
        });

    }

    /** @private */
    private function initSpecialEffect():void {
        _effect['fire_ing']  = new EffectVO(
                'xg_fire_ing', {
                    blendMode: BlendMode.ADD, isSpecial: true, targetColorOffset: [-255, -255, -255]
                });
        _effect['ice_ing']   = new EffectVO(
                'xg_ice_ing', {blendMode: BlendMode.ADD, isSpecial: true, targetColorOffset: [0, 0, 255]});
        _effect['shock_ing'] = new EffectVO(
                'xg_dian_ing', {
                    blendMode: BlendMode.ADD, isSpecial: true, targetColorOffset: [50, -75, 255]
                });
    }

    /** @private */
    private function initBuffEffect():void {
        _effect['buff_effect_speed']   = new EffectVO('xg_buff_effect_speed', {blendMode: BlendMode.ADD});
        _effect['buff_effect_power']   = new EffectVO('xg_buff_effect_power', {blendMode: BlendMode.ADD});
        _effect['buff_effect_defense'] = new EffectVO('xg_buff_effect_defense', {blendMode: BlendMode.ADD});

        _effect['buff_speed']   = new EffectVO('xg_buff_speed', {blendMode: BlendMode.ADD, isBuff: true});
        _effect['buff_power']   = new EffectVO('xg_buff_power', {blendMode: BlendMode.ADD, isBuff: true});
        _effect['buff_defense'] = new EffectVO('xg_buff_defense', {blendMode: BlendMode.ADD, isBuff: true});
    }

    /** @private */
    private function initSteelHitEffect():void {
        _effect['steel_hit_kan']  = new EffectVO(
                'XG_kan2', {
                    sound                                                             : 'snd_hit11', freeze: 400, blendMode: BlendMode.ADD,
                    shine: {color: 0xffffff, alpha: 0.2}, randRotate: true, isSteelHit: true
                });
        _effect['steel_hit_qdj']  = new EffectVO(
                'XG_qdj', {
                    sound                                                             : 'snd_hit11', freeze: 400, blendMode: BlendMode.ADD,
                    shine: {color: 0xffffff, alpha: 0.2}, randRotate: true, isSteelHit: true
                });
        _effect['steel_hit_mfdj'] = new EffectVO(
                'XG_mfdj', {
                    sound                                                             : 'snd_hit11', freeze: 400, blendMode: BlendMode.ADD,
                    shine: {color: 0xffffff, alpha: 0.2}, randRotate: true, isSteelHit: true
                });
    }

    /** @private */
    private function addHitEffect(type:int, className:String, param:Object = null):void {
        var effect:EffectVO    = new EffectVO(className, param);
        _effect['hit_' + type] = effect;
    }

    /** @private */
    private function addDefenseEffect(type:int, className:String, param:Object = null):void {
        var effect:EffectVO        = new EffectVO(className, param);
        _effect['defense_' + type] = effect;
    }

    /** @private */
    private function addEnemyHitEffect(type:int, className:String, param:Object = null):void {
        var effect:EffectVO          = new EffectVO(className, param);
        _effect['hit_enemy_' + type] = effect;
    }

    /** @private */
    private function addEnemyDefenseEffect(type:int, className:String, param:Object = null):void {
        var effect:EffectVO              = new EffectVO(className, param);
        _effect['defense_enemy_' + type] = effect;
    }

}
}
