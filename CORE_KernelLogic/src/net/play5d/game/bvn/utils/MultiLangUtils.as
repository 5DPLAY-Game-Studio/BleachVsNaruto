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
import net.play5d.game.bvn.ctrl.AssetManager;
import net.play5d.pcl.utils.ClassUtils;

/**
 * 多语言工具集
 */
public class MultiLangUtils {
    include "_INCLUDE_.as";

    // 分隔符
    private const SEPARATOR:String = '.';

    // 单例
    private static var _instance:MultiLangUtils;

    // 解析的语言对象
    private var _languageObj:Object;
    // 多语言缓存池
    private var _cacheObj:Object = {};

    /**
     * 单例
     */
    public static function get I():MultiLangUtils {
        _instance ||= new MultiLangUtils();
        return _instance;
    }

    /**
     * 初始化
     * @param language 所选语言
     * @param back 成功回调
     * @param fail 失败回调
     */
    public function initialize(language:String, back:Function, fail:Function):void {
        var url:String = 'config/language/' + language + '.json';
        AssetManager.I.loadJSON(url, loadSuccess, loadFailed);

        /**
         * 加载成功回调
         * @param data 加载成功的数据
         */
        function loadSuccess(data:Object):void {
            trace(data);
            _languageObj = data;

            if (back != null) {
                back();
            }
        }

        /**
         * 加载失败回调
         */
        function loadFailed():void {
            if (fail != null) {
                fail();
            }
        }
    }

    /**
     * 得到当前语言文本
     * @param tree 文本的树形路径
     * @return 当前语言文本
     */
    public function getLangText(tree:String):String {
        if (!_languageObj) {
            return null;
        }
        // 如果缓存中存在已有的对象，则返回缓存中的数值
        if (_cacheObj[tree]) {
            return _cacheObj[tree];
        }

        var text:String     = ClassUtils.continuousAccess(_languageObj, tree.split(SEPARATOR));
        if (!text) {
            return null;
        }

        // 缓存
        _cacheObj[tree] = text;
        return text;
    }

}
}
