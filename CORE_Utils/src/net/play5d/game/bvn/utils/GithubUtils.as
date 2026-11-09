/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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
import flash.utils.ByteArray;

import mx.utils.StringUtil;

/**
 * 读取编译期嵌入的分支提交哈希，并拼出 GitHub 链接。
 *
 * <p>调试版用 <code>develop</code>，否则用 <code>master</code>。哈希是编译时刻的分支 tip，不是当前 <code>HEAD</code>。</p>
 *
 * @example
 * <listing version="3.0">
 * var label:String = GithubUtils.getCommitsDisplayLabel();
 * </listing>
 * @see URL#GITHUB
 * @see #getCommitsHash()
 */
public class GithubUtils {

    /** @private Git 完整提交哈希格式（40 位十六进制） */
    private static const HASH_PATTERN:RegExp = /^[0-9a-f]{40}$/i;

    /** @private 短哈希显示长度，与 Git 默认缩写一致 */
    private static const HASH_SHORT_LENGTH:uint = 7;

    /**
     * 主分支名称。
     *
     * @default master
     */
    public static const BRANCH_MASTER:String  = 'master';

    /**
     * 开发分支名称。
     *
     * @default develop
     */
    public static const BRANCH_DEVELOP:String = 'develop';

    /** @private 缓存的主分支 tip；尚未读取时为 null */
    private static var _cachedMasterHash:String;

    /** @private 缓存的开发分支 tip；尚未读取时为 null */
    private static var _cachedDevelopHash:String;

    /** @private 主分支 tip。Embed 标红时，到 IDEA 忽略的文件和文件夹里去掉 .git */
    [Embed(source='/../../.git/refs/heads/master', mimeType='application/octet-stream')]
    private static const _masterCommitHash:Class;

    /** @private 开发分支 tip */
    [Embed(source='/../../.git/refs/heads/develop', mimeType='application/octet-stream')]
    private static const _developCommitHash:Class;

    /**
     * 获取编译期嵌入的分支 tip 提交哈希。
     *
     * <p><code>IsDebugger()</code> 为真时返回 <code>develop</code>，否则返回 <code>master</code>。</p>
     *
     * @return 40 位提交哈希；读取或校验失败时返回空字符串。
     * @example
     * <listing version="3.0">
     * GithubUtils.getCommitsHash();
     * </listing>
     */
    public static function getCommitsHash():String {
        return IsDebugger() ? getDevelopCommitHash() : getMasterCommitHash();
    }

    /**
     * 获取当前分支 tip 的短提交哈希。
     *
     * @return 前 7 位；完整哈希无效时返回空字符串。
     * @example
     * <listing version="3.0">
     * GithubUtils.getCommitsHashShort();
     * </listing>
     */
    public static function getCommitsHashShort():String {
        var hash:String = getCommitsHash();
        if (!isValidHash(hash)) {
            return '';
        }

        return hash.substr(0, HASH_SHORT_LENGTH);
    }

    /**
     * 获取当前运行时对应的分支名称。
     *
     * <p><code>IsDebugger()</code> 为真时返回 <code>develop</code>，否则返回 <code>master</code>。</p>
     *
     * @return 分支名称。
     * @example
     * <listing version="3.0">
     * GithubUtils.getCommitBranch();
     * </listing>
     * @see #BRANCH_DEVELOP
     * @see #BRANCH_MASTER
     */
    public static function getCommitBranch():String {
        return IsDebugger() ? BRANCH_DEVELOP : BRANCH_MASTER;
    }

    /**
     * 获取提交展示文本。
     *
     * <p>格式为 <code>分支&#64;短哈希</code>，例如 <code>develop&#64;a8dbce1</code>。</p>
     *
     * @return 展示文本；哈希无效时返回空字符串。
     * @example
     * <listing version="3.0">
     * GithubUtils.getCommitsDisplayLabel();
     * </listing>
     * @see #getCommitBranch()
     * @see #getCommitsHashShort()
     */
    public static function getCommitsDisplayLabel():String {
        var hashShort:String = getCommitsHashShort();
        if (!hashShort) {
            return '';
        }

        return getCommitBranch() + '@' + hashShort;
    }

    /**
     * 在浏览器中打开该提交的 GitHub 页面。
     *
     * @param hash 提交哈希。
     * @example
     * <listing version="3.0">
     * GithubUtils.goCommitsByHash(GithubUtils.getCommitsHash());
     * </listing>
     * @see #getCommitsUrlByHash()
     */
    public static function goCommitsByHash(hash:String):void {
        URL.go(getCommitsUrlByHash(hash), false);
    }

    /**
     * 获取当前分支的提交列表地址。
     *
     * @return GitHub 提交列表地址。
     * @example
     * <listing version="3.0">
     * var url:String = GithubUtils.getBranchUrl();
     * </listing>
     * @see URL#GITHUB
     */
    public static function getBranchUrl():String {
        return URL.GITHUB + '/commits/' + getCommitBranch() + '/';
    }

    /**
     * 取得某次提交的 GitHub 地址。
     *
     * @param hash 提交哈希。
     * @return 提交页地址；哈希无效时返回仓库首页。
     * @example
     * <listing version="3.0">
     * GithubUtils.getCommitsUrlByHash(GithubUtils.getCommitsHash());
     * </listing>
     * @see URL#GITHUB
     */
    public static function getCommitsUrlByHash(hash:String):String {
        if (!isValidHash(hash)) {
            return URL.GITHUB;
        }

        return URL.GITHUB + '/commit/' + hash;
    }

    /** @private 读取并缓存主分支 tip，失败返回空串 */
    private static function getMasterCommitHash():String {
        if (_cachedMasterHash == null) {
            _cachedMasterHash = readEmbeddedHash(_masterCommitHash);
        }

        return _cachedMasterHash;
    }

    /** @private 读取并缓存开发分支 tip，失败返回空串 */
    private static function getDevelopCommitHash():String {
        if (_cachedDevelopHash == null) {
            _cachedDevelopHash = readEmbeddedHash(_developCommitHash);
        }

        return _cachedDevelopHash;
    }

    /** @private 读取 Embed 字节并校验为 40 位哈希，失败返回空串 */
    private static function readEmbeddedHash(embedClass:Class):String {
        var bytes:ByteArray = new embedClass() as ByteArray;
        if (!bytes || bytes.length == 0) {
            return '';
        }

        bytes.position = 0;

        var hash:String = StringUtil.trim(bytes.readUTFBytes(bytes.length));
        return isValidHash(hash) ? hash : '';
    }

    /** @private 是否为 40 位十六进制提交哈希 */
    private static function isValidHash(hash:String):Boolean {
        return hash && HASH_PATTERN.test(hash);
    }
}
}
