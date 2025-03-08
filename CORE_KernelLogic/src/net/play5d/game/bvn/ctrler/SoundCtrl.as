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

package net.play5d.game.bvn.ctrler {
import flash.media.Sound;
import flash.media.SoundTransform;
import flash.utils.getTimer;

import net.play5d.game.bvn.data.vos.BgmVO;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.kyo.loader.KyoSoundLoader;
import net.play5d.kyo.sound.KyoBGSounder;
import net.play5d.kyo.utils.KyoRandom;

public class SoundCtrl {
    include '../../../../../../include/_INCLUDE_.as';

    private static var _i:SoundCtrl;

    public static function get I():SoundCtrl {
        _i ||= new SoundCtrl();
        return _i;
    }

    public function SoundCtrl() {
    }
    private var _bgSound:KyoBGSounder;
    private var _soundLoader:KyoSoundLoader;
    private var _bgmObj:Object;
    private var _bgmPaused:Boolean           = false;
    private var _waitingSound:Object;
    private var _sndTransform:SoundTransform = new SoundTransform();
    private var _lastSndTime:int;

    public function setSoundVolumn(v:Number):void {
        _sndTransform.volume = v;
    }

    public function setBgmVolumn(v:Number):void {
        if (!_bgSound) {
            _bgSound = new KyoBGSounder();
        }
        _bgSound.volume = v;
    }

    public function playAssetSound(name:String, vol:Number = 1):void {

        if (name == null) {
            return;
        }

        var sound:Sound = AssetManager.I.getSound(name);
        if (sound) {
            var st:SoundTransform = _sndTransform;
            if (vol != 1) {
                st = new SoundTransform(vol * _sndTransform.volume);
            }

            sound.play(0, 0, st);
            _lastSndTime = getTimer();
        }
    }

    public function playEffectSound(name:String, vol:Number = 1):void {
        if (name == null) {
            return;
        }
        if (keepSoundNoise()) {
            return;
        }

        var sound:Sound = AssetManager.I.getEffect(name);
        if (sound) {
            var st:SoundTransform = _sndTransform;
            if (vol != 1) {
                st = new SoundTransform(vol * _sndTransform.volume);
            }
            sound.play(0, 0, st);
            _lastSndTime = getTimer();
        }
    }

    public function playAssetSoundRandom(...params):void {
        if (keepSoundNoise()) {
            return;
        }
        var name:String = KyoRandom.getRandomInArray(params);
        playAssetSound(name);
    }

    public function playSwcSound(sc:Class):void {
        if (keepSoundNoise()) {
            return;
        }
        var snd:Sound = new sc();
        snd.play(0, 0, _sndTransform);
        _lastSndTime = getTimer();
    }

    public function BGM(sound:Object, loop:Boolean = true):void {

        if (_bgmPaused) {
            _waitingSound = sound;
            return;
        }

        if (!_bgSound) {
            _bgSound = new KyoBGSounder();
        }

        if (_bgSound.sound == sound) {
            return;
        }
        if (_bgSound.playing) {
            _bgSound.stop();
        }

        if (sound) {
            _bgSound.play(sound, loop);
        }
    }

    public function pauseBGM():void {
        if (_bgmPaused) {
            return;
        }
        _bgmPaused = true;
        if (_bgSound) {
            _bgSound.pause();
        }
    }

    public function resumeBGM():void {
        if (!_bgmPaused) {
            return;
        }
        _bgmPaused = false;

        if (_waitingSound) {
            BGM(_waitingSound);
            _waitingSound = null;
            return;
        }

        if (_bgSound) {
            _bgSound.resume();
        }
    }

    /**
     * 加载战斗BGM
     * @param arr {id:Object,url:String,rate:Number(0-1)} , 如果是场景ID，ID值为'map'
     * @param success
     * @param fail
     * @param process
     *
     */
    public function loadFightBGM(arr:Vector.<BgmVO>, success:Function, fail:Function = null,
                                 process:Function                                    = null
    ):void {
        _bgmObj        = {};
        var urls:Array = [];
        for each(var o:Object in arr) {
            _bgmObj[o.id] = o;
            urls.push(o.url);
        }

        _soundLoader   = new KyoSoundLoader();
        var curUrl:String;
        var sndLen:int = urls.length;

        loadNext();

        function loadNext():void {
            if (urls.length < 1) {
                if (success != null) {
                    success();
                }
                return;
            }
            curUrl = urls.shift();
            AssetManager.I.loadSound(curUrl, loadBack, loadFail, loadProcess);
        }

        function loadBack(snd:Sound):void {
            _soundLoader.addSound(curUrl, snd);
            loadNext();
        }

        function loadFail():void {
            TraceLang('debug.trace.data.sound_ctrl.load_fight_bgm_fail', curUrl);
            loadNext();
        }

        function loadProcess(v:Number):void {
            if (process != null) {
                var cur:Number = sndLen - urls.length - 1 + v;
                var p:Number   = cur / sndLen;
                process(v);
            }
        }

    }

    public function playBossBGM(isNaruto:Boolean):void {
        playFighterBGM(isNaruto ? 'boss_naruto' : 'boss_bleach');
    }

    public function playFighterBGM(id:String):Boolean {
        var o:Object = _bgmObj[id];
        if (!o) {
            return true;
        }

        var sound:Sound = _soundLoader.getSound(o.url);
        BGM(sound);

        return false;
    }

    public function smartPlayGameBGM(id:String):void {

        var o:Object = _bgmObj[id];

        if (id == 'map') {
            if (o == null) {
                return;
            }
        }
        else {
            if (o == null) {
                smartPlayGameBGM('map');
                return;
            }
            if (Math.random() > Number(o.rate)) {
                smartPlayGameBGM('map');
                return;
            }
        }

        var sound:Sound = _soundLoader.getSound(o.url);
        BGM(sound);
    }

    public function unloadFightBGM():void {
        BGM(null);
        if (_soundLoader) {
            _soundLoader.unload();
            _soundLoader = null;
        }
    }

    //选择音效
    public function sndSelect():void {
        playSwcSound(snd_menu1);
    }

    //确定音效
    public function sndConfrim():void {
        playSwcSound(snd_menu2);
    }

    /**
     * 保持声音噪音
     * @return 是否保持声音噪音
     */
    private function keepSoundNoise():Boolean {
        if (GameMode.currentMode != GameMode.MOSOU_ACRADE) {
            return false;
        }

        return getTimer() - _lastSndTime < 20;
    }

}
}
