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
import com.greensock.TweenLite;
import com.greensock.easing.Back;
import com.greensock.easing.Elastic;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;

import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.ui.MenuBtn;
import net.play5d.game.bvn.ui.SetBtnLine;
import net.play5d.game.bvn.ui.dialog.DialogManager;
import net.play5d.game.bvn.ui.language.CountryItem;
import net.play5d.kyo.display.bitmap.BitmapFont;
import net.play5d.kyo.display.bitmap.BitmapFontText;
import net.play5d.kyo.utils.BitmapDataPool;

/**
 * 启动与交互前的资源预热，消除首次悬停 / 点击时的卡顿。
 *
 * <p>分两阶段：<code>warmEarly</code> 在语言页可用；
 * <code>warmBasic</code> 在 <code>AssetManager.loadBasic</code> 完成后执行。</p>
 *
 * @see SoundCtrl#warmMenuSounds()
 * @see SoundCtrl#warmCommonSwcSounds()
 * @see MenuBtn#warmCommon()
 * @see SetBtnLine#warmCommon()
 * @example
 * <listing version="3.0">
 * WarmupCtrl.I.warmEarly();
 * WarmupCtrl.I.warmCountryItems(items);
 * // loadBasic 完成后：
 * WarmupCtrl.I.warmBasic();
 * </listing>
 */
public class WarmupCtrl {

    private static var _i:WarmupCtrl;

    /**
     * 单例。
     */
    public static function get I():WarmupCtrl {
        if (!_i) {
            _i = new WarmupCtrl();
        }
        return _i;
    }

    /** @private */
    private var _earlyDone:Boolean;
    /** @private */
    private var _basicDone:Boolean;
    /** @private 复用探针，避免多次分配 */
    private var _probe:Sprite;

    /**
     * 早期预热（语言页阶段）：TweenLite 引擎与菜单选择 / 确认音。
     *
     * <p>幂等；可在字体 / 基础资源尚未加载时调用。</p>
     */
    public function warmEarly():void {
        if (_earlyDone) {
            return;
        }
        _earlyDone = true;

        warmTweenEngine();
        SoundCtrl.I.warmMenuSounds();
    }

    /**
     * 预热语言列表项的选中条光栅化。
     *
     * @param items <code>CountryItem</code> 数组。
     */
    public function warmCountryItems(items:Array):void {
        if (!items) {
            return;
        }
        for each (var country:CountryItem in items) {
            if (country) {
                country.warmUp();
            }
        }
    }

    /**
     * 基础资源加载完成后的完整预热。
     *
     * <p>幂等。预热位图字体、缓动插件、常用 SWC 音、菜单 / 设置类缩放探针、
     * BGM 播放器、对话框遮罩与 <code>BitmapDataPool</code>。</p>
     */
    public function warmBasic():void {
        if (_basicDone) {
            return;
        }
        _basicDone = true;

        // 若未走过语言页，补齐引擎与菜单音
        warmEarly();

        warmTweenPlugins();
        SoundCtrl.I.warmCommonSwcSounds();
        warmBitmapFont();
        MenuBtn.warmCommon();
        SetBtnLine.warmCommon();
        warmUiScaleProbes();
        warmBgmPlayer();
        DialogManager.warmUp();
        warmBitmapDataPool();
        warmFilters();
    }

    /**
     * @private TweenLite 引擎冷启动。
     */
    private function warmTweenEngine():void {
        var probe:Sprite = getProbe();
        TweenLite.killTweensOf(probe);
        TweenLite.to(probe, 0, {alpha: probe.alpha});
        // 非零时长 scale 缓动，覆盖悬停真实路径
        probe.scaleX = 0;
        TweenLite.to(probe, 0.01, {scaleX: 1});
        probe.scaleX = 1;
    }

    /**
     * @private Back / Elastic 等缓动插件首次注册。
     */
    private function warmTweenPlugins():void {
        var probe:Sprite = getProbe();
        TweenLite.killTweensOf(probe);
        TweenLite.to(probe, 0, {scaleX: 1, ease: Back.easeOut});
        TweenLite.to(probe, 0, {alpha: 1, ease: Elastic.easeOut});
    }

    /**
     * @private 首次渲染 font1 位图字。
     */
    private function warmBitmapFont():void {
        var font:BitmapFont = AssetManager.I.getFont('font1');
        if (!font) {
            return;
        }
        var txt:BitmapFontText = new BitmapFontText(font);
        txt.text               = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        txt.width;
        txt.dispose();
    }

    /**
     * @private 模拟 MenuBtn / SetBtnLine / MenuBtnGroup 的 scale 从近 0 展开。
     */
    private function warmUiScaleProbes():void {
        var probe:Sprite = getProbe();
        TweenLite.killTweensOf(probe);

        // MenuBtn.hover / MenuBtnGroup.fadIn
        probe.scaleX = 0.01;
        TweenLite.to(probe, 0, {scaleX: 1, ease: Back.easeOut});

        // SetBtnLine.show
        probe.scaleX = 0.1;
        TweenLite.to(probe, 0, {scaleX: 1});

        // MenuBtn.select Elastic
        probe.alpha = 0;
        TweenLite.to(probe, 0, {alpha: 1, ease: Elastic.easeOut});

        probe.scaleX = 1;
        probe.alpha  = 1;
    }

    /**
     * @private 分配 KyoBGSounder，避免首次播 BGM 卡顿。
     */
    private function warmBgmPlayer():void {
        try {
            var vol:Number = GameData.I && GameData.I.config ? GameData.I.config.bgmVolume : 0.7;
            SoundCtrl.I.setBgmVolumn(vol);
        }
        catch (e:Error) {
        }
    }

    /**
     * @private 预取常用尺寸进入位图池。
     */
    private function warmBitmapDataPool():void {
        var bd:BitmapData = BitmapDataPool.I.acquire(64, 64, true, 0);
        if (bd) {
            BitmapDataPool.I.release(bd);
        }
        bd = BitmapDataPool.I.acquire(128, 128, true, 0);
        if (bd) {
            BitmapDataPool.I.release(bd);
        }
    }

    /**
     * @private 预构造常用滤镜类（选人 / HUD 首次使用）。
     */
    private function warmFilters():void {
        new GlowFilter(0xffffff, 1, 2, 2, 2);
        new DropShadowFilter(2, 45, 0, 0.5, 2, 2);
    }

    /** @private */
    private function getProbe():Sprite {
        if (!_probe) {
            _probe = new Sprite();
        }
        return _probe;
    }

}
}
