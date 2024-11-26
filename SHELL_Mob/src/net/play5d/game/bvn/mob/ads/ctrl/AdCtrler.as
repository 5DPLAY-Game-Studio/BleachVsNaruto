//package net.play5d.game.bvn.mob.ads.ctrl
//{
//	import flash.events.EventDispatcher;
//	import flash.utils.clearTimeout;
//	import flash.utils.setTimeout;
//
//	import net.play5d.game.bvn.mob.ads.JooMobAd;
//	import net.play5d.game.bvn.mob.ads.JuHeAd;
//	import net.play5d.game.bvn.mob.ads.YdAd;
//	import net.play5d.game.bvn.mob.ads.YuAd;
//	import net.play5d.game.bvn.mob.ads.utils.AdAction;
//	import net.play5d.game.bvn.mob.ads.utils.AdEvent;
//	import net.play5d.game.bvn.mob.ads.utils.AdType;
//	import net.play5d.game.bvn.mob.ads.utils.IAd;
//
//	public class AdCtrler extends EventDispatcher
//	{
//		public static var SHOW_OPENAD_ON_START:Boolean = true;
//		public static var SMART_ONLY_VIDEO:Boolean = false;
//
//		private var _showAdTimes:int;
//
////		private var _topAdShowing:Boolean;
//
//		private const _showAdTimesTotal:int = 1;
//
//		private var _showVideoAdTimes:int;
//		private const _showVideoAdTimesTotal:int = 2;
//
//		private var _initSdkBack:Function;
//		private var _openCloseBack:Function;
//		private var _showOpenAdTimer:int;
//
//		private var _adGroup:AdGroup;
//
//		private var _adConfMap:Object = {};
//
//		// ADS
////		private var _ydad:YdAd;
////		private var _yuad:YuAd;
////		private var _juhead:JuHeAd;
////		private var _joomobad:JooMobAd;
//
//		public function AdCtrler()
//		{
//		}
//
//		public function avaliable():Boolean {
//			return _adGroup && _adGroup.avaliable();
//		}
//
//		public function initAD(ads:Vector.<IAd>, onlyOne:Boolean = false, initSdkBack:Function = null,
// openCloseBack:Function = null):void{ _initSdkBack = initSdkBack; _openCloseBack = openCloseBack; initAdGroup(ads,
// onlyOne); }  public function updatePolity(adconfs:Vector.<AdConfVO>):void { trace("============= update AD polity
// ============");  for each(var adconf:AdConfVO_ in adconfs) { trace(" config settings ------ ");
// trace(adconf.toString());  var adConfDir:AdConfDir = _adConfMap[adconf.code]; if(adConfDir && adConfDir.ad &&
// adConfDir.type) { adConfDir.ad.setRank(adConfDir.type,adconf.rank);
// adConfDir.ad.setRate(adConfDir.type,adconf.rate); adConfDir.ad.setADEnabled(adConfDir.type,adconf.enabled); trace("
// CONFIG PARAM [" + adconf.code + "] :: " + adConfDir.toString()); } else { trace(" CONFIG PARAM [" + adconf.code + "]
// not match ------ "); } }  trace("============= update AD polity END ============"); }  private function
// initAdGroup(ads:Vector.<IAd>, onlyOne:Boolean = false):void{  _adGroup = new AdGroup();
// _adGroup.addEventListener(AdEvent.METHOD_CALL, methodCallHandler); _adGroup.addEventListener(AdEvent.AD_ACTION, adActionHandler);  // 初始化AD列表 //			_ydad = new YdAd(); //			_adGroup.add(_ydad); for each(var ad:IAd in ads){ _adGroup.add(ad); }  //			_yuad = new YuAd(); //			_adGroup.add(_yuad); // //			_juhead = new JuHeAd(); //			_adGroup.add(_juhead); //			 //			_joomobad = new JooMobAd(); //			_adGroup.add(_joomobad);  //			_adGroup.onlyOneAd = _ydad; if(onlyOne && ads.length ==1) _adGroup.onlyOneAd = ads[0];  _adGroup.initalize(); initConfMap(); }  private function initConfMap():void { _adConfMap = {};  for each(var i:IAd in _adGroup.getAdList()) { var configCode:AdConfigCode = i.getConfigCode();  setConf(configCode.open,i,"OPEN"); setConf(configCode.inter,i,"INTER"); setConf(configCode.video,i,"VIDEO"); setConf(configCode.rewardVideo,i,"REWARD_VIDEO"); }  function setConf(param1:String, ad:IAd, param3:String):void { if(param1 != null) { _adConfMap[param1] = new AdConfDir(param1,ad,param3); } } }    private function adActionHandler(e:AdEvent):void{  if(e.adAction == AdAction.INIT_OK){  if(_initSdkBack != null){ _initSdkBack(); _initSdkBack = null; }  if(_openCloseBack){ _showOpenAdTimer = setTimeout(openCloseBack, 8000); }  showOpenAd(); //				setTimeout(showOpenAd, 2000); }  if(e.adAction == AdAction.INIT_FAIL){ }  if(e.adAction == AdAction.SHOW){ if(e.adType == AdType.OPEN){ _topAdShowing = true; clearTimeout(_showOpenAdTimer); } if(e.adType == AdType.VIDEO){ _topAdShowing = true; } }  if(e.adAction == AdAction.CLOSE){ if(e.adType == AdType.OPEN){ _topAdShowing = false; openCloseBack(); } if(e.adType == AdType.VIDEO){ _topAdShowing = false; _adGroup.cacheVideo(); } if(e.adType == AdType.INTER){ _adGroup.cacheInter(); } }  if(e.adAction == AdAction.CLICK){ if(e.adType == AdType.INTER){ _showAdTimes = 0; } if(e.adType == AdType.VIDEO){ _showVideoAdTimes = 0; } }  if(e.adAction == AdAction.ERROR){ if(e.adType == AdType.OPEN){ _topAdShowing = false; openCloseBack(); } if(e.adType == AdType.VIDEO){ _topAdShowing = false; } }  dispatchEvent(new AdEvent(e.type, e.adAction, e.adType, e.ad)); }  private function methodCallHandler(e:AdEvent):void{ dispatchEvent(new AdEvent(e.type, e.adAction, e.adType, e.ad)); }  public function cancelInitBack():void{ clearTimeout(_showOpenAdTimer); _initSdkBack = null; _openCloseBack = null; }  private function openCloseBack():void{ clearTimeout(_showOpenAdTimer); if(_openCloseBack){ _openCloseBack(); _openCloseBack = null; } }  public function showSmartAd():void{  if(_topAdShowing){ return; }  _showVideoAdTimes++; if(_showVideoAdTimes >= _showVideoAdTimesTotal){ _showVideoAdTimes = 0; showVideoAd(); return; }  showInterAd(); }  public function showInterAdOrVideoAd():void{  if(_topAdShowing){ return; } showInterAd(); }  public function showInterAd():void{  if(_topAdShowing){ return; }  //			_wxAne.showInterstitial(); _adGroup.showInter(); }  public function cacheInterAd():void{ _adGroup.cacheInter(); }  public function cacheVideoAd():void{ _adGroup.cacheVideo(); }  public function showVideoAd():void{  if(_topAdShowing){ return; }  _adGroup.showVideo(); }  public function showOpenAd():void{  if(_topAdShowing){ return; }  if(!_adGroup.showOpen()){ openCloseBack(); } }  public function onPause():void{ _adGroup.onGamePause(); }  public function onResume():void{ _adGroup.onGameResume(); }  public function getPackageName():String{ return _ydad.getANE().getPackageName(); }  } }

package net.play5d.game.bvn.mob.ads.ctrl {
import flash.events.EventDispatcher;
import flash.utils.clearTimeout;

import net.play5d.game.bvn.mob.ads.AdConfigCode;
import net.play5d.game.bvn.mob.ads.AdManager;
import net.play5d.game.bvn.mob.ads.utils.AdEvent;
import net.play5d.game.bvn.mob.ads.utils.IAd;
import net.play5d.game.bvn.mob.data.AdConfVO;
import net.play5d.game.bvn.mob.utils.TimerOutUtils;

public class AdCtrler extends EventDispatcher {

    private const _showAdTimesTotal:int = 1;
    private const _showVideoAdTimesTotal:int = 2;
    public static var SHOW_OPENAD_ON_START:Boolean = true;
    public static var SMART_ONLY_VIDEO:Boolean = false;

    public function AdCtrler() {
        _adConfMap = {};
        super();
    }
    private var _showAdTimes:int;
    private var _showVideoAdTimes:int;
    private var _initSdkBack:Function;
    private var _openCloseBack:Function;
    private var _showOpenAdTimer:int;
    private var _adGroup:AdGroup;
    private var _adConfMap:Object;

    public function avaliable():Boolean {
        return _adGroup && _adGroup.avaliable();
    }

    public function initAD(
            param1:Vector.<IAd>, param2:Boolean = false, param3:Function = null, param4:Function = null):void {
        _initSdkBack   = param3;
        _openCloseBack = param4;
        initAdGroup(param1, param2);
    }

    public function updatePolity(param1:Vector.<AdConfVO>):void {
        var _loc3_:AdConfDir = null;
        trace('============= update AD polity ============');
        for each(var _loc2_ in param1) {
            trace(' config settings ------ ');
            trace(_loc2_.toString());
            _loc3_ = _adConfMap[_loc2_.code];
            if (_loc3_ && _loc3_.ad && _loc3_.type) {
                _loc3_.ad.setRank(_loc3_.type, _loc2_.rank);
                _loc3_.ad.setRate(_loc3_.type, _loc2_.rate);
                _loc3_.ad.setADEnabled(_loc3_.type, _loc2_.enabled);
                trace(' CONFIG PARAM [' + _loc2_.code + '] :: ' + _loc3_.toString());
            }
            else {
                trace(' CONFIG PARAM [' + _loc2_.code + '] not match ------ ');
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
            AdManager.I.showAd('VIDEO');
            return;
        }
        _showVideoAdTimes++;
        if (_showVideoAdTimes >= 2) {
            _showVideoAdTimes = 0;
            AdManager.I.showAd('VIDEO');
            return;
        }
        AdManager.I.showAd('NATIVE');
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

    public function showRewardVideoAd(param1:String, param2:int, param3:Function, param4:Function):void {
        _adGroup.showRewardVideo(param1, param2, param3, param4);
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

    public function showNativeAd(param1:Boolean):void {
        _adGroup.showNativeAd(param1);
    }

    public function closeNativeAd():void {
        _adGroup.closeNativeAd();
    }

    private function initAdGroup(param1:Vector.<IAd>, param2:Boolean = false):void {
        _adGroup = new AdGroup();
        _adGroup.addEventListener('METHOD_CALL', methodCallHandler);
        _adGroup.addEventListener('AD_ACTION', adActionHandler);
        for each(var _loc3_ in param1) {
            _adGroup.add(_loc3_);
        }
        if (param2 && param1.length == 1) {
            _adGroup.onlyOneAd = param1[0];
        }
        _adGroup.initalize();
        initConfMap();
    }

    private function initConfMap():void {
        var i:IAd;
        var configCode:AdConfigCode;
        var setConf:* = function (param1:String, param2:IAd, param3:String):void {
            if (param1 != null) {
                _adConfMap[param1] = new AdConfDir(param1, param2, param3);
            }
        };
        _adConfMap    = {};
        for each(i in _adGroup.getAdList()) {
            configCode = i.getConfigCode();
            setConf(configCode.open, i, 'OPEN');
            setConf(configCode.inter, i, 'INTER');
            setConf(configCode.video, i, 'VIDEO');
            setConf(configCode.rewardVideo, i, 'REWARD_VIDEO');
        }
    }

    private function openCloseBack():void {
        clearTimeout(_showOpenAdTimer);
        if (Boolean(_openCloseBack)) {
            _openCloseBack();
            _openCloseBack = null;
        }
    }

    private function adActionHandler(param1:AdEvent):void {
        if (param1.adAction == 'INIT_OK') {
            if (_initSdkBack != null) {
                _initSdkBack();
                _initSdkBack = null;
            }
            if (SHOW_OPENAD_ON_START) {
                if (Boolean(_openCloseBack)) {
                    _showOpenAdTimer = TimerOutUtils.setTimeout(openCloseBack, 8000);
                }
                AdManager.I.showAd('OPEN');
            }
            else {
                openCloseBack();
            }
        }
        if (param1.adAction == 'INIT_FAIL') {
        }
        if (param1.adAction == 'SHOW') {
            if (param1.adType == 'OPEN') {
                clearTimeout(_showOpenAdTimer);
            }
            if (param1.adType == 'VIDEO') {
            }
        }
        if (param1.adAction == 'CLOSE') {
            if (param1.adType == 'OPEN') {
                openCloseBack();
            }
            if (param1.adType == 'VIDEO') {
                _adGroup.cacheVideo();
            }
            if (param1.adType == 'INTER') {
                _adGroup.cacheInter();
            }
        }
        if (param1.adAction == 'CLICK') {
            if (param1.adType == 'INTER') {
                _showAdTimes = 0;
            }
            if (param1.adType == 'VIDEO') {
                _showVideoAdTimes = 0;
            }
        }
        if (param1.adAction == 'ERROR') {
            if (param1.adType == 'OPEN') {
                openCloseBack();
            }
            if (param1.adType == 'VIDEO') {
            }
        }
        dispatchEvent(new AdEvent(param1.type, param1.adAction, param1.adType, param1.ad));
    }

    private function methodCallHandler(param1:AdEvent):void {
        dispatchEvent(new AdEvent(param1.type, param1.adAction, param1.adType, param1.ad));
    }
}
}
