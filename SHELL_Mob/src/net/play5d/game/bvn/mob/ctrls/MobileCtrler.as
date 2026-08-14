package net.play5d.game.bvn.mob.ctrls {
import flash.system.System;

import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;

public class MobileCtrler {
    private static var _i:MobileCtrler;

    public static function get I():MobileCtrler {
        _i ||= new MobileCtrler();
        return _i;
    }

    public function MobileCtrler() {
    }

    public function pause():void {
        trace('pause process');
        System.pause();
        GameCtrl.I.pause(true);
        SoundCtrl.I.pauseBGM();
    }

    public function resume():void {
        trace('resume process');
        System.resume();
        SoundCtrl.I.resumeBGM();
    }

}
}
