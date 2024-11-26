package net.play5d.game.bvn.mob.utils {
public class UDPMsgFactory {
    public static function createFindHostMsg():String {
        return MsgType.FIND_HOST.toString();
    }

    public static function createFindHostBackMsg():String {
        return MsgType.FIND_HOST_BACK.toString();
    }

    public function UDPMsgFactory() {
    }


}
}
