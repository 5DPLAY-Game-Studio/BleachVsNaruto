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

package net.play5d.game.bvn.input {
import flash.display.Stage;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import net.play5d.game.bvn.data.vos.KeyConfigVO;
import net.play5d.game.bvn.interfaces.IGameInput;
import net.play5d.kyo.utils.KyoKeyboard;

/**
 * 键盘输入。
 *
 * <p>按下记 1，松开记 0，键不会从记录里删掉。<code>enabled</code> 只供外层跳过，本类查询不看它。
 * 返回键固定是 ESC。卍解是攻击和跳同时按下。必杀读 <code>superKill</code>，特殊键读 <code>beckons</code>。
 * 配置不是 <code>KeyConfigVO</code> 时存成 null，之后读方向和技能会抛错。</p>
 *
 * @see net.play5d.game.bvn.interfaces.IGameInput
 * @see net.play5d.game.bvn.data.vos.KeyConfigVO
 */
public class GameKeyInput implements IGameInput {

    /** @private */
    private var _config:KeyConfigVO;
    /** @private */
    private var _downKeys:Object = {};

    /** @private */
    private var _enabled:Boolean = true;

    /**
     * 是否启用。查询本身不看这个值。
     *
     * @return 当前是否启用。
     * @default true
     */
    public function get enabled():Boolean {
        return _enabled;
    }

    /** @private */
    public function set enabled(v:Boolean):void {
        _enabled = v;
    }

    /**
     * 初始化键盘并登记本实例的按下、松开。
     *
     * <p>同一个处理函数不会重复登记。键盘还没初始化成功时，这次登记会被丢掉。</p>
     *
     * @param stage 舞台。null 时抛错。
     * @throws TypeError 舞台不能监听时。
     * @example
     * <listing version="3.0">
     * input.initialize(stage);
     * </listing>
     */
    public function initialize(stage:Stage):void {
        KyoKeyboard.initialize(stage);
        KyoKeyboard.listen(keyBoardHandler);
    }

    /**
     * 换键盘配置。传入对象不是 <code>KeyConfigVO</code> 时记成 null。
     *
     * @param config 键位配置。
     * @example
     * <listing version="3.0">
     * input.setConfig(config);
     * </listing>
     */
    public function setConfig(config:Object):void {
        _config = config as KeyConfigVO;
    }

    /**
     * 把焦点设回舞台。键盘还没初始化时直接返回。
     *
     * @example
     * <listing version="3.0">
     * input.focus();
     * </listing>
     */
    public function focus():void {
        KyoKeyboard.focus();
    }

    /**
     * 是否有任意键正按着。值为 0 的松开记录不算。
     *
     * @return 有键按下时为 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.anyKey();
     * </listing>
     */
    public function anyKey():Boolean {
        for (var i:String in _downKeys) {
            if (_downKeys[i] == 1) {
                return true;
            }
        }
        return false;
    }


    /**
     * 返回键是否按下。固定看 ESC。
     *
     * @return 按下时为 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.back();
     * </listing>
     */
    public function back():Boolean {
        return isDown(Keyboard.ESCAPE);
    }

    /**
     * 确认键是否有一个按下。
     *
     * @return 任一确认键按下时为 true。
     * @throws TypeError 没有配置，或 <code>selects</code> 为 null 时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.select();
     * </listing>
     */
    public function select():Boolean {
        for each(var i:int in _config.selects) {
            if (isDown(i)) {
                return true;
            }
        }
        return false;
    }

    /**
     * 上是否按下。
     *
     * @return 按下时为 true。
     * @throws TypeError 没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.up();
     * </listing>
     */
    public function up():Boolean {
        return isDown(_config.up);
    }

    /**
     * 下是否按下。
     *
     * @return 按下时为 true。
     * @throws TypeError 没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.down();
     * </listing>
     */
    public function down():Boolean {
        return isDown(_config.down);
    }

    /**
     * 左是否按下。
     *
     * @return 按下时为 true。
     * @throws TypeError 没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.left();
     * </listing>
     */
    public function left():Boolean {
        return isDown(_config.left);
    }

    /**
     * 右是否按下。
     *
     * @return 按下时为 true。
     * @throws TypeError 没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.right();
     * </listing>
     */
    public function right():Boolean {
        return isDown(_config.right);
    }

    /**
     * 攻击是否按下。
     *
     * @return 按下时为 true。
     * @throws TypeError 没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.attack();
     * </listing>
     */
    public function attack():Boolean {
        return isDown(_config.attack);
    }

    /**
     * 跳是否按下。
     *
     * @return 按下时为 true。
     * @throws TypeError 没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.jump();
     * </listing>
     */
    public function jump():Boolean {
        return isDown(_config.jump);
    }

    /**
     * 冲刺是否按下。
     *
     * @return 按下时为 true。
     * @throws TypeError 没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.dash();
     * </listing>
     */
    public function dash():Boolean {
        return isDown(_config.dash);
    }

    /**
     * 技能是否按下。
     *
     * @return 按下时为 true。
     * @throws TypeError 没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.skill();
     * </listing>
     */
    public function skill():Boolean {
        return isDown(_config.skill);
    }

    /**
     * 必杀是否按下。读的是 <code>superKill</code>。
     *
     * @return 按下时为 true。
     * @throws TypeError 没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.superSkill();
     * </listing>
     */
    public function superSkill():Boolean {
        return isDown(_config.superKill);
    }

    /**
     * 特殊键是否按下。读的是 <code>beckons</code>。
     *
     * @return 按下时为 true。
     * @throws TypeError 没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.special();
     * </listing>
     */
    public function special():Boolean {
        return isDown(_config.beckons);
    }

    /**
     * 攻击和跳是否都按下。
     *
     * @return 两个都按下时为 true。
     * @throws TypeError 没有配置时。
     * @example
     * <listing version="3.0">
     * var down:Boolean = input.bankai();
     * </listing>
     */
    public function bankai():Boolean {
        return isDown(_config.attack) && isDown(_config.jump);
    }

    /**
     * 丢掉全部按键记录。
     *
     * @example
     * <listing version="3.0">
     * input.clear();
     * </listing>
     */
    public function clear():void {
        _downKeys = {};
    }

    /** @private 记录值为 1 才算按下 */
    private function isDown(keycode:uint):Boolean {
        return _downKeys[keycode] == 1;
    }

    /** @private */
    private function keyBoardHandler(e:KeyboardEvent):void {
        switch (e.type) {
        case KeyboardEvent.KEY_DOWN:
            _downKeys[e.keyCode] = 1;
            break;
        case KeyboardEvent.KEY_UP:
            _downKeys[e.keyCode] = 0;
            break;
        }
    }

}
}
