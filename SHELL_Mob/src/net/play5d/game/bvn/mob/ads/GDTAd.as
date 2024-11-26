//package net.play5d.game.bvn.mob.ads
//{
//	public class GDTAd
//	{
//		public function GDTAd()
//		{
//		}
//	}
//}

package net.play5d.game.bvn.mob.ads {
import flash.events.StatusEvent;

import net.play5d.game.bvn.mob.ads.utils.AdEventListener;
import net.play5d.game.bvn.mob.utils.TimerOutUtils;

public class GDTAd extends BaseAd {


    public function GDTAd(param1:String, param2:String, param3:String, param4:String, param5:String) {
        super();
        $name                   = 'GDT';
        $enabled                = true;
        this.appid              = param1;
        this.interstitial       = param3;
        this.rewardvideo        = param4;
        this.nativeId           = param5;
        $configCode             = new AdConfigCode();
        $configCode.inter       = 'GDT-INTER';
        $configCode.open        = 'GDT-OPEN';
        $configCode.rewardVideo = 'GDT-REWARD-VIDEO';
        $configCode.video       = 'GDT-VIDEO';
        $configCode.native      = 'GDT-NATIVE';
    }
    private var appid:String = '1110076897';
    private var splashid:String = '3082021928935304';
    private var interstitial:String = '3072533491204880';
    private var rewardvideo:String = '7032629938039577';
    private var nativeId:String = '3072844414448932';
    private var _onRewardVideoSucc:Function;
    private var _onRewardVideoFail:Function;
    private var _videoLoading:Boolean = false;
    private var _interLoading:Boolean = false;
    private var _initTimer:int;
    private var _listener:AdEventListener;
    private var _currentShowingVideoType:String;

    override public function initalize(param1:AdEventListener):void {
        _listener = param1;
//			GDTManager.Instance.addEventListener("status",statusHandler);
//			GDTManager.Instance.initAdSDK(this.appid,false);
    }

    override public function showOpen():void {
//			GDTManager.Instance.showSplash(this.splashid);
        _listener.onShow(this, 'OPEN');
    }

    override public function cacheInter():void {
        if ($interReady) {
            return;
        }
        if (_interLoading) {
            return;
        }
        AdManager.toast('GDT - cacheInter');
//			GDTManager.Instance.loadInterstitail(this.interstitial);
        _interLoading = true;
    }

    override public function showInter():void {
//			GDTManager.Instance.showInterstitial();
        _listener.onShow(this, 'INTER');
    }

    override public function cacheVideo():void {
        if ($videoReady) {
            return;
        }
        if (_videoLoading) {
            return;
        }
//			GDTManager.Instance.loadRewardVideo(this.rewardvideo);
        _videoLoading = true;
    }

    override public function playVideo():void {
        if (!$videoReady) {
            cacheVideo();
            return;
        }
        _currentShowingVideoType = 'VIDEO';
//			GDTManager.Instance.showRewardAd();
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
        _onRewardVideoSucc       = param3;
        _onRewardVideoFail       = param4;
        _currentShowingVideoType = 'REWARD_VIDEO';
//			GDTManager.Instance.showRewardAd();
        _listener.onShow(this, 'REWARD_VIDEO');
    }

    override public function showNative(param1:Boolean):void {
//			GDTManager.Instance.showNativeExpressAd(nativeId,param1);
    }

    override public function closeNative():void {
//			GDTManager.Instance.closeNativeExpressAd();
    }

    override public function onGamePause():void {
    }

    override public function onGameResume():void {
    }

    override public function onDeactive():void {
    }

    override public function onActive():void {
    }

    private function initSucc():void {
        _listener.onInitOK(this);
        AdManager.toast('GDT init success!');
    }

    private function statusHandler(param1:StatusEvent):void {
        AdManager.toast('GDT - statusHandler: ' + param1.code + ',' + param1.level);
        loop0:
                switch (param1.code) {
                case 'init':
                    if (param1.level == 'success') {
                        TimerOutUtils.clearTimeout(_initTimer);
                        _initTimer = TimerOutUtils.setTimeout(initSucc, 2000);
                        break;
                    }
                    break;
                case 'rewardVideo':
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
                        _onRewardVideoSucc = null;
                        _onRewardVideoFail = null;
                        $videoReady        = false;
                        _videoLoading      = false;
                        cacheVideo();
                        _listener.onClose(this, _currentShowingVideoType);
                        break loop0;
                    case 'prise':
                        if (_onRewardVideoSucc != null) {
                            _onRewardVideoSucc();
                        }
                        $videoReady = false;
                    }
                    break;
                case 'initerstitial':
                    switch (param1.level) {
                    case 'loadsuccess':
                        $interReady   = true;
                        _interLoading = false;
                        break loop0;
                    case 'loadfail':
                        $interReady   = false;
                        _interLoading = false;
                        _listener.onError(this, 'INTER');
                        break loop0;
                    case 'close':
                        _interLoading = false;
                        $interReady   = false;
                        cacheInter();
                        _listener.onClose(this, 'INTER');
                    }
                }
    }
}
}
