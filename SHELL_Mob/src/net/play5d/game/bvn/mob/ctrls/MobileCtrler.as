package net.play5d.game.bvn.mob.ctrls {
import flash.system.System;

import net.play5d.game.bvn.ctrl.SoundCtrl;
import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
import net.play5d.game.bvn.mob.ads.AdManager;

//	import net.play5d.game.bvn.mob.utils.UMengAneManager;
public class MobileCtrler {
    private static var _i:MobileCtrler;

    public static function get I():MobileCtrler {
        _i ||= new MobileCtrler();
        return _i;
    }

//		private var _adPauseView:AdPauseView;

    public function MobileCtrler() {
    }
    public var isAdPause:Boolean;

    public function adPause():void {
        if (isAdPause) {
            return;
        }

        trace('adPause');

        isAdPause = true;

//			if(!_adPauseView){
//				_adPauseView = new AdPauseView();
//			}
//			launch.STAGE.addChild(_adPauseView);

        GameCtrl.I.pause(true);
        SoundCtrl.I.pauseBGM();
    }

    public function adResume():void {
        if (!isAdPause) {
            return;
        }

        isAdPause = false;

        trace('adResume');

//			if(_adPauseView){
//				try{
//					launch.STAGE.removeChild(_adPauseView);
//				}catch(e:Error){}
//			}
        SoundCtrl.I.resumeBGM();
        GameCtrl.I.resume(true);
    }

    public function pause():void {
        trace('pause process');
        System.pause();
        GameCtrl.I.pause(true);
        SoundCtrl.I.pauseBGM();
        AdManager.I.onPause();
    }

    public function resume():void {
        trace('resume process');
        System.resume();
        AdManager.I.onResume();
//			if(!isAdPause){
        SoundCtrl.I.resumeBGM();
//				GameCtrl.I.resume(true);
//			}
    }

}
}
