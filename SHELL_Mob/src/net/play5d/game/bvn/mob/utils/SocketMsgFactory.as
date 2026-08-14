package net.play5d.game.bvn.mob.utils {
import flash.utils.ByteArray;

import net.play5d.game.bvn.data.lan.LanSocketMsgFactory;
import net.play5d.game.bvn.mob.ctrls.LANServerCtrl;

/**
 * Mob 壳局域网消息工厂；共用 Object 消息委托 <code>LanSocketMsgFactory</code>。
 *
 * @see LanSocketMsgFactory
 */
public class SocketMsgFactory {
    /**
     * 寻找主机
     */
    public static function createFindHostMsg():ByteArray {
        var byte:ByteArray = new ByteArray();
        byte.writeByte(MsgType.FIND_HOST);
        return byte;
    }

    /**
     * 寻找主机返回
     */
    public static function createFindHostBackMsg():ByteArray {
        var byte:ByteArray = new ByteArray();
        byte.writeByte(MsgType.FIND_HOST_BACK);
        byte.writeBytes(LANServerCtrl.I.host.toByteArray());
        return byte;
    }

    /**
     * 加入游戏
     */
    public static function createJoinMsg():Object {
        return LanSocketMsgFactory.createJoinMsg('mobile_user');
    }

    /**
     * 加入游戏成功
     */
    public static function createJoinSuccessMsg():Object {
        return LanSocketMsgFactory.createJoinSuccessMsg();
    }

    /**
     * 加入房间
     */
    public static function createJoinInMsg():Object {
        return LanSocketMsgFactory.createJoinInMsg('mobile_user');
    }

    /**
     * 加入游戏失败
     */
    public static function createJoinFailMsg(msg:String = null):Object {
        return LanSocketMsgFactory.createJoinFailMsg(msg);
    }

    /**
     * 踢出房间
     */
    public static function createKickOutMsg(msg:String = null):Object {
        return LanSocketMsgFactory.createKickOutMsg(msg);
    }

    /**
     * 消息
     */
    public static function createChat(content:String, name:String):Object {
        return LanSocketMsgFactory.createChat(content, name);
    }

    /**
     * 开始游戏
     */
    public static function createStartGame():Object {
        return LanSocketMsgFactory.createStartGame();
    }

}
}
