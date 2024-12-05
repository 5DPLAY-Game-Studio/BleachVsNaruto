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

package net.play5d.game.bvn.ctrl {
import flash.display.Stage;
import flash.events.Event;
import flash.utils.Dictionary;

/**
 * 全局渲染器
 */
public class GameRender {
    include '../../../../../../include/_INCLUDE_.as';

    public static var isRender:Boolean = true;
    private static var _fucs:Dictionary = new Dictionary();

    public static function initlize(stage:Stage):void {
        stage.addEventListener(Event.ENTER_FRAME, render);
    }

    public static function add(func:Function, owner:* = null):void {
        owner ||= 'anyone';
        if (_fucs[owner] && _fucs[owner].indexOf(func) != -1) {
            return;
        }
        _fucs[owner] ||= new Vector.<Function>;
        _fucs[owner].push(func);
    }

    public static function remove(func:Function, owner:* = null):void {
        owner ||= 'anyone';
        if (!_fucs[owner]) {
            return;
        }
        var id:int = _fucs[owner].indexOf(func);
        if (id != -1) {
            _fucs[owner].splice(id, 1);
        }
    }

    private static function render(e:Event):void {

        if (!isRender) {
            return;
        }

        var i:int = 0, l:int;
        var v:Vector.<Function>;

        for each(v in _fucs) {
            l = v.length;
            for (i = 0; i < l; i++) {
                if (i > v.length - 1) {
                    break;
                }
                v[i]();
            }
        }


    }

}
}
