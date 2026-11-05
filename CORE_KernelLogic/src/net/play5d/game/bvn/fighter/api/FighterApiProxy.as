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

package net.play5d.game.bvn.fighter.api {
import flash.utils.Dictionary;
import flash.utils.Proxy;
import flash.utils.QName;
import flash.utils.describeType;
import flash.utils.flash_proxy;
import flash.utils.getQualifiedClassName;

/**
 * 角色时间轴门面的缺方法记录。
 *
 * <p>类上已经声明的方法仍直接调用。没有声明的读取、赋值和调用各记一条，同名再次出现只累加次数，不中断对局。</p>
 *
 * @see #records
 */
public class FighterApiProxy extends Proxy {

    /** @private */
    private static var _records:Array      = [];
    /** @private */
    private static var _seen:Object        = {};
    /** @private 每个门面类已声明的公开成员 */
    private static var _known:Dictionary   = new Dictionary();

    /**
     * 本局已经碰到的无效调用。
     *
     * <p>每项含 <code>api</code>、<code>kind</code>（<code>call</code> / <code>get</code> / <code>set</code> / <code>delete</code>）、<code>name</code>、<code>count</code>、<code>detail</code>。</p>
     *
     * @return 记录列表。
     * @example
     * <listing version="3.0">
     * FighterApiProxy.records;
     * </listing>
     */
    public static function get records():Array {
        return _records;
    }

    /**
     * 清空无效调用记录。
     *
     * @example
     * <listing version="3.0">
     * FighterApiProxy.clearRecords();
     * </listing>
     */
    public static function clearRecords():void {
        _records.length = 0;
        _seen           = {};
    }

    /** @private */
    override flash_proxy function hasProperty(name:*):Boolean {
        return knows(localName(name));
    }

    /** @private */
    override flash_proxy function getProperty(name:*):* {
        note('get', name, '');

        return undefined;
    }

    /** @private */
    override flash_proxy function setProperty(name:*, value:*):void {
        note('set', name, argText([value]));
    }

    /** @private */
    override flash_proxy function callProperty(name:*, ...rest):* {
        note('call', name, argText(rest));

        return undefined;
    }

    /** @private */
    override flash_proxy function deleteProperty(name:*):Boolean {
        note('delete', name, '');

        return false;
    }

    /** @private */
    override flash_proxy function nextNameIndex(index:int):int {
        return 0;
    }

    /** @private */
    override flash_proxy function nextName(index:int):String {
        return null;
    }

    /** @private */
    override flash_proxy function nextValue(index:int):* {
        return undefined;
    }

    /**
     * @private 同名无效访问只在第一次打跟踪。
     */
    private function note(kind:String, name:*, detail:String):void {
        var method:String = localName(name);
        var api:String    = apiName();
        var key:String    = api + '\n' + kind + '\n' + method;
        var row:Object    = _seen[key];
        if (row) {
            row.count++;
            return;
        }

        row = {
            api   : api,
            kind  : kind,
            name  : method,
            count : 1,
            detail: detail
        };
        _seen[key] = row;
        _records.push(row);
        TraceLang('debug.trace.data.fighter_api_proxy.invalid_call', {
            api : api,
            kind: kind,
            name: method
        });
    }

    /**
     * @private 类上是否声明了该公开成员。
     */
    private function knows(name:String):Boolean {
        var cache:Object = _known[constructor];
        if (!cache) {
            cache = {};
            var info:XML = describeType(this);
            mark(cache, info.method);
            mark(cache, info.accessor);
            mark(cache, info.variable);
            mark(cache, info.constant);
            _known[constructor] = cache;
        }

        return cache[name] == true;
    }

    /** @private */
    private function apiName():String {
        var full:String = getQualifiedClassName(this);
        var cut:int     = full.lastIndexOf('::');
        if (cut >= 0) {
            return full.substr(cut + 2);
        }
        cut = full.lastIndexOf('.');
        if (cut >= 0) {
            return full.substr(cut + 1);
        }

        return full;
    }

    /** @private */
    private static function localName(name:*):String {
        if (name is QName) {
            return QName(name).localName;
        }

        return String(name);
    }

    /** @private */
    private static function mark(cache:Object, nodes:XMLList):void {
        for each (var node:XML in nodes) {
            cache[String(node.@name)] = true;
        }
    }

    /** @private */
    private static function argText(args:Array):String {
        if (!args || args.length == 0) {
            return '';
        }

        var parts:Array = [];
        var n:int       = args.length > 4 ? 4 : args.length;
        for (var i:int = 0; i < n; i++) {
            parts.push(String(args[i]));
        }
        var text:String = parts.join(', ');
        if (text.length > 80) {
            text = text.substr(0, 80);
        }

        return text;
    }

}
}
