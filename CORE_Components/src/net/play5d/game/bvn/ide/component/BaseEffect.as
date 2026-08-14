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

package net.play5d.game.bvn.ide.component {
import net.play5d.game.bvn.ide.utils.IdeRuntimeUtils;

/**
 * 效果类 IDE 组件基类。
 *
 * <p>仅面向 FighterMain 时间轴：读取 <code>$effect_ctrler</code>。</p>
 * <p>无参效果可用 <code>bindNoArgCall</code> 一次绑定标题、预览与调用。</p>
 *
 * @see net.play5d.game.bvn.ide.utils.IdeRuntimeUtils#findEffectCtrler()
 * @see #invokeEffect()
 * @see #bindNoArgCall()
 */
public class BaseEffect extends BaseIdeCtrler {

    /** @private 无参效果方法名；有参子类勿设 */
    private var _noArgMethod:String = null;

    /**
     * 绑定无参效果：标题 + 预览 + <code>doAction</code> 调用。
     *
     * @param titleLabel 标题（自动加 <code>// </code>）。
     * @param methodName <code>$effect_ctrler</code> 方法名。
     *
     * @example
     * <listing version="3.0">
     * bindNoArgCall('效果_走路', 'walk');
     * </listing>
     */
    protected function bindNoArgCall(titleLabel:String, methodName:String):void {
        title        = titleLabel;
        _noArgMethod = methodName;
        updateCallPreview(methodName);
    }

    /**
     * 安全调用效果控制器方法。
     *
     * @param methodName 方法名。
     * @param args 参数列表。
     * @return 调用成功返回 <code>true</code>。
     *
     * @example
     * <listing version="3.0">
     * invokeEffect('shine', [0xffffff]);
     * </listing>
     */
    protected function invokeEffect(methodName:String, args:Array = null):Boolean {
        return invokeCtrler(methodName, args);
    }

    /**
     * @inheritDoc
     */
    override public function doAction():void {
        if (_noArgMethod) {
            invokeEffect(_noArgMethod);
            return;
        }

        super.doAction();
    }

    /**
     * @inheritDoc
     */
    override protected function resolveCtrler():void {
        _ctrlerProp = IdeRuntimeUtils.EFFECT_CTRLER_PROP;
        _ctrler     = IdeRuntimeUtils.findEffectCtrler(this);
    }
}
}
