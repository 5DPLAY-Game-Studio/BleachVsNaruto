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

package net.play5d.game.bvn.win.input {
import flash.display.Stage;

import net.play5d.game.bvn.input.IGameInput;
import net.play5d.game.bvn.win.data.SocketInputData;

public class GameSocketInput implements IGameInput {
    public function GameSocketInput() {
        initK();
    }
    private var _data:SocketInputData;
    private var _inputers:Vector.<IGameInput>;

    private var _inputData:int = 0;

    private var _upK:int;
    private var _downK:int;
    private var _leftK:int;
    private var _rightK:int;
    private var _attackK:int;
    private var _jumpK:int;
    private var _dashK:int;
    private var _skillK:int;
    private var _bishaK:int;
    private var _specialK:int;

    private var _enabled:Boolean = false;

    public function get enabled():Boolean {
        return _enabled;
    }

    public function set enabled(v:Boolean):void {
        _enabled = v;
        if (v) {
            _data = new SocketInputData();
//				for each(var i:IGameInput in _inputers){
//					i.initlize(MainGame.I.stage);
//				}
        }
        else {
            _data = null;
        }
    }

    public function setInputers(inputers:Array):void {
        _inputers = new Vector.<IGameInput>();
        for each(var i:IGameInput in inputers) {
            _inputers.push(i);
        }
    }

    /**
     * 每一帧获取按键状态 ，只要在时间范围内按过，就算有效
     */
    public function renderInput():void {

        if (!_inputers || _inputers.length < 1) {
            return;
        }

        var i:int;
        var l:int = _inputers.length;
        var p:IGameInput;
        for (i = 0; i < l; i++) {
            p = _inputers[i];

            p.up() && (
                    _inputData |= _upK
            );
            p.down() && (
                    _inputData |= _downK
            );
            p.left() && (
                    _inputData |= _leftK
            );
            p.right() && (
                    _inputData |= _rightK
            );

            p.attack() && (
                    _inputData |= _attackK
            );
            p.jump() && (
                    _inputData |= _jumpK
            );
            p.dash() && (
                    _inputData |= _dashK
            );

            p.skill() && (
                    _inputData |= _skillK
            );
            p.superSkill() && (
                    _inputData |= _bishaK
            );
            p.special() && (
                    _inputData |= _specialK
            );

        }

    }

    public function freeRender():void {
        if (!_inputers || _inputers.length < 1) {
            return;
        }
        if (!_data) {
            return;
        }

        _data.clear();

        var i:int;
        var l:int = _inputers.length;
        var p:IGameInput;
        for (i = 0; i < l; i++) {
            p = _inputers[i];

            _data.up ||= p.up();
            _data.down ||= p.down();
            _data.left ||= p.left();
            _data.right ||= p.right();

            _data.attack ||= p.attack();
            _data.jump ||= p.jump();
            _data.dash ||= p.dash();

            _data.skill ||= p.skill();
            _data.superSkill ||= p.superSkill();
            _data.special ||= p.special();

        }
    }

    /**
     * 清空按键状态
     */
    public function resetInput():void {
        _inputData = 0;
        renderInput();
    }

    public function setSocketData(msg:int):void {
        if (!_data) {
            trace('GameSocketInput.data is null!');
            return;
        }

        var ejz:String   = msg.toString(2);
        var l:int        = ejz.length;
        _data.special    = ejz.charAt(l - 1) == '1';
        _data.superSkill = ejz.charAt(l - 2) == '1';
        _data.skill      = ejz.charAt(l - 3) == '1';
        _data.dash       = ejz.charAt(l - 4) == '1';
        _data.jump       = ejz.charAt(l - 5) == '1';
        _data.attack     = ejz.charAt(l - 6) == '1';
        _data.right      = ejz.charAt(l - 7) == '1';
        _data.left       = ejz.charAt(l - 8) == '1';
        _data.down       = ejz.charAt(l - 9) == '1';
        _data.up         = ejz.charAt(l - 10) == '1';

    }

    /**
     * 获取按键状态数据,返回一个二进制数转十进制数
     */
    public function getSocketData():int {
        return _inputData;
    }

    public function initlize(stage:Stage):void {

    }

    public function setConfig(config:Object):void {
    }

    public function focus():void {
    }

    public function anyKey():Boolean {
        return false;
    }

    public function back():Boolean {
        return false;
    }

    public function select():Boolean {
        return _data && _data.attack;
    }

    public function up():Boolean {
        return _data && _data.up;
    }

    public function down():Boolean {
        return _data && _data.down;
    }

    public function left():Boolean {
        return _data && _data.left;
    }

    public function right():Boolean {
        return _data && _data.right;
    }

    public function attack():Boolean {
        return _data && _data.attack;
    }

    public function jump():Boolean {
        return _data && _data.jump;
    }

    public function dash():Boolean {
        return _data && _data.dash;
    }

    public function skill():Boolean {
        return _data && _data.skill;
    }

    public function superSkill():Boolean {
        return _data && _data.superSkill;
    }

    public function special():Boolean {
        return _data && _data.special;
    }

    public function wankai():Boolean {
        return _data && _data.attack && _data.jump;
    }

    public function clear():void {
        _data && _data.clear();
        resetInput();
    }

    private function initK():void {
        _upK      = parseInt('1000000000', 2);
        _downK    = parseInt('0100000000', 2);
        _leftK    = parseInt('0010000000', 2);
        _rightK   = parseInt('0001000000', 2);
        _attackK  = parseInt('0000100000', 2);
        _jumpK    = parseInt('0000010000', 2);
        _dashK    = parseInt('0000001000', 2);
        _skillK   = parseInt('0000000100', 2);
        _bishaK   = parseInt('0000000010', 2);
        _specialK = parseInt('0000000001', 2);

    }
}
}
