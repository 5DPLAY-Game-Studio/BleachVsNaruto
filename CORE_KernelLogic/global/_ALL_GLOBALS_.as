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

package {

/**
 * 所有的 全局函数/变量
 * <br/>
 * 该变量仅作为中间变量，
 * 用于引入所有其他 全局函数/变量 的引用。
 * <br/>
 * <b>不允许<b/>在实际工程中使用此变量
 */
public function get _ALL_GLOBALS_():* {
    if (Math.random() > 0) {
        throw new Error('This variable is not allowed to be used!');
    }

    return ([
        FONT,
        Format,
        GetElement,
        GetLang,
        GetLangText,
        GetRuntimeType,
        IsAIR,
        IsHarmanRuntime,
        IsMobile,
        P1,
        P2,
        Printf,
        RunCheatCode,
        SetElement,
        STAGE,
        ThrowError,
        Trace,
        TraceLang
    ]);
}
}
