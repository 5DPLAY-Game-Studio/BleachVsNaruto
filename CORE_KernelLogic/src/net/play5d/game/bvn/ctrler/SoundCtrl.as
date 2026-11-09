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

/**
 * 音效和战斗背景音乐。
 *
 * <p>无双闯关里，距上次真正播出去的声音不足 20 毫秒时，特效、随机、文件和 SWC 声音会被丢掉。
 * <code>playAssetSound</code> 不看这个间隔。暂停中调用 <code>BGM</code> 只记下待播的一首，恢复时再播，不再恢复原来那首。
 * <code>playFighterBGM</code> 找到并切过去时返回 <code>false</code>，没有这首时返回 <code>true</code>。</p>
 *
 * @see AssetManager
 */
public class SoundCtrl {

    /** @private */
    private static var _i:SoundCtrl;

    /**
     * 唯一实例。第一次读取时创建。
     *
     * @return 声音控制。
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.sndSelect();
     * </listing>
     */
    public static function get I():SoundCtrl {
        _i ||= new SoundCtrl();
        return _i;
    }

    /** @private */
    private var _bgSound:KyoBGSounder;
    /** @private */
    private var _soundLoader:KyoSoundLoader;
    /** @private */
    private var _bgmObj:Object;
    /** @private */
    private var _bgmPaused:Boolean           = false;
    /** @private */
    private var _waitingSound:Object;
    /** @private */
    private var _sndTransform:SoundTransform = new SoundTransform();
    /** @private */
    private var _lastSndTime:int;
    /** @private SWC 声音类 -&gt; 复用实例，避免每次 new */
    private var _swcSoundCache:Dictionary;
    /** @private effect.swf 声音类名 -&gt; 复用实例 */
    private var _effectSoundCache:Dictionary;
    /** @private 静音预热用 */
    private var _silentTransform:SoundTransform;

    /**
     * 设置之后播放的音效音量。
     *
     * <p>已经在播的声音不会改。</p>
     *
     * @param v 音量。
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.setSoundVolume(0.5);
     * </listing>
     */
    public function setSoundVolume(v:Number):void {
        _sndTransform.volume = v;
    }

    /**
     * 设置背景音乐音量。还没有播放器时会先建一个。
     *
     * @param v 音量。
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.setBgmVolume(0.5);
     * </listing>
     */
    public function setBgmVolume(v:Number):void {
        if (!_bgSound) {
            _bgSound = new KyoBGSounder();
        }
        _bgSound.volume = v;
    }

    /**
     * 播放基础资源里的音效。
     *
     * <p>名字为空或资源里没有时直接返回。不看无双的 20 毫秒间隔。<code>vol</code> 不是 1 时再乘上当前音效音量。</p>
     *
     * @param name 资源名。
     * @param vol 相对音量。默认 1。
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.playAssetSound('snd_hit');
     * </listing>
     */
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

    /**
     * 播放 effect 包里的音效，并缓存实例。
     *
     * <p>无双里距上次播放不足 20 毫秒时丢掉。类不存在时会抛错。</p>
     *
     * @param name 声音类名。
     * @param vol 相对音量。默认 1。
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.playEffectSound('snd_kan1');
     * </listing>
     */
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

    /**
     * 从给出的资源名里随机播一个。
     *
     * <p>无双里距上次播放不足 20 毫秒时整次丢掉，不会抽名字。</p>
     *
     * @param params 资源名。
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.playAssetSoundRandom('snd_a', 'snd_b');
     * </listing>
     */
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

    /**
     * 切换背景音乐。
     *
     * <p>和当前是同一份对象时不重播。暂停中只把这首记下来，恢复时播放，原来那首不再继续。
     * 传入 <code>null</code> 且当前正在播时会停掉。</p>
     *
     * @param sound 声音或其它 <code>KyoBGSounder</code> 接受的对象。
     * @param loop 是否循环。默认 <code>true</code>。
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.BGM(sound);
     * </listing>
     */
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

    /**
     * 暂停背景音乐。已经暂停时直接返回。
     *
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.pauseBGM();
     * </listing>
     */
    public function pauseBGM():void {
        if (_bgmPaused) {
            return;
        }
        _bgmPaused = true;
        if (_bgSound) {
            _bgSound.pause();
        }
    }

    /**
     * 恢复背景音乐。
     *
     * <p>暂停期间记下了新曲子时改播那首，不再恢复原来的进度。</p>
     *
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.resumeBGM();
     * </listing>
     */
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
     * 按列表加载战斗背景音乐，并换掉上一批记录。
     *
     * <p>某一首失败时跳过，继续下一首。进度回调收到的是当前这一首自己的进度，不是整批比例。
     * 列表为空时仍会建加载器，并立刻调用成功回调。</p>
     *
     * @param arr 曲目。id 为 <code>map</code> 时表示场景曲。
     * @param success 全部尝试结束后的回调，含跳过失败的情况。
     * @param fail 未使用。可省略。
     * @param progress 单首进度，范围 0 到 1。可省略。
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.loadFightBGM(list, function ():void {});
     * </listing>
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

    /**
     * 播放火影或死神的头目曲。
     *
     * @param isNaruto 为 <code>true</code> 时播 <code>boss_naruto</code>，否则播 <code>boss_bleach</code>。
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.playBossBGM(true);
     * </listing>
     */
    public function playBossBGM(isNaruto:Boolean):void {
        playFighterBGM(isNaruto ? 'boss_naruto' : 'boss_bleach');
    }

    /**
     * 按角色 id 切战斗背景音乐。
     *
     * <p>还没加载过曲目表时会抛错。找到时切过去并返回 <code>false</code>；没有这首时返回 <code>true</code>，当前音乐不动。</p>
     *
     * @param id 曲目 id。
     * @return 没有这首时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var missing:Boolean = SoundCtrl.I.playFighterBGM(id);
     * </listing>
     */
    public function playFighterBGM(id:String):Boolean {
        var o:Object = _bgmObj[id];
        if (!o) {
            return true;
        }

        var sound:Sound = _soundLoader.getSound(o.url);
        BGM(sound);

        return false;
    }

    /**
     * 按权重决定播角色曲还是地图曲。
     *
     * <p>id 不是 <code>map</code> 且没有这首，或随机数大于 <code>rate</code> 时，改播 <code>map</code>。
     * 地图曲也不存在时直接返回。曲目表还没加载时会抛错。</p>
     *
     * @param id 角色 id 或 <code>map</code>。
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.smartPlayGameBGM(fighterId);
     * </listing>
     */
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

    /**
     * 停掉战斗背景音乐并卸载已加载的曲目。
     *
     * <p>正在暂停时，这次停播只会记成待播的空值，当前声音要等恢复时才停。</p>
     *
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.unloadFightBGM();
     * </listing>
     */
    public function unloadFightBGM():void {
        BGM(null);
        if (_soundLoader) {
            _soundLoader.unload();
            _soundLoader = null;
        }
    }

    /**
     * 播放菜单选择音 <code>snd_menu1</code>。
     *
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.sndSelect();
     * </listing>
     */
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

    /**
     * 播放菜单确认音 <code>snd_menu2</code>。
     *
     * @example
     * <listing version="3.0">
     * SoundCtrl.I.sndConfirm();
     * </listing>
     */
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
