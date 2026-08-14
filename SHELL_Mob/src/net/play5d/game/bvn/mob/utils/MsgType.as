package net.play5d.game.bvn.mob.utils {
import net.play5d.game.bvn.data.lan.LanMsgType;

/**
 * 移动壳局域网消息类型。
 *
 * <p>跨平台常量委托 <code>LanMsgType</code>；寻主机为 ByteArray/int 线格式。</p>
 *
 * @see LanMsgType
 */
public class MsgType {

    public static const CHAT:String = LanMsgType.CHAT;

    public static const START_GAME:String = LanMsgType.START_GAME;

    public static const JOIN:String      = LanMsgType.JOIN;
    public static const JOIN_IN:String   = LanMsgType.JOIN_IN;
    public static const JOIN_BACK:String = LanMsgType.JOIN_BACK;

    /** Mob：整型寻主机 */
    public static const FIND_HOST:int      = 20;
    public static const FIND_HOST_BACK:int = 21;

    public static const KICK_OUT:String = LanMsgType.KICK_OUT;

    public static const INPUT_SEND:int   = LanMsgType.INPUT_SEND;
    public static const INPUT_UPDATE:int = LanMsgType.INPUT_UPDATE;
    public static const INPUT_SYNC:int   = LanMsgType.INPUT_SYNC;

}
}
