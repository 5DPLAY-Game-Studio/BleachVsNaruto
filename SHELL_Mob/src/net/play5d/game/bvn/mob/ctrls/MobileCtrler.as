package net.play5d.game.bvn.mob.ctrls {
import flash.system.System;

import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.mob.ads.AdManager;

public class MobileCtrler {
    private static var _i:MobileCtrler;

    public static function get I():MobileCtrler {
        _i ||= new MobileCtrler();
        return _i;
    }

    public function MobileCtrler() {
    }
    public var isAdPause:Boolean;

    public function adPause():void {
        if (isAdPause) {
            return;
        }

        trace('adPause');

        isAdPause = true;

        GameCtrl.I.pause(true);
        SoundCtrl.I.pauseBGM();
    }

    public function adResume():void {
        if (!isAdPause) {
            return;
        }

        isAdPause = false;

        trace('adResume');

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
        SoundCtrl.I.resumeBGM();
    }

}
}
