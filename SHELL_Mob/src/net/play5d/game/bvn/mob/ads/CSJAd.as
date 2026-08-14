package net.play5d.game.bvn.mob.ads {
import flash.events.StatusEvent;

import net.play5d.game.bvn.mob.ads.utils.AdEventListener;
import net.play5d.kyo.utils.KyoTimerUtils;

public class CSJAd extends BaseAd {

    public function CSJAd(param1:String, param2:String, param3:String, param4:String) {
        super();
        this.appid              = param1;
        this.splashid           = param2;
        this.interstitial       = param3;
        this.nativeId           = param4;
        $name                   = 'CSJ';
        $enabled                = true;
        $configCode             = new AdConfigCode();
        $configCode.open        = 'CSJ-OPEN';
        $configCode.loading     = 'CSJ-LOADING';
        $configCode.inter       = 'CSJ-INTER';
        $configCode.video       = 'CSJ-VIDEO';
        $configCode.rewardVideo = 'CSJ-REWARD-VIDEO';
        $configCode.native      = 'CSJ-NATIVE';
    }
    private var appid:String = '5209719';
    private var splashid:String = '887546806';
    private var interstitial:String = '946590821';
    private var nativeId:String = '946834540';
    private var _videoLoading:Boolean;
    private var _listener:AdEventListener;
    private var _currentShowingVideoType:String;
    private var _rewardSuccess:Function;

    override public function initialize(param1:AdEventListener):void {
        _listener = param1;
    }

    override public function showOpen():void {
        _listener.onShow(this, 'OPEN');
        KyoTimerUtils.setTimeout(openFinish, 1000);
    }

    override public function cacheInter():void {
    }

    override public function showInter():void {
    }

    override public function showNative(param1:Boolean):void {
        if (!nativeId) {
            return;
        }
        _listener.onShow(this, 'NATIVE');
    }

    override public function closeNative():void {
    }

    override public function cacheVideo():void {
        if ($videoReady) {
            return;
        }
        if (_videoLoading) {
            return;
        }
        _videoLoading = true;
    }

    override public function playVideo():void {
        if (!$videoReady) {
            cacheVideo();
            return;
        }
        _currentShowingVideoType = 'VIDEO';
        _listener.onShow(this, 'VIDEO');
    }

    override public function playRewardVideo(param1:String, param2:int, param3:Function, param4:Function):void {
        if (!$videoReady) {
            cacheVideo();
            if (param4 != null) {
                param4();
            }
            return;
        }
        _rewardSuccess           = param3;
        _currentShowingVideoType = 'REWARD_VIDEO';
        _listener.onShow(this, 'REWARD_VIDEO');
    }

    private function openFinish():void {
        _listener.onClose(this, 'OPEN');
    }

    private function statusHandler(param1:StatusEvent):void {
        AdManager.toast('CSJ - statusHandler: ' + param1.code + ',' + param1.level);
        loop0:
                switch (param1.code) {
                case 'initSdk':
                    if (param1.level == 'success') {
                        trace('sdk init successed!');
                        AdManager.toast('CSJ init success!');
                        _listener.onInitOK(this);
                        break;
                    }
                    if (param1.level == 'fail') {
                        _listener.onInitFail(this);
                        break;
                    }
                    break;
                case 'initerstitial':
                    switch (param1.level) {
                    case 'loadsuccess':
                        $videoReady   = true;
                        _videoLoading = false;
                        break loop0;
                    case 'loadfail':
                        $videoReady   = false;
                        _videoLoading = false;
                        _listener.onError(this, _currentShowingVideoType);
                        break loop0;
                    case 'close':
                        $videoReady   = false;
                        _videoLoading = false;
                        _listener.onClose(this, _currentShowingVideoType);
                        if (_rewardSuccess != null) {
                            _rewardSuccess();
                            _rewardSuccess = null;
                        }
                        cacheVideo();
                    }
                    break;
                case 'nativeExpressAd':
                    switch (param1.level) {
                    case 'loadsuccess':
                        break loop0;
                    case 'loadfail':
                        _listener.onError(this, 'NATIVE');
                        break loop0;
                    case 'renderFail':
                        _listener.onError(this, 'NATIVE');
                        break loop0;
                    case 'close':
                        _listener.onClose(this, 'NATIVE');
                    }
                }
    }
}
}
