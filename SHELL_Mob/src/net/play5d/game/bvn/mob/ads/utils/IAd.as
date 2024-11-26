package net.play5d.game.bvn.mob.ads.utils {
import net.play5d.game.bvn.mob.ads.AdConfigCode;

public interface IAd {
    /**
     * 是否有效
     */
    function getEnabled():Boolean;

    /**
     * 初始化
     */
    function initalize(listener:AdEventListener):void;

    /**
     * 超时时间（有效期）
     */
    function exceptDate():Date;

    /**
     * 获取权重 0 - 10
     */
    function getRank(type:String):int;

    /**
     * 设置权重 0 - 10
     */
    function setRank(param1:String, param2:int):void;

    /**
     * 获取概率 = - 100
     */
    function getRate(type:String):Number;

    /**
     * 设置概率
     */
    function setRate(param1:String, param2:Number):void;


    function getADEnabled(param1:String):Boolean;

    function setADEnabled(param1:String, param2:Boolean):void;


    /**
     * 开屏
     */
    function showOpen():void;

    /**
     * 缓存插屏
     */
    function cacheInter():void;

    /**
     * 插屏缓存完成
     */
    function interReady():Boolean;

    /**
     * 插屏
     */
    function showInter():void;


    function showNative(param1:Boolean):void;

    function closeNative():void;

    /**
     * 缓存视频
     */
    function cacheVideo():void;

    /**
     * 视频缓存成功
     */
    function videoReady():Boolean;

    /**
     * 播放视频
     */
    function playVideo():void;


    function playRewardVideo(param1:String, param2:int, param3:Function, param4:Function):void;


    /**
     * 暂停游戏时
     */
    function onGamePause():void;

    /**
     * 恢复游戏时
     */
    function onGameResume():void;

    function getName():String;

    function onDeactive():void;

    function onActive():void;

    function getConfigCode():AdConfigCode;
}
}
