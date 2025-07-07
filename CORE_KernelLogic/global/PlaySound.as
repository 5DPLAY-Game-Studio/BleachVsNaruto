/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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

package {
import flash.media.Sound;

import net.play5d.game.bvn.ctrler.SoundCtrl;

/**
 * 全局函数，播放声音
 * <p/>
 * 下列代码演示如何使用全局方法 <code>PlaySound()</code>
 * 进行声音播放：
 * <listing version="3.0">
 PlaySound(snd_cls);
 PlaySound(snd);
 * </listing>
 *
 * @param obj 声音对象，可为 Class 类型或 Sound 类型
 *
 * @see           Class
 * @see           Sound
 *
 * @langversion   3.0
 * @playerversion Flash 9, Lite 4
 */
public function PlaySound(obj:Object):void {
    if (obj is Sound) {
        SoundCtrl.I.playSound(obj as Sound);
    }
    else if (obj is Class) {
        SoundCtrl.I.playSwcSound(obj as Class);
    }
}
}
