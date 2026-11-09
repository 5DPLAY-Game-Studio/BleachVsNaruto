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
import flash.utils.Dictionary;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.GameRender;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameInputType;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.interfaces.IGameInput;

/**
 * 菜单和对局共用的输入查询。
 *
 * <p>槽位里第一个启用的输入返回 true 就停。<code>anyKey</code> 和 <code>back</code> 固定查菜单槽。
 * <code>justDown</code> 为 0 表示按住，1 表示这次按下的沿，2 表示按下后大约 0.1 秒，其它值按按住算。
 * 0.1 秒换成 <code>MainGame.getFPS</code> 的帧数。登记过的键会在 <code>render</code> 里先走一遍沿判断，这一帧的沿可能被提前吃掉。
 * 总开关关掉后查询都是 false，焦点标记清掉，各输入自己的 <code>clear</code> 仍会执行。</p>
 *
 * @see GameKeyInput
 * @see net.play5d.game.bvn.data.GameInputType
 */
public class GameInputter {

    /** @private 刚按下后保持的秒数 */
    private static const JUST_DOWN_DELAY:Number  = 0.1;
    /** @private */
    private static var _enabled:Boolean          = true;
    /** @private */
    private static var _isFocused:Boolean        = false;
    /** @private */
    private static var _inputMap:Dictionary      = new Dictionary();
    /** @private */
    private static var _justDownKeys:Object      = {};
    /** @private */
    private static var _justDownDelayKeys:Object = {};
    /** @private */
    private static var _listenKeys:Object;

    /**
     * 总开关。关掉后按键查询返回 false。
     *
     * @return 当前是否启用。
     * @default true
     */
    public static function get enabled():Boolean {
        return _enabled;
    }

    /** @private */
    public static function set enabled(v:Boolean):void {
        _enabled = v;
        if (v) {
            focus(true);
        }
        else {
            _isFocused = false;
        }
    }

    /**
     * 装上菜单、1P、2P 的输入，初始化启用的输入，并把 <code>render</code> 交给渲染器。
     *
     * <p>每次调用都会再登记一次渲染。壳没有给出某槽时，该槽换成一个新的键盘输入。空向量会保留。</p>
     *
     * @param stage 交给各输入的舞台。键盘输入遇到 null 会抛错。
     * @throws TypeError 壳接口不存在，或舞台还不能监听键盘时。
     * @example
     * <listing version="3.0">
     * GameInputter.initialize(stage);
     * </listing>
     */
    public static function initialize(stage:Stage):void {
        initInput();
        callVoid('initialize', stage);
        GameRender.add(render);
    }

    /**
     * 按壳当前的输入列表重填菜单、1P 和 2P。
     *
     * <p>某槽取到 null 时换成一个新的键盘输入。</p>
     *
     * @throws TypeError 壳接口不存在时。
     * @example
     * <listing version="3.0">
     * GameInputter.initInput();
     * </listing>
     */
    public static function initInput():void {
        var menu:Vector.<IGameInput> = GameInterface.instance.getGameInput(GameInputType.MENU);
        menu ||= new Vector.<IGameInput>([new GameKeyInput()]);

        var p1:Vector.<IGameInput> = GameInterface.instance.getGameInput(GameInputType.P1);
        p1 ||= new Vector.<IGameInput>([new GameKeyInput()]);

        var p2:Vector.<IGameInput> = GameInterface.instance.getGameInput(GameInputType.P2);
        p2 ||= new Vector.<IGameInput>([new GameKeyInput()]);

        setInput(GameInputType.MENU, menu);
        GameInputter.setInput(GameInputType.P1, p1);
        GameInputter.setInput(GameInputType.P2, p2);
    }

    /**
     * 换掉某个槽位的输入列表，存的是传入的向量本身。
     *
     * @param type 槽位名。
     * @param input 该槽的输入。之后查询时向量为 null 会抛错。
     * @example
     * <listing version="3.0">
     * GameInputter.setInput(GameInputType.P1, inputs);
     * </listing>
     */
    public static function setInput(type:String, input:Vector.<IGameInput>):void {
        _inputMap[type] = input;
    }

    /**
     * 让壳刷新输入配置。壳返回 true 时就结束，不再写菜单和两边的键盘配置。
     *
     * <p>总开关关掉时，键盘配置也不会写下去。</p>
     *
     * @example
     * <listing version="3.0">
     * GameInputter.updateConfig();
     * </listing>
     */
    public static function updateConfig():void {
        if (GameInterface.instance.updateInputConfig()) {
            return;
        }
        setConfig(GameInputType.MENU, GameData.I.config.key_menu);
        setConfig(GameInputType.P1, GameData.I.config.key_p1);
        setConfig(GameInputType.P2, GameData.I.config.key_p2);
    }

    /**
     * 让启用中的输入取得焦点。
     *
     * @param force 默认 false。已经聚焦过且不强制时直接返回。打开总开关时会用 true 再聚一次。
     * @example
     * <listing version="3.0">
     * GameInputter.focus();
     * </listing>
     */
    public static function focus(force:Boolean = false):void {
        if (!force && _isFocused) {
            return;
        }
        _isFocused = true;
        callVoid('focus');
    }

    /**
     * 登记要在渲染里提前查询的键。同一槽位和同一种 <code>justDown</code> 会盖掉上一份。
     *
     * @param type 槽位名。
     * @param ids 方法名，例如 <code>up</code>、<code>attack</code>。
     * @param justDown 只有 1 和 2 会记下，其它值直接返回。
     * @example
     * <listing version="3.0">
     * GameInputter.listenKeys(GameInputType.MENU, ['up', 'down'], 1);
     * </listing>
     */
    public static function listenKeys(type:String, ids:Array, justDown:int):void {

        if (justDown != 1 && justDown != 2) {
            return;
        }

        _listenKeys ||= {};
        var id:String   = type + '_' + justDown;
        _listenKeys[id] = {
            type    : type,
            ids     : ids,
            justDown: justDown
        };
    }

    /**
     * 去掉先前登记的一组键。
     *
     * @param type 槽位名。
     * @param justDown 和登记时相同的 1 或 2。
     * @throws TypeError 还没有成功登记过时。
     * @example
     * <listing version="3.0">
     * GameInputter.unListenKeys(GameInputType.MENU, 1);
     * </listing>
     */
    public static function unListenKeys(type:String, justDown:int):void {
        var id:String = type + '_' + justDown;
        delete _listenKeys[id];
    }

    /**
     * 递减刚按下的保持帧，并查询已登记的键。
     *
     * <p>保持帧减到 0 及以下会删掉。遍历时删除，后面的键可能这一帧还留着。</p>
     *
     * @example
     * <listing version="3.0">
     * GameInputter.render();
     * </listing>
     */
    public static function render():void {
        var i:String, o:Object, isDown:Boolean;
        for (i in _justDownDelayKeys) {
            if (_justDownDelayKeys[i] > 0) {
                _justDownDelayKeys[i]--;
            }
            else {
                delete _justDownDelayKeys[i];
            }
        }
        renderListenKeys();
    }

    /**
     * 菜单槽是否有任意键。
     *
     * @param justDown 默认 0，按住。1 是按下的沿，2 是按下后大约 0.1 秒。
     * @return 成立时为 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = GameInputter.anyKey(1);
     * </listing>
     */
    public static function anyKey(justDown:int = 0):Boolean {
        return isDown(GameInputType.MENU, 'anyKey', justDown);
    }

    /**
     * 菜单槽的返回键。
     *
     * @param justDown 默认 0，按住。1 是按下的沿，2 是按下后大约 0.1 秒。
     * @return 成立时为 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = GameInputter.back();
     * </listing>
     */
    public static function back(justDown:int = 0):Boolean {
        return isDown(GameInputType.MENU, 'back', justDown);
    }

    /**
     * 指定槽的确认键。
     *
     * @param type 槽位名。
     * @param justDown 默认 0，按住。1 是按下的沿，2 是按下后大约 0.1 秒。
     * @return 成立时为 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = GameInputter.select(GameInputType.P1);
     * </listing>
     */
    public static function select(type:String, justDown:int = 0):Boolean {
        return isDown(type, 'select', justDown);
    }

    /**
     * 指定槽的上。
     *
     * @param type 槽位名。
     * @param justDown 默认 0，按住。1 是按下的沿，2 是按下后大约 0.1 秒。
     * @return 成立时为 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = GameInputter.up(GameInputType.P1);
     * </listing>
     */
    public static function up(type:String, justDown:int = 0):Boolean {
        return isDown(type, 'up', justDown);
    }

    /**
     * 指定槽的下。
     *
     * @param type 槽位名。
     * @param justDown 默认 0，按住。1 是按下的沿，2 是按下后大约 0.1 秒。
     * @return 成立时为 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = GameInputter.down(GameInputType.P1);
     * </listing>
     */
    public static function down(type:String, justDown:int = 0):Boolean {
        return isDown(type, 'down', justDown);
    }

    /**
     * 指定槽的左。
     *
     * @param type 槽位名。
     * @param justDown 默认 0，按住。1 是按下的沿，2 是按下后大约 0.1 秒。
     * @return 成立时为 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = GameInputter.left(GameInputType.P1);
     * </listing>
     */
    public static function left(type:String, justDown:int = 0):Boolean {
        return isDown(type, 'left', justDown);
    }

    /**
     * 指定槽的右。
     *
     * @param type 槽位名。
     * @param justDown 默认 0，按住。1 是按下的沿，2 是按下后大约 0.1 秒。
     * @return 成立时为 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = GameInputter.right(GameInputType.P1);
     * </listing>
     */
    public static function right(type:String, justDown:int = 0):Boolean {
        return isDown(type, 'right', justDown);
    }

    /**
     * 指定槽的攻击。
     *
     * @param type 槽位名。
     * @param justDown 默认 0，按住。1 是按下的沿，2 是按下后大约 0.1 秒。
     * @return 成立时为 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = GameInputter.attack(GameInputType.P1);
     * </listing>
     */
    public static function attack(type:String, justDown:int = 0):Boolean {
        return isDown(type, 'attack', justDown);
    }

    /**
     * 指定槽的跳。
     *
     * @param type 槽位名。
     * @param justDown 默认 0，按住。1 是按下的沿，2 是按下后大约 0.1 秒。
     * @return 成立时为 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = GameInputter.jump(GameInputType.P1);
     * </listing>
     */
    public static function jump(type:String, justDown:int = 0):Boolean {
        return isDown(type, 'jump', justDown);
    }

    /**
     * 指定槽的冲刺。
     *
     * @param type 槽位名。
     * @param justDown 默认 0，按住。1 是按下的沿，2 是按下后大约 0.1 秒。
     * @return 成立时为 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = GameInputter.dash(GameInputType.P1);
     * </listing>
     */
    public static function dash(type:String, justDown:int = 0):Boolean {
        return isDown(type, 'dash', justDown);
    }

    /**
     * 指定槽的技能。
     *
     * @param type 槽位名。
     * @param justDown 默认 0，按住。1 是按下的沿，2 是按下后大约 0.1 秒。
     * @return 成立时为 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = GameInputter.skill(GameInputType.P1);
     * </listing>
     */
    public static function skill(type:String, justDown:int = 0):Boolean {
        return isDown(type, 'skill', justDown);
    }

    /**
     * 指定槽的必杀。
     *
     * @param type 槽位名。
     * @param justDown 默认 0，按住。1 是按下的沿，2 是按下后大约 0.1 秒。
     * @return 成立时为 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = GameInputter.superSkill(GameInputType.P1);
     * </listing>
     */
    public static function superSkill(type:String, justDown:int = 0):Boolean {
        return isDown(type, 'superSkill', justDown);
    }

    /**
     * 指定槽的特殊键。
     *
     * @param type 槽位名。
     * @param justDown 默认 0，按住。1 是按下的沿，2 是按下后大约 0.1 秒。
     * @return 成立时为 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = GameInputter.special(GameInputType.P1);
     * </listing>
     */
    public static function special(type:String, justDown:int = 0):Boolean {
        return isDown(type, 'special', justDown);
    }

    /**
     * 指定槽的卍解。
     *
     * @param type 槽位名。
     * @param justDown 默认 0，按住。1 是按下的沿，2 是按下后大约 0.1 秒。
     * @return 成立时为 true。
     * @example
     * <listing version="3.0">
     * var down:Boolean = GameInputter.bankai(GameInputType.P1);
     * </listing>
     */
    public static function bankai(type:String, justDown:int = 0):Boolean {
        return isDown(type, 'bankai', justDown);
    }

    /**
     * 清掉刚按下记录，并让启用中的输入清空自己的按键。
     *
     * <p>总开关关掉时仍会清空。</p>
     *
     * @example
     * <listing version="3.0">
     * GameInputter.clearInput();
     * </listing>
     */
    public static function clearInput():void {
        _justDownKeys      = {};
        _justDownDelayKeys = {};
        callVoid('clear');
    }

    /** @private 总开关关掉或该槽没有输入时直接返回 */
    private static function setConfig(type:String, config:Object):void {
        if (!enabled) {
            return;
        }
        var inputs:Vector.<IGameInput> = _inputMap[type];
        if (!inputs) {
            return;
        }

        var input:IGameInput;
        for (var i:int; i < inputs.length; i++) {
            input = inputs[i];
            if (!input.enabled) {
                continue;
            }
            input.setConfig(config);
        }
    }

    /** @private */
    private static function renderListenKeys():void {
        if (!_listenKeys) {
            return;
        }

        var i:int, l:int, a:Array;
        for each(var o:Object in _listenKeys) {
            a = o.ids;
            l = a.length;
            for (i = 0; i < l; i++) {
                isDown(o.type, a[i], o.justDown, true);
            }
        }
    }

    /** @private */
    private static function isListenedKey(type:String, funcName:String, justDown:int):Boolean {

        if (!_listenKeys) {
            return false;
        }

        var id:String = type + '_' + justDown;
        var o:Object  = _listenKeys[id];

        if (!o || !o.ids) {
            return false;
        }

        return o.ids.indexOf(funcName) != -1;
    }

    /** @private justDown 1 取沿，2 取保持，其余取按住 */
    private static function isDown(type:String, funcName:String, justDown:int = 0,
                                   isListenCall:Boolean                       = false
    ):Boolean {

        var listened:Boolean = isListenCall ? false : isListenedKey(type, funcName, justDown);

        if (justDown == 1) {
            return isJustDown(type, funcName);
        }
        if (justDown == 2) {
            return isJustDownDelay(type, funcName, listened);
        }
        return call(type, funcName);
    }

    /** @private 按住期间只有第一次返回 true */
    private static function isJustDown(type:String, funcName:String):Boolean {

        var id:String = type + '_' + funcName;

        var isDown:Boolean = call(type, funcName);
        if (!isDown) {
            _justDownKeys[id] = false;
            return false;
        }

        if (_justDownKeys[id]) {
            return false;
        }

        _justDownKeys[id] = true;
        return true;
    }

    /** @private 出现沿时写入保持帧，帧数大于 0 则返回 true */
    private static function isJustDownDelay(type:String, funcName:String, listened:Boolean):Boolean {
        var justDown:Boolean = isJustDown(type, funcName);

        var id:String = type + '_' + funcName;

        if (justDown) {
            _justDownDelayKeys[id] = JUST_DOWN_DELAY * MainGame.I.getFPS();
        }

        return _justDownDelayKeys[id] && _justDownDelayKeys[id] > 0;
    }

    /** @private 总开关关掉、槽位缺失或全部未启用时返回 false */
    private static function call(type:String, funcName:String):Boolean {
        if (!enabled) {
            return false;
        }
        var inputs:Vector.<IGameInput> = _inputMap[type];
        if (!inputs) {
            return false;
        }

        var input:IGameInput;
        for (var i:int; i < inputs.length; i++) {
            input = inputs[i];
            if (!input.enabled) {
                continue;
            }
            if (query(input, funcName)) {
                return true;
            }
        }

        return false;
    }

    // 按键名直接对应接口方法，查询时不分配参数数组。
    /** @private 未知方法名返回 false */
    private static function query(input:IGameInput, funcName:String):Boolean {
        switch (funcName) {
        case 'anyKey':
            return input.anyKey();
        case 'back':
            return input.back();
        case 'select':
            return input.select();
        case 'up':
            return input.up();
        case 'down':
            return input.down();
        case 'left':
            return input.left();
        case 'right':
            return input.right();
        case 'attack':
            return input.attack();
        case 'jump':
            return input.jump();
        case 'dash':
            return input.dash();
        case 'skill':
            return input.skill();
        case 'superSkill':
            return input.superSkill();
        case 'special':
            return input.special();
        case 'bankai':
            return input.bankai();
        default:
            return false;
        }
    }

    /** @private 跳过未启用的输入 */
    private static function callVoid(funcName:String, stage:Stage = null):void {
        var inputs:Vector.<IGameInput>;
        var input:IGameInput;
        var i:int;

        for each(inputs in _inputMap) {
            for (i = 0; i < inputs.length; i++) {
                input = inputs[i];
                if (!input.enabled) {
                    continue;
                }
                switch (funcName) {
                case 'initialize':
                    input.initialize(stage);
                    break;
                case 'focus':
                    input.focus();
                    break;
                case 'clear':
                    input.clear();
                    break;
                }
            }
        }
    }

}
}
