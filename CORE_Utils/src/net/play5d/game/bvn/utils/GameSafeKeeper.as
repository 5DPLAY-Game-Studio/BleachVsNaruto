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
import flash.net.URLLoaderDataFormat;
import flash.utils.ByteArray;

import net.play5d.kyo.loader.KyoURLLoader;
import net.play5d.kyo.utils.EncryptUtils;

/**
 * 用内置 MD5 表校验已加载资源。
 *
 * <p>先解密 <code>assets/.md5</code>。任一文件不一致后，失败状态会保持。</p>
 *
 * @see #loadConfigure()
 * @see #checkFile()
 */
public class GameSafeKeeper {
    /** @private AES 密钥 */
    private const KEY:String = 'Wo&Ye@bu!Neng(889^Yang%a!Po!xO!bB)_(';

    /** @private AES 初始向量 */
    private const IV:String  = '#$@!#%^cscscsDDW*><1998AZSfdxx##(x_x)###2';

    /** @private */
    private static var _i:GameSafeKeeper;

    /**
     * 单例。
     *
     * @return 唯一实例。
     * @example
     * <listing version="3.0">
     * GameSafeKeeper.I.loadConfigure(onReady);
     * </listing>
     */
    public static function get I():GameSafeKeeper {
        _i ||= new GameSafeKeeper();
        return _i;
    }

    /** @private 解密后的路径到 MD5 表 */
    private var _fileSaveMap:Object;

    /** @private 配置加载或解密失败 */
    private var _configFailed:Boolean;

    /** @private 已判定不一致的路径 */
    private var _failFileMap:Object = {};

    /** @private 至少有一个文件校验失败 */
    private var _fileFailed:Boolean;

    /**
     * 加载并解密 MD5 配置。
     *
     * @param succ 成功回调，无参数。
     * @param fail 失败回调。解密失败时传入错误，加载失败时无参数。
     * @example
     * <listing version="3.0">
     * GameSafeKeeper.I.loadConfigure(start, onFail);
     * </listing>
     */
    public function loadConfigure(succ:Function, fail:Function = null):void {

        function succBack(data:ByteArray):void {
            try {
                var json:String    = EncryptUtils.decryptAES(data, KEY, IV);
                var jsonObj:Object = JSON.parse(json);
                _fileSaveMap       = jsonObj;
                if (succ != null) {
                    succ();
                }
            }
            catch (e:Error) {
                if (fail != null) {
                    fail(e);
                }
            }
        }

        function failBack(e:* = null):void {
            GameLogger.error('load', 'loadSafeFile fail: ' + e);
            _configFailed = true;
            if (fail != null) {
                fail();
            }
        }

        KyoURLLoader.load('assets/.md5', succBack, failBack, {dataFormat: URLLoaderDataFormat.BINARY});
    }

    /**
     * 配置是否加载失败。
     *
     * @return 失败时为 <code>true</code>。
     * @default false
     * @example
     * <listing version="3.0">
     * GameSafeKeeper.I.getConfigFailed();
     * </listing>
     */
    public function getConfigFailed():Boolean {
        return _configFailed;
    }

    /**
     * 是否已有文件校验失败。
     *
     * @return 失败过为 <code>true</code>。
     * @default false
     * @example
     * <listing version="3.0">
     * GameSafeKeeper.I.getFailed();
     * </listing>
     */
    public function getFailed():Boolean {
        return _fileFailed;
    }

    /**
     * 配置或文件校验是否失败。
     *
     * @return 任一失败时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * GameSafeKeeper.I.getConfigOrFileFailed();
     * </listing>
     * @see #getConfigFailed()
     * @see #getFailed()
     */
    public function getConfigOrFileFailed():Boolean {
        return _configFailed || _fileFailed;
    }

    /**
     * 按配置表核对文件字节的 MD5。
     *
     * <p>配置未就绪、表中无此路径或摘要不一致时返回 <code>false</code>。</p>
     *
     * @param url 资源路径。以 <code>assets</code> 开头时会去掉该前缀再查表。
     * @param fileBytes 文件内容。
     * @return 摘要一致时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = GameSafeKeeper.I.checkFile(url, bytes);
     * </listing>
     */
    public function checkFile(url:String, fileBytes:ByteArray):Boolean {
        if (_configFailed || !_fileSaveMap) {
            return false;
        }

        if (_failFileMap[url]) {
            GameLogger.error('load', 'checkFile not match: ' + url);

            return false;
        }

        // 配置表键不含 assets/ 前缀
        if (url.indexOf('assets') == 0) {
            url = url.substr(7);
        }

        var md5:String = _fileSaveMap[url];
        if (!md5) {
            GameLogger.error('load', 'checkFile md5 not found: ' + url);

            return false;
        }

        var fileMd5:String = EncryptUtils.md5(fileBytes);

        if (md5 == fileMd5) {
            return true;
        }

        GameLogger.error('load', 'checkFile md5 not match: ' + url);

        _failFileMap[url] = 1;
        _fileFailed       = true;

        return false;
    }

}
}
