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
 * 全局函数，使用命名占位符 “<b>{name}</b>” 格式化字符串。
 * 若要表示字面量的大括号请写作 <code>{{</code> 与 <code>}}</code>。
 * <p/>
 * 下列代码演示如何使用全局方法 <code>Format()</code> 格式化字符串：
 * <listing version="3.0">
 var source:String = "今天是星期{weekday}，天气：{weather}";
 var params:Object = {weekday: 1, weather: "晴"};
 var output:String = Format(source, params);

 // 输出结果：“今天是星期1，天气：晴”
 trace(output);
 * </listing>
 *
 * @param           format  源字符串
 * @param           params  占位符名到替换值的映射，可为 null
 *
 * @remarks         占位符个数不固定、无上限；按模板长度线性扫描，动态拼接结果。
 *
 * @see             String
 * @see             Object
 * @throws          ArgumentError
 * @return          基于命名占位符格式化处理后的字符串
 *
 * @langversion     3.0
 * @playerversion   Flash 9, Lite 4
 */
public function Format(format:String, params:Object = null):String {
    if (!format) {
        return format;
    }

    var len:int = format.length;
    // 无 “{” 则不可能含命名占位符，直接返回避免后续分配
    if (len == 0 || format.indexOf('{') == -1) {
        return format;
    }

    params ||= {};

    // 是否含字面量转义 “{{” / “}}”（与占位符个数无关，仅决定是否走转义分支）
    var hasEscape:Boolean = format.indexOf('{{') != -1 || format.indexOf('}}') != -1;

    // parts     — 输出片段列表（字面量段 + 替换值），长度随占位符数量动态增长
    // missing   — 懒分配：记录 params 中缺失的占位符名，扫描结束后统一抛错
    // i         — 当前扫描位置
    // literalStart — 尚未写入 parts 的字面量区间起点（substring 左闭）
    // replaced  — 是否发生过替换或转义展开；为 false 时可原样返回 format
    var parts:Array       = [];
    var missing:Array     = null;
    var i:int             = 0;
    var literalStart:int  = 0;
    var replaced:Boolean  = false;

    // 单次线性扫描：顺序处理字面量、转义大括号、命名占位符
    while (i < len) {
        var c:int = format.charCodeAt(i);

        // —— 字面量 “}}”：输出单个 “}”，跳过第二个 “}”
        if (hasEscape && c == 0x7D) { // '}'
            if (i + 1 < len && format.charCodeAt(i + 1) == 0x7D) {
                parts[parts.length]  = format.substring(literalStart, i);
                parts[parts.length]  = '}';
                i                   += 2;
                literalStart         = i;
                replaced             = true;
                continue;
            }
        }

        // 非 “{” 继续向后扫描
        if (c != 0x7B) { // '{'
            i++;
            continue;
        }

        // —— 字面量 “{{”：输出单个 “{”，跳过第二个 “{”
        if (hasEscape && i + 1 < len && format.charCodeAt(i + 1) == 0x7B) {
            parts[parts.length] = format.substring(literalStart, i);
            parts[parts.length] = '{';
            i                  += 2;
            literalStart        = i;
            replaced            = true;
            continue;
        }

        // —— 尝试解析命名占位符 “{name}”，name 须符合 [A-Za-z_][A-Za-z0-9_]*
        var nameStart:int = i + 1;
        if (nameStart >= len) {
            i++;
            continue;
        }

        // 标识符首字符：_ / A–Z / a–z
        var nc:int = format.charCodeAt(nameStart);
        if (nc != 95 && (nc < 65 || nc > 90) && (nc < 97 || nc > 122)) {
            i++;
            continue;
        }

        // 标识符后续字符：首字符规则 + 0–9
        var j:int = nameStart + 1;
        var cc:int;
        while (j < len) {
            cc = format.charCodeAt(j);
            if (cc == 95 || (cc >= 65 && cc <= 90) || (cc >= 97 && cc <= 122) || (cc >= 48 && cc <= 57)) {
                j++;
            } else {
                break;
            }
        }

        // 未以 “}” 闭合则视为普通字符，不作为占位符
        if (j >= len || format.charCodeAt(j) != 0x7D) { // '}'
            i++;
            continue;
        }

        var name:String = format.substring(nameStart, j);
        // 占位符前的字面量段
        parts[parts.length] = format.substring(literalStart, i);
        replaced            = true;

        if (!(name in params)) {
            if (!missing) {
                missing = [];
            }
            missing[missing.length] = name;
            // 暂保留 “{name}” 原文，便于在抛错前仍得到可读的中间结果
            parts[parts.length] = '{' + name + '}';
        } else {
            var val:* = params[name];
            parts[parts.length] = val is String ? val as String : String(val);
        }

        // 从闭合 “}” 之后继续扫描
        i            = j + 1;
        literalStart = i;
    }

    // 全程未识别到占位符或转义：无分配必要，返回原串
    if (!replaced) {
        return format;
    }

    // 追加最后一个字面量尾段
    parts[parts.length] = format.substring(literalStart);

    if (missing != null && missing.length > 0) {
        throw new ArgumentError(
                'Format: missing parameter(s): ' + missing.join(', ')
        );
    }

    return parts.join('');
}
}
