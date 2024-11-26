package net.play5d.game.bvn.mob.ads {
import net.play5d.game.bvn.mob.ads.utils.AdEventListener;
import net.play5d.game.bvn.mob.ads.utils.IAd;

public class BaseAd implements IAd {

    public function BaseAd() {
    }
    protected var $enabled:Boolean         = true;
    protected var $name:String             = 'Unset Name';
    protected var $interReady:Boolean      = false;
    protected var $videoReady:Boolean      = false;
    protected var $configCode:AdConfigCode = null;
    protected var $exceptDate:Date;
    private var _rankObj:Object     = {};
    private var _rateObj:Object     = {};
    private var _adEnableObj:Object = {};

    public function getEnabled():Boolean {
        return $enabled;
    }

    public function exceptDate():Date {
        return $exceptDate;
    }

    public function getRank(type:String):int {
        if (_rankObj[type]) {
            return _rankObj[type];
        }

        return 3;
    }

    public function setRank(type:String, v:int):void {
        _rankObj[type] = v;
    }

    public function getRate(type:String):Number {
        if (_rateObj[type]) {
            return _rateObj[type];
        }

        return 10;
    }

    public function setRate(type:String, v:Number):void {
        _rateObj[type] = v;
    }

    public function setRankAndRate(type:String, rank:int, rate:Number):void {
        _rankObj[type] = rank;
        _rateObj[type] = rate;
    }

    public function getADEnabled(type:String):Boolean {
        if (_adEnableObj[type] !== undefined) {
            return _adEnableObj[type];
        }
        return true;
    }

    public function setADEnabled(type:String, v:Boolean):void {
        _adEnableObj[type] = v;
    }

    public function getName():String {
        return $name;
    }

    public function interReady():Boolean {
        return $interReady;
    }

    public function videoReady():Boolean {
        return $videoReady;
    }

    public function getConfigCode():AdConfigCode {
        return $configCode;
    }

    public function initalize(listener:AdEventListener):void {
    }

    public function showOpen():void {
    }

    public function cacheInter():void {
    }

    public function showInter():void {
    }

    public function showNative(showClose:Boolean):void {
    }

    public function closeNative():void {
    }

    public function cacheVideo():void {
    }

    public function playVideo():void {
    }

    public function playRewardVideo(rewardName:String, rewardValue:int, success:Function, fail:Function):void {
    }

    public function onGamePause():void {
    }

    public function onGameResume():void {
    }

    public function onDeactive():void {
    }

    public function onActive():void {
    }
}
}
