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
import flash.display.Stage;
import flash.events.TimerEvent;
import flash.external.ExternalInterface;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.text.TextField;
import flash.utils.Timer;
import flash.utils.clearInterval;
import flash.utils.setInterval;

public class WebUtils {
//		public static var allowGetURL:Boolean = true;
//		public static var setURLtoClipboard:Boolean = false;
//
//		public static var getUrlBack:Function;

    private static var _url:String;

    public static function getURL(url:String, target:String = '_blank'):void {
        if (!url) {
            trace('getURL: url is null');
            return;
        }
        try {
            navigateToURL(new URLRequest(url), target);
//				if(setURLtoClipboard) System.setClipboard(url);
//				if(getUrlBack != null)getUrlBack();
        }
        catch (e:Error) {
            trace(e);
        }
    }

    public static function addJSCallBack(functionName:String, closure:Function, jsReady:String = null,
                                         debugTxt:TextField                                    = null
    ):void {
        if (jsReady == null) {
            try {
                ExternalInterface.addCallback(functionName, closure);
            }
            catch (e:Error) {
                trace(e);
            }
        }
        else {
            var timer:Timer = new Timer(100);
            timer.addEventListener(TimerEvent.TIMER, function (e:TimerEvent):void {
                try {
                    var jsVar:Boolean = ExternalInterface.call(jsReady);
                }
                catch (e:Error) {
                    trace(e);
                    timer.stop();
                    timer = null;
                }
                if (debugTxt != null) {
                    debugTxt.text = jsVar.toString();
                }
                if (jsVar) {
                    addJSCallBack(functionName, closure);
                    timer.stop();
                    timer = null;
                }
            });
            timer.start();
        }
    }

    public static function checkLockedURL(...params):Boolean {
        for each(var i:Object in params) {
            if (i is Array) {
                for each(var j:String in i) {
                    if (!checkURL(j)) {
                        return false;
                    }
                }
            }
            else {
                if (!checkURL(i as String)) {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * 获取URL传来的参数
     * @param stage
     * @param checkVar 检测传来的属性KEY
     * @param back 成功后调用，有一个参数Object，即URL参数集合
     * @param timeout 在一定时间(毫秒)后，认为失败，调用back。为0时直到取到参数为止
     */
    public static function getParameters(stage:Stage, checkVar:String, back:Function, timeout:int = 0):void {
        var loadint:int = setInterval(loadp, 300);
        var loadTimes:int = timeout == 0 ? -1 : Math.ceil(timeout / 300);

        function loadp():void {
            var ckvar:Object = stage.loaderInfo.parameters[checkVar];
            if (loadTimes > 0) {
                loadTimes--;
            }
            if (ckvar || loadTimes == 0) {
                clearInterval(loadint);
                if (back != null) {
                    back(stage.loaderInfo.parameters);
                }
            }
        }
    }

    public static function getLocalUrl(s:Stage):String {
        var url:String = s.loaderInfo.url;
        var i:int      = url.lastIndexOf('/');
        url            = url.substr(0, i + 1);
        return url;
    }

    public static function replaceUrl(txt:String, matchKey:String, urlPath:String):String {
        var v:String = txt.replace(matchKey, matchKey + urlPath);
        v            = v.replace(urlPath + 'http://', 'http://');
        return v;
    }

    public static function getUrlFloder(url:String):String {
        var x:int = url.lastIndexOf('/');
        return url.substr(0, x + 1);
    }

    public static function getLocalFloder(url:String):String {
        var x:int = url.lastIndexOf('\\');
        return url.substr(0, x + 1);
    }

    public static function getFileName(stage:Stage):String {
        var url:String = stage.loaderInfo.url;
        var x:int      = url.lastIndexOf('/');
        return url.substr(x + 1);
    }

    public static function getStageUrlFloder(stage:Stage):String {
        var url:String = stage.loaderInfo.url;
        return getUrlFloder(url);
    }

    public static function refresh():void {
        getURL('javascript:location.reload();', '_self');
    }

    public static function alert(v:String):void {
        getURL('javascript:alert("' + v + '");', '_self');
    }

    private static function checkURL(url:String):Boolean {
        if (_url == null) {
            try {
                _url = ExternalInterface.call('eval', 'window.location.href');
            }
            catch (e:Error) {
                trace(e);
                return false;
            }
            var s:int = _url.indexOf('//') + 2;
            var e:int = _url.indexOf('/', s);
            e         = e == -1 ? int.MAX_VALUE : e - s;
            _url      = _url.substr(s, e);
        }
        return _url.indexOf(url) != -1;
    }

}
}
