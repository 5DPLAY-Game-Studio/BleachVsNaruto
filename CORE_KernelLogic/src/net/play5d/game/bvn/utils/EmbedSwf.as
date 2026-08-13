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

package net.play5d.game.bvn.utils {
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

/**
 * 从 Embed SWF（含 <code>movieClipData</code>）加载到当前域，供取类与属性。
 *
 * @see #getClass()
 * @see ResUtils
 */
public class EmbedSwf {

    /**
     * @param swfClass Embed 生成的 SWF 类。
     */
    public function EmbedSwf(swfClass:Class) {
        _swf = new swfClass();

        var bytes:ByteArray = _swf.movieClipData;

        if (!bytes) {
            throw new Error(GetLang('debug.error.data.embed_swf.no_movie_clip_data'));
        }

        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete, false, 0, true);

        var lc:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
        lc.allowCodeImport   = true;

        loader.loadBytes(bytes, lc);
    }

    /** 是否加载完成 */
    public var isReady:Boolean;
    /** 就绪回调，参数为本实例 */
    public var ready:Function;
    /** 错误回调（可选），参数为错误信息字符串 */
    public var error:Function;

    /** @private */
    private var _swf:*;
    /** @private */
    private var _domain:ApplicationDomain;
    /** @private */
    private var _content:DisplayObject;

    /**
     * 从 SWF 域取得类定义。
     * @param name 链接名。
     * @return 类。
     */
    public function getClass(name:String):Class {
        return _domain.getDefinition(name) as Class;
    }

    /**
     * 读取根内容上的属性。
     * @param name 属性名。
     * @return 属性值。
     */
    public function getProperty(name:String):* {
        return _content[name];
    }

    /**
     * 调用根内容上的方法。
     * @param func 方法名。
     * @param params 参数。
     * @return 返回值。
     */
    public function call(func:String, params:Array = null):* {
        if (!_content) {
            trace('swf is null !');
            return null;
        }

        try {
            var fn:Function = _content[func];
            return fn.apply(null, params);
        }
        catch (e:Error) {
            trace(e);
            throw new Error('swf.' + func + ' call failed ! ');
        }
    }

    /** @private */
    private function loadComplete(e:Event):void {
        var l:LoaderInfo = e.currentTarget as LoaderInfo;
        _domain          = l.applicationDomain;
        _content         = l.content;

        isReady = true;

        if (ready != null) {
            ready(this);
            ready = null;
        }
    }

}
}
