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
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import net.play5d.game.bvn.data.vos.BgmVO;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.kyo.loader.KyoSoundLoader;
import net.play5d.kyo.sound.KyoBGSounder;
import net.play5d.kyo.utils.KyoRandom;

public class SoundCtrl {

    private static var _i:SoundCtrl;

    public static function get I():SoundCtrl {
        _i ||= new SoundCtrl();
        return _i;
    }

    private var _bgSound:KyoBGSounder;
    private var _soundLoader:KyoSoundLoader;
    private var _bgmObj:Object;
    private var _bgmPaused:Boolean           = false;
    private var _waitingSound:Object;
    private var _sndTransform:SoundTransform = new SoundTransform();
    private var _lastSndTime:int;
    /** @private SWC 声音类 -&gt; 复用实例，避免每次 new */
    private var _swcSoundCache:Dictionary;
    /** @private effect.swf 声音类名 -&gt; 复用实例 */
    private var _effectSoundCache:Dictionary;
    /** @private 静音预热用 */
    private var _silentTransform:SoundTransform;

    public function setSoundVolume(v:Number):void {
        _sndTransform.volume = v;
    }

    public function setBgmVolume(v:Number):void {
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

        var sound:Sound = getCachedEffectSound(name);
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

    /**
     * 播放 <code>assets/sounds</code> 中的音效。
     *
     * <p>文件名为类名加 <code>.mp3</code>。已缓存则立即播放；
     * 尚未载入时先加载再播，供语言页在基础资源预载之前使用。</p>
     *
     * @param name 文件名（不含后缀），如 <code>snd_menu1</code>。
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.playSoundFile('snd_menu1');
     * </listing>
     */
    public function playSoundFile(name:String):void {
        if (name == null) {
            return;
        }

        var sound:Sound = AssetManager.I.getSound(name);
        if (sound) {
            playSound(sound);
            return;
        }

        AssetManager.I.loadCachedSound('sounds/' + name + '.mp3', function (snd:Sound):void {
            playSound(snd);
        });
    }

    /**
     * 播放声音（类链接）
     *
     * @param sndCls 声音类链接
     */
    public function playSwcSound(sndCls:Class):void {
        if (!sndCls) {
            return;
        }

        playSound(getCachedSwcSound(sndCls));
    }

    /**
     * 播放声音
     *
     * @param snd 声音实例
     */
    public function playSound(snd:Sound):void {
        if (!snd) {
            return;
        }

        if (keepSoundNoise()) {
            return;
        }

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
     * @param progress
     *
     */
    public function loadFightBGM(arr:Vector.<BgmVO>, success:Function, fail:Function = null,
                                 progress:Function                                    = null
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
            AssetManager.I.loadSound(curUrl, loadBack, loadFail, loadProgress);
        }

        function loadBack(snd:Sound):void {
            _soundLoader.addSound(curUrl, snd);
            loadNext();
        }

        function loadFail():void {
            TraceLang('sound_ctrl.load_fight_bgm_fail', {url: curUrl});
            loadNext();
        }

        function loadProgress(v:Number):void {
            if (progress != null) {
                var cur:Number = sndLen - urls.length - 1 + v;
                var p:Number   = cur / sndLen;
                progress(v);
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
        playSoundFile('snd_menu1');
    }

    /**
     * 预加载菜单选择 / 确认音，并做一次静音播放。
     *
     * <p>语言页阶段基础资源尚未预载，本方法自行载入
     * <code>snd_menu1.mp3</code> 与 <code>snd_menu2.mp3</code>。</p>
     *
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.warmMenuSounds();
     * </listing>
     */
    public function warmMenuSounds():void {
        warmSoundFile('snd_menu1');
        warmSoundFile('snd_menu2');
    }

    /**
     * 预加载常用界面音效，并做一次静音播放。
     *
     * <p>含菜单、胜负 / KO、幽步等。应在 <code>loadBasic</code> 之后调用。</p>
     *
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.warmCommonSounds();
     * </listing>
     */
    public function warmCommonSounds():void {
        warmMenuSounds();
        warmSoundFile('snd_menu5');
        warmSoundFile('snd_gameover');
        warmSoundFile('snd_over_hit');
        warmSoundFile('snd_ko');
        warmSoundFile('snd_ko_bs');
        warmSoundFile('snd_ghost_jump');
        warmSoundFile('snd_ghost_jump2');
        warmSoundFile('snd_ghost_dash');
    }

    /**
     * 预实例化 effect.swf 中的一个声音类，并做一次静音播放。
     *
     * <p>同一类名只保留一份 <code>Sound</code>。重复调用直接命中缓存。</p>
     *
     * @param name 声音类名，如 <code>snd_kan1</code>。
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.warmEffectSound('snd_kan1');
     * </listing>
     */
    public function warmEffectSound(name:String):void {
        if (!name) {
            return;
        }
        try {
            silentPlay(getCachedEffectSound(name));
        }
        catch (e:Error) {
        }
    }

    /**
     * 预实例化单个 SWC 声音类并做一次静音播放，打通解码 / 混音路径。
     *
     * @param sndCls 声音类链接。
     */
    public function warmSwcSound(sndCls:Class):void {
        if (!sndCls) {
            return;
        }
        try {
            silentPlay(getCachedSwcSound(sndCls));
        }
        catch (e:Error) {
        }
    }

    /**
     * @private 载入 <code>assets/sounds</code> 中的音效并静音播放一次。
     */
    private function warmSoundFile(name:String):void {
        AssetManager.I.loadCachedSound('sounds/' + name + '.mp3', function (snd:Sound):void {
            silentPlay(snd);
        });
    }

    /**
     * @private 静音播放一次，打通解码 / 混音路径。
     */
    private function silentPlay(snd:Sound):void {
        if (!snd) {
            return;
        }
        try {
            if (!_silentTransform) {
                _silentTransform = new SoundTransform(0);
            }
            var ch:SoundChannel = snd.play(0, 0, _silentTransform);
            if (ch) {
                ch.stop();
            }
        }
        catch (e:Error) {
        }
    }

    /**
     * @private 取得或创建并缓存 effect.swf 声音。类缺失时与原先一样抛错。
     */
    private function getCachedEffectSound(name:String):Sound {
        _effectSoundCache ||= new Dictionary();
        var snd:Sound = _effectSoundCache[name] as Sound;
        if (!snd) {
            snd = AssetManager.I.getEffect(name) as Sound;
            if (snd) {
                _effectSoundCache[name] = snd;
            }
        }
        return snd;
    }

    /**
     * @private 取得或创建并缓存 SWC 声音实例。
     */
    private function getCachedSwcSound(sndCls:Class):Sound {
        _swcSoundCache ||= new Dictionary();
        var snd:Sound = _swcSoundCache[sndCls] as Sound;
        if (!snd) {
            snd                     = new sndCls() as Sound;
            _swcSoundCache[sndCls]  = snd;
        }
        return snd;
    }

    //确定音效
    public function sndConfirm():void {
        playSoundFile('snd_menu2');
    }

    /**
     * 保持声音噪音
     * @return 是否保持声音噪音
     */
    private function keepSoundNoise():Boolean {
        if (GameMode.currentMode != GameMode.MUSOU_ARCADE) {
            return false;
        }

        return getTimer() - _lastSndTime < 20;
    }

}
}
