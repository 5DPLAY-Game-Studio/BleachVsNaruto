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
 * 镜头控制器类 IDE 组件基类。
 *
 * <p>仅面向 FighterMain 时间轴：读取 <code>$camera_ctrler</code>。</p>
 *
 * @see net.play5d.game.bvn.ide.utils.IdeRuntimeUtils#findCameraCtrler()
 * @see #invokeCamera()
 */
public class BaseCamera extends BaseIdeCtrler {

    /**
     * 安全调用镜头控制器方法。
     *
     * @param methodName 方法名。
     * @param args 参数列表。
     * @return 调用成功返回 <code>true</code>。
     *
     * @example
     * <listing version="3.0">
     * invokeCamera('focusSelf');
     * </listing>
     */
    protected function invokeCamera(methodName:String, args:Array = null):Boolean {
        return invokeCtrler(methodName, args);
    }

    /**
     * @inheritDoc
     */
    override protected function resolveCtrler():void {
        _ctrlerProp = IdeRuntimeUtils.CAMERA_CTRLER_PROP;
        _ctrler     = IdeRuntimeUtils.findCameraCtrler(this);
    }
}
}
