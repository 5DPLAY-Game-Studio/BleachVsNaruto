package net.play5d.game.bvn.mob.data {
public class AdConfVO {

    public function AdConfVO() {
    }
    public var code:String;
    public var rank:Number     = 0;
    public var rate:Number     = 0;
    public var enabled:Boolean = true;

    public function toString():String {
        return 'AdConfVO ::  ' +
               'enabled[' + enabled + ']' +
               ' code[' + code + ']' +
               ' rank[' + rank + ']' +
               ' rate[' + rate + ']';
    }
}
}
