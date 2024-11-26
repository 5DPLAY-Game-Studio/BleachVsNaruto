package net.play5d.game.bvn.mob.ads.ctrl {
import net.play5d.game.bvn.mob.ads.utils.IAd;

public class AdConfDir {

    public function AdConfDir(code:String, ad:IAd, type:String) {
        this.code = code;
        this.ad   = ad;
        this.type = type;
    }
    public var code:String;
    public var ad:IAd;
    public var type:String;

    public function toString():String {
        var str:String = 'AdConfDir ::  code[' + code + ']' + ' type[' + type + ']';

        if (ad) {
            str += ' enabled[' + ad.getADEnabled(type) + '] rank[' + ad.getRank(type) + ']' + ' rate[' +
                   ad.getRate(type) + ']';
        }

        return str;
    }
}
}
