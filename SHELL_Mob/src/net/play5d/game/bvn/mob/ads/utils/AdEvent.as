package net.play5d.game.bvn.mob.ads.utils {
import flash.events.Event;

public class AdEvent extends Event {
    /**
     * AD事件
     */
    public static const AD_ACTION:String = 'AD_ACTION';

    /**
     * 方法调用
     */
    public static const METHOD_CALL:String = 'METHOD_CALL';

    public function AdEvent(type:String, adAction:String, adType:String, ad:IAd = null) {
        super(type, false, false);
        this.adType   = adType;
        this.adAction = adAction;
        this.ad       = ad;
    }
    public var ad:IAd;
    public var adType:String;
    public var adAction:String;
}
}
