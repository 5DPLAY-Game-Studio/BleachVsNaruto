//package net.play5d.game.bvn.mob.ads.ctrl
//{
//	import flash.events.EventDispatcher;
//	import flash.utils.Timer;
//	import flash.utils.setTimeout;
//
//	import avmplus.getQualifiedClassName;
//
//	import net.play5d.game.bvn.mob.ads.utils.AdAction;
//	import net.play5d.game.bvn.mob.ads.utils.AdEvent;
//	import net.play5d.game.bvn.mob.ads.utils.AdEventListener;
//	import net.play5d.game.bvn.mob.ads.utils.AdType;
//	import net.play5d.game.bvn.mob.ads.utils.IAd;
//	import net.play5d.game.bvn.mob.utils.TimerOutUtils;
//
//	public class AdGroup extends EventDispatcher
//	{
//
//		/**
//		 * 设置时，只有该AD显示，但不影响其他ANE初始化
//		 */
//		public var onlyOneAd:IAd;
//
//
//		/**
//		 * 所有AD
//		 */
//		private var _adList:Vector.<IAd> = new Vector.<IAd>();
//
//		/**
//		 * 有效且正常初始化的AD
//		 */
//		private var _enabledAdList:Vector.<IAd> = new Vector.<IAd>();
//
//		/**
//		 * 无效的AD
//		 */
//		private var _failAdList:Vector.<IAd> = new Vector.<IAd>();
//
//		private var _listener:AdEventListener;
//
//		private var _initAdQueue:Vector.<IAd>;
//		private var _initAdCount:int;
//
//		private var _initTimer:int;
//
//		public function AdGroup()
//		{
//		}
//
//		public function add(ad:IAd):void{
//			_adList.push(ad);
//		}
//
//		public function initalize():void{
//			if(_adList.length < 1){
//				throw new Error('add ad first!');
//				return;
//			}
//
//			initListener();
//
//			_initAdQueue = new Vector.<IAd>();
//
//			for each(var d:IAd in _adList){
//				if(d.getEnabled()){
//					_initAdQueue.push(d);
//				}else{
//					_failAdList.push(d);
//				}
//			}
//
//			_initAdCount = _initAdQueue.length;
//
//			initNext();
//		}
//
//		private function initNext():void{
//
//			TimerOutUtils.clearTimeout(_initTimer);
//
//			if(_initAdQueue.length < 1){
//				adInitComplete();
//				return;
//			}
//
//			var d:IAd = _initAdQueue.shift();
//
//			_initTimer = TimerOutUtils.setTimeout(initTimeout, 5000, d);
//
//			trace('init ::', d, ' - ', _initAdCount - _initAdQueue.length, '/', _initAdCount);
//			d.initalize(_listener);
//		}
//
//		private function initTimeout(ad:IAd):void{
//			trace('init timeout', ad);
//
//			if(_failAdList.indexOf(ad) == -1){
//				_failAdList.push(ad);
//			}
//
//			initNext();
//		}
//
//		private function testRate():void{
//			var countMap:Object = {};
//
//			countMap[AdType.INTER] = {};
//			countMap[AdType.VIDEO] = {};
//
//			var interCount:Object = countMap[AdType.INTER];
//			var videoCount:Object = countMap[AdType.VIDEO];
//
//			var testCount:int = 100000;
//
//			for(var i:int; i < testCount; i++){
//				var interAd:IAd = getRankAd(AdType.INTER);
//
//				var interClassName:String = getQualifiedClassName(interAd);
//				if(interCount[interClassName] === undefined) interCount[interClassName] = 0;
//				interCount[interClassName] ++;
//
//				var videoAd:IAd = getRankAd(AdType.VIDEO);
//				var videoClassName:String = getQualifiedClassName(videoAd);
//				if(videoCount[videoClassName] === undefined) videoCount[videoClassName] = 0;
//				videoCount[videoClassName] ++;
//			}
//
//			trace('------ RANK REPORT [ Count:'+testCount+' ]
// ---------------------------------------------------------'); for(var j:String in countMap){ trace(j + '
// -----------------------------------------------------------------'); for(var k:String in countMap[j]){ var num:int =
// countMap[j][k]; var rate:Number = (num / testCount) * 100; trace(k + ' : ' + rate + "%"); }
// trace('-----------------------------------------------------------------'); }  }  private function
// initListener():void{ _listener = new AdEventListener();  _listener.listen(AdAction.INIT_OK, adHandler);
// _listener.listen(AdAction.INIT_FAIL, adHandler);  _listener.listen(AdAction.SHOW, adHandler);
// _listener.listen(AdAction.CLOSE, adHandler); _listener.listen(AdAction.CLICK, adHandler);
// _listener.listen(AdAction.SUCCESS, adHandler); _listener.listen(AdAction.ERROR, adHandler); }  private function
// adHandler(ad:IAd = null, adType:String = null, adAction:String = null):void{  if(adAction == AdAction.INIT_OK){
// if(_enabledAdList.indexOf(ad) == -1){ _enabledAdList.push(ad); initNext(); return; } }  if(adAction == AdAction.INIT_FAIL){ if(_failAdList.indexOf(ad) == -1){ _failAdList.push(ad); initNext(); return; } }  dispatchEvent(new AdEvent(AdEvent.AD_ACTION, adAction, adType, ad)); }  private function adInitComplete():void{ trace('all ad is ok!'); dispatchEvent(new AdEvent(AdEvent.AD_ACTION, AdAction.INIT_OK, null, null));   // TEST SHOW RATE //			testRate();  }  public function cacheInter():void{ var ad:IAd = getRankAd(AdType.INTER); if(!ad) return;  ad.cacheInter(); dispatchEvent(new AdEvent(AdEvent.METHOD_CALL, AdAction.CACHE, AdType.INTER, ad)); }  public function showInter():void{			 var ad:IAd = getReadyAd(AdType.INTER); if(!ad){ cacheInter(); return; }  ad.showInter(); dispatchEvent(new AdEvent(AdEvent.METHOD_CALL, AdAction.SHOW, AdType.INTER, ad)); }  public function cacheVideo():void{ var ad:IAd = getRankAd(AdType.VIDEO); if(!ad) return;  ad.cacheVideo(); dispatchEvent(new AdEvent(AdEvent.METHOD_CALL, "cache", AdType.VIDEO, ad)); }  public function playVideo():Boolean{ var ad:IAd = getReadyAd(AdType.VIDEO); if(!ad) return false;  ad.playVideo(); dispatchEvent(new AdEvent(AdEvent.METHOD_CALL, "play", AdType.VIDEO, ad)); return true; }  public function showVideo():void{ if(playVideo()) return; cacheVideo(); }  public function showOpen():Boolean{ var ad:IAd = getRankAd(AdType.OPEN); if(!ad) return false;  ad.showOpen(); dispatchEvent(new AdEvent(AdEvent.METHOD_CALL, AdAction.SHOW, AdType.OPEN, ad));  return true; }  public function onGamePause():void{ for each(var d:IAd in _enabledAdList){ d.onGamePause(); } }  public function onGameResume():void{ for each(var d:IAd in _enabledAdList){ d.onGameResume(); } }  private function getReadyAd(type:String):IAd{ if(onlyOneAd) return onlyOneAd; for(var i:int; i < _enabledAdList.length; i++){ var d:IAd = _enabledAdList[i];  switch(type){ case AdType.INTER: if(d.interReady()) return d; break; case AdType.VIDEO: if(d.videoReady()) return d; break; } }  return null; }  private function getRankAd(type:String):IAd{ if(onlyOneAd) return onlyOneAd;  function sortAd(A:IAd, B:IAd):int{ if(A.getRank(type) > B.getRank(type)) return -1; if(A.getRank(type) < B.getRank(type)) return 1; return 0; }  _enabledAdList.sort(sortAd);  for(var i:int; i < _enabledAdList.length; i++){ var d:IAd = _enabledAdList[i]; var rank:int = d.getRank(type); if(rank <= 0) continue;  var rate:Number = d.getRate(type);  if(Math.random() * 100 < rate){ return d; } }  return _enabledAdList[0];			 }   } }

package net.play5d.game.bvn.mob.ads.ctrl {
import avmplus.getQualifiedClassName;

import flash.events.EventDispatcher;

import net.play5d.game.bvn.mob.ads.AdManager;
import net.play5d.game.bvn.mob.ads.utils.AdEvent;
import net.play5d.game.bvn.mob.ads.utils.AdEventListener;
import net.play5d.game.bvn.mob.ads.utils.IAd;
import net.play5d.game.bvn.mob.utils.TimerOutUtils;

public class AdGroup extends EventDispatcher {


    public function AdGroup() {
        _adList        = new Vector.<IAd>();
        _enabledAdList = new Vector.<IAd>();
        _failAdList    = new Vector.<IAd>();
        super();
    }
    public var onlyOneAd:IAd;
    private var _adList:Vector.<IAd>;
    private var _enabledAdList:Vector.<IAd>;
    private var _failAdList:Vector.<IAd>;
    private var _listener:AdEventListener;
    private var _initAdQueue:Vector.<IAd>;
    private var _initAdCount:int;
    private var _initTimer:int;

    public function avaliable():Boolean {
        return _enabledAdList.length > 0;
    }

    public function getAdList():Vector.<IAd> {
        return _adList;
    }

    public function add(param1:IAd):void {
        _adList.push(param1);
    }

    public function initalize():void {
        if (_adList.length < 1) {
            throw new Error('add ad first!');
        }
        initListener();
        _initAdQueue = new Vector.<IAd>();
        for each(var _loc1_ in _adList) {
            if (_loc1_.getEnabled()) {
                _initAdQueue.push(_loc1_);
            }
            else {
                _failAdList.push(_loc1_);
            }
        }
        _initAdCount = _initAdQueue.length;
        initNext();
    }

    public function cacheInter():void {
        var _loc1_:IAd = getRankAd('INTER');
        if (!_loc1_) {
            return;
        }
        _loc1_.cacheInter();
        dispatchEvent(new AdEvent('METHOD_CALL', 'CACHE', 'INTER', _loc1_));
    }

    public function showInter():void {
        var _loc1_:IAd = getAndCacheRankReadyAd('INTER');
        if (!_loc1_) {
            return;
        }
        AdManager.toast(_loc1_.getName() + '.SHOW INTER');
        _loc1_.showInter();
        dispatchEvent(new AdEvent('METHOD_CALL', 'SHOW', 'INTER', _loc1_));
    }

    public function cacheVideo():void {
        var _loc1_:IAd = getRankAd('VIDEO');
        if (!_loc1_) {
            return;
        }
        _loc1_.cacheVideo();
        dispatchEvent(new AdEvent('METHOD_CALL', 'cache', 'VIDEO', _loc1_));
    }

    public function playVideo():Boolean {
        var _loc1_:IAd = getAndCacheRankReadyAd('VIDEO');
        if (!_loc1_) {
            return false;
        }
        AdManager.toast(_loc1_.getName() + '.PLAY VIDEO');
        _loc1_.playVideo();
        dispatchEvent(new AdEvent('METHOD_CALL', 'play', 'VIDEO', _loc1_));
        return true;
    }

    public function showVideo():Boolean {
        if (playVideo()) {
            return true;
        }
        cacheVideo();
        return false;
    }

    public function showRewardVideo(param1:String, param2:int, param3:Function, param4:Function):void {
        var _loc5_:IAd;
        if (!(
                _loc5_ = getRankAd('REWARD_VIDEO')
        )) {
            return;
        }
        AdManager.toast(_loc5_.getName() + '.REWARD VIDEO');
        _loc5_.playRewardVideo(param1, param2, param3, param4);
    }

    public function showOpen():Boolean {
        var _loc1_:IAd = getRankAd('OPEN');
        if (!_loc1_) {
            return false;
        }
        AdManager.toast(_loc1_.getName() + '.OPEN');
        _loc1_.showOpen();
        dispatchEvent(new AdEvent('METHOD_CALL', 'SHOW', 'OPEN', _loc1_));
        return true;
    }

    public function onGamePause():void {
        for each(var _loc1_ in _enabledAdList) {
            _loc1_.onGamePause();
        }
    }

    public function onGameResume():void {
        for each(var _loc1_ in _enabledAdList) {
            _loc1_.onGameResume();
        }
    }

    public function onDeactive():void {
        for each(var _loc1_ in _enabledAdList) {
            _loc1_.onDeactive();
        }
    }

    public function onActive():void {
        for each(var _loc1_ in _enabledAdList) {
            _loc1_.onActive();
        }
    }

    public function showNativeAd(param1:Boolean):void {
        var _loc2_:IAd = getRankAd('NATIVE');
        if (!_loc2_) {
            return;
        }
        AdManager.toast(_loc2_.getName() + '.NATIVE');
        _loc2_.showNative(param1);
        dispatchEvent(new AdEvent('METHOD_CALL', 'SHOW', 'NATIVE', _loc2_));
    }

    public function closeNativeAd():void {
        for each(var _loc1_ in _enabledAdList) {
            _loc1_.closeNative();
        }
    }

    private function initNext():void {
        TimerOutUtils.clearTimeout(_initTimer);
        if (_initAdQueue.length < 1) {
            adInitComplete();
            return;
        }
        var _loc1_:IAd = _initAdQueue.shift();
        _initTimer     = TimerOutUtils.setTimeout(initTimeout, 5000, _loc1_);
        trace('init ::', _loc1_, ' - ', _initAdCount - _initAdQueue.length, '/', _initAdCount);
        _loc1_.initalize(_listener);
    }

    private function initTimeout(param1:IAd):void {
        trace('init timeout', param1);
        if (_failAdList.indexOf(param1) == -1) {
            _failAdList.push(param1);
        }
        initNext();
    }

    private function testRate():void {
        var _loc6_:int     = 0;
        var _loc7_:IAd     = null;
        var _loc8_:String  = null;
        var _loc3_:IAd     = null;
        var _loc4_:String  = null;
        var _loc5_:int     = 0;
        var _loc12_:Number = NaN;
        var _loc13_:Object;
        (
                _loc13_ = {}
        )['INTER']         = {};
        _loc13_['VIDEO']   = {};
        var _loc2_:Object  = _loc13_['INTER'];
        var _loc11_:Object = _loc13_['VIDEO'];
        while (_loc6_ < 100000) {
            if (_loc7_ = getRankAd('INTER')) {
                _loc8_ = getQualifiedClassName(_loc7_);
                if (_loc2_[_loc8_] === undefined) {
                    _loc2_[_loc8_] = 0;
                }
                _loc2_[_loc8_]++;
            }
            _loc3_ = getRankAd('VIDEO');
            if (_loc3_) {
                _loc4_ = getQualifiedClassName(_loc3_);
                if (_loc11_[_loc4_] === undefined) {
                    _loc11_[_loc4_] = 0;
                }
                _loc11_[_loc4_]++;
            }
            _loc6_++;
        }
        trace('------ RANK REPORT [ Count:' + 100000 + ' ] ---------------------------------------------------------');
        for (var _loc9_ in _loc13_) {
            trace(_loc9_ + '    -----------------------------------------------------------------');
            for (var _loc10_ in _loc13_[_loc9_]) {
                _loc12_ = (
                                  _loc5_ = int(_loc13_[_loc9_][_loc10_])
                          ) / 100000 * 100;
                trace(_loc10_ + ' : ' + _loc12_ + '%');
            }
            trace('-----------------------------------------------------------------');
        }
    }

    private function initListener():void {
        _listener = new AdEventListener();
        _listener.listen('INIT_OK', adHandler);
        _listener.listen('INIT_FAIL', adHandler);
        _listener.listen('SHOW', adHandler);
        _listener.listen('CLOSE', adHandler);
        _listener.listen('CLICK', adHandler);
        _listener.listen('SUCCESS', adHandler);
        _listener.listen('ERROR', adHandler);
    }

    private function adHandler(param1:IAd = null, param2:String = null, param3:String = null):void {
        if (param3 == 'INIT_OK') {
            if (_enabledAdList.indexOf(param1) == -1) {
                _enabledAdList.push(param1);
                initNext();
                return;
            }
        }
        if (param3 == 'INIT_FAIL') {
            if (_failAdList.indexOf(param1) == -1) {
                _failAdList.push(param1);
                initNext();
                return;
            }
        }
        dispatchEvent(new AdEvent('AD_ACTION', param3, param2, param1));
    }

    private function adInitComplete():void {
        trace('all ad is ok!');
        dispatchEvent(new AdEvent('AD_ACTION', 'INIT_OK', null, null));
    }

    private function getAndCacheRankReadyAd(param1:String):IAd {
        if (onlyOneAd) {
            return onlyOneAd;
        }
        var _loc3_:Vector.<IAd> = getRankAdList(param1);
        if (_loc3_ == null || _loc3_.length < 1) {
            return null;
        }
        var _loc2_:IAd = getReadyAd(_loc3_, param1);
        if (_loc2_ != null) {
            if (_loc3_[0] != _loc2_) {
                if (param1 == 'VIDEO') {
                    _loc3_[0].cacheVideo();
                }
                if (param1 == 'INTER') {
                    _loc3_[0].cacheInter();
                }
            }
        }
        return _loc2_;
    }

    private function getReadyAd(param1:Vector.<IAd>, param2:String):IAd {
        var _loc4_:int = 0;
        var _loc3_:IAd = null;
        if (onlyOneAd) {
            return onlyOneAd;
        }
        while (_loc4_ < param1.length) {
            _loc3_ = param1[_loc4_];
            switch (param2) {
            case 'INTER':
                if (_loc3_.interReady()) {
                    return _loc3_;
                }
                break;
            case 'VIDEO':
                if (_loc3_.videoReady()) {
                    return _loc3_;
                }
                break;
            }
            _loc4_++;
        }
        return null;
    }

    private function getRankAd(param1:String):IAd {
        var enabledTypeList:Vector.<IAd>;
        var i:int;
        var d:IAd;
        var rank:int;
        var rate:Number;
        var type:String = param1;
        var sortAd:*    = function (param1:IAd, param2:IAd):int {
            if (param1.getRank(type) > param2.getRank(type)) {
                return -1;
            }
            if (param1.getRank(type) < param2.getRank(type)) {
                return 1;
            }
            return 0;
        };
        if (onlyOneAd) {
            if (onlyOneAd.getADEnabled(type)) {
                return onlyOneAd;
            }
            return null;
        }
        enabledTypeList = _enabledAdList.filter(function (param1:IAd, param2:int, param3:Vector.<IAd>):Boolean {
            return param1.getADEnabled(type);
        });
        if (enabledTypeList.length < 1) {
            return null;
        }
        enabledTypeList.sort(sortAd);
        while (i < enabledTypeList.length) {
            d    = enabledTypeList[i];
            rank = d.getRank(type);
            if (rank > 0) {
                rate = d.getRate(type);
                if (Math.random() * 100 < rate) {
                    return d;
                }
            }
            i++;
        }
        return enabledTypeList[0];
    }

    private function getRankAdList(param1:String):Vector.<IAd> {
        var enabledTypeList:Vector.<IAd>;
        var i:int;
        var d:IAd;
        var rank:int;
        var rate:Number;
        var j:int;
        var ad:IAd;
        var type:String         = param1;
        var sortAd:*            = function (param1:IAd, param2:IAd):int {
            if (param1.getRank(type) > param2.getRank(type)) {
                return -1;
            }
            if (param1.getRank(type) < param2.getRank(type)) {
                return 1;
            }
            return 0;
        };
        var result:Vector.<IAd> = new Vector.<IAd>();
        if (onlyOneAd) {
            if (onlyOneAd.getADEnabled(type)) {
                result.push(onlyOneAd);
                return result;
            }
            return null;
        }
        enabledTypeList = _enabledAdList.filter(function (param1:IAd, param2:int, param3:Vector.<IAd>):Boolean {
            return param1.getADEnabled(type);
        });
        if (enabledTypeList.length < 1) {
            return null;
        }
        enabledTypeList.sort(sortAd);
        while (i < enabledTypeList.length) {
            d    = enabledTypeList[i];
            rank = d.getRank(type);
            if (rank > 0) {
                rate = d.getRate(type);
                if (Math.random() * 100 < rate) {
                    result.push(d);
                }
            }
            i++;
        }
        while (j < enabledTypeList.length) {
            ad = enabledTypeList[j];
            if (result.indexOf(ad) == -1) {
                result.push(ad);
            }
            j++;
        }
        return result;
    }
}
}
