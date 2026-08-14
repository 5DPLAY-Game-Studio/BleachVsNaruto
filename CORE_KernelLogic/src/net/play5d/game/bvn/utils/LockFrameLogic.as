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

package net.play5d.game.bvn.utils {
import flash.display.Stage;
import flash.events.Event;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.GameRender;
import net.play5d.game.bvn.data.GameData;

/**
 * 局域网锁帧：统一 30FPS / 长按输入，并按服务端或客户端回调驱动是否渲染。
 *
 * @see #initServer()
 * @see #initClient()
 */
public class LockFrameLogic {

    /** @private */
    private static var _i:LockFrameLogic;

    /**
     * 单例。
     */
    public static function get I():LockFrameLogic {
        _i ||= new LockFrameLogic();
        return _i;
    }

    /** @private */
    private var _stage:Stage;
    /** @private */
    private var _orgFps:int;
    /** @private */
    private var _orgInputMode:int;
    /** @private 无参，返回 Boolean */
    private var _renderGame:Function;

    /**
     * 以服务端模式初始化。
     * @param renderGame 每帧调用，返回是否允许 <code>GameRender</code>。
     */
    public function initServer(renderGame:Function):void {
        _renderGame = renderGame;
        init(MainGame.I.stage);
    }

    /**
     * 以客户端模式初始化。
     * @param renderGame 每帧调用，返回是否允许 <code>GameRender</code>。
     */
    public function initClient(renderGame:Function):void {
        _renderGame = renderGame;
        init(MainGame.I.stage);
    }

    /**
     * 解除锁帧并还原 FPS / 输入模式。
     */
    public function dispose():void {
        if (_stage) {
            _stage.removeEventListener(Event.ENTER_FRAME, render);
        }
        GameRender.isRender = true;
        _renderGame         = null;

        GameConfig.setGameFps(_orgFps);
        GameData.I.config.keyInputMode = _orgInputMode;
    }

    /** @private */
    private function init(stage:Stage):void {
        _stage = stage;
        stage.addEventListener(Event.ENTER_FRAME, render);

        _orgFps       = GameConfig.FPS_GAME;
        _orgInputMode = GameData.I.config.keyInputMode;

        GameConfig.setGameFps(30);
        GameData.I.config.keyInputMode = 1;
    }

    /** @private */
    private function render(e:Event):void {
        if (_renderGame != null) {
            GameRender.isRender = _renderGame();
        }
    }

}
}
