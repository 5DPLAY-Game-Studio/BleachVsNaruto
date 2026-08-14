/*
 * Copyright (C) 2021-2024, 5DPLAY Game Studio
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package net.play5d.game.bvn.win.utils {
import net.play5d.game.bvn.data.lan.LanMsgType;

/**
 * PC 壳局域网消息类型。
 *
 * <p>跨平台常量委托 <code>LanMsgType</code>；寻主机为 Object/String 线格式。</p>
 *
 * @see LanMsgType
 */
public class MsgType {

    public static const CHAT:String = LanMsgType.CHAT;

    public static const START_GAME:String = LanMsgType.START_GAME;

    public static const JOIN:String      = LanMsgType.JOIN;
    public static const JOIN_IN:String   = LanMsgType.JOIN_IN;
    public static const JOIN_BACK:String = LanMsgType.JOIN_BACK;

    /** PC：字符串寻主机 */
    public static const FIND_HOST:String      = 'FIND_HOST';
    public static const FIND_HOST_BACK:String = 'FIND_HOST_BACK';

    public static const KICK_OUT:String = LanMsgType.KICK_OUT;

    public static const INPUT_SEND:int   = LanMsgType.INPUT_SEND;
    public static const INPUT_UPDATE:int = LanMsgType.INPUT_UPDATE;
    public static const INPUT_SYNC:int   = LanMsgType.INPUT_SYNC;

}
}
