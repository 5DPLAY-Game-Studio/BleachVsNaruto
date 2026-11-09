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

package net.play5d.game.bvn.utils {
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.media.SoundTransform;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.describeType;

import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.interfaces.ISwfLib;
import net.play5d.kyo.loader.KyoLoaderLite;

/**
 * SWF 资源入口。单例用 <code>I</code>。库还没赋值时，初始化抛错。
 *
 * <p>初始化一旦开始就把已初始化标成 true。中途失败只调用错误回调，不把进行中的标记清掉，之后再初始化会一直抛初始化进行中的错误。已经完成后再调用，只执行成功回调，不会重新打开库里的 SWF。找不到联动类时，创建显示对象没有返回值，创建位图数据返回 null。</p>
 */
public class ResUtils {

    /**
     * 设置界面的联动名。
     *
     * @default $setting$MC_stgSetUI
     */
    public static var SETTING:String         = '$setting$MC_stgSetUI';
    /**
     * 通关界面的联动名。
     *
     * @default $common$MC_congratulations
     */
    public static var CONGRATULATIONS:String = '$common$MC_congratulations';
    /**
     * 胜利界面的联动名。
     *
     * @default $loading$MC_stageWinner
     */
    public static var WINNER:String          = '$loading$MC_stageWinner';
    /**
     * 标题界面的联动名。
     *
     * @default $title$MC_stgTitle
     */
    public static var TITLE:String           = '$title$MC_stgTitle';
    /**
     * 结束界面的联动名。
     *
     * @default $game_over$MC_stgGameOver
     */
    public static var GAME_OVER:String       = '$game_over$MC_stgGameOver';
    /**
     * 选人界面的联动名。
     *
     * @default $select$MC_stgSelect
     */
    public static var SELECT:String          = '$select$MC_stgSelect';
    /**
     * 大地图的联动名。
     *
     * @default $big_map$MC_bigMap
     */
    public static var BIG_MAP:String         = '$big_map$MC_bigMap';
    /**
     * SWF 库。初始化前必须赋值。
     *
     * @default null
     */
    public static var swfLib:ISwfLib;
    private static var _i:ResUtils;

    /**
     * 唯一实例。第一次取时创建。
     *
     * @return 资源工具。
     * @example
     * <listing version="3.0">
     * var res:ResUtils = ResUtils.I;
     * </listing>
     */
    public static function get I():ResUtils {
        _i ||= new ResUtils();
        return _i;
    }

    private var _swfPool:Dictionary;
    private var _initBack:Function;
    private var _initError:Function;
    private var _inited:Boolean;
    private var _initing:Boolean;

    /**
     * 打开库里每一个非空字符串地址。正在初始化时抛错。库是 null 时抛错。已经完成时只调用成功回调。
     *
     * @param back 全部就绪后调用。默认 null。
     * @param error 某个 SWF 失败时调用，不带参数。默认 null。失败后标记不会复位。
     * @throws Error 正在初始化，或库还没赋值时。
     * @example
     * <listing version="3.0">
     * ResUtils.I.initialize(onReady, onError);
     * </listing>
     */
    public function initialize(back:Function = null, error:Function = null):void {

        if (_initing) {
            throw new Error(GetLang('log.error.load.res_utils.init_in_progress'));
        }

        if (swfLib == null) {
            throw new Error(GetLang('log.error.load.res_utils.swf_lib_not_init'));
        }

        if (_inited) {
            if (back != null) {
                back();
            }
            return;
        }

        _inited  = true;
        _initing = true;

        _swfPool ||= new Dictionary();

        _initBack  = back;
        _initError = error;

        var xml:XML = describeType(swfLib);

        for each(var j:XML in xml.accessor) {
            var value:* = swfLib[String(j.@name)];
            if (value is String && value) {
                openSwf(value);
            }
        }

    }

    /**
     * 再打开一个 SWF。同一个地址会换掉池里的那份，已经在加载的旧对象不取消。池还没有时会先建。
     *
     * @param url 相对 <code>assets/</code> 的地址。
     * @example
     * <listing version="3.0">
     * ResUtils.I.addSwf(url);
     * </listing>
     */
    public function addSwf(url:String):void {
        _swfPool ||= new Dictionary();
        openSwf(url);
    }

    /**
     * 按联动名创建实例。是精灵时把音量设成当前配置。找不到类时没有返回值。配置缺失时抛错。
     *
     * @param swf 已打开的 SWF 地址。
     * @param itemName 联动名。
     * @return 新实例。找不到类时没有返回值。
     * @throws Error SWF 不在池里，或还没初始化时。
     * @throws TypeError 实例是精灵但存档配置缺失时。
     * @example
     * <listing version="3.0">
     * var view:* = ResUtils.I.createDisplayObject(swf, itemName);
     * </listing>
     */
    public function createDisplayObject(swf:String, itemName:String):* {
        var cls:Class = getItemClass(swf, itemName);
        if (cls) {
            var d:* = new cls();
            if (d is Sprite) {
                var mc:Sprite         = d as Sprite;
                var st:SoundTransform = mc.soundTransform;
                st.volume             = GameData.I.config.soundVolume;
                mc.soundTransform     = st;
                return mc;
            }
            return d;
        }
    }

    /**
     * 按联动名创建位图数据。找不到类时返回 null。
     *
     * @param swf 已打开的 SWF 地址。
     * @param itemName 联动名。
     * @param width 宽度。
     * @param height 高度。
     * @return 新的位图数据。找不到类时为 null。
     * @throws Error SWF 不在池里时。
     * @example
     * <listing version="3.0">
     * var pixels:BitmapData = ResUtils.I.createBitmapData(swf, itemName, 32, 32);
     * </listing>
     */
    public function createBitmapData(swf:String, itemName:String, width:int, height:int):BitmapData {
        var cls:Class = getItemClass(swf, itemName);
        if (!cls) {
            return null;
        }
        var bd:BitmapData = new cls(width, height);
        return bd;
    }

    /**
     * 取联动类。
     *
     * @param swf 已打开的 SWF 地址。
     * @param itemName 联动名。
     * @return 类。库里没有时由 SWF 对象决定。
     * @throws Error SWF 不在池里时。
     * @example
     * <listing version="3.0">
     * var cls:Class = ResUtils.I.getItemClass(swf, itemName);
     * </listing>
     */
    public function getItemClass(swf:String, itemName:String):Class {
        return find(swf).getClass(itemName);
    }

    /**
     * 取 SWF 上的属性。
     *
     * @param swf 已打开的 SWF 地址。
     * @param name 属性名。
     * @return 属性值。
     * @throws Error SWF 不在池里时。
     * @example
     * <listing version="3.0">
     * var value:* = ResUtils.I.getItemProperty(swf, name);
     * </listing>
     */
    public function getItemProperty(swf:String, name:String):* {
        return find(swf).getProperty(name);
    }

    /**
     * 调用 SWF 里的函数。
     *
     * @param swf 已打开的 SWF 地址。
     * @param func 函数名。
     * @param params 参数数组。默认 null。
     * @return 函数返回值。
     * @throws Error SWF 不在池里时。
     * @example
     * <listing version="3.0">
     * var value:* = ResUtils.I.callSwfFunction(swf, func);
     * </listing>
     */
    public function callSwfFunction(swf:String, func:String, params:Array = null):* {
        return find(swf).call(func, params);
    }

    /** @private */
    private function openSwf(url:String):void {
        var swf:EmbedSwf = new EmbedSwf();
        swf.ready        = swfReadyBack;
        swf.error        = swfErrorBack;
        _swfPool[url]    = swf;

        KyoLoaderLite.loadBytes('assets/' + url, function (bytes:ByteArray):void {
            swf.open(bytes);
        }, function ():void {
            swfErrorBack(url);
        });
    }

    /** @private */
    private function find(swf:String):EmbedSwf {
        if (!_swfPool) {
            throw new Error(GetLang('log.error.load.res_utils.not_initialized'));
        }

        var loaded:EmbedSwf = _swfPool[swf];
        if (!loaded) {
            throw new Error('swf is undefined!');
        }

        return loaded;
    }

    private function swfReadyBack(target:EmbedSwf):void {
        for each(var i:EmbedSwf in _swfPool) {
            if (!i.isReady) {
                return;
            }
        }
        finish();
    }

    private function swfErrorBack(msg:String):void {
        if (_initError != null) {
            _initError();
        }
    }

    private function finish():void {

        _initing = false;

        if (_initBack != null) {
            _initBack();
            _initBack = null;
        }
    }

}
}
