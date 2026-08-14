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
import net.play5d.game.bvn.data.lan.LanSocketMsgFactory;
import net.play5d.game.bvn.win.ctrls.LANServerCtrl;
import net.play5d.game.bvn.win.data.LanGameModel;

/**
 * PC 壳局域网消息工厂；共用 Object 消息委托 <code>LanSocketMsgFactory</code>。
 *
 * @see LanSocketMsgFactory
 */
public class SocketMsgFactory {
    /**
     * 寻找主机
     */
    public static function createFindHostMsg():Object {
        var msg:Object = {};
        msg.type       = MsgType.FIND_HOST;
        return msg;
    }

    /**
     * 寻找主机返回
     */
    public static function createFindHostBackMsg():Object {
        var msg:Object = {};
        msg.type       = MsgType.FIND_HOST_BACK;
        msg.host       = LANServerCtrl.I.host.toJson();
        return msg;
    }

    /**
     * 加入游戏
     */
    public static function createJoinMsg():Object {
        return LanSocketMsgFactory.createJoinMsg(LanGameModel.I.playerName);
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
        return LanSocketMsgFactory.createJoinInMsg(LanGameModel.I.playerName);
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
