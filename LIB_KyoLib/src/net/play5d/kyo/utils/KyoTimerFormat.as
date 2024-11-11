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

package net.play5d.kyo.utils {
/**
 * 时间格式化类
 * @author kyo
 */
public class KyoTimerFormat {
    private static const EN_DAYS:Object = {
        0: 'Sunday',
        1: 'Monday',
        2: 'Tuesdry',
        3: 'Wednesday',
        4: 'Thursday',
        5: 'Friday',
        6: 'Saturday'
    };
    private static const CN_DAYS:Object = {
        0: '星期天',
        1: '星期一',
        2: '星期二',
        3: '星期三',
        4: '星期四',
        5: '星期五',
        6: '星期六'
    };

    public static function isAM(date:Date):Boolean {
        return date.hours < 12;
    }

    public static function getTime(date:Date, sign:String = ' : ', second:Boolean = true,
                                   type24:Boolean                                 = true
    ):String {
        var h:int = date.hours;
        var m:String = formatNum(date.minutes);
        var s:String = second ? sign + formatNum(date.seconds) : '';
        if (!type24 && h > 12) {
            h -= 12;
        }
        var hh:String = formatNum(h);
        return hh + sign + m + s;
    }

    public static function getDate(date:Date, sign:String = '/'):String {
        return date.fullYear + sign + formatNum(date.month + 1) + sign + formatNum(date.date);
    }

    public static function getDateTime(date:Date, sign_date:String = '/', sign_time:String = ' : ',
                                       second:Boolean                                      = true, type24:Boolean               = true
    ):String {
        return getDate(date, sign_date) + ' ' + getTime(date, sign_time, second, type24);
    }

    /**
     * 获取星期几
     * @param date
     * @param type 返回的样式 -> 0：返回数字 ， 1：返回英文，2：返回中文
     */
    public static function getDay(date:Date, type:int = 1):String {
        var n:int = date.day;
        switch (type) {
        case 1:
            return EN_DAYS[n];
        case 2:
            return CN_DAYS[n];
        default:
            return n.toString();
        }
    }

    /**
     * 将秒转换为时间（时：分：秒）
     */
    public static function secToTime(s:int, gap:String = ':', second:Boolean = true, hour:Boolean = true):String {
        var h:int = s / 60 / 60;
        s -= h * 60 * 60;
        var m:int = s / 60;
        s -= m * 60;

        var hs:String = '';
        if (hour) {
            hs = h >= 10 ? h.toString() : '0' + h;
            hs += gap;
        }

        var ms:String = m >= 10 ? m.toString() : '0' + m;

        var ss:String = '';
        if (second) {
            ss = s >= 10 ? s.toString() : '0' + s;
            ss = gap + ss;
        }
        return hs + ms + ss;
    }

    public static function formatNum(n:int):String {
        return n >= 10 ? n.toString() : '0' + n;
    }

}
}
