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
import net.play5d.alice.utils.ClassUtils;
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.data.LanguageType;

/**
 * 多语言工具集
 *
 * <p>所选语言缺键时静默回退到简体中文（<code>zh-CN</code>）；
 * 中文亦无定义时由 <code>GetLangText</code> 返回 <code>[N/A]</code>。</p>
 */
public class MultiLangUtils {

    // 分隔符
    private const SEPARATOR:String = '.';

    // 单例
    private static var _instance:MultiLangUtils;

    /**
     * 单例
     */
    public static function get I():MultiLangUtils {
        _instance ||= new MultiLangUtils();
        return _instance;
    }

    // 当前语言对象
    private var _languageObj:Object;
    // 简体中文兜底对象
    private var _fallbackObj:Object;
    // 多语言缓存池（已解析最终文案）
    private var _cacheObj:Object = {};

    /**
     * 初始化
     * @param language 所选语言
     * @param back 成功回调（zh-CN 就绪即可；其它语言包缺失时仍成功并走中文兜底）
     * @param fail 失败回调（仅 zh-CN 加载失败）
     */
    public function initialize(language:String, back:Function, fail:Function):void {
        var fallbackUrl:String = langUrl(LanguageType.CHINESE_SIMPLIFIED);

        AssetManager.I.loadJSON(fallbackUrl, onFallbackOk, onFallbackFail);

        function onFallbackOk(data:Object):void {
            _fallbackObj = data;
            _cacheObj    = {};

            if (LanguageType.isSimplifiedChinese(language)) {
                _languageObj = data;
                if (back != null) {
                    back();
                }
                return;
            }

            AssetManager.I.loadJSON(langUrl(language), onLangOk, onLangFail);
        }

        function onFallbackFail():void {
            _fallbackObj = null;
            _languageObj = null;
            _cacheObj    = {};

            if (fail != null) {
                fail();
            }
        }

        function onLangOk(data:Object):void {
            _languageObj = data;
            if (back != null) {
                back();
            }
        }

        function onLangFail():void {
            // 所选语言包缺失：静默仅用 zh-CN
            _languageObj = null;
            if (back != null) {
                back();
            }
        }
    }

    /**
     * 得到当前语言文本
     * @param tree 文本的树形路径
     * @return 当前语言文本；缺键时回退 zh-CN；皆无则 <code>null</code>
     */
    public function getLangText(tree:String):String {
        if (!_languageObj && !_fallbackObj) {
            return null;
        }

        if (_cacheObj.hasOwnProperty(tree)) {
            return _cacheObj[tree];
        }

        var text:String = lookupText(_languageObj, tree);
        if (!text) {
            text = lookupText(_fallbackObj, tree);
        }
        if (!text) {
            return null;
        }

        _cacheObj[tree] = text;
        return text;
    }

    /**
     * @private 语言包 URL
     */
    private static function langUrl(language:String):String {
        return 'config/language/' + language + '.json';
    }

    /**
     * @private 按点分路径取字符串叶节点
     */
    private function lookupText(obj:Object, tree:String):String {
        if (!obj) {
            return null;
        }

        var text:String = ClassUtils.continuousAccess(obj, tree.split(SEPARATOR));
        return text || null;
    }

}
}
