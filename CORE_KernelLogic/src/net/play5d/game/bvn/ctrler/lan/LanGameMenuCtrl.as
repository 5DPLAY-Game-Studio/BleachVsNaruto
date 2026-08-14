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

package net.play5d.game.bvn.ctrler.lan {
import flash.display.DisplayObject;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.interfaces.lan.ILanExitDialog;
import net.play5d.kyo.utils.KeyBoarder;

/**
 * 联机对局 ESC 退出菜单（对话框由壳注入）。
 *
 * @see net.play5d.game.bvn.interfaces.lan.ILanExitDialog
 */
public class LanGameMenuCtrl {
    /** @private */
    private static var _i:LanGameMenuCtrl;

    /**
     * 单例。
     * @return 实例。
     */
    public static function get I():LanGameMenuCtrl {
        _i ||= new LanGameMenuCtrl();

        return _i;
    }

    /**
     * 构造控制器。
     */

    /** @private */
    private var _isKeyDown:Boolean;
    /** @private */
    private var _exitDialog:ILanExitDialog;

    /**
     * 注册 ESC 监听并挂上退出对话框。
     * @param dialog 壳层对话框（须为 <code>DisplayObject</code>）。
     */
    public function init(dialog:ILanExitDialog):void {
        _exitDialog = dialog;
        _exitDialog.hide();
        KeyBoarder.listen(keyHandler);
    }

    /**
     * 移除监听并销毁对话框。
     */
    public function dispose():void {
        if (_exitDialog) {
            try {
                MainGame.I.root.removeChild(_exitDialog as DisplayObject);
            }
            catch (e:Error) {
                trace(e);
            }
            _exitDialog.destroy();
            _exitDialog = null;
        }

        KeyBoarder.unlisten(keyHandler);

        _isKeyDown = false;
    }

    /** @private */
    private function keyHandler(e:KeyboardEvent):void {
        if (e.type == KeyboardEvent.KEY_DOWN) {
            if (_isKeyDown) {
                return;
            }
            if (!_exitDialog) {
                return;
            }
            if (e.keyCode == Keyboard.ESCAPE) {
                _isKeyDown = true;
                if (_exitDialog.isShowing()) {
                    _exitDialog.hide();
                }
                else {
                    MainGame.I.root.addChild(_exitDialog as DisplayObject);
                    _exitDialog.show();
                }
            }
        }

        if (e.type == KeyboardEvent.KEY_UP) {
            if (e.keyCode == Keyboard.ESCAPE) {
                _isKeyDown = false;
            }
        }
    }
}
}
