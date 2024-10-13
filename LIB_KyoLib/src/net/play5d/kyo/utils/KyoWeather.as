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
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;

import net.play5d.kyo.utils.vo.KyoWeaterVO;

public class KyoWeather {
    private static var _weatherxml:XML;
    private static var yweather:Namespace = new Namespace('http://xml.weather.yahoo.com/ns/rss/1.0');

    private static var _todayWeather:KyoWeaterVO;

    public static function get todayWeather():KyoWeaterVO {
        if (!_weatherxml) {
            return null;
        }
        if (!_todayWeather) {
            _todayWeather      = new KyoWeaterVO();
            var x:XML          = _weatherxml.channel.item.yweather::forecast[0];
            _todayWeather.low  = x.@low;
            _todayWeather.high = x.@high;
            _todayWeather.code = x.@code;
        }
        return _todayWeather;
    }

    private static var _tomorrowWeather:KyoWeaterVO;

    public static function get tomorrowWeather():KyoWeaterVO {
        if (!_weatherxml) {
            return null;
        }
        if (!_tomorrowWeather) {
            _tomorrowWeather      = new KyoWeaterVO();
            var x:XML             = _weatherxml.channel.item.yweather::forecast[1];
            _tomorrowWeather.low  = x.@low;
            _tomorrowWeather.high = x.@high;
            _tomorrowWeather.code = x.@code;
        }
        return _tomorrowWeather;
    }

    public static function loadWeather(cityCode:int, back:Function = null, error:Function = null):void {
        var url:String   = 'http://weather.yahooapis.com/forecastrss' +
                           '?w=' + cityCode + '&u=c';
        var ul:URLLoader = new URLLoader(new URLRequest(url));
        ul.addEventListener(Event.COMPLETE, success);
        ul.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
        ul.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);

        function success(e:Event):void {
            removeListeners();
            _weatherxml          = new XML(ul.data);
            var codeToday:String = _weatherxml.channel.item.yweather::forecast[0].@code;
            if (back != null) {
                back();
            }
            ul = null;
        }

        function errorHandler(e:Event):void {
            removeListeners();
            if (error != null) {
                error();
            }
            ul = null;
        }

        function removeListeners():void {
            ul.removeEventListener(Event.COMPLETE, success);
            ul.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            ul.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
        }
    }

}
}
