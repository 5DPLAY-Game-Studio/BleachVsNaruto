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

package net.play5d.game.bvn.mob.ads.ctrl {
import flash.events.EventDispatcher;
import flash.utils.clearTimeout;

import net.play5d.game.bvn.mob.ads.AdConfigCode;
import net.play5d.game.bvn.mob.ads.AdManager;
import net.play5d.game.bvn.mob.ads.utils.AdAction;
import net.play5d.game.bvn.mob.ads.utils.AdEvent;
import net.play5d.game.bvn.mob.ads.utils.AdType;
import net.play5d.game.bvn.mob.ads.utils.IAd;
import net.play5d.game.bvn.mob.data.AdConfVO;
import net.play5d.kyo.utils.KyoTimerUtils;

public class AdCtrler extends EventDispatcher {
    private const _showAdTimesTotal:int = 1;
    private const _showVideoAdTimesTotal:int = 2;
    public static var SHOW_OPENAD_ON_START:Boolean = true;
    public static var SMART_ONLY_VIDEO:Boolean     = false;

    public function AdCtrler() {
    }
    private var _showAdTimes:int;
    private var _showVideoAdTimes:int;
    private var _initSdkBack:Function;
    private var _openCloseBack:Function;
    private var _showOpenAdTimer:int;
    private var _adGroup:AdGroup;
    private var _adConfMap:Object = {};

    public function avaliable():Boolean {
        return _adGroup && _adGroup.avaliable();
    }

    public function initAD(
            ads:Vector.<IAd>, onlyOne:Boolean = false, initSdkBack:Function = null,
            openCloseBack:Function = null
    ):void {
        _initSdkBack   = initSdkBack;
        _openCloseBack = openCloseBack;
        initAdGroup(ads, onlyOne);
    }

    public function updatePolity(adconfs:Vector.<AdConfVO>):void {
        trace('============= update AD polity ============');

        for each(var adconf:AdConfVO in adconfs) {
            trace(' config settings ------ ');
            trace(adconf.toString());

            var adConfDir:AdConfDir = _adConfMap[adconf.code];
            if (adConfDir && adConfDir.ad && adConfDir.type) {
                adConfDir.ad.setRank(adConfDir.type, adconf.rank);
                adConfDir.ad.setRate(adConfDir.type, adconf.rate);
                adConfDir.ad.setADEnabled(adConfDir.type, adconf.enabled);

                trace(' CONFIG PARAM [' + adconf.code + '] :: ' + adConfDir.toString());
            }
            else {
                trace(' CONFIG PARAM [' + adconf.code + '] not match ------ ');
            }
        }

        trace('============= update AD polity END ============');
    }

    public function cancelInitBack():void {
        clearTimeout(_showOpenAdTimer);
        _initSdkBack   = null;
        _openCloseBack = null;
    }

    public function showSmartAd():void {
        if (SMART_ONLY_VIDEO) {
            AdManager.I.showAd(AdType.VIDEO);

            return;
        }

        _showVideoAdTimes++;
        if (_showVideoAdTimes >= _showVideoAdTimesTotal) {
            _showVideoAdTimes = 0;
            AdManager.I.showAd(AdType.VIDEO);
            return;
        }

        AdManager.I.showAd(AdType.NATIVE);
    }

    public function showInterAdOrVideoAd():void {
        showInterAd();
    }

    public function showInterAd():void {
        _adGroup.showInter();
    }

    public function cacheInterAd():void {
        _adGroup.cacheInter();
    }

    public function cacheVideoAd():void {
        _adGroup.cacheVideo();
    }

    public function showVideoAd():void {
        _adGroup.showVideo();
    }

    public function showRewardVideoAd(rewardName:String, rewardValue:int, succ:Function, fail:Function):void {
        _adGroup.showRewardVideo(rewardName, rewardValue, succ, fail);
    }

    public function showOpenAd():void {
        if (!_adGroup.showOpen()) {
            openCloseBack();
        }
    }

    public function onPause():void {
        _adGroup.onGamePause();
    }

    public function onResume():void {
        _adGroup.onGameResume();
    }

    public function onDeactive():void {
        _adGroup.onDeactive();
    }

    public function onActive():void {
        _adGroup.onActive();
    }

    public function showNativeAd(showClose:Boolean):void {
        _adGroup.showNativeAd(showClose);
    }

    public function closeNativeAd():void {
        _adGroup.closeNativeAd();
    }

    private function initAdGroup(ads:Vector.<IAd>, onlyOne:Boolean = false):void {
        _adGroup = new AdGroup();
        _adGroup.addEventListener(AdEvent.METHOD_CALL, methodCallHandler);
        _adGroup.addEventListener(AdEvent.AD_ACTION, adActionHandler);

        // 初始化AD列表
        for each(var ad:IAd in ads) {
            _adGroup.add(ad);
        }

        if (onlyOne && ads.length == 1) {
            _adGroup.onlyOneAd = ads[0];
        }

        _adGroup.initialize();
        initConfMap();
    }

    private function initConfMap():void {
        _adConfMap = {};

        for each(var i:IAd in _adGroup.getAdList()) {
            var configCode:AdConfigCode = i.getConfigCode();

            setConf(configCode.open, i, AdType.OPEN);
            setConf(configCode.inter, i, AdType.INTER);
            setConf(configCode.video, i, AdType.VIDEO);
            setConf(configCode.rewardVideo, i, AdType.REWARD_VIDEO);
        }

        function setConf(code:String, ad:IAd, type:String):void {
            if (code != null) {
                _adConfMap[code] = new AdConfDir(code, ad, type);
            }
        }
    }

    private function openCloseBack():void {
        clearTimeout(_showOpenAdTimer);
        if (_openCloseBack != null) {
            _openCloseBack();
            _openCloseBack = null;
        }
    }

    private function adActionHandler(e:AdEvent):void {
        if (e.adAction == AdAction.INIT_OK) {
            if (_initSdkBack != null) {
                _initSdkBack();
                _initSdkBack = null;
            }

            if (SHOW_OPENAD_ON_START) {
                if (_openCloseBack != null) {
                    _showOpenAdTimer = KyoTimerUtils.setTimeout(openCloseBack, 8000);
                }

                AdManager.I.showAd(AdType.OPEN);
            }
            else {
                openCloseBack();
            }
        }

        if (e.adAction == AdAction.INIT_FAIL) {
        }

        if (e.adAction == AdAction.SHOW) {
            if (e.adType == AdType.OPEN) {
                clearTimeout(_showOpenAdTimer);
            }
        }

        if (e.adAction == AdAction.CLOSE) {
            if (e.adType == AdType.OPEN) {
                openCloseBack();
            }
            if (e.adType == AdType.VIDEO) {
                _adGroup.cacheVideo();
            }
            if (e.adType == AdType.INTER) {
                _adGroup.cacheInter();
            }
        }

        if (e.adAction == AdAction.CLICK) {
            if (e.adType == AdType.INTER) {
                _showAdTimes = 0;
            }
            if (e.adType == AdType.VIDEO) {
                _showVideoAdTimes = 0;
            }
        }

        if (e.adAction == AdAction.ERROR) {
            if (e.adType == AdType.OPEN) {
                openCloseBack();
            }
        }

        dispatchEvent(new AdEvent(e.type, e.adAction, e.adType, e.ad));
    }

    private function methodCallHandler(e:AdEvent):void {
        dispatchEvent(new AdEvent(e.type, e.adAction, e.adType, e.ad));
    }

}
}
