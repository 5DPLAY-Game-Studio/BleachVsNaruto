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

package net.play5d.game.bvn.win.ctrls {
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.win.sockets.SocketClient;
import net.play5d.game.bvn.win.views.lan.LANGameState;

public class LANGameCtrl {

    public static const PORT_UDP_SERVER:int = 17477;
    public static const PORT_UDP_CLIENT:int = 17478;

    public static const PORT_TCP:int = 17511;

    private static var _i:LANGameCtrl;

    public static function get I():LANGameCtrl {
        _i ||= new LANGameCtrl();
        return _i;
    }

    public function LANGameCtrl() {
    }
    public var gameMode:int;
    public var userName:String = 'test';
    private var _client:SocketClient;

    public function goLANGameState():void {
        this.gameMode = gameMode;
        MainGame.stageCtrl.goStage(new LANGameState());
    }

}
}
