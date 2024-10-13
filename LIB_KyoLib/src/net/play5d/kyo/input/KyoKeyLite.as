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

package net.play5d.kyo.input {
import flash.display.Stage;
import flash.events.KeyboardEvent;

public class KyoKeyLite {
    public static var debug:Boolean = false;
    private static var _stage:Stage;
    private static var _keyDowning:Object;

    public static function active(stage:Stage):void {
        _stage = stage;

        if (!_stage) {
            throw new Error('stage is null!');
            return;
        }

        _keyDowning = {};
        stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
        stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
    }

    public static function off():void {
        if (!_stage) {
            return;
        }
        _stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
        _stage.removeEventListener(KeyboardEvent.KEY_UP, keyHandler);
    }

    public static function isDown(code:uint):Boolean {
        if (!_keyDowning) {
            throw new Error('此类尚未激活，需要先调用active方法!');
            return false;
        }
        return _keyDowning[code] != null;
    }

    public function KyoKeyLite() {
    }

    private static function keyHandler(e:KeyboardEvent):void {
        var code:uint = e.keyCode;
        if (e.type == KeyboardEvent.KEY_DOWN) {
            _keyDowning[code] = 1;
        }
        if (e.type == KeyboardEvent.KEY_UP) {
            delete _keyDowning[code];
        }
        if (debug) {
            trace(e.type + ' : ' + code);
        }
    }

}
}
