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

package net.play5d.game.bvn.input {
import flash.display.Stage;

import net.play5d.game.bvn.data.lan.SocketInputBitCodec;
import net.play5d.game.bvn.data.lan.SocketInputData;
import net.play5d.game.bvn.interfaces.IGameInput;
import net.play5d.game.bvn.interfaces.lan.ILanSocketInput;

/**
 * 联机锁帧用 Socket 输入通道。
 *
 * <p>聚合多个本地 <code>IGameInput</code>，打包为整数键位供锁帧同步；
 * 亦可从对端解包回写。</p>
 *
 * @see ILanSocketInput
 * @see IGameInput
 */
public class GameSocketInput implements IGameInput, ILanSocketInput {

    /**
     * 创建通道并初始化键位掩码。
     */
    public function GameSocketInput() {
        initK();
    }

    /** @private */
    private var _data:SocketInputData;
    /** @private */
    private var _inputers:Vector.<IGameInput>;
    /** @private */
    private var _inputData:int = 0;
    /** @private */
    private var _upK:int;
    /** @private */
    private var _downK:int;
    /** @private */
    private var _leftK:int;
    /** @private */
    private var _rightK:int;
    /** @private */
    private var _attackK:int;
    /** @private */
    private var _jumpK:int;
    /** @private */
    private var _dashK:int;
    /** @private */
    private var _skillK:int;
    /** @private */
    private var _bishaK:int;
    /** @private */
    private var _specialK:int;
    /** @private */
    private var _enabled:Boolean = false;

    /**
     * 是否启用本通道。
     */
    public function get enabled():Boolean {
        return _enabled;
    }

    /** @private */
    public function set enabled(v:Boolean):void {
        _enabled = v;
        if (v) {
            _data = new SocketInputData();
        }
        else {
            _data = null;
        }
    }

    /**
     * 设置聚合的本地输入源。
     *
     * @param inputers 本地 <code>IGameInput</code> 列表。
     */
    public function setInputers(inputers:Array):void {
        _inputers = new Vector.<IGameInput>();
        for each(var i:IGameInput in inputers) {
            _inputers.push(i);
        }
    }

    /**
     * 每一帧采集按键，时间范围内按过即有效。
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

    /**
     * 非锁帧场景采集（含 select/back）。
     */
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

            _data.select ||= p.select();
            _data.back ||= p.back();
        }
    }

    /**
     * 清空按键状态。
     */
    public function resetInput():void {
        _inputData = 0;
        renderInput();
    }

    /**
     * 从整数整数解包写入当前键位状态。
     *
     * @param msg 打包后的按键整数。
     */
    public function setSocketData(msg:int):void {
        if (!_data) {
            trace('GameSocketInput.data is null!');
            return;
        }

        SocketInputBitCodec.unpack(msg, _data);
    }

    /**
     * 获取打包后的按键整数。
     *
     * @return 二进制键位转十进制。
     */
    public function getSocketData():int {
        return _inputData;
    }

    /**
     * @param stage 舞台（本实现无需绑定）。
     */
    public function initialize(stage:Stage):void {
    }

    /**
     * @param config 配置对象（本实现忽略）。
     */
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
        return _data && (
                _data.attack || _data.select
        );
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
