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
import flash.events.KeyboardEvent;
import flash.utils.Dictionary;
import net.play5d.kyo.input.KyoKeyCode;
import net.play5d.kyo.input.KyoKeyVO;
import net.play5d.kyo.utils.UUID;

/**
 * 作弊码管理器
 *
 * <p>用于管理和检测玩家输入的作弊码序列。当玩家依次按下指定的按键组合时，
 * 触发对应的回调函数。该类采用单例模式，确保全局只有一个作弊码管理器实例，
 * 统一管理所有作弊码的注册、检测和注销。</p>
 *
 * <p><b>核心设计理念：</b></p>
 * <ul>
 *   <li><b>单一职责：</b>专注于作弊码的管理和检测，不负责游戏逻辑</li>
 *   <li><b>全局共享：</b>采用单例模式，确保全局状态一致性</li>
 *   <li><b>低耦合：</b>通过回调机制与游戏逻辑解耦</li>
 *   <li><b>高性能：</b>使用 Dictionary 和 CheatCodeEntry 优化查找效率</li>
 * </ul>
 *
 * <p><b>设计特点：</b></p>
 * <ul>
 *   <li><b>共享监听器：</b>使用单一键盘事件监听器，减少性能开销</li>
 *   <li><b>双重触发模式：</b>支持单次触发（isRunOnce）和重复触发两种模式</li>
 *   <li><b>生命周期管理：</b>每个注册的作弊码都返回唯一的注销函数</li>
 *   <li><b>高效存储：</b>使用 Dictionary 存储状态，键值查找效率为 O(1)</li>
 *   <li><b>数据封装：</b>使用 CheatCodeEntry 类封装作弊码数据</li>
 * </ul>
 *
 * <p><b>工作原理：</b></p>
 * <ol>
 *   <li><b>注册阶段：</b>将作弊码字符串解析为按键序列，存储到 Dictionary</li>
 *   <li><b>监听阶段：</b>注册全局键盘事件监听器，等待按键输入</li>
 *   <li><b>匹配阶段：</b>每次按键时遍历所有作弊码，检查是否匹配</li>
 *   <li><b>触发阶段：</b>匹配成功时调用对应的回调函数</li>
 *   <li><b>清理阶段：</b>注销作弊码或关闭管理器时释放资源</li>
 * </ol>
 *
 * <p><b>使用示例：</b></p>
 * <pre>
 * // 注册一个可重复触发的作弊码
 * var removeCheat1:Function = CheatCodeManager.I.register("W|S|A|K", function():void {
 *     trace("Konami 作弊码激活！");
 * });
 *
 * // 注册一个单次触发的作弊码（如秘籍）
 * CheatCodeManager.I.register("G|O|D|M|O|D|E", function():void {
 *     player.godMode = true;
 * }, true);
 *
 * // 临时禁用所有作弊码
 * CheatCodeManager.I.enabled = false;
 *
 * // 重新启用作弊码
 * CheatCodeManager.I.enabled = true;
 *
 * // 注销单个作弊码
 * removeCheat1();
 *
 * // 注销所有作弊码（场景切换时）
 * CheatCodeManager.I.unregisterAll();
 * </pre>
 *
 * <p><b>性能考量：</b></p>
 * <ul>
 *   <li>使用单一监听器避免监听器泛滥</li>
 *   <li>Dictionary 查找效率高于 Array 遍历</li>
 *   <li>已触发的单次作弊码通过标志位快速跳过</li>
 * </ul>
 *
 * @see RunCheatCode
 * @see CheatCodeEntry
 * @author 5DPLAY Game Studio
 * @version 1.0
 */

public class CheatCodeManager {

    /** 单例实例 */
    private static var _instance:CheatCodeManager;

    /** 全局启用/禁用标志 */
    private static var _enabled:Boolean = true;

    /** 是否已添加键盘事件监听器的标志（修复：使用内部标志而非检查STAGE） */
    private var _hasListener:Boolean = false;

    /**
     * 已注册的作弊码字典
     *
     * <p>结构：Dictionary[id] = CheatCodeEntry</p>
     */
    private var _registeredCodes:Dictionary = new Dictionary();

    /**
     * 获取单例实例
     *
     * <p>使用延迟初始化模式确保全局只有一个 CheatCodeManager 实例。</p>
     *
     * @return CheatCodeManager 单例实例
     */
    public static function get I():CheatCodeManager {
        _instance ||= new CheatCodeManager();

        return _instance;
    }

    /**
     * 全局启用/禁用属性
     *
     * <p>控制是否处理按键输入。当设为 false 时，所有作弊码的检测将被忽略，
     * 但已注册的作弊码状态会被保留。</p>
     *
     * @default true
     */
    public function get enabled():Boolean {
        return _enabled;
    }

    /**
     * @private
     */
    public function set enabled(v:Boolean):void {
        _enabled = v;
    }

    /**
     * 注册一个作弊码
     *
     * <p>将指定的按键序列与回调函数关联。当玩家依次按下对应的按键时，
     * 自动调用回调函数。该方法是作弊码系统的核心注册接口，负责将用户定义的
     * 按键序列转换为内部可处理的格式，并管理生命周期。</p>
     *
     * <p><b>注册流程：</b></p>
     * <ol>
     *   <li><b>前置检查：</b>检查 STAGE 是否可用，不可用则返回 null</li>
     *   <li><b>解析作弊码：</b>将字符串格式转换为 KyoKeyVO 向量</li>
     *   <li><b>生成唯一 ID：</b>使用 UUID 生成全局唯一的作弊码标识符</li>
     *   <li><b>创建条目：</b>实例化 CheatCodeEntry 对象并设置初始状态</li>
     *   <li><b>注册监听器：</b>如果是第一个作弊码，注册全局键盘事件监听器</li>
     *   <li><b>返回注销函数：</b>返回一个闭包函数，用于后续注销该作弊码</li>
     * </ol>
     *
     * <p><b>按键格式说明：</b></p>
     * <ul>
     *   <li><b>分隔符：</b>按键之间用竖线 <code>|</code> 分隔</li>
     *   <li><b>按键名称：</b>应与 <code>KyoKeyCode</code> 中定义的常量一致</li>
     *   <li><b>大小写：</b>不区分大小写</li>
     *   <li><b>单个按键：</b>可以只注册单个按键，如 "U" 或 "ESC"</li>
     * </ul>
     *
     * <p><b>触发模式：</b></p>
     * <ul>
     *   <li><b>重复触发（默认）：</b>每次正确输入按键序列都会触发回调</li>
     *   <li><b>单次触发：</b>设置 isRunOnce 为 true，作弊码只会触发一次</li>
     * </ul>
     *
     * <p><b>示例：</b></p>
     * <pre>
     * // 注册一个可重复触发的作弊码
     * var removeCheat1:Function = CheatCodeManager.I.register("W|S|A|K", function():void {
     *     trace("Konami 作弊码激活！");
     * });
     *
     * // 注册一个单次触发的作弊码
     * CheatCodeManager.I.register("G|O|D|M|O|D|E", function():void {
     *     player.godMode = true;
     * }, true);
     *
     * // 注销作弊码
     * removeCheat1();
     * </pre>
     *
     * <p><b>注意事项：</b></p>
     * <ul>
     *   <li>该方法必须在 STAGE 初始化完成后调用</li>
     *   <li>回调函数中应避免执行耗时操作</li>
     *   <li>建议在游戏主界面初始化完成后注册作弊码</li>
     * </ul>
     *
     * @param code      作弊码字符串，格式为 "按键1|按键2|按键3..."，例如 "W|S|A|K"
     * @param success   成功触发时调用的回调函数，无参数，无返回值
     * @param isRunOnce 是否只触发一次。默认为 false；设为 true 时，该作弊码只会触发一次
     * @return 注销函数。调用此函数可移除该作弊码的监听。
     *         如果注册失败（如 STAGE 不可用或解析失败），返回 null
     *
     * @see #unregister()
     * @see #parseCode()
     * @see CheatCodeEntry
     * @see net.play5d.kyo.input.KyoKeyCode
     */
    public function register(code:String, success:Function, isRunOnce:Boolean = false):Function {
        if (!STAGE) {
            return null;
        }

        /** 解析作弊码字符串 */
        var cheatCode:Vector.<KyoKeyVO> = parseCode(code);
        if (!cheatCode) {
            return null;
        }

        /** 生成唯一的作弊码 ID */
        var id:String = UUID.create();
        var entry:CheatCodeEntry = new CheatCodeEntry({
            code        : code,
            success     : success,
            isRunOnce   : isRunOnce,
            keys        : cheatCode,
            currentIndex: 0,
            hasSucceeded: false
        });
        _registeredCodes[id] = entry;

        // 使用内部标志 _hasListener 而非检查 STAGE 上的所有监听器
        if (!_hasListener) {
            STAGE.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            _hasListener = true;
        }

        // 返回注销函数
        return function():void {
            unregister(id); 
        };
    }

    /**
     * 注销指定的作弊码
     *
     * <p>根据提供的 ID 移除对应的作弊码监听。如果注销后不再有任何注册的作弊码，
     * 自动移除全局键盘事件监听器以优化性能。</p>
     *
     * @param id 注册时返回的唯一标识符
     */
    public function unregister(id:String):void {
        /** 检查作弊码是否存在并移除 */
        if (_registeredCodes[id]) {
            delete _registeredCodes[id];

            /** 注销键盘事件监听器 */
            if (isEmpty()) {
                STAGE.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
                _hasListener = false;
            }
        }
    }

    /**
     * 注销所有已注册的作弊码
     *
     * <p>清空所有已注册的作弊码，同时移除全局键盘事件监听器。
     * 通常在游戏场景切换或需要重置作弊码状态时调用。</p>
     *
     * @example
     * <pre>
     * // 进入新游戏时重置所有作弊码
     * CheatCodeManager.I.unregisterAll();
     * </pre>
     */
    public function unregisterAll():void {
        for (var id:String in _registeredCodes) {
            /** 注销每个作弊码 */
            unregister(id);
        }
    }

    /**
     * 获取所有已注册的作弊码列表
     *
     * <p>返回当前已注册的所有作弊码字符串数组。
     * 主要用于调试目的，查看哪些作弊码正在被监听。</p>
     *
     * @return 已注册作弊码的字符串数组
     *
     * @example
     * <pre>
     * var codes:Array = CheatCodeManager.I.getRegisteredCodes();
     * trace("当前注册的作弊码:", codes);
     * </pre>
     */
    public function getRegisteredCodes():Array {
        var result:Array = [];
        for (var id:String in _registeredCodes) {
            var entry:CheatCodeEntry = _registeredCodes[id] as CheatCodeEntry;
            result.push(entry.code);
        }

        return result;
    }

    /**
     * 键盘按下事件处理函数
     *
     * <p>这是全局共享的键盘事件监听器。每次按键都会遍历所有已注册的作弊码，
     * 检查是否匹配当前进度。采用统一监听器设计，避免为每个作弊码注册独立监听器，
     * 减少事件监听器数量，提高性能。</p>
     *
     * <p><b>匹配逻辑流程：</b></p>
     * <ol>
     *   <li><b>前置检查：</b>如果全局启用标志为 false，直接返回不做处理</li>
     *   <li><b>遍历检查：</b>遍历所有已注册的作弊码</li>
     *   <li><b>单次触发检查：</b>如果作弊码设置为单次触发且已成功触发过，跳过</li>
     *   <li><b>按键匹配：</b>如果按键与当前期待的按键匹配，进度索引 +1</li>
     *   <li><b>完成检查：</b>如果进度达到序列长度，触发成功回调</li>
     *   <li><b>重置进度：</b>无论成功与否，匹配完成后重置进度为 0</li>
     *   <li><b>不匹配处理：</b>如果按键不匹配，立即重置进度为 0</li>
     * </ol>
     *
     * <p><b>性能优化策略：</b></p>
     * <ul>
     *   <li><b>单一监听器：</b>使用单一的全局监听器，避免为每个作弊码注册独立监听器</li>
     *   <li><b>高效查找：</b>通过 Dictionary 直接访问状态，查找效率为 O(1)</li>
     *   <li><b>提前跳过：</b>对于已触发的单次作弊码，通过 hasSucceeded 标志提前跳过</li>
     *   <li><b>类型安全：</b>使用 CheatCodeEntry 类封装数据，避免类型转换开销</li>
     * </ul>
     *
     * <p><b>线程安全性：</b>该方法在 Flash Player 的事件线程中执行，无需额外的同步措施。
     * 但需要注意不要在回调函数中执行耗时操作，以免阻塞事件处理。</p>
     *
     * @param e 键盘事件对象，包含按键的 keyCode 信息
     *
     * @see #enabled
     * @see #_registeredCodes
     * @see CheatCodeEntry
     */
    private function onKeyDown(e:KeyboardEvent):void {
        if (!_enabled) {
            return;
        }

        // 遍历所有已注册的作弊码
        for (var id:String in _registeredCodes) {
            var entry:CheatCodeEntry = _registeredCodes[id] as CheatCodeEntry;

            // 检查是否已触发过
            if (entry.isRunOnce && entry.hasSucceeded) {
                continue;
            }

            // 检查按键是否匹配当前期待的按键
            if (e.keyCode == entry.keys[entry.currentIndex].code) {
                entry.currentIndex++;

                // 检查是否匹配完成
                if (entry.currentIndex >= entry.keys.length) {
                    if (entry.isRunOnce) {
                        entry.hasSucceeded = true;
                    }

                    // 重置进度
                    entry.currentIndex = 0;

                    // 触发成功回调
                    if (entry.success != null) {
                        entry.success();
                    }
                }
            }
            // 检查按键不匹配，重置进度
            else {
                // 重置进度
                entry.currentIndex = 0;
            }
        }
    }


    private static var SEPARATOR:String = '|';

    /**
     * 解析作弊码字符串为按键序列
     *
     * <p>将形如 "W|S|A|K" 的字符串解析为对应的 KyoKeyVO 向量。</p>
     *
     * <p><b>解析规则：</b></p>
     * <ul>
     *   <li>使用竖线 <code>|</code> 作为分隔符</li>
     *   <li>如果不包含分隔符，则视为单个按键</li>
     *   <li>每个按键名必须存在于 <code>KyoKeyCode</code> 中</li>
     *   <li>如果任何按键名无效，解析失败返回 null</li>
     * </ul>
     *
     * @param code 原始作弊码字符串
     * @return 解析后的按键序列向量，如果解析失败则返回 null
     *
     * @throws 如果传入 null 或空字符串，返回 null
     */
    private function parseCode(code:String):Vector.<KyoKeyVO> {
        /** 分隔后的按键名数组，包含单个按键或多个按键 */
        var parts:Array = code.indexOf(SEPARATOR) == -1
            ? [code]
            : code.split(SEPARATOR);

        /** 解析后的按键序列向量 */
        var result:Vector.<KyoKeyVO> = new Vector.<KyoKeyVO>();
        for each (var name:String in parts) {
            // 检查按键名是否有效
            if (!name || !KyoKeyCode[name]) {
                return null;
            }

            result.push(KyoKeyCode[name]);
        }

        return result;
    }

    /**
     * 检查是否还有已注册的作弊码
     *
     * <p>用于判断是否可以移除全局键盘事件监听器。
     * 当没有任何作弊码注册时，应移除监听器以节省资源。</p>
     *
     * @return 如果至少有一个已注册的作弊码返回 true，否则返回 false
     */
    private function isEmpty():Boolean {
        for (var id:String in _registeredCodes) {
            return false;
        }

        return true;
    }

}
}

import net.play5d.kyo.input.KyoKeyVO;

/**
 * 作弊码条目类
 *
 * <p>用于存储每个注册的作弊码的详细信息，将分散的数据封装为单一对象，
 * 提高访问效率和代码可维护性。该类是作弊码系统的核心数据结构，
 * 包含了作弊码的定义、状态和回调信息。</p>
 *
 * <p><b>设计目的：</b></p>
 * <ul>
 *   <li><b>数据封装：</b>将作弊码的所有相关数据集中管理</li>
 *   <li><b>状态追踪：</b>维护当前按键匹配进度和触发状态</li>
 *   <li><b>性能优化：</b>减少 Dictionary 查找次数，提高访问效率</li>
 *   <li><b>类型安全：</b>提供强类型的属性访问</li>
 * </ul>
 *
 * <p><b>状态流转：</b></p>
 * <ol>
 *   <li><b>初始状态：</b>currentIndex = 0, hasSucceeded = false</li>
 *   <li><b>匹配中：</b>currentIndex 逐渐增加</li>
 *   <li><b>触发成功：</b>currentIndex >= keys.length，调用回调</li>
 *   <li><b>重置状态：</b>currentIndex 重置为 0</li>
 *   <li><b>单次触发完成：</b>isRunOnce = true 时，hasSucceeded = true</li>
 * </ol>
 */
class CheatCodeEntry {
    
    /** 
     * 原始作弊码字符串（如 "W|S|A|K"）
     * 
     * <p>用于调试和日志输出，不参与匹配逻辑。</p>
     */
    public var code:String;
    
    /** 
     * 成功触发作弊码时调用的回调函数
     * 
     * <p>该函数无参数，无返回值。在作弊码完整匹配时被调用。</p>
     */
    public var success:Function;
    
    /** 
     * 是否只允许触发一次
     * 
     * <p>默认为 false。设为 true 时，作弊码只会触发一次，
     * 触发后通过 hasSucceeded 标志跳过后续匹配。</p>
     */
    public var isRunOnce:Boolean;
    
    /** 
     * 解析后的按键序列向量
     * 
     * <p>包含 KyoKeyVO 对象，每个对象代表一个按键。
     * 匹配时按顺序检查每个按键。</p>
     */
    public var keys:Vector.<KyoKeyVO>;
    
    /** 
     * 当前按键匹配进度（从 0 开始）
     * 
     * <p>表示当前已经成功匹配到第几个按键。
     * 范围：0 到 keys.length - 1。</p>
     */
    public var currentIndex:int;
    
    /** 
     * 是否已成功触发过（仅用于 isRunOnce 为 true 的情况）
     * 
     * <p>当 isRunOnce 为 true 且作弊码已触发时，该值为 true，
     * 后续按键将跳过此作弊码的匹配检查。</p>
     */
    public var hasSucceeded:Boolean;

    /**
     * 构造函数
     *
     * <p>初始化作弊码条目，设置所有属性的初始值。</p>
     *
     * @param params 包含初始化参数的对象，应包含以下属性：
     *               code, success, isRunOnce, keys, currentIndex, hasSucceeded
     */
    public function CheatCodeEntry(params:Object) {
        this.code           = params.code;
        this.success        = params.success;   
        this.isRunOnce      = params.isRunOnce;
        this.keys           = params.keys;
        this.currentIndex   = params.currentIndex;
        this.hasSucceeded   = params.hasSucceeded;
    }
}