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
import flash.display.BitmapData;
import flash.utils.Dictionary;
import flash.utils.describeType;

/**
 * Embed SWF 资源池：扫描子类上的 Embed 字段，经 <code>EmbedSwf</code> 加载后按名取类。
 *
 * <p>子类需提供 UI Embed 字段，并实现 <code>getUiClass</code>。</p>
 *
 * @see EmbedSwf
 * @see #initalize()
 */
public class EmbedSwfAssetUtil {

    /**
     * 构造函数。
     */
    public function EmbedSwfAssetUtil() {
    }

    /** @private */
    private var _swfPool:Dictionary;
    /** @private */
    private var _initBack:Function;
    /** @private */
    private var _inited:Boolean;
    /** @private */
    private var _initing:Boolean;

    /**
     * 子类返回主 UI Embed 类（用于 <code>getItemClass</code>）。
     * @return Embed 类。
     */
    protected function getUiClass():Class {
        return null;
    }

    /**
     * 初始化：加载本实例上全部 Embed 变量。
     * @param back 全部就绪回调。
     */
    public function initalize(back:Function = null):void {

        if (_initing) {
            throw new Error(GetLang('debug.error.data.embed_swf_asset_util.init_in_progress'));
        }

        if (_inited) {
            if (back != null) {
                back();
            }
            return;
        }

        _inited  = true;
        _initing = true;

        _swfPool = new Dictionary();

        _initBack = back;

        var xml:XML = describeType(this);

        for each(var j:XML in xml.variable) {
            var k:String  = j.@name;
            var cls:Class = this[k];

            var swf:EmbedSwf = new EmbedSwf(cls);
            swf.ready        = swfReadyBack;
            _swfPool[cls]    = swf;

        }

    }

    /**
     * 创建显示对象。
     * @param itemName 链接名。
     * @return 实例。
     */
    public function createDisplayObject(itemName:String):* {
        var cls:Class = getItemClass(itemName);
        if (cls) {
            return new cls();
        }
    }

    /**
     * 创建 BitmapData。
     * @param itemName 链接名。
     * @param width 宽。
     * @param height 高。
     * @return 位图数据。
     */
    public function createBitmapData(itemName:String, width:int, height:int):BitmapData {
        var cls:Class = getItemClass(itemName);
        if (!cls) {
            return null;
        }
        var bd:BitmapData = new cls(width, height);
        return bd;
    }

    /**
     * 取得链接类。
     * @param itemName 链接名。
     * @return 类。
     */
    public function getItemClass(itemName:String):Class {

        if (!_swfPool) {
            throw new Error(GetLang('debug.error.data.embed_swf_asset_util.not_initialized'));
        }

        var ui:Class     = getUiClass();
        var swf:EmbedSwf = _swfPool[ui];
        if (!swf) {
            throw new Error('swf is undefined!');
        }
        return swf.getClass(itemName);
    }

    /** @private */
    private function swfReadyBack(target:EmbedSwf):void {
        for each(var i:EmbedSwf in _swfPool) {
            if (!i.isReady) {
                return;
            }
        }
        finish();
    }

    /** @private */
    private function finish():void {

        _initing = false;

        if (_initBack != null) {
            _initBack();
            _initBack = null;
        }
    }

}
}
