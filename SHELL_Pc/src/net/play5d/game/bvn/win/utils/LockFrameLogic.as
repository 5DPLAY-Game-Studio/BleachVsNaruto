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
import flash.display.Stage;
import flash.events.Event;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrl.GameRender;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.win.ctrls.LANClientCtrl;
import net.play5d.game.bvn.win.ctrls.LANServerCtrl;

/**
 * 锁帧算法
 */
public class LockFrameLogic {

    private static var _i:LockFrameLogic;

    public static function get I():LockFrameLogic {
        _i ||= new LockFrameLogic();
        return _i;
    }

    public function LockFrameLogic() {
    }
    private var _mode:int;
    private var _stage:Stage;
    private var _orgFps:int;
    private var _orgInputMode:int;

    public function initServer():void {
        _mode = 1;
        init(MainGame.I.stage);
//			GameConfig.setGameFps(60);
    }

    public function initClient():void {
        _mode = 2;
        init(MainGame.I.stage);
//			GameConfig.setGameFps(30);
    }

    public function dispose():void {
        if (_stage) {
            _stage.removeEventListener(Event.ENTER_FRAME, render);
        }
        GameRender.isRender = true;

        //还原原来的设置
        GameConfig.setGameFps(_orgFps);
        GameData.I.config.keyInputMode = _orgInputMode;
    }

    private function init(stage:Stage):void {
        _stage = stage;
        stage.addEventListener(Event.ENTER_FRAME, render);


        //统一使用30FPS，长按模式进行游戏
        _orgFps       = GameConfig.FPS_GAME;
        _orgInputMode = GameData.I.config.keyInputMode;

        GameConfig.setGameFps(30);
        GameData.I.config.keyInputMode = 1;

    }

    private function render(e:Event):void {

        if (_mode == 1) {
            GameRender.isRender = LANServerCtrl.I.renderGame();
        }

        if (_mode == 2) {
            GameRender.isRender = LANClientCtrl.I.renderGame();
        }

    }

}
}
