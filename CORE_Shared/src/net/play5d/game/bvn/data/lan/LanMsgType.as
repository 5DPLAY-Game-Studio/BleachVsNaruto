/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.data.lan {

/**
 * 局域网消息类型公开常量（跨壳一致部分）。
 *
 * <p><code>FIND_HOST</code> / <code>FIND_HOST_BACK</code> 因 Pc（String）与 Mob（int）线格式不同，
 * 仍由各壳消息类型定义。</p>
 *
 * @see LanSocketMsgFactory
 */
public class LanMsgType {
    include '../../../../../../../include/ImportVersion.as';

    /** 聊天 */
    public static const CHAT:String = 'CHAT';

    /** 开始游戏 */
    public static const START_GAME:String = 'START_GAME';

    /** 请求加入 */
    public static const JOIN:String      = 'JOIN';
    /** 已加入房间 */
    public static const JOIN_IN:String   = 'JOIN_IN';
    /** 加入结果回包 */
    public static const JOIN_BACK:String = 'JOIN_BACK';

    /** 踢出房间 */
    public static const KICK_OUT:String = 'KICK_OUT';

    /** 输入发送 */
    public static const INPUT_SEND:int   = 8;
    /** 输入更新 */
    public static const INPUT_UPDATE:int = 9;
    /** 输入同步 */
    public static const INPUT_SYNC:int   = 10;

}
}
