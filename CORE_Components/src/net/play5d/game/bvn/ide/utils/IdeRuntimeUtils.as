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

package net.play5d.game.bvn.ide.utils {
import flash.display.DisplayObject;
import flash.utils.getQualifiedClassName;

/**
 * Animate IDE 组件运行时解析工具。
 *
 * <p>聚焦 FighterMain 时间轴：沿显示树读取 <code>initFighter</code> 注入的动态属性。</p>
 * <p>动态类型需配合 <code>hasMethod</code> / <code>requireMethods</code> 做能力校验。</p>
 *
 * @see #findEffectCtrler()
 * @see #hasMethod()
 */
public class IdeRuntimeUtils {

    /**
     * 角色主控制器属性名。
     *
     * @default $fighter_ctrler
     */
    public static const FIGHTER_CTRLER_PROP:String = '$fighter_ctrler';

    /**
     * MC / 动作控制器属性名。
     *
     * @default $mc_ctrler
     */
    public static const MC_CTRLER_PROP:String = '$mc_ctrler';

    /**
     * 效果控制器属性名。
     *
     * @default $effect_ctrler
     */
    public static const EFFECT_CTRLER_PROP:String = '$effect_ctrler';

    /**
     * 镜头控制器属性名。
     *
     * @default $camera_ctrler
     */
    public static const CAMERA_CTRLER_PROP:String = '$camera_ctrler';

    /**
     * 判断目标是否具备指定方法。
     *
     * @param target 控制器对象。
     * @param methodName 方法名。
     * @return 存在且为 Function 时返回 <code>true</code>。
     *
     * @example
     * <listing version="3.0">
     * if (IdeRuntimeUtils.hasMethod(ctrler, 'shine')) {
     *     ctrler.shine(0xffffff);
     * }
     * </listing>
     */
    public static function hasMethod(target:*, methodName:String):Boolean {
        if (!target || !methodName) {
            return false;
        }

        try {
            return (methodName in target) && (target[methodName] is Function);
        }
        catch (e:Error) {
        }
        return false;
    }

    /**
     * 校验目标是否具备全部指定方法。
     *
     * @param target 控制器对象。
     * @param methodNames 方法名列表。
     * @return 全部存在返回 <code>true</code>。
     * @example
     * <listing version="3.0">
     * IdeRuntimeUtils.requireMethods(ctrler, ['shine', 'shake']);
     * </listing>
     */
    public static function requireMethods(target:*, methodNames:Array):Boolean {
        if (!target || !methodNames) {
            return false;
        }

        for each (var name:String in methodNames) {
            if (!hasMethod(target, name)) {
                return false;
            }
        }
        return true;
    }

    /**
     * 沿 parent 链查找已注入的角色主控制器。
     *
     * @param from 起始显示对象。
     * @return 角色主控制器；未找到时返回 <code>null</code>。
     *
     * @example
     * <listing version="3.0">
     * var ctrler:* = IdeRuntimeUtils.findFighterCtrler(this);
     * </listing>
     * @see #FIGHTER_CTRLER_PROP
     */
    public static function findFighterCtrler(from:DisplayObject):* {
        return findInjected(from, FIGHTER_CTRLER_PROP, true);
    }

    /**
     * 沿 parent 链查找已注入的 MC 控制器。
     *
     * @param from 起始显示对象。
     * @return MC 控制器；未找到时返回 <code>null</code>。
     *
     * @example
     * <listing version="3.0">
     * var ctrler:* = IdeRuntimeUtils.findMcCtrler(this);
     * </listing>
     * @see #MC_CTRLER_PROP
     */
    public static function findMcCtrler(from:DisplayObject):* {
        return findInjected(from, MC_CTRLER_PROP, true);
    }

    /**
     * 沿 parent 链查找已注入的效果控制器。
     *
     * <p>对应 <code>parent.$effect_ctrler</code>（FighterMain）。</p>
     *
     * @param from 起始显示对象。
     * @param requiredMethods 可选，需具备的方法名列表。
     * @return 效果控制器；未找到或校验失败时返回 <code>null</code>。
     *
     * @example
     * <listing version="3.0">
     * var ctrler:* = IdeRuntimeUtils.findEffectCtrler(this, ['shine']);
     * </listing>
     *
     * @see #EFFECT_CTRLER_PROP
     * @see #hasMethod()
     */
    public static function findEffectCtrler(from:DisplayObject, requiredMethods:Array = null):* {
        var ctrler:* = findInjected(from, EFFECT_CTRLER_PROP, true);
        if (!ctrler) {
            return null;
        }

        if (requiredMethods && !requireMethods(ctrler, requiredMethods)) {
            warnInvalidMethods(from, EFFECT_CTRLER_PROP, ctrler, requiredMethods);
            return null;
        }

        return ctrler;
    }

    /**
     * 沿 parent 链查找已注入的镜头控制器。
     *
     * @param from 起始显示对象。
     * @param requiredMethods 可选，需具备的方法名列表。
     * @return 镜头控制器；未找到或校验失败时返回 <code>null</code>。
     *
     * @example
     * <listing version="3.0">
     * var ctrler:* = IdeRuntimeUtils.findCameraCtrler(this, ['focusSelf']);
     * </listing>
     * @see #CAMERA_CTRLER_PROP
     */
    public static function findCameraCtrler(from:DisplayObject, requiredMethods:Array = null):* {
        var ctrler:* = findInjected(from, CAMERA_CTRLER_PROP, true);
        if (!ctrler) {
            return null;
        }

        if (requiredMethods && !requireMethods(ctrler, requiredMethods)) {
            warnInvalidMethods(from, CAMERA_CTRLER_PROP, ctrler, requiredMethods);
            return null;
        }

        return ctrler;
    }

    /** @private 沿 parent 链读取注入属性，缺失时 trace */
    private static function findInjected(from:DisplayObject, prop:String, warnIfMissing:Boolean):* {
        if (!from) {
            if (warnIfMissing) {
                warnMissing(null, prop, 'from is null');
            }
            return null;
        }

        var node:DisplayObject = from;
        var sawProp:Boolean    = false;

        while (node) {
            try {
                if (prop in node) {
                    sawProp = true;
                    var value:* = node[prop];
                    if (value != null) {
                        return value;
                    }
                }
            }
            catch (e:Error) {
            }

            node = node.parent;
        }

        if (warnIfMissing) {
            if (sawProp) {
                warnMissing(from, prop, 'property exists but value is null (initFighter not called?)');
            }
            else {
                warnMissing(from, prop, 'not found on FighterMain display tree');
            }
        }

        return null;
    }

    /** @private */
    private static function warnMissing(from:DisplayObject, prop:String, detail:String):void {
        trace('[IdeRuntimeUtils] missing', prop, '-', detail, '-', describe(from));
    }

    /** @private */
    private static function warnInvalidMethods(
        from           :DisplayObject,
        prop           :String,
        ctrler         :*,
        requiredMethods:Array
    ):void {
        var missing:Array = [];
        for each (var name:String in requiredMethods) {
            if (!hasMethod(ctrler, name)) {
                missing.push(name);
            }
        }

        trace(
            '[IdeRuntimeUtils] invalid', prop,
            'missing methods:', missing.join(','),
            'ctrler:', getQualifiedClassName(ctrler),
            '-', describe(from)
        );
    }

    /** @private */
    private static function describe(from:DisplayObject):String {
        if (!from) {
            return '(null)';
        }

        var name:String = from.name ? from.name : '(no-name)';
        return getQualifiedClassName(from) + '#' + name;
    }
}
}
