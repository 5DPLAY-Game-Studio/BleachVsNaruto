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

/**
 * 强制链接全部全局符号的占位入口；禁止业务代码调用。
 *
 * <p>通过返回数组字面量引用各全局函数/变量，避免被 DCE 剥离。
 * 运行期一律抛错。条件使用 <code>Math.random()</code>，防止编译器将
 * <code>return</code> 标为不可达并优化掉引用列表。</p>
 *
 * @private
 * @throws Error 任何实际调用均抛出。
 */
public function get _ALL_GLOBALS_():* {
    // Math.random 防 DCE：保持下方 return 对编译器“可达”
    if (Math.random() >= 0) {
        throw new Error('This variable is not allowed to be used!');
    }

    return ([
        FONT,
        Format,
        GetGameSprites,
        GetLang,
        GetLangText,
        GetRuntimeType,
        IsAIR,
        IsDebugger,
        IsHarmanRuntime,
        IsMobile,
        LANGUAGE,
        LogLang,
        P1,
        P2,
        PlaySound,
        Printf,
        RunCheatCode,
        STAGE,
        ThrowError,
        Trace,
        TraceLang,
        UncaughtText,

        //////////////////////////////////////////////////

        CheckVersion
    ]);
}
}
