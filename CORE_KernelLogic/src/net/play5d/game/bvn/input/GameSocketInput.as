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
import net.play5d.game.bvn.utils.GameLogger;

/**
 * 联机锁帧用的输入通道。
 *
 * <p>锁帧采集只往整数掩码里加位，<code>getSocketData</code> 返回这份掩码。
 * <code>setSocketData</code> 以及方向、技能查询走另一份数据，两份互不覆盖。
 * 通道默认关闭。打开时新建那份数据，关掉就丢掉，查询变为假。
 * <code>anyKey</code> 和 <code>back</code> 固定返回 false。确认是攻击或确认有一个为真。卍解是攻击和跳同时为真。
 * <code>clear</code> 清完会立刻再采集，当时按住的键会马上回到掩码里。</p>
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
    private var _inputters:Vector.<IGameInput>;
    /** @private */
    private var _inputData:int   = 0;
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
     * 是否启用。打开时新建键位数据，关掉就丢掉。
     *
     * @return 当前是否启用。
     * @default false
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
     * @param inputters 本地输入列表。null 时抛错。
     * @throws TypeError 列表为 null 时。
     */
    public function setInputters(inputters:Array):void {
        _inputters = new Vector.<IGameInput>();
        for each(var i:IGameInput in inputters) {
            _inputters.push(i);
        }
    }

    /**
     * 把当前按住的方向和技能并进整数掩码。已有的位保留。
     *
     * <p>没有输入源时直接返回。不看通道是否启用。</p>
     */
    public function renderInput():void {
        if (!_inputters || _inputters.length < 1) {
            return;
        }

        var i:int;
        var l:int = _inputters.length;
        var p:IGameInput;
        for (i = 0; i < l; i++) {
            p = _inputters[i];

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
     * 按当前按住状态重写菜单用的键位，包含确认和返回。
     *
     * <p>没有输入源，或通道没打开时直接返回。这次会先清空再采集。</p>
     */
    public function freeRender():void {
        if (!_inputters || _inputters.length < 1) {
            return;
        }
        if (!_data) {
            return;
        }

        _data.clear();

        var i:int;
        var l:int = _inputters.length;
        var p:IGameInput;
        for (i = 0; i < l; i++) {
            p = _inputters[i];

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
     * 把整数掩码清零，并立刻再采集一次。
     *
     * @example
     * <listing version="3.0">
     * input.resetInput();
     * </listing>
     */
    public function resetInput():void {
        _inputData = 0;
        renderInput();
    }

    /**
     * 把整数解包进查询用的键位。掩码不变。
     *
     * <p>通道没打开时打日志并返回。</p>
     *
     * @param msg 打包后的按键整数。
     */
    public function setSocketData(msg:int):void {
        if (!_data) {
            GameLogger.warn('input', 'GameSocketInput.data is null');
            return;
        }

        SocketInputBitCodec.unpack(msg, _data);
    }

    /**
     * 取得锁帧采集的整数掩码。
     *
     * @return 当前掩码。通道关掉后仍返回最后一次的值。
     */
    public function getSocketData():int {
        return _inputData;
    }

    /**
     * 空实现。
     *
     * @param stage 不使用。
     */
    public function initialize(stage:Stage):void {
    }

    /**
     * 空实现。
     *
     * @param config 不使用。
     */
    public function setConfig(config:Object):void {
    }

    /**
     * 空实现。
     */
    public function focus():void {
    }

    /**
     * 固定返回 false。
     *
     * @return false。
     */
    public function anyKey():Boolean {
        return false;
    }

    /**
     * 固定返回 false。查询数据里的返回键不从这里读。
     *
     * @return false。
     */
    public function back():Boolean {
        return false;
    }

    /**
     * 攻击或确认是否为真。
     *
     * @return 通道打开且其中之一为真时是 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.select();
     * </listing>
     */
    public function select():Boolean {
        return _data && (
                _data.attack || _data.select
        );
    }

    /**
     * 上是否为真。通道关闭时为假。
     *
     * @return 打开且上为真时是 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.up();
     * </listing>
     */
    public function up():Boolean {
        return _data && _data.up;
    }

    /**
     * 下是否为真。通道关闭时为假。
     *
     * @return 打开且下为真时是 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.down();
     * </listing>
     */
    public function down():Boolean {
        return _data && _data.down;
    }

    /**
     * 左是否为真。通道关闭时为假。
     *
     * @return 打开且左为真时是 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.left();
     * </listing>
     */
    public function left():Boolean {
        return _data && _data.left;
    }

    /**
     * 右是否为真。通道关闭时为假。
     *
     * @return 打开且右为真时是 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.right();
     * </listing>
     */
    public function right():Boolean {
        return _data && _data.right;
    }

    /**
     * 攻击是否为真。通道关闭时为假。
     *
     * @return 打开且攻击为真时是 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.attack();
     * </listing>
     */
    public function attack():Boolean {
        return _data && _data.attack;
    }

    /**
     * 跳是否为真。通道关闭时为假。
     *
     * @return 打开且跳为真时是 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.jump();
     * </listing>
     */
    public function jump():Boolean {
        return _data && _data.jump;
    }

    /**
     * 冲刺是否为真。通道关闭时为假。
     *
     * @return 打开且冲刺为真时是 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.dash();
     * </listing>
     */
    public function dash():Boolean {
        return _data && _data.dash;
    }

    /**
     * 技能是否为真。通道关闭时为假。
     *
     * @return 打开且技能为真时是 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.skill();
     * </listing>
     */
    public function skill():Boolean {
        return _data && _data.skill;
    }

    /**
     * 必杀是否为真。通道关闭时为假。
     *
     * @return 打开且必杀为真时是 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.superSkill();
     * </listing>
     */
    public function superSkill():Boolean {
        return _data && _data.superSkill;
    }

    /**
     * 特殊键是否为真。通道关闭时为假。
     *
     * @return 打开且特殊键为真时是 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.special();
     * </listing>
     */
    public function special():Boolean {
        return _data && _data.special;
    }

    /**
     * 攻击和跳是否同时为真。
     *
     * @return 通道打开且两者都为真时是 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.bankai();
     * </listing>
     */
    public function bankai():Boolean {
        return _data && _data.attack && _data.jump;
    }

    /**
     * 清掉查询数据，再把掩码清零并立刻重新采集。
     *
     * @example
     * <listing version="3.0">
     * input.clear();
     * </listing>
     */
    public function clear():void {
        _data && _data.clear();
        resetInput();
    }

    /** @private 从高位到低位依次是上下左右、攻击、跳、冲刺、技能、必杀、特殊 */
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
