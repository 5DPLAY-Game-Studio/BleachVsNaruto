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
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.geom.Point;
import flash.media.Sound;

import net.play5d.game.bvn.data.AssisterModel;
import net.play5d.game.bvn.data.FighterModel;
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.data.MapModel;
import net.play5d.game.bvn.data.vos.MapVO;
import net.play5d.game.bvn.interfaces.IAssetLoader;
import net.play5d.game.bvn.utils.BitmapAssetLoader;
import net.play5d.game.bvn.utils.GameLogger;
import net.play5d.kyo.display.bitmap.BitmapFont;
import net.play5d.kyo.display.bitmap.BitmapFontLoader;
import net.play5d.kyo.loader.KyoClassLoader;
import net.play5d.kyo.loader.KyoSoundLoader;
import net.play5d.kyo.utils.KyoArrayUtils;

/**
 * 字体、特效类、声音、头像和加载器入口。
 *
 * <p>头像和地图图取到的是缓存里的同一张位图，改宽高会留到下一次。
 * <code>getEffect</code> 在类不存在时抛错。加载器还没设置时，加载和卸载会抛错。
 * <code>loadCachedSound</code> 对空地址直接返回，失败回调也不会走；同一路径同时加载时，失败只调用最先那一次的失败回调。</p>
 *
 * @see IAssetLoader
 */
public class AssetManager {

    /** @private */
    private const _effectSwfPath:String = 'effect.swf';
    /** @private */
    private static var _i:AssetManager;

    /**
     * 唯一实例。第一次读取时创建。
     *
     * @return 资源管理。
     * @example
     * <listing version="3.0">
     * var font:BitmapFont = AssetManager.I.getFont(id);
     * </listing>
     */
    public static function get I():AssetManager {
        _i ||= new AssetManager();
        return _i;
    }

    /** @private */
    private var _swfLoader:KyoClassLoader          = new KyoClassLoader();
    /** @private */
    private var _soundLoader:KyoSoundLoader        = new KyoSoundLoader();
    /** @private */
    private var _bitmapLoader:BitmapAssetLoader    = new BitmapAssetLoader();
    /** @private */
    private var _bitmapFontLoader:BitmapFontLoader = new BitmapFontLoader();
    /** @private */
    private var _assetLoader:IAssetLoader          = null;
    /** @private 同一路径的声音尚未载入完成时，排队成功回调 */
    private var _soundWait:Object;

    /**
     * 空方法。
     */
    public function init():void {
    }

    /**
     * 按 id 取已加载的位图字体。
     *
     * @param id 字体 id。
     * @return 字体；没有这个 id 时为 <code>undefined</code>。
     * @example
     * <listing version="3.0">
     * var font:BitmapFont = AssetManager.I.getFont(id);
     * </listing>
     */
    public function getFont(id:String):BitmapFont {
        return _bitmapFontLoader.getFont(id);
    }

    /**
     * 换上实际的资源加载器。
     *
     * <p>传 <code>null</code> 之后，加载和卸载会抛错。</p>
     *
     * @param v 加载器。
     * @example
     * <listing version="3.0">
     * AssetManager.I.setAssetLoader(loader);
     * </listing>
     */
    public function setAssetLoader(v:IAssetLoader):void {
        _assetLoader = v;
    }

    /**
     * 按声音、特效、字体、位图的顺序加载基础资源。
     *
     * <p>进度回调是 <code>progress(进度, 文案, 当前步, 4)</code>。进度大于 1 时收成 1。
     * 收尾之后迟到的进度不再上报。</p>
     *
     * @param back 四步都结束后的回调。
     * @param progress 进度回调。可省略。
     * @example
     * <listing version="3.0">
     * AssetManager.I.loadBasic(function ():void {});
     * </listing>
     */
    public function loadBasic(back:Function, progress:Function = null):void {
        var loadStep:int     = 0;
        var loadCount:int    = 4;
        var reportStep:int   = 0;
        var type:String;
        var finished:Boolean = false;

        function loadProgress(p:Number):void {
            // 收尾阶段 loadStep 会变为 5；滞后 PROGRESS 不得再上报成 (5/4)
            if (finished || reportStep < 1 || reportStep > loadCount) {
                return;
            }
            if (progress != null) {
                if (p > 1) {
                    p = 1;
                }
                progress(p, type, reportStep, loadCount);
            }
        }

        function loadNext():void {
            if (finished) {
                return;
            }

            loadStep++;

            if (loadStep > loadCount) {
                finished   = true;
                reportStep = 0;
                initAssets();
                if (back != null) {
                    back();
                }

                return;
            }

            reportStep = loadStep;

            switch (loadStep) {
            case 1:
                type = GetLang('loading.sound');
                loadProgress(0);
                loadPreLoadSounds(loadNext, loadProgress);
                break;
            case 2:
                type = GetLang('loading.effect');
                loadProgress(0);
                loadGraphics([_effectSwfPath], loadNext, loadProgress);
                break;
            case 3:
                type = GetLang('loading.font');
                loadProgress(0);
                loadFonts(loadNext, loadProgress);
                break;
            case 4:
                type = GetLang('loading.bitmap');
                loadProgress(0);
                loadBitmaps(loadNext, loadProgress);
                break;
            }
        }

        loadNext();
    }

    /**
     * 从已加载的 SWF 里取类。
     *
     * <p>这份 SWF 还没加载，或里面没有这个类时抛错。</p>
     *
     * @param className 类名。
     * @param swfPath SWF 路径。
     * @return 类。
     * @example
     * <listing version="3.0">
     * var cls:Class = AssetManager.I.getClass('main_mc', 'effect.swf');
     * </listing>
     */
    public function getClass(className:String, swfPath:String):Class {
        var cls:Class = _swfLoader.getClass(className, swfPath);
        return cls;
    }

    /**
     * 用 <code>effect.swf</code> 里的类新建一个实例。
     *
     * <p>类不存在时抛错。</p>
     *
     * @param className 类名。
     * @return 新实例。
     * @example
     * <listing version="3.0">
     * var fx:* = AssetManager.I.getEffect('hit_fx');
     * </listing>
     */
    public function getEffect(className:String):* {
        var cls:Class = _swfLoader.getClass(className, _effectSwfPath);
        return new cls();
    }

    /**
     * 按名字取已缓存的声音。
     *
     * @param name 声音名或路径，跟写入缓存时用的键一致。
     * @return 声音；没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var snd:Sound = AssetManager.I.getSound(name);
     * </listing>
     */
    public function getSound(name:String):Sound {
        return _soundLoader.getSound(name);
    }

    /**
     * 加载声音并写入缓存。
     *
     * <p>已缓存则立即回调。同一路径并发只发起一次请求，其余回调排队。</p>
     *
     * @param url 相对 <code>assets/</code> 的路径，如 <code>sounds/snd_menu1.mp3</code>。
     * @param back 成功回调，签名为 <code>function(sound:Sound):void</code>；可为 <code>null</code>。
     * @param fail 失败回调，签名为 <code>function():void</code>；可为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * AssetManager.I.loadCachedSound('sounds/snd_menu1.mp3', onSound);
     * </listing>
     */
    public function loadCachedSound(url:String, back:Function = null, fail:Function = null):void {
        if (!url) {
            return;
        }

        var cached:Sound = _soundLoader.getSound(url);
        if (cached) {
            if (back != null) {
                back(cached);
            }
            return;
        }

        _soundWait ||= {};
        var wait:Array = _soundWait[url];
        if (wait) {
            if (back != null) {
                wait.push(back);
            }
            return;
        }

        wait = [];
        if (back != null) {
            wait.push(back);
        }
        _soundWait[url] = wait;

        if (!_assetLoader) {
            delete _soundWait[url];
            if (fail != null) {
                fail();
            }
            return;
        }

        _assetLoader.loadSound(url, onSound, onFail, null);

        function onSound(snd:Sound):void {
            _soundLoader.addSound(url, snd);
            var cbs:Array = _soundWait[url];
            delete _soundWait[url];
            if (!cbs) {
                return;
            }
            for each (var cb:Function in cbs) {
                cb(snd);
            }
        }

        function onFail():void {
            delete _soundWait[url];
            if (fail != null) {
                fail();
            }
        }
    }

    /**
     * 取角色小头像，默认 50×50。
     *
     * <p>改的是缓存里的同一张图。没有图或 <code>fv</code> 为空时，前者返回 <code>null</code>，后者抛错。</p>
     *
     * @param fv 角色数据。
     * @param size 目标宽高。省略时为 50×50。
     * @return 位图；没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var face:DisplayObject = AssetManager.I.getFighterFace(fv);
     * </listing>
     */
    public function getFighterFace(fv:FighterVO, size:Point = null):DisplayObject {
        var bp:Bitmap = _bitmapLoader.getBitmap(fv.faceUrl);
        if (!bp) {
            return null;
        }

        size ||= new Point(50, 50);

        bp.width  = size.x;
        bp.height = size.y;

        return bp;
    }

    /**
     * 取角色大头像，默认 245×62。
     *
     * <p>改的是缓存里的同一张图。<code>fv</code> 为空时抛错。</p>
     *
     * @param fv 角色数据。
     * @param size 目标宽高。省略时为 245×62。
     * @return 位图；没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var face:DisplayObject = AssetManager.I.getFighterFaceBig(fv);
     * </listing>
     */
    public function getFighterFaceBig(fv:FighterVO, size:Point = null):DisplayObject {
        var bp:Bitmap = _bitmapLoader.getBitmap(fv.faceBigUrl);
        if (!bp) {
            return null;
        }

        size ||= new Point(245, 62);

        bp.width  = size.x;
        bp.height = size.y;

        return bp;
    }

    /**
     * 取角色血条头像，默认 102×64。
     *
     * <p>改的是缓存里的同一张图。<code>fv</code> 为空时抛错。</p>
     *
     * @param fv 角色数据。
     * @param size 目标宽高。省略时为 102×64。
     * @return 位图；没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var face:DisplayObject = AssetManager.I.getFighterFaceBar(fv);
     * </listing>
     */
    public function getFighterFaceBar(fv:FighterVO, size:Point = null):DisplayObject {
        var bp:Bitmap = _bitmapLoader.getBitmap(fv.faceBarUrl);
        if (!bp) {
            return null;
        }

        size ||= new Point(102, 64);

        bp.width  = size.x;
        bp.height = size.y;

        return bp;
    }

    /**
     * 取角色胜利图，默认 300×250。
     *
     * <p>数据或地址为空时返回 <code>null</code>。改的是缓存里的同一张图。</p>
     *
     * @param fv 角色数据。
     * @param size 目标宽高。省略时为 300×250。
     * @return 位图；没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var face:DisplayObject = AssetManager.I.getFighterFaceWin(fv);
     * </listing>
     */
    public function getFighterFaceWin(fv:FighterVO, size:Point = null):DisplayObject {
        if (!fv) {
            return null;
        }
        if (!fv.faceWinUrl) {
            return null;
        }
        var bp:Bitmap = _bitmapLoader.getBitmap(fv.faceWinUrl);
        if (!bp) {
            return null;
        }

        size ||= new Point(300, 250);

        bp.width  = size.x;
        bp.height = size.y;

        return bp;
    }

    /**
     * 取地图预览图，默认 450×240。
     *
     * <p>改的是缓存里的同一张图。<code>mv</code> 为空时抛错。</p>
     *
     * @param mv 地图数据。
     * @param size 目标宽高。省略时为 450×240。
     * @return 位图；没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var pic:DisplayObject = AssetManager.I.getMapPic(mv);
     * </listing>
     */
    public function getMapPic(mv:MapVO, size:Point = null):DisplayObject {
        var bp:Bitmap = _bitmapLoader.getBitmap(mv.picUrl);
        if (!bp) {
            return null;
        }
        size ||= new Point(450, 240);

        bp.width  = size.x;
        bp.height = size.y;

        return bp;
    }

    /**
     * 把 XML 加载交给当前加载器。
     *
     * <p>加载器还没设置时抛错。</p>
     *
     * @param url 地址。
     * @param back 成功回调。
     * @param fail 失败回调。
     * @example
     * <listing version="3.0">
     * AssetManager.I.loadXML(url, onOk, onFail);
     * </listing>
     */
    public function loadXML(url:String, back:Function, fail:Function):void {
        _assetLoader.loadXML(url, back, fail);
    }

    /**
     * 把 JSON 加载交给当前加载器。
     *
     * <p>加载器还没设置时抛错。</p>
     *
     * @param url 地址。
     * @param back 成功回调。
     * @param fail 失败回调。
     * @example
     * <listing version="3.0">
     * AssetManager.I.loadJSON(url, onOk, onFail);
     * </listing>
     */
    public function loadJSON(url:String, back:Function, fail:Function):void {
        _assetLoader.loadJSON(url, back, fail);
    }

    /**
     * 把 SWF 加载交给当前加载器。
     *
     * <p>加载器还没设置时抛错。</p>
     *
     * @param url 地址。
     * @param back 成功回调。
     * @param fail 失败回调。可省略。
     * @param progress 进度回调。可省略。
     * @example
     * <listing version="3.0">
     * AssetManager.I.loadSWF(url, onOk);
     * </listing>
     */
    public function loadSWF(url:String, back:Function, fail:Function = null, progress:Function = null):void {
        _assetLoader.loadSwf(url, back, fail, progress);
    }

    /**
     * 把声音加载交给当前加载器。不写入本类的声音缓存。
     *
     * <p>加载器还没设置时抛错。</p>
     *
     * @param url 地址。
     * @param back 成功回调。
     * @param fail 失败回调。可省略。
     * @param progress 进度回调。可省略。
     * @example
     * <listing version="3.0">
     * AssetManager.I.loadSound(url, onOk);
     * </listing>
     */
    public function loadSound(url:String, back:Function, fail:Function = null, progress:Function = null):void {
        _assetLoader.loadSound(url, back, fail, progress);
    }

    /**
     * 把位图加载交给当前加载器。
     *
     * <p>加载器还没设置时抛错。</p>
     *
     * @param url 地址。
     * @param back 成功回调。
     * @param fail 失败回调。可省略。
     * @param progress 进度回调。可省略。
     * @example
     * <listing version="3.0">
     * AssetManager.I.loadBitmap(url, onOk);
     * </listing>
     */
    public function loadBitmap(url:String, back:Function, fail:Function = null, progress:Function = null):void {
        _assetLoader.loadBitmap(url, back, fail, progress);
    }

    /**
     * 按地址卸载一份资源。
     *
     * <p>加载器还没设置时抛错。</p>
     *
     * @param url 地址。
     * @example
     * <listing version="3.0">
     * AssetManager.I.disposeAsset(url);
     * </listing>
     */
    public function disposeAsset(url:String):void {
        _assetLoader.dispose(url);
    }

    /**
     * 按序加载 SWF 并登记到类加载器。
     * @param loadarray URL 数组（相对 assets 路径）。
     * @param back 全部成功回调；可省略。
     * @param progress 单项进度回调；可省略。
     * @param fail 单项最终失败回调（参数为失败 URL）；传入则失败后中止且不调 <code>back</code>；省略则跳过失败项继续（如 effect.swf）。
     */
    public function loadSWFs(
            loadarray:Array, back:Function = null, progress:Function = null, fail:Function = null
    ):void {
        loadGraphics(loadarray, back, progress, fail);
    }

    /**
     * 当前加载器是否还有预加载。
     *
     * <p>加载器还没设置时抛错。</p>
     *
     * @return 需要预加载时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var need:Boolean = AssetManager.I.needPreLoad();
     * </listing>
     */
    public function needPreLoad():Boolean {
        return _assetLoader.needPreLoad();
    }

    /**
     * 把预加载交给当前加载器。
     *
     * <p>加载器还没设置时抛错。</p>
     *
     * @param back 成功回调。
     * @param fail 失败回调。可省略。
     * @param progress 进度回调。可省略。
     * @example
     * <listing version="3.0">
     * AssetManager.I.loadPreLoad(function ():void {});
     * </listing>
     */
    public function loadPreLoad(back:Function, fail:Function = null, progress:Function = null):void {
        _assetLoader.loadPreLoad(back, fail, progress);
    }

    private function loadPreLoadSounds(back:Function, progress:Function):void {

        _assetLoader.loadJSON('config/preload.json', function (obj:Object):void {
            var sounds:Array = [];

            var bgmObj:Object   = obj['bgm'];
            var soundObj:Object = obj['sound'];

            for each(var bgm:String in bgmObj['item']) {
                sounds.push(bgmObj['path'] + bgm);
            }
            for each(var sound:String in soundObj['item']) {
                sounds.push(soundObj['path'] + sound);
            }

            loadSnds(sounds, back, progress);
        });
    }

    private function loadSnds(sounds:Array, back:Function, progress:Function):void {
        var snds:Array = sounds.concat();
        var sndLen:int = snds.length;
        var curUrl:String;

        loadNext();

        function loadNext():void {

            if (snds.length < 1) {
                if (back != null) {
                    back();
                }
                return;
            }

            curUrl = snds.shift();
            if (_soundLoader.getSound(curUrl)) {
                loadNext();
                return;
            }
            _assetLoader.loadSound(curUrl, loadCom, loadErr, loadProgress);
        }

        function loadCom(snd:Sound):void {
            _soundLoader.addSound(curUrl, snd);
            _assetLoader.dispose(curUrl);
            loadNext();
        }

        function loadErr():void {
            TraceLang('asset_manager.load_sound_fail', {url: curUrl});
            loadNext();
        }

        function loadProgress(v:Number):void {
            if (progress != null) {
                var cur:Number = sndLen - snds.length - 1 + v;
                var p:Number   = cur / sndLen;
                progress(p);
            }
        }

    }

    private function initAssets():void {
        applyFont1Metrics();

        // 基础资源就绪后统一预热，避免进入菜单 / 对战后首次交互卡顿
        WarmupCtrl.I.warmBasic();
    }

    // 每次登记 font1 都要写。只在加载收尾写一次的话，重复完成回调会换上新实例，字距回到 0。
    private function applyFont1Metrics():void {
        var font1:BitmapFont = getFont('font1');
        if (!font1) {
            return;
        }
        font1.charGap  = -8;
        font1.spaceGap = 10;
        font1.offsetY  = -5;
    }

    private function loadGraphics(
            loadarray:Array, back:Function = null, progress:Function = null, fail:Function = null
    ):void {

        var loads:Array = loadarray.concat();
        var loadedAmount:int;
        var curUrl:String;
        var curRetry:int;

        loadNext();

        function loadNext():void {
            if (loads.length < 1) {
                if (back != null) {
                    back();
                }
                return;
            }
            curUrl   = loads.shift();
            curRetry = 0;

            // 已登记则跳过，避免同 URL 重复加载（如 zh-CN / en 共用字体）
            if (_swfLoader.hasSwf(curUrl)) {
                loadedAmount++;
                loadNext();
                return;
            }

            _assetLoader.loadSwf(curUrl, loadCom, loadFail, progress);
        }

        function loadCom(loader:Loader):void {
            loadedAmount++;
            _swfLoader.addSwf(curUrl, loader);
            _assetLoader.dispose(curUrl);
            loadNext();
        }

        function loadFail():void {
            // 偶发 IO 失败时重试一次
            if (curRetry < 1) {
                curRetry++;
                GameLogger.warn('load', 'load SWF retry: ' + curUrl);
                _assetLoader.loadSwf(curUrl, loadCom, loadFail, progress);
                return;
            }

            logSwfFail(curUrl);

            // 有 fail 则中止（语言页）；无 fail 则跳过继续（effect 等）
            if (fail != null) {
                fail(curUrl);
                return;
            }
            loadNext();
        }

        function logSwfFail(url:String):void {
            // 语言页早于语言包初始化，TraceLang 会变成 [N/A][N/A]
            if (GetLangText('log.debug.trace.asset_manager.load_swf_fail') != '[N/A]') {
                TraceLang('asset_manager.load_swf_fail', {url: url});
            }
            else {
                GameLogger.error('load', 'load SWF fail: ' + url);
            }
        }

    }

    private function loadBitmaps(back:Function = null, progress:Function = null):void {

        var bps:Array = getFighterFaceUrls(FighterModel.I.getAllFighters(), true, true);
        bps           = bps.concat(getFighterFaceUrls(AssisterModel.I.getAllAssisters()));
        bps           = bps.concat(getMapPicUrls(MapModel.I.getAllMaps()));

        KyoArrayUtils.deleteDuplicates(bps);

        _bitmapLoader.loadQueue(bps, back, progress);
    }

    private function loadFonts(back:Function = null, progress:Function = null):void {

        var url:String = 'font/font1.xml';
        var fontXML:XML;
        var fontBitmapUrl:String;

        _assetLoader.loadXML(url, loadXMLCom, loadXMLFail);

        function loadXMLCom(xml:XML):void {

            fontXML = xml;

            var bpurl:String  = xml.pages.page.@file;
            var folder:String = url.substr(0, url.lastIndexOf('/') + 1);
            fontBitmapUrl     = folder + bpurl;

            _assetLoader.loadBitmap(fontBitmapUrl, bitmapCom, bitmapFail);
        }

        function bitmapCom(d:DisplayObject):void {
            var bp:Bitmap = d as Bitmap;
            if (bp && bp.bitmapData) {
                // 拷走贴图再交给字库。随后 Loader.unloadAndStop 可能释放原图。
                var atlas:BitmapData = bp.bitmapData.clone();
                _bitmapFontLoader.addFont(fontXML, atlas);
                applyFont1Metrics();
            }
            _assetLoader.dispose(fontBitmapUrl);
            if (back != null) {
                back();
            }
        }

        function bitmapFail():void {
            TraceLang('asset_manager.load_font_bitmap_fail', {url: url});
        }

        function loadXMLFail():void {
            TraceLang('asset_manager.load_font_xml_fail', {url: url});
        }
    }

    private static function getFighterFaceUrls(fighters:Object, loadBar:Boolean = false, loadWin:Boolean = false):Array {
        var ra:Array = [];
        for each(var i:FighterVO in fighters) {
            if (i.faceUrl) {
                ra.push(i.faceUrl);
            }
            if (i.faceBigUrl) {
                ra.push(i.faceBigUrl);
            }
            if (loadBar && i.faceBarUrl) {
                ra.push(i.faceBarUrl);
            }
            if (loadWin && i.faceWinUrl) {
                ra.push(i.faceWinUrl);
            }
        }
        return ra;
    }

    private static function getMapPicUrls(maps:Object):Array {
        var ra:Array = [];
        for each(var i:MapVO in maps) {
            ra.push(i.picUrl);
        }
        return ra;
    }

}
}
