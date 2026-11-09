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

package net.play5d.game.bvn.fighter.ctrler {
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

import net.play5d.game.bvn.data.GameData;
import net.play5d.kyo.utils.KyoRandom;

/**
 * 按编号播放角色语音。
 *
 * <p>音量在构造时从配置抄一份，之后改设置不会改到这里。
 * 上一条还没播完时直接返回。随机数大于 <code>rate</code> 时也返回，所以 <code>rate</code> 为 1 时一定会尝试播放。
 * 只有一条时用那一条，多条时随机。销毁后再播放会抛错。</p>
 *
 * @see FighterVoice
 */
public class FighterVoiceCtrler {

    /**
     * 按当前音效音量建一份变换。
     *
     * <p>配置还没就绪时抛错。</p>
     *
     * @example
     * <listing version="3.0">
     * var voice:FighterVoiceCtrler = new FighterVoiceCtrler();
     * </listing>
     */
    public function FighterVoiceCtrler() {
        _soundTransform        = new SoundTransform();
        _soundTransform.volume = GameData.I.config.soundVolume;
    }

    /** @private */
    private var _voiceObj:Object = {};

    /** @private */
    private var _channel:SoundChannel;
    /** @private */
    private var _curLength:int;
    /** @private */
    private var _soundTransform:SoundTransform;

    /**
     * 停掉正在播的声音并丢掉语音表。
     *
     * @example
     * <listing version="3.0">
     * voice.destroy();
     * </listing>
     */
    public function destroy():void {
        if (_voiceObj) {
            _voiceObj = null;
        }
        if (_channel) {
            _channel.stop();
            _channel = null;
        }
    }

    /**
     * 记下这个编号的声音类数组。同一编号后来的覆盖先前的。
     *
     * @param id 语音编号。
     * @param sounds 声音类。可以是 <code>null</code>。
     * @example
     * <listing version="3.0">
     * voice.setVoice(FighterVoice.HURT, sounds);
     * </listing>
     */
    public function setVoice(id:int, sounds:Array):void {
        _voiceObj[id] = sounds;
    }

    /**
     * 按编号播一条。没有这个编号，或数组是空的，则什么都不播。
     *
     * @param id 语音编号。
     * @param rate 播放概率，0 到 1。默认 1。
     * @example
     * <listing version="3.0">
     * voice.playVoice(FighterVoice.DIE, 1);
     * </listing>
     */
    public function playVoice(id:int, rate:Number = 1):void {

        if (_channel && _channel.position < _curLength) {
            return;
        }
        if (Math.random() > rate) {
            return;
        }

        var sounds:Array = _voiceObj[id];
        if (sounds && sounds.length > 0) {
            var snd:Class = sounds.length > 1 ? KyoRandom.getRandomInArray(sounds) : sounds[0];

            if (snd) {
                var sound:Sound = new snd();
                _curLength      = sound.length;
                _channel        = sound.play(0, 0, _soundTransform);
            }

        }
    }

}
}
