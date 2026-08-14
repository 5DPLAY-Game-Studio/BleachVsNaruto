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
 * 跨壳一致的局域网 Object/JSON 消息工厂（静态公开 API）。
 *
 * <p>仅构造与 <code>LanMsgType</code> 对齐的消息对象；不含收发。
 * 寻主机（FIND_HOST）因 Pc/Mob 线格式不同，仍由各壳消息工厂实现。</p>
 *
 * @see LanMsgType
 */
public class LanSocketMsgFactory {
    include '../../../../../../../include/ImportVersion.as';

    /**
     * 创建「请求加入」消息。
     * @param name 玩家名。
     * @return 含 <code>type=JOIN</code> 的消息对象。
     * @example
     * <listing version="3.0">
     * LanSocketMsgFactory.createJoinMsg('player1');
     * </listing>
     */
    public static function createJoinMsg(name:String):Object {
        var msg:Object = {};
        msg.type       = LanMsgType.JOIN;
        msg.name       = name;

        return msg;
    }

    /**
     * 创建「加入成功」回包。
     * @return 含 <code>type=JOIN_BACK</code>、<code>success=true</code> 的消息对象。
     * @example
     * <listing version="3.0">
     * LanSocketMsgFactory.createJoinSuccessMsg();
     * </listing>
     */
    public static function createJoinSuccessMsg():Object {
        var msg:Object = {};
        msg.type       = LanMsgType.JOIN_BACK;
        msg.success    = true;

        return msg;
    }

    /**
     * 创建「有人加入房间」通知。
     * @param name 玩家名。
     * @return 含 <code>type=JOIN_IN</code> 的消息对象。
     * @example
     * <listing version="3.0">
     * LanSocketMsgFactory.createJoinInMsg('player1');
     * </listing>
     */
    public static function createJoinInMsg(name:String):Object {
        var msg:Object = {};
        msg.type       = LanMsgType.JOIN_IN;
        msg.name       = name;

        return msg;
    }

    /**
     * 创建「加入失败」回包。
     * @param failReason 失败原因；可为 <code>null</code>。
     * @return 含 <code>type=JOIN_BACK</code>、<code>success=false</code> 的消息对象。
     * @example
     * <listing version="3.0">
     * LanSocketMsgFactory.createJoinFailMsg('room full');
     * </listing>
     */
    public static function createJoinFailMsg(failReason:String = null):Object {
        var msg:Object = {};
        msg.type       = LanMsgType.JOIN_BACK;
        msg.success    = false;
        msg.msg        = failReason;

        return msg;
    }

    /**
     * 创建「踢出房间」消息。
     * @param reason 原因；可为 <code>null</code>。
     * @return 含 <code>type=KICK_OUT</code> 的消息对象。
     * @example
     * <listing version="3.0">
     * LanSocketMsgFactory.createKickOutMsg('timeout');
     * </listing>
     */
    public static function createKickOutMsg(reason:String = null):Object {
        var msg:Object = {};
        msg.type       = LanMsgType.KICK_OUT;
        msg.msg        = reason;

        return msg;
    }

    /**
     * 创建聊天消息。
     *
     * @param content 聊天内容。
     * @param name 发送者名。
     * @return 含 <code>type=CHAT</code> 的消息对象。
     * @example
     * <listing version="3.0">
     * LanSocketMsgFactory.createChat('hello', 'player1');
     * </listing>
     */
    public static function createChat(content:String, name:String):Object {
        var msg:Object = {};
        msg.type       = LanMsgType.CHAT;
        msg.msg        = content;
        msg.name       = name;

        return msg;
    }

    /**
     * 创建「开始游戏」消息。
     * @return 含 <code>type=START_GAME</code> 的消息对象。
     * @example
     * <listing version="3.0">
     * LanSocketMsgFactory.createStartGame();
     * </listing>
     */
    public static function createStartGame():Object {
        var msg:Object = {};
        msg.type       = LanMsgType.START_GAME;

        return msg;
    }
}
}
