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

package {
import flash.media.Sound;

import net.play5d.game.bvn.ctrler.SoundCtrl;

/**
 * 播放音效（<code>Sound</code> 实例或 SWC 声音类）。
 *
 * <p>委托 <code>SoundCtrl</code>；<code>null</code> 或类型不匹配时静默忽略。
 * 无双闯关里，距离上一次播放不足 20 毫秒的音效会被丢掉。</p>
 *
 * @param obj <code>Sound</code> 实例，或可实例化为声音的 <code>Class</code>。
 * @example
 * <listing version="3.0">
 * PlaySound(hitSnd);
 * PlaySound(Snd_Hit);
 * </listing>
 * @see flash.media.Sound
 * @see net.play5d.game.bvn.ctrler.SoundCtrl
 */
public function PlaySound(obj:Object):void {
    if (obj is Sound) {
        SoundCtrl.I.playSound(obj as Sound);
        return;
    }
    if (obj is Class) {
        SoundCtrl.I.playSwcSound(obj as Class);
    }
}
}
