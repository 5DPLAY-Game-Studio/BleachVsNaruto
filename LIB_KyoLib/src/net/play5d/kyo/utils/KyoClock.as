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
import flash.events.TimerEvent;
import flash.utils.Timer;

/**
 * 时钟类
 * @author kyo
 */
public class KyoClock {
    public function KyoClock() {
    }
    /**
     * 获取当前时间
     * 如果需要对时间进行格式化，请参考 net.play5d.kyo.utils.KyoTimerFormat
     * @return
     */
    public var now:Date = new Date();
    private var _timer:Timer;
    private var _functions:Array = [];
    private var _td:String;

    public function get isam():Boolean {
        return now.hours < 12;
    }

    /**
     * xx:xx
     */
    public function get time():String {
        return KyoTimerFormat.getTime(now, ':', false);
    }

    /**
     * xx:xx:xx
     */
    public function get time2():String {
        return KyoTimerFormat.getTime(now, ':', true);
    }

    public function get date():String {
        return now.fullYear + '.' + (
               now.month + 1
        ) + '.' + now.date;
    }

    public function get day():String {
        return KyoTimerFormat.getDay(now, 2);
    }

    public function getTime(type24:Boolean = true, srcond:Boolean = false, ampm:Boolean = false):String {
        var sr:String = KyoTimerFormat.getTime(now, ':', srcond, type24);
        if (ampm) {
            var apm:String = now.hours < 12 ? 'am' : 'pm';
            sr += ' ' + apm;
        }
        return sr;
    }

    public function getDateStr(ys:String = '年', ms:String = '月', ds:String = '日'):String {
        return now.fullYear + ys + KyoTimerFormat.formatNum(now.month + 1) + ms + KyoTimerFormat.formatNum(now.date) +
               ds;
    }

    public function addCallBack(fun:Function, params:Array = null):void {
        var i:int = _functions.indexOf(fun);
        if (i == -1) {
            _functions.push([fun, params]);
        }
    }

    public function removeCallBack(fun:Function):void {
        var i:int = _functions.indexOf(fun);
        if (i == -1) {
            _functions.splice(i, 1);
        }
    }

    public function start(delay:Number = 1):void {
        delay *= 1000;
        if (!_timer) {
            _timer = new Timer(delay);
            _timer.addEventListener(TimerEvent.TIMER, onTimer);
        }
        _timer.delay = delay;
        _timer.reset();
        _timer.start();
    }

    public function stop():void {
        if (_timer) {
            _timer.stop();
        }
    }

    public function reset():void {
        if (_timer) {
            _timer.reset();
        }
    }

    public function clear():void {
        stop();
        if (_timer) {
            _timer.removeEventListener(TimerEvent.TIMER, onTimer);
            _timer = null;
        }
        _functions = null;
    }

    private function onTimer(e:TimerEvent):void {
        now = new Date();
        for each(var i:Array in _functions) {
            var f:Function = i[0];
            var p:Array    = i[1];
            f.apply(null, p);
        }
    }
}
}
