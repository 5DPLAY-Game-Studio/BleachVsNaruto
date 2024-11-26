package net.play5d.game.bvn.mob.ads {
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.mob.ads.ctrl.AdCtrler;
import net.play5d.game.bvn.mob.ads.utils.AdAction;
import net.play5d.game.bvn.mob.ads.utils.AdEvent;
import net.play5d.game.bvn.mob.ads.utils.AdType;
import net.play5d.game.bvn.mob.ads.utils.IAd;
import net.play5d.game.bvn.mob.ctrls.GamePolyCtrl;
import net.play5d.game.bvn.mob.ctrls.MobileCtrler;
import net.play5d.game.bvn.mob.utils.TimerOutUtils;

public class AdManager {

    public static var DEBUG:Boolean = false;
    private static var _i:AdManager;

    public static function get I():AdManager {
        _i ||= new AdManager();
        return _i;
    }

    public static function toast(msg:String):void {
        if (!DEBUG) {
            return;
        }

//			TTAdManager.Instance.showToast(msg);
    }

    public function AdManager() {
        _adCtrler = new AdCtrler();
        _adCtrler.addEventListener(AdEvent.AD_ACTION, adEventHandler);
    }
    public var customGameEventHandler:Function = null;
    private var _adCtrler:AdCtrler;
    private var _showMenuTimes:int;
    private var _showingAdType:Object = {};

    public function initAD(
            ads:Vector.<IAd>, onlyOne:Boolean = false, initSdkBack:Function = null,
            openCloseBack:Function                                          = null
    ):void {
        if (ads.length < 1) {
            initSdkBack();
            openCloseBack();
            return;
        }

        _adCtrler.initAD(ads, onlyOne, initSdkBack, openCloseBack);
    }

    public function updatePolity():void {
        if (!_adCtrler.avaliable()) {
            return;
        }
        _adCtrler.updatePolity(GamePolyCtrl.I.getAdConf());
    }

    public function cancelInitBack():void {
        if (!_adCtrler.avaliable()) {
            return;
        }
        _adCtrler.cancelInitBack();
    }

    public function beforeGameInit():void {
        if (!_adCtrler.avaliable()) {
            return;
        }

        GameEvent.addEventListener(GameEvent.PAUSE_GAME, gameEventHandler);
        GameEvent.addEventListener(GameEvent.RESUME_GAME, gameEventHandler);
        GameEvent.addEventListener(GameEvent.GAME_OVER_CONTINUE, gameEventHandler);
        GameEvent.addEventListener(GameEvent.GAME_OVER, gameEventHandler);
        GameEvent.addEventListener(GameEvent.WINNER_SHOW, gameEventHandler);
        GameEvent.addEventListener(GameEvent.MOSOU_MISSION_FINISH, gameEventHandler);
        GameEvent.addEventListener(GameEvent.LOAD_GAME_START, gameEventHandler);
        GameEvent.addEventListener(GameEvent.LOAD_GAME_COMPLETE, gameEventHandler);
        GameEvent.addEventListener(GameEvent.MOSOU_LOADING_START, gameEventHandler);
        GameEvent.addEventListener(GameEvent.MOSOU_LOADING_FINISH, gameEventHandler);
        GameEvent.addEventListener(GameEvent.CONFRIM_BACK_MENU, gameEventHandler);
        GameEvent.addEventListener(GameEvent.CONFRIM_MOSOU_NEXT_MISSION, gameEventHandler);
    }

    public function onGameInited():void {
        if (!_adCtrler.avaliable()) {
            return;
        }

        _adCtrler.cacheInterAd();

        TimerOutUtils.setTimeout(_adCtrler.cacheVideoAd, 2000);
    }

    public function isShowingAd(type:*):Boolean {
        if (type is Array) {
            var arr:Array = type;

            for each(var i:String in arr) {
                if (_showingAdType[i]) {
                    return true;
                }
            }

            return false;
        }

        return _showingAdType[type] === true;
    }

    public function showAd(type:String):void {
        if (isShowingAd(type)) {
            return;
        }
        if (isShowingAd([AdType.INTER, AdType.VIDEO, AdType.REWARD_VIDEO, AdType.NATIVE])) {
            return;
        }

        switch (type) {
        case AdType.OPEN:
            _adCtrler.showOpenAd();
            break;
        case AdType.INTER:
            _adCtrler.showInterAd();
            break;
        case AdType.VIDEO:
            _adCtrler.showVideoAd();
            break;
        case AdType.NATIVE:
            _adCtrler.showNativeAd(true);
        }
    }

    public function onDeactive():void {
        if (!_adCtrler.avaliable()) {
            return;
        }

        _adCtrler.onDeactive();
    }

    public function onActive():void {
        if (!_adCtrler.avaliable()) {
            return;
        }

        _adCtrler.onActive();
    }

    public function onPause():void {
        if (!_adCtrler.avaliable()) {
            return;
        }

        _adCtrler.onPause();
    }

    public function onResume():void {
        if (!_adCtrler.avaliable()) {
            return;
        }

        _adCtrler.onResume();
    }

    public function checkPackage():Boolean {
//			try{
//				var pkgName:String = _adCtrler.getPackageName();
//				return (pkgName == 'com.jarworld.bleach.bvn' || pkgName == "com.jarworld.bleach.bvn.debug");
//			}catch(e:Error){
//				trace('checkPackage', e);
//			}
//			return false;

        return true;
    }

    public function showRewardVideo(rewardName:String, rewardValue:int, succ:Function, fail:Function):void {
        if (!_adCtrler.avaliable()) {
            return;
        }

        _showingAdType = {};
        _adCtrler.showRewardVideoAd(rewardName, rewardValue, succ, fail);
    }

    private function adEventHandler(e:AdEvent):void {
        switch (e.adType) {
        case AdType.OPEN:
            if (e.adAction == AdAction.SHOW) {
                _showingAdType[AdType.OPEN] = true;
                break;
            }
            if (e.adAction == AdAction.CLOSE || e.adAction == AdAction.ERROR) {
                _showingAdType[AdType.OPEN] = false;
                break;
            }
            break;
        case AdType.VIDEO:

            if (e.adAction == AdAction.SHOW) {
                _showingAdType[AdType.VIDEO] = true;
                _showMenuTimes               = 0;
                MobileCtrler.I.adPause();
                break;
            }

            if (e.adAction == AdAction.CLOSE || e.adAction == AdAction.ERROR) {
                _showingAdType[AdType.VIDEO] = false;
                MobileCtrler.I.adResume();
                break;
            }

            break;
        case AdType.INTER:
            if (e.adAction == AdAction.SHOW) {
                _showingAdType[AdType.INTER] = true;
                break;
            }
            if (e.adAction == AdAction.CLOSE || e.adAction == AdAction.ERROR) {
                _showingAdType[AdType.INTER] = false;
                break;
            }
            break;
        case AdType.REWARD_VIDEO:
            if (e.adAction == AdAction.SHOW) {
                _showingAdType[AdType.REWARD_VIDEO] = true;
                break;
            }
            if (e.adAction == AdAction.CLOSE || e.adAction == AdAction.ERROR) {
                _showingAdType[AdType.REWARD_VIDEO] = false;
                break;
            }
            break;
        case AdType.NATIVE:
            if (e.adAction == AdAction.SHOW) {
                _showingAdType[AdType.NATIVE] = true;
                break;
            }
            if (e.adAction == AdAction.CLOSE || e.adAction == AdAction.ERROR) {
                _showingAdType[AdType.NATIVE] = false;
                break;
            }
            break;
        }
    }

    private function gameEventHandler(e:GameEvent):void {
        if (customGameEventHandler != null) {
            if (customGameEventHandler(e)) {
                return;
            }
        }

        switch (e.type) {
        case GameEvent.PAUSE_GAME:
            showAd(AdType.INTER);
            break;
        case GameEvent.RESUME_GAME:
            break;
        case GameEvent.GAME_OVER_CONTINUE:
            showAd(AdType.VIDEO);
            break;
        case GameEvent.GAME_OVER:
            break;
        case GameEvent.WINNER_SHOW:
            _adCtrler.showSmartAd();
            break;
        case GameEvent.MOSOU_MISSION_FINISH:
            _adCtrler.showSmartAd();
            break;
        case GameEvent.LOAD_GAME_START:
            AdManager.toast('GameEvent.LOAD_GAME_START');
            _adCtrler.showNativeAd(false);
            break;
        case GameEvent.LOAD_GAME_COMPLETE:
            AdManager.toast('GameEvent.LOAD_GAME_COMPLETE');
            _adCtrler.closeNativeAd();
            _showingAdType[AdType.NATIVE] = false;
            break;
        case GameEvent.CONFRIM_BACK_MENU:
            showAd(AdType.NATIVE);
        }
    }

}
}
