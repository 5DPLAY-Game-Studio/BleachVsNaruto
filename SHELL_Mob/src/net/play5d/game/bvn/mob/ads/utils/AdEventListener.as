package net.play5d.game.bvn.mob.ads.utils {
public class AdEventListener {

    public function AdEventListener() {
    }
    private var _listenMap:Object = {};

    public function listen(adAction:String, handler:Function):void {
        if (_listenMap[adAction]) {
            throw Error(adAction + '已侦听，仅支持侦听一次！');
        }
        _listenMap[adAction] = handler;
    }

    public function onInitOK(ad:IAd):void {
        doFunction(AdAction.INIT_OK, ad);
    }

    public function onInitFail(ad:IAd):void {
        doFunction(AdAction.INIT_FAIL, ad);
    }

    public function onShow(ad:IAd, adType:String):void {
        doFunction(AdAction.SHOW, ad, adType);
    }

    public function onClose(ad:IAd, adType:String):void {
        doFunction(AdAction.CLOSE, ad, adType);
    }

    public function onClick(ad:IAd, adType:String):void {
        doFunction(AdAction.CLICK, ad, adType);
    }

    public function onError(ad:IAd, adType:String):void {
        doFunction(AdAction.ERROR, ad, adType);
    }

    private function doFunction(adAction:String, target:IAd, adType:String = null):void {
        if (_listenMap[adAction]) {
            _listenMap[adAction](target, adType, adAction);
        }
    }

}
}
